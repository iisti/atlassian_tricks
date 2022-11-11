# Start/stop script when server is started/shutdown

* In this example the Jira server is running on a Debian Linux VM with Dockerized Postgres database.

1. Create scripts for start and stop, for example:
    * /opt/scripts/start_script.sh
    ~~~
    #!/bin/bash

    # Check that the script has been executed as a superuser
    if [ "$USER" != "root" ]; then
      echo "This script should be executed as superuser - use sudo!" 2>&1
      echo "Exiting..." 2>&1
      exit 1
    fi

    # Retrieve from which folder the script is run
    # Source: https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
    func_get_script_source_dir () {
        SOURCE="${BASH_SOURCE[0]}"
        while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
            DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
            SOURCE="$(readlink "$SOURCE")"
            # if $SOURCE was a relative symlink, we need to resolve it relative
            # to the path where the symlink file was located
            [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        done
        local DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        echo $DIR
    }

    # Check that xmllint is installed
    dpkg -s libxml2-utils &> /dev/null
    if [ ! $? -eq 0 ]
    then
        echo "Package libxml2-utils with xmllint is required. Install the pacakge before running this script."
        exit 1
    fi

    logfile="$(func_get_script_source_dir)"/"start_psql_jira.log"
    dbconfig="/opt/storage/jira-home/dbconfig.xml"

    url=$(xmllint --xpath "string(//url)" $dbconfig)
    user=$(xmllint --xpath "string(//username)" $dbconfig)
    pw=$(xmllint --xpath "string(//password)" $dbconfig)
    host="localhost"

    db=$(echo $url | rev | cut -d'/' -f 1 | rev)

    echo ""
    echo "###############################################"
    echo "### Starting PSQL and Jira $(date +"%F %T")" | tee -a $logfile
    echo "###############################################"

    echo "Start Docker Composer" | tee -a $logfile
    docker compose -f /opt/storage/docker/jira-db/docker-compose.yml up -d | tee -a $logfile

    # Login for user (`-U`) and once logged in execute quit ( `-c \q` )
    # If we can not login sleep for 1 sec
    until PGPASSWORD=$pw psql -h "$host" -d "$db" -U "$user" -c '\q'; do
      echo "Postgres is unavailable - sleeping" | tee -a $logfile
      sleep 1
    done

    echo "Postgres is up" | tee -a $logfile
    echo "Starting Jira" | tee -a $logfile
    sudo runuser -l jira -c "/opt/storage/jira/bin/start-jira.sh" | tee -a $logfile
    ~~~
    * /opt/scripts/stop_script.sh
    ~~~
    #!/bin/bash

    # Retrieve from which folder the script is run
    # Source: https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
    func_get_script_source_dir () {
        SOURCE="${BASH_SOURCE[0]}"
        while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
            DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
            SOURCE="$(readlink "$SOURCE")"
            # if $SOURCE was a relative symlink, we need to resolve it relative
            # to the path where the symlink file was located
            [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        done
        local DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        echo $DIR
    }

    logfile="$(func_get_script_source_dir)"/"stop_psql_jira.log"

    # Check that the script has been executed as a superuser
    if [ "$USER" != "root" ]; then
      echo "This script should be executed as superuser - use sudo!" 2>&1
      echo "Exiting..." 2>&1
      exit 1
    fi

    echo ""
    echo "##################################################"
    echo "### Stopping PSQL and Jira $(date +"%F %T")" | tee -a $logfile
    echo "##################################################"
    echo "Stopping Jira" | tee -a $logfile
    sudo runuser -l jira -c "/opt/storage/jira/bin/stop-jira.sh" | tee -a $logfile
    echo "Stopping Docker Composer PSQL" | tee -a $logfile
    docker compose -f /opt/storage/docker/jira-db/docker-compose.yml down | tee -a $logfile
    ~~~
1. Make the scripts executable `chmod +x script_name`.
1. Create systemd file
    * /etc/systemd/system/start_and_stop.service
        ~~~
        [Unit]
        Description=Start and stop scripts on startup and shutdown.

        [Service]
        User=root
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/opt/scripts/start_script.sh
        ExecStop=/opt/scripts/stop_script.sh

        [Install]
        WantedBy=multi-user.target
        ~~~
1. Enable the Service with the command:
    ~~~
    systemctl enable start_and_stop
    ~~~
1. Now one can also start and stop the scripts via systemctl. This is also good test to check if the script is run properly.
    ~~~
    sudo systemctl start start_and_stop
    ~~~
1. Reboot machine to test that the script is run properly.
