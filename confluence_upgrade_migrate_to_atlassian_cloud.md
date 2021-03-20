# Upgrade and migrate local Confluence server to Atlassian Cloud

## Local Confluence server information
* confluence.domain.com

    ~~~
    Running version: 5.6.5
    ~~~
* License

    ~~~
    confluence.domain.com -> Administration -> License Details:
    License Type	Confluence (Server) 500 Users: Commercial License
      Licensed Users	500 (111 signed up currently)
      Confluence support and updates for this license ended on Nov 19, 2015.
    ~~~
* OS details

    ~~~
    OS: Debian GNU/Linux 9 (stretch)
    JAVA: 1.7.0_15-b03
      Application Server: Apache Tomcat/7.0.52
      Maximum Heap Size: 4096 MB
    Database: MSSQL
      Version: 11.00.7462
      Driver: net.sourceforge.jtds.jdbc.Driver
      Driver Version: 1.2.2
      Connection URL: jdbc:jtds:sqlserver://sql-db.domain.com:1433/confluence
    ~~~

* Storage (most of the storage is taken by backups):

    ~~~
    admin@confluence-srv:/opt/storage/atlassian/confluence-data/backups$ df -h
    Filesystem      Size  Used Avail Use% Mounted on
    udev            3.9G     0  3.9G   0% /dev
    tmpfs           799M   81M  718M  11% /run
    /dev/xvda1       50G   24G   24G  51% /
    tmpfs           3.9G     0  3.9G   0% /dev/shm
    tmpfs           5.0M     0  5.0M   0% /run/lock
    tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
    /dev/xvdb       492G   97G  370G  21% /opt/storage
    tmpfs           799M     0  799M   0% /run/user/1000
    ~~~

## TIP:   Reset the installation process to fresh installation
* Stop Confluence
* rm <confluence-home>/confluence.cfg.xml
* Start Confluence
* Source: *Resolution 10* https://confluence.atlassian.com/confkb/confluence-does-not-start-due-to-spring-application-context-has-not-been-set-218278311.html


## Installation process
* VM name: *confluence-01*
* OS: Debian 9
* How to check license:

    ~~~
    cat confluence.cfg.xml
    ~~~
* Download installation package for Confluence:
  * https://www.atlassian.com/software/confluence/download-archives

### Confluence 5.6.5, current installation
* Version 5.6.5 Server - Standalone (TAR.GZ Archive)
    * https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.6.5.tar.gz
* Version 5.6.5 Server Linux installer (64 bit)
    * https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.6.5-x64.bin
    * Supports:
        * Java 1.7 **THIS DOES NOT SUPPORT TLSv1.2 BY DEFAULT AND IT IS NOT POSSIBLE TO USE marketplace.atlassian.com for installing migration Add-On!**
        * Apache Tomcat 7.0.x
        * PostgreSQL 8.4, 9.0, 9.1, 9.2, 9.3

### Confluence 5.7.5, tested, doesn't support Confluence Cloud Migration Assistant
* Version 5.7.5 Server - Standalone (TAR.GZ Archive)
    * This is the latest which is supported by our license.
    * https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.7.5.tar.gz
* Version 5.7.5 Server Linux installer (64bit)
    * https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.7.5-x64.bin
    * Supports:
        * Java 1.7 and 1.8 (JRE only)
        * Apache Tomcat 7.0.x
        * PostgreSQL 9.2, 9.3

### Confluence 5.10.9, the latest from 5.x
* Version 5.7.5 Server Linux installer (64bit)
    * https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.10.9-x64.bin
* Complete Guide http://product-downloads.atlassian.com/software/confluence/downloads/documentation/Confluence*5-10-0_CompleteGuide*PDF.pdf
    * Supports:
        * Java Oracle JRE / JDK 1.8
        * Apache Tomcat 8.0.x
        * PostgreSQL 9.2, 9.3, 9.4, 9.5

### Check what database, JAVA, etc, Confluence supports
* https://confluence.atlassian.com/alldoc/confluence-documentation-directory-12877996.html


## Add extra disk for Confluence installation
* Check disk

    ~~~
    sudo fdisk -l
    Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    Disklabel type: dos
    Disk identifier: 0x227e5c75

    Device     Boot Start      End  Sectors Size Id Type
    /dev/sda1  *     4096 41943006 41938911  20G 83 Linux


    Disk /dev/sdb: 150 GiB, 161061273600 bytes, 314572800 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    ~~~
* Format

    ~~~
    fdisk /dev/sdb
    # Choices: n, p, 1, default, default, w
    fdisk -l
    # Check what filesystem the original disk uses
    df -hT
    # Format the new disk
    mkfs.ext4 /dev/sdb1
    # Create mountpoint
    mkdir -p /opt/storage/disk-02
    mount /dev/sdb1 /opt/storage/disk-02
    ~~~
* Add to fstab

    ~~~
    /etc/fstab

    # Extra disk for Confluence installation
    /dev/sdb1 /opt/storage/disk-02              ext4 defaults 0 0
    ~~~

* Check that reboot doesn't mess up the system.

## Install PostgreSQL Database
* Depending on Confluence version install database that is supported.

* PostgreSQL 9.3 Database

    ~~~
    sudo apt-get install -y software-properties-common gnupg2; \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - ; \
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'; \
    sudo apt-get update; \
    sudo apt-get install -y postgresql-9.3 pgadmin4; \
    psql --version

    psql (PostgreSQL) 9.3.25
    ~~~

* PostgreSQL 9.5 Database

    ~~~
    sudo apt-get update; \
    sudo apt-get -y install wget ca-certificates; \
    sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -; \
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'; \
    sudo apt-get update; \
    sudo apt-get -y install postgresql-9.5; \
    psql --version

    psql (PostgreSQL) 9.5.23
    ~~~

## Create database and user in PostgreSQL

~~~
sudo -u postgres psql
postgres=# create database mydb;
postgres=# create user myuser with encrypted password 'mypass';
postgres=# grant all privileges on database mydb to myuser;
\q
~~~

# Installing Confluence with .bin file

~~~
# The installer creates Linux user "confluence", so there's no need to create it separately 

# Download the bin file and make it executable
wget #URL
chmod u<ins>x atlassian-confluence-*-x64.bin

# Run the bin file
sudo ./atlassian-confluence-*-x64.bin

# Installation configurations
Install dir: /opt/storage/disk-02/confluence
Home dir: /opt/storage/disk-02/confluence-home
Use default ports (HTTP: 8090, Control: 8000)
Install as service

# Probably this is not actually required as installer create Linux user "confluence" automatically.
# Might be good point to stop the web service and chown install/home dirs
#chown -R confluence:confluence confluence
#chown -R confluence:confluence confluence-home/
~~~

#### How to Start/Stop Confluence

~~~
# Stop Confluence
sudo runuser -l confluence -c "/opt/storage/disk-02/confluence/bin/stop-confluence.sh"
# Start Confluence
sudo runuser -l confluence -c "/opt/storage/disk-02/confluence/bin/start-confluence.sh"
# Startup log, it'll show "INFO: Server startup in" xxx ms after accessible.
sudo tail -f /opt/storage/disk-02/confluence/logs/catalina.out
~~~

#### Access with browser:
* http://IP_OR_HOSTNAME:8090


## Finishing with web interface
* One can follow that the web setup is doing something with this log

    ~~~
    tail -f confluence-home/logs/atlassian-confluence.log 
    ~~~
1. Generate license
1. Select External database

    ~~~ 
    Direct JDBC
    Driver Class Name: org.postgresql.Driver
    Database URL: jdbc:postgresql://localhost:5432/confluence_db
    username
    pw
    ~~~
1. Select **Restore from backup**
    * Copy XML backup from old Confluence to the new VM in the *<confluence-home>/restore* directory. *../restore* folder doesn't exist before clicking *Restore from backup**.
    
        ~~~ 
        scp backup-2020_10_10.zip confluence@10.0.0.2:/opt/storage/disk-02/confluence-home/restore/
        ~~~

    * There are two ways to choose the backup file. It's good to use *Restore a backup from the Confluence Home Directory* as backup file can be big and uploading with browser can be impossible.
    * In section *Restore a backup from the Confluence Home Directory* the backup which was copied to <confluence-home>/restore directory should show up. If the backup didn't show up, press *Restore*; this will reload the page and the backup file should show up. Keep Build Index checked and select Restore.
        * This can take hours, depending on the size of the backup. 14GB backup took 36 mins to restore. After 5 minutes there was estimation of 1 hour, before that Remaining time was *Unknown**. Restore/upgrade from 5.6.5 to 5.7.5 with 14 GB backup file took 40 mins.
        * Probably catalina.out will show an error 

            ~~~
            SEVERE: Unable to create directory for deployment: /opt/storage/disk02/confluence/conf/Standalone/localhost
            ~~~
        * FIX
        
            ~~~
            # Stop Confluence
            # chown confluence home and install directories
            # Reset installation
            # Start Confluence
            # Start the restore process again
            ~~~
* Error: JAVA Out of Memory

    ~~~
    <confluence-home>/logs/atlassian-confluence.log

    2020-08-26 11:23:59,087 ERROR [Long running task: Importing data] [confluence.util.longrunning.ConfluenceAbstractLongRunningTask] run Long running task "Importing data" failed to run.
     -- referer: http://10.0.0.29:8090/setup/setup-restore-local.action | url: /setup/longrunningtaskxml.action | userName: anonymous | action: longrunningtaskxml
    java.lang.OutOfMemoryError: Java heap space
    ~~~
    * FIX
    
        ~~~
        sudo vim /opt/storage/disk-02/confluence/bin/setenv.sh 

        # Original
        CATALINA*OPTS="$CATALINA*OPTS -Xms1024m -Xmx1024m -XX:MaxPermSize=256m -XX:</ins>UseG1GC"

        # Fix JAVA Out of Memory
        CATALINA*OPTS="$CATALINA*OPTS -Xms1024m -Xmx4096m -XX:MaxPermSize=256m -XX:<ins>UseG1GC"

        # Source https://confluence.atlassian.com/confkb/cannot-create-or-restore-xml-backup-due-to-outofmemory-errors-128843918.html
        ~~~
    
        * Reset installation process and start restoring again.
* Now login to Confluence with local administrator credentials.
  * http://IP_OR_HOSTNAME:8090/dashboard.action


## Configure HTTPS Confluence <-> Crowd
* Sources
    * https://community.atlassian.com/t5/Confluence-questions/Configure-Atlassian-Crowd-Server-Connection-test-failed/qaq-p/900193
    * https://confluence.atlassian.com/kb/how-to-import-a-public-ssl-certificate-into-a-jvm-867025849.html

* Confluence gives error when testing connection to Crowd if certs are not imported properly

    ~~~
    Connection test failed. Response from the server:
    javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    ~~~
### Test with SSLPoke
* Test on Confluence VM:

    ~~~
    wget https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class

    sudo /opt/storage/disk-02/confluence/jre/bin/java -Djavax.net.ssl.trustStore=/opt/storage/disk-02/confluence/jre/lib/security/cacerts SSLPoke crowd.domain.com 443
    sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
            at sun.security.validator.PKIXValidator.doBuild(Unknown Source)
            at sun.security.validator.PKIXValidator.engineValidate(Unknown Source)
            at sun.security.validator.Validator.validate(Unknown Source)
            at sun.security.ssl.X509TrustManagerImpl.validate(Unknown Source)
            at sun.security.ssl.X509TrustManagerImpl.checkTrusted(Unknown Source)
            at sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(Unknown Source)
            at sun.security.ssl.ClientHandshaker.serverCertificate(Unknown Source)
            at sun.security.ssl.ClientHandshaker.processMessage(Unknown Source)
            at sun.security.ssl.Handshaker.processLoop(Unknown Source)
            at sun.security.ssl.Handshaker.process_record(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.readRecord(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.performInitialHandshake(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.writeRecord(Unknown Source)
            at sun.security.ssl.AppOutputStream.write(Unknown Source)
            at sun.security.ssl.AppOutputStream.write(Unknown Source)
            at SSLPoke.main(SSLPoke.java:31)
    Caused by: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
            at sun.security.provider.certpath.SunCertPathBuilder.engineBuild(Unknown Source)
            at java.security.cert.CertPathBuilder.build(Unknown Source)
            ... 16 more
    ~~~
    * Fix JAVA not trusting crowd.domain.com root CA from Let's Encrypt
        * Grab DST Root CA X3 with browser/etc from crowd.domain.com
        
        ~~~
        -----BEGIN CERTIFICATE-----
        MIIDSjCCAjKgAwIBAgIQRK</ins>wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
        MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
        DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
        PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
        Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
        AN<ins>v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi</ins>DoM3ZJKuM/IUmTrE4O
        rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
        OLl5CjH9UL2AZd<ins>3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
        xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt</ins>/yUFw
        7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
        aeQQmxkqtilX4<ins>U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
        HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62</ins>FLkHX/xBVghYkQMA0GCSqG
        SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or<ins>Dxz9LwwmglSBd49lZRNI</ins>DT69
        ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX<ins>5v3gTt23ADq1cEmv8uXr
        AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK</ins>rlmM6pZW87ipxZz
        R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
        JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL<ins>T0yjWW06XyxV3bqxbYo
        Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
        -----END CERTIFICATE-----
        ~~~
    * SSH to Confluence VM and add the cert to JAVA cert store
    
        ~~~
        # Copy the CA cert above to file
        vim crowd_dst_root_ca_x3.pem

        sudo /opt/storage/disk-02/confluence/jre/bin/keytool -import -alias crowd.domain.com -keystore /opt/storage/disk-02/confluence/jre/lib/security/cacerts -file crowd_dst_root_ca_x3.pem 
        ~~~
    * Successful test:
    
        ~~~
        /opt/storage/disk-02/confluence/jre/bin/java -Djavax.net.ssl.trustStore=/opt/storage/disk-02/confluence/jre/lib/security/cacerts SSLPoke crowd.domain.com 443
        Successfully connected
        ~~~

#### ~~CentOS 8 Apache server proxy-srv.domain.com doesn't serve correct cert~~
* This isn't actually probably true as openssl doesn't use SNI in the cert fetching.
    * Add option *-servername crowd.domain.com** so the openssl command will show correct cert.
    * For some reason the CentOS 8 Apache server is providing default *proxy-srv.domain.com* HTTPS cert first (browser shows correct cert). Check with openssl cmd client what cert is served:
    
    ~~~
    openssl s_client -showcerts -connect crowd.domain.com:443
    ~~~
    * Fix by adding *proxy-srv.domain.com* cert.
    
        ~~~
        cd

        openssl s_client -connect crowd.domain.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > proxy-srv.crt

        sudo /opt/storage/disk-02/confluence/jre/bin/keytool -import -alias proxy-srv -keystore /opt/storage/disk-02/confluence/jre/lib/security/cacerts -file proxy-srv.crt

        # Default JAVA keystore pw "changeit"
        ~~~
    * Reboot VM and start Confluence.


# Reverse proxy configuration from proxy-srv.domain.com

~~~
<user01@proxy-srv sites-enabled>$ cat confluence01.domain.com.conf 


<VirtualHost *:80>
    ServerName confluence01.domain.com
    ServerAdmin email@domain.com
    DocumentRoot /var/www/html

RewriteEngine on
RewriteCond %{SERVER_NAME} =confluence01.domain.com
RewriteRule <sup> https://%{SERVER*NAME}%{REQUEST*URI} [END,NE,R=permanent]
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerAdmin email@domain.com
    ServerName confluence01.domain.com
    DocumentRoot /var/www

    <Directory />
            Options FollowSymLinks
            AllowOverride All
    </Directory>

# Added because there was a timeout between proxy VM and confluence VM. Error from Chrome:
#Proxy Error
#The proxy server received an invalid response from an upstream server.
#The proxy server could not handle the request GET /dashboard.action.
#
#Reason: Error reading from remote server
#
#Apache/2.4.25 (Debian) Server at confluence.domain.com Port 443
Timeout 2400
ProxyTimeout 2400
ProxyBadHeader Ignore

ProxyPass /     http://10.0.0.29:8090/
ProxyPassReverse /      http://10.0.0.29:8090/

Include /etc/letsencrypt/options-ssl-apache.conf
SSLCertificateFile /etc/letsencrypt/live/confluence01.domain.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/confluence01.domain.com/privkey.pem
</VirtualHost>

# MaxRequestsPerChild (so no apache child will be to big!)
MaxRequestsPerChild 400
</IfModule>
~~~


# Proper proxying for installing Migration Assistant
* There is error, when trying to access Marketplace (browse add-ons)

    ~~~
    The base URL configuration of your instance is inconsistent with the URL in your browser. This may prevent many operations on this page from working correctly. See the UPM documentation for more details about this error.
    ~~~
    * FIX: Added the below to */opt/storage/disk-02/confluence/server.xml* and the error disappeared.
        * Source: https://confluence.atlassian.com/doc/configuring-the-server-base-url-148592.html
        * Source: https://confluence.atlassian.com/kb/proxying-atlassian-server-applications-with-apache-http-server-mod*proxy*http-806032611.html

        ~~~
        proxyName="confluence01.domain.com"
        proxyPort="443"
        scheme="https"
        ~~~
* Whole server.xml after modification

~~~
user01@del-confluence-test-01:/opt/storage/disk-02/confluence/conf$ cat server.xml
<Server port="8000" shutdown="SHUTDOWN" debug="0">
    <Service name="Tomcat-Standalone">
        <Connector port="8090" connectionTimeout="20000" redirectPort="8443"
                maxThreads="200" minSpareThreads="10"
                enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
                proxyName="confluence01.domain.com"
                proxyPort="443"
                scheme="https"
                />

        <Engine name="Standalone" defaultHost="localhost" debug="0">

            <Host name="localhost" debug="0" appBase="webapps" unpackWARs="true" autoDeploy="false">

                <Context path="" docBase="../confluence" debug="0" reloadable="false" useHttpOnly="true">
                    <!-- Logger is deprecated in Tomcat 5.5. Logging configuration for Confluence is specified in confluence/WEB-INF/classes/log4j.properties -->
                    <Manager pathname="" />
                </Context>
            </Host>

        </Engine>

        <!--
            To run Confluence via HTTPS:
             * Uncomment the Connector below
             * Execute:
                 %JAVA_HOME%\bin\keytool -genkey -alias tomcat -keyalg RSA (Windows)
                 $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA  (Unix)
               with a password value of "changeit" for both the certificate and the keystore itself.
             * Restart and visit https://localhost:8443/

             For more info, see http://confluence.atlassian.com/display/DOC/Adding</ins>SSL<ins>for</ins>Secure<ins>Logins</ins>and<ins>Page</ins>Security
        -->
<!--
        <Connector port="8443" maxHttpHeaderSize="8192"
                   maxThreads="150" minSpareThreads="25"
                   enableLookups="false" disableUploadTimeout="true"
                   acceptCount="100" scheme="https" secure="true"
                   clientAuth="false" sslProtocol="TLS" SSLEnabled="true"
                   URIEncoding="UTF-8" keystorePass="<MY*CERTIFICATE*PASSWORD>"/>
-->
    </Service>
</Server>
~~~


# Can't connect to marketplace.atlassian.com
* Manage Add-ons page gives error:
    
    ~~~
    The Atlassian Marketplace server is not reachable. To avoid problems when loading this page, you can disable the connection to the Marketplace server. Click here for more information...
    ~~~
    * Error when login to Confluence *tail -f /opt/storage/disk-02/confluence-home/logs/atlassian-confluence.log*
    
    ~~~
    2020-10-12 14:05:58,253 WARN <http-bio-8090-exec-9> [atlassian.upm.pac.PacClientImpl] unknown Error when querying application info from MPAC: com.atlassian.marketplace.client.MpacException: javax.net.ssl.SSLPeerUnverifiedException: peer not authenticated
     -- referer: https://confluence01.domain.com/login.action?logout=true | url: /dashboard.action | userName: user01.name01
    ~~~

### Adding certs to fix problem
* Source: https://confluence.atlassian.com/confkb/the-atlassian-marketplace-server-is-not-reachable-due-to-peer-not-authenticated-321850263.html?utm*medium=hercules-issue-view&utm_source=SAC&utm*content=420060
    * Keystore /opt/storage/disk-02/confluence/jre/lib/security/cacerts
    
    ~~~
    openssl s_client -connect marketplace.atlassian.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > marketplace.atlassian.com.crt
    sudo /opt/storage/disk-02/confluence/jre/bin/keytool -import -alias marketplace.atlassian.com:443 -keystore /opt/storage/disk-02/confluence/jre/lib/security/cacerts -file marketplace.atlassian.com.crt
    ~~~
    * Added also ciphers as in this instruction *Resolution 2*
        * https://confluence.atlassian.com/kb/security-tools-report-the-default-ssl-ciphers-are-too-weak-755140945.html

    * Adding line to setenv.sh
    
        ~~~
        CATALINA*OPTS="$CATALINA*OPTS -Dhttps.protocols=TLSv1.1,TLSv1.2"
        ~~~

### Some tests which might be useful or not
* Java version

    ~~~
    user01@del-confluence-test-01:/opt/storage/disk-02/confluence/jre/bin$ ./java -version
    java version "1.7.0_15"
    Java(TM) SE Runtime Environment (build 1.7.0_15-b03)
    Java HotSpot(TM) 64-Bit Server VM (build 23.7-b01, mixed mode)
    ~~~
* Testing in shell, it seems the issue might be that JAVA 1.7 can't handle TLS 1.2

    ~~~
    user01@del-confluence-test-01:<sub>$ sudo /opt/storage/disk-02/confluence/jre/bin/java -Djavax.net.ssl.trustStore=/opt/storage/disk-02/confluence/jre/lib/security/cacerts SSLPoke marketplace.atlassian.com 443
    javax.net.ssl.SSLException: Received fatal alert: protocol_version
            at sun.security.ssl.Alerts.getSSLException(Unknown Source)
            at sun.security.ssl.Alerts.getSSLException(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.recvAlert(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.readRecord(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.performInitialHandshake(Unknown Source)
            at sun.security.ssl.SSLSocketImpl.writeRecord(Unknown Source)
            at sun.security.ssl.AppOutputStream.write(Unknown Source)
            at sun.security.ssl.AppOutputStream.write(Unknown Source)
            at SSLPoke.main(SSLPoke.java:31)
    ~~~
    * Testing in shell with *openssl**
        * Error with TLS1.0
        
            ~~~
            openssl s_client -connect marketplace.atlassian.com:443 -tls1
            CONNECTED(00000003)
            140414846185536:error:1409442E:SSL routines:ssl3*read_bytes:tlsv1 alert protocol version:../ssl/record/rec_layer*s3.c:1407:SSL alert number 70
            ...
            ~~~
        * TLS 1.2 works
        
            ~~~
            openssl s*client -connect marketplace.atlassian.com:443 -tls1*2
            CONNECTED(00000003)
            depth=2 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert High Assurance EV Root CA
            ...
            ~~~
* Testing with httpclienttest-1.0.2.jar
    * Source https://confluence.atlassian.com/confkb/ssl-handshake-error-when-connecting-to-atlassian-marketplace-978215061.html

        ~~~
        /opt/storage/disk-02/confluence/jre/bin/java -Djavax.net.debug=all -jar httpclienttest-1.0.2.jar https://marketplace.atlassian.com
        Exception in thread "main" java.lang.UnsupportedClassVersionError: com/atlassianlabs/sslclient/Main : Unsupported major.minor version 52.0
                at java.lang.ClassLoader.defineClass1(Native Method)
                at java.lang.ClassLoader.defineClass(Unknown Source)
                at java.security.SecureClassLoader.defineClass(Unknown Source)
                at java.net.URLClassLoader.defineClass(Unknown Source)
                at java.net.URLClassLoader.access$100(Unknown Source)
                at java.net.URLClassLoader$1.run(Unknown Source)
                at java.net.URLClassLoader$1.run(Unknown Source)
                at java.security.AccessController.doPrivileged(Native Method)
                at java.net.URLClassLoader.findClass(Unknown Source)
                at java.lang.ClassLoader.loadClass(Unknown Source)
                at sun.misc.Launcher$AppClassLoader.loadClass(Unknown Source)
                at java.lang.ClassLoader.loadClass(Unknown Source)
                at sun.launcher.LauncherHelper.checkAndLoadMain(Unknown Source)
        ~~~

#### Test on JIRA
* SSLPoke is successful

    ~~~
    user01@jira01:</sub>$ sudo /opt/storage/disk-02/jira/jre/bin/java SSLPoke marketplace.atlassian.com 443
    Successfully connected
    ~~~
* JAVA version

    ~~~
    sudo /opt/storage/disk-02/jira/jre/bin/java -version
    java version "1.8.0_11"
    Java(TM) SE Runtime Environment (build 1.8.0_11-b12)
    Java HotSpot(TM) 64-Bit Server VM (build 25.11-b03, mixed mode)
    ~~~

# ~~Changing JAVA version~~ Can't change JAVA version as 5.6.5 doesn't support higher than JAVA 1.7 
* To select which JAVA is being used check setenv.sh
    * In the source there's talk about setjre.sh, but this file doesn't seem to exist in Confluence  5.6.5 *** https://confluence.atlassian.com/doc/change-the-java-vendor-or-version-confluence-uses-962342397.html

    ~~~
    # The last line of /opt/storage/disk-02/confluence/bin/setenv.sh
    JRE_HOME="/opt/storage/disk-02/confluence/jre/"; export JRE_HOME
    ~~~
* Install JAVA 8 / 1.8 with SDKMAN

    ~~~
    confluence@del-confluence-test-01:<sub>$ which java
    /home/confluence/.sdkman/candidates/java/8.0.265-zulu/bin/java
    ~~~
    * Test JAVA 8 / 1.8 works, so it's the JAVA which is messing up for sure
    
        ~~~
        confluence@del-confluence-test-01:</sub>$ java SSLPoke marketplace.atlassian.com 443
        Successfully connected
        ~~~
    * Testing with option *-Djdk.tls.client.protocols="**
        * Doesn't work when using TLSv1
        
            ~~~
            java -Djdk.tls.client.protocols=TLSv1 -Djavax.net.debug=all SSLPoke marketplace.atlassian.com 443

            .
            .
            .
            main, READ: TLSv1 Alert, length = 2
            main, RECV TLSv1.2 ALERT:  fatal, protocol_version
            %% Invalidated:  <Session-1, SSL*NULL_WITH_NULL*NULL>
            main, called closeSocket()
            main, handling exception: javax.net.ssl.SSLException: Received fatal alert: protocol_version
            javax.net.ssl.SSLException: Received fatal alert: protocol_version
                    at sun.security.ssl.Alerts.getSSLException(Alerts.java:208)
                    at sun.security.ssl.Alerts.getSSLException(Alerts.java:154)
                    at sun.security.ssl.SSLSocketImpl.recvAlert(SSLSocketImpl.java:1970)
                    at sun.security.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:1087)
                    at sun.security.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1323)
                    at sun.security.ssl.SSLSocketImpl.writeRecord(SSLSocketImpl.java:712)
                    at sun.security.ssl.AppOutputStream.write(AppOutputStream.java:122)
                    at sun.security.ssl.AppOutputStream.write(AppOutputStream.java:136)
                    at SSLPoke.main(SSLPoke.java:31)
            ~~~
        * Works when adding TLSv1.2
        
            ~~~
            java -Djdk.tls.client.protocols=TLSv1,TLSv1.2 -Djavax.net.debug=all SSLPoke marketplace.atlassian.com 443
            .
            .
            .
            main, READ: TLSv1.2 Change Cipher Spec, length = 1
            update handshake state: change*cipher*spec
            upcoming handshake states: server finished<20>
            [Raw read]: length = 5
            0000: 16 03 03 00 28                                     ....(
            <Raw read>: length = 40
            0000: 00 00 00 00 00 00 00 00   15 83 13 C3 DE 10 A6 E9  ................
            0010: D6 60 9C 98 0C C4 3E 42   4E EE CA 84 27 1A 1C 48  .`....>BN...'..H
            0020: 62 4A 0C D8 DA 0B FC 0C                            bJ......
            main, READ: TLSv1.2 Handshake, length = 40
            Padded plaintext after DECRYPTION:  len = 16
            0000: 14 00 00 0C B4 FF 83 5E   B2 A2 52 E1 7E 0F 22 30  .......</sup>..R..."0
            check handshake state: finished[20]
            update handshake state: finished[20]
                    * Finished
            verify_data:  { 180, 255, 131, 94, 178, 162, 82, 225, 126, 15, 34, 48 }
                    *
            %% Cached client session: [Session-2, TLS*ECDHE_RSA_WITH_AES_128_GCM*SHA256]
            [read] MD5 and SHA1 hashes:  len = 16
            0000: 14 00 00 0C B4 FF 83 5E   B2 A2 52 E1 7E 0F 22 30  .......^..R..."0
            Padded plaintext before ENCRYPTION:  len = 1
            0000: 01                                                 .
            main, WRITE: TLSv1.2 Application Data, length = 25
            [Raw write]: length = 30
            0000: 17 03 03 00 19 00 00 00   00 00 00 00 01 08 78 8E  ..............x.
            0010: 41 D7 71 09 EB 50 1E 36   D3 D2 A6 8A BD 17        A.q..P.6......
            Successfully connected
            ~~~

# Installing the latest version which the Confluence license supports 5.7.5

1. VM name: confluence02
    * Debian 9
    * 2 vCPU 
    * 8 GB mem
    * base disk 20 gb spinning
    * extra disk 150 gb ssd
1. Add extra disk
1. Install psql 9.3
1. Create database, same credentials as del-confluence-test-01
1. Install Confluence with installer bin
1. Stop Confluence
1. chown confluence install dir and home
    * The installer uses JAVA 7 which doesn't support by default TLSv1.2
        * Install newer version with *sdkman**
1. Restore Confluence
1. After one can login with local/internal Confluence admin credentials:
    * Set up Apache reverse proxy for HTTPS
    * Correct Server Base URL
        * Shutdown Confluence and fix reverse proxy settings in *server.xml*
1. Manage Add-ons page gives error:

    ~~~
    The Atlassian Marketplace server is not reachable. To avoid problems when loading this page, you can disable the connection to the Marketplace server. Click here for more information...
    ~~~
    * Error when trying to check Add-Ons in Confluence, *<confluence-home>/logs/atlassian-confluence.log*
        
        ~~~
        user01@confluence02:/opt/storage/disk-02/confluence/conf$ sudo tail -f /opt/storage/disk-02/confluence-home/logs/atlassian-confluence.log

        2020-10-15 08:50:10,351 INFO [localhost-startStop-1] [com.atlassian.confluence.lifecycle] init Confluence is ready to serve
        2020-10-15 08:51:14,853 WARN [http-bio-8090-exec-6] [atlassian.upm.pac.PacClientImpl] unknown Error when querying application info from MPAC: com.atlassian.marketplace.client.MpacException: javax.net.ssl.SSLException: hostname in certificate didn't match: <marketplace.atlassian.com> != <**.services.atlassian.com> OR <**.services.atlassian.com> OR <services.atlassian.com>
         -- referer: https://confluence03.domain.com/login.action?os_destination=%2Fdashboard.action | url: /dashboard.action | userName: sysop
        2020-10-15 08:51:30,572 WARN [http-bio-8090-exec-5] [atlassian.upm.pac.PacClientImpl] unknown Error when querying application info from MPAC: com.atlassian.marketplace.client.MpacException: javax.net.ssl.SSLException: hostname in certificate didn't match: <marketplace.atlassian.com> != <**.services.atlassian.com> OR <**.services.atlassian.com> OR <services.atlassian.com>
        ~~~
    * *FIX*
        * Install JAVA 8 with sdkman.
        * Check that one can connect to Confluence and open **Manage add-ons** page without errors.
        * Enable Crowd user directory
            * Add to proxy-srv reverse proxy's crowd.domain.com.conf configuration Confluence test instance IP.
            * Otherwise there will be an error when testing Crowd settings in Confluence
                
                ~~~
                Connection test failed. Response from the server:
                The following URL does not specify a valid Crowd User Management REST service: https://crowd.domain.com/crowd/rest/usermanagement/1/search?entity-type=user&start-index=0&max-results=1&expand=user
                ~~~
    * If one wants to use only HTTP then add the new Confluence instance IP to Crowd -> Applications -> Confluence -> Remote addresses



# Errors that probably were fixed by doing something else and these didn't require fixing at all...
* Manage Add-ons page gives error:
    
    ~~~
    The Atlassian Marketplace server is not reachable. To avoid problems when loading this page, you can disable the connection to the Marketplace server. Click here for more information...
    ~~~
* Error when trying to check Add-Ons in Confluence, *<confluence-home>/logs/atlassian-confluence.log**
    
    ~~~
    user01@confluence02:/opt/storage/disk-02/confluence/conf$ sudo tail -f /opt/storage/disk-02/confluence-home/logs/atlassian-confluence.log

    2020-10-15 08:50:10,351 INFO [localhost-startStop-1] [com.atlassian.confluence.lifecycle] init Confluence is ready to serve
    2020-10-15 08:51:14,853 WARN [http-bio-8090-exec-6] [atlassian.upm.pac.PacClientImpl] unknown Error when querying application info from MPAC: com.atlassian.marketplace.client.MpacException: javax.net.ssl.SSLException: hostname in certificate didn't match: <marketplace.atlassian.com> != <**.services.atlassian.com> OR <**.services.atlassian.com> OR <services.atlassian.com>
     -- referer: https://confluence03.domain.com/login.action?os_destination=%2Fdashboard.action | url: /dashboard.action | userName: sysop
    2020-10-15 08:51:30,572 WARN [http-bio-8090-exec-5] [atlassian.upm.pac.PacClientImpl] unknown Error when querying application info from MPAC: com.atlassian.marketplace.client.MpacException: javax.net.ssl.SSLException: hostname in certificate didn't match: <marketplace.atlassian.com> != <**.services.atlassian.com> OR <**.services.atlassian.com> OR <services.atlassian.com>
    ~~~
    * *FIX*: Adding certs to JAVA keystore
        * Note that with the default JAVA (when Confluence is installed with BIN) Keystore is in */opt/storage/disk-02/confluence/jre/lib/security/cacerts*
        * As the JAVA has been replaced with Azul JAVA the Keystore path is */home/confluence/.sdkman/candidates/java/current/jre/lib/security/cacerts*
        
        ~~~
        # Fetch *.atlassian.com cert
        openssl s_client -connect marketplace.atlassian.com:443 -servername marketplace.atlassian.com < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > asterisk.atlassian.com.crt

        # Import certificate to JAVA keystore
        sudo /opt/storage/disk-02/confluence/jre/bin/keytool -import -alias "*.atlassian.com:443" -keystore /home/confluence/.sdkman/candidates/java/current/jre/lib/security/cacerts -file asterisk.atlassian.com.crt

        # This fetches wrong cert (*.services.atlassian.com)
        #openssl s_client -connect marketplace.atlassian.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > marketplace.atlassian.com.crt
        ~~~
    * Possible fix
        * https://confluence.atlassian.com/jirakb/plugin-updates-via-upm-fail-in-jira-server-939499479.html
        * Source: https://confluence.atlassian.com/confkb/the-atlassian-marketplace-server-is-not-reachable-due-to-peer-not-authenticated-321850263.html?utm*medium=hercules-issue-view&utm_source=SAC&utm*content=420060
* ~~Error **java.lang.OutOfMemoryError: PermGen space**~~ This wasn't actually a real issue; there was a typing mistake in setenv.sh
    * sudo less /opt/storage/disk-02/confluence-home/logs/atlassian-confluence.log
    
        ~~~
        2020-10-15 11:38:03,558 INFO <localhost-startStop-1> [atlassian.plugin.manager.DefaultPluginManager] earlyStartup Plugin system earlyStartup begun
        2020-10-15 11:38:38,016 ERROR [ThreadPoolAsyncTaskExecutor::Thread 14] [plugin.osgi.factory.OsgiPlugin] onPluginContainerFailed Unable to start the plugin container for plugin 'com.atlassian.confluence.plugins.confluence-remote-page-view-plugin'
        org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'remotePageViewService' defined in URL [bundle://45.0:0/META-INF/spring/atlassian-plugins-components.xml]: Unsatisfied dependency expressed through co
        nstructor argument with index 6 of type [com.atlassian.sal.api.message.I18nResolver]: : Error creating bean with name 'i18nResolver': FactoryBean threw exception on object creation; nested exception is java.lang.OutOfMemoryError: PermGen space; n
        ested exception is org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'i18nResolver': FactoryBean threw exception on object creation; nested exception is java.lang.OutOfMemoryError: PermGen space
                at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:591)
                at org.springframework.beans.factory.support.ConstructorResolver.autowireConstructor(ConstructorResolver.java:193)
                at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.autowireConstructor(AbstractAutowireCapableBeanFactory.java:925)
                at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBeanInstance(AbstractAutowireCapableBeanFactory.java:835)
                at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:440)
                at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory$1.run(AbstractAutowireCapableBeanFactory.java:409)
                at java.security.AccessController.doPrivileged(Native Method)
                at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:380)
                at org.springframework.beans.factory.support.AbstractBeanFactory$1.getObject(AbstractBeanFactory.java:264)
                at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:222)
                at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:261)
                at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:185)
                at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:164)
                at org.springframework.beans.factory.support.DefaultListableBeanFactory.preInstantiateSingletons(DefaultListableBeanFactory.java:429)
                at org.springframework.context.support.AbstractApplicationContext.finishBeanFactoryInitialization(AbstractApplicationContext.java:728)
                at org.springframework.osgi.context.support.AbstractDelegatedExecutionApplicationContext.access$1600(AbstractDelegatedExecutionApplicationContext.java:69)
                at org.springframework.osgi.context.support.AbstractDelegatedExecutionApplicationContext$4.run(AbstractDelegatedExecutionApplicationContext.java:355)
                at org.springframework.osgi.util.internal.PrivilegedUtils.executeWithCustomTCCL(PrivilegedUtils.java:85)
                at org.springframework.osgi.context.support.AbstractDelegatedExecutionApplicationContext.completeRefresh(AbstractDelegatedExecutionApplicationContext.java:320)
                at org.springframework.osgi.extender.internal.dependencies.startup.DependencyWaiterApplicationContextExecutor$CompleteRefreshTask.run(DependencyWaiterApplicationContextExecutor.java:132)
                at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1152)
                at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:622)
                at java.lang.Thread.run(Thread.java:748)
        Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'i18nResolver': FactoryBean threw exception on object creation; nested exception is java.lang.OutOfMemoryError: PermGen space
                at org.springframework.beans.factory.support.FactoryBeanRegistrySupport$1.run(FactoryBeanRegistrySupport.java:127)
                at java.security.AccessController.doPrivileged(Native Method)
                at org.springframework.beans.factory.support.FactoryBeanRegistrySupport.doGetObjectFromFactoryBean(FactoryBeanRegistrySupport.java:116)
                at org.springframework.beans.factory.support.FactoryBeanRegistrySupport.getObjectFromFactoryBean(FactoryBeanRegistrySupport.java:91)
                at org.springframework.beans.factory.support.AbstractBeanFactory.getObjectForBeanInstance(AbstractBeanFactory.java:1288)
                at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:217)
                at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:185)
                at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:164)
                at org.springframework.beans.factory.support.DefaultListableBeanFactory.findAutowireCandidates(DefaultListableBeanFactory.java:671)
                at org.springframework.beans.factory.support.DefaultListableBeanFactory.resolveDependency(DefaultListableBeanFactory.java:610)
                at org.springframework.beans.factory.support.ConstructorResolver.resolveAutowiredArgument(ConstructorResolver.java:622)
                at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:584)
                ... 22 more
        Caused by: java.lang.OutOfMemoryError: PermGen space
        ~~~
    * FIX: https://confluence.atlassian.com/confkb/confluence-crashes-due-to-outofmemoryerror-permgen-space-126910596.html#:~:text=If%20you%20get%20the%20error,opposed%20to%20the%20objects%20created.


# Installing the latest 5.x branch 5.10.9, so that Confluence Migration Assistant is supported

1. VM name: confluence03
    * Debian 9
    * 2 vCPU 
    * 8 GB mem
    * Base disk 20 GB SSD
    * Extra disk 150 GB SSD
1. Add extra disk
1. Install psql 9.5
1. Create database, same credentials as del-confluence-test-01
1. Install Confluence with installer bin
    * The installer uses JAVA 8 which uses TLSv1.2 by default
        
        ~~~
        /opt/storage/disk-02/confluence/jre/bin/java -version

        java version "1.8.0_152"
        Java(TM) SE Runtime Environment (build 1.8.0_152-b16)
        Java HotSpot(TM) 64-Bit Server VM (build 25.152-b16, mixed mode)
        ~~~
1. Stop Confluence
1. Set user permissions to help moving things around
    * chown confluence install dir and home
    * chmod g+rx confluence-home
    * usermod -a -G confluence username
1. Start Confluence
1. Restore Confluence
1. Login with local/internal Confluence admin credentials:
    * Set up Apache reverse proxy for HTTPS
    * Correct Server Base URL
        * Shutdown Confluence and fix reverse proxy settings in *server.xml**
1. Manage Add-ons page gives error:

    ~~~
    The base URL configuration of your instance does not match the URL in your browser. This can prevent operations on this page from working correctly. See UPM documentation for more details about this error.
    ~~~
    * *FIX* server.xml
    
    ~~~
    proxyName="confluence03.domain.com"
    proxyPort="443"
    scheme="https"
    ~~~
    * Check that one can connect to Confluence and open *Manage add-ons** page without errors.
1. Enable Crowd user directory
    * Add to proxy-srv reverse proxy's crowd.domain.com.conf configuration Confluence test instance IP.
        * Otherwise there will be an error when testing Crowd settings in Confluence
        ~~~
        Connection test failed. Response from the server:
        The following URL does not specify a valid Crowd User Management REST service: https://crowd.domain.com/crowd/rest/usermanagement/1/search?entity-type=user&start-index=0&max-results=1&expand=user
        ~~~
    * If one wants to use only HTTP then add the new Confluence instance IP to Crowd -> Applications -> Confluence -> Remote addresses
1. Upgrade plugins
1. Install **Confluence Cloud Migration Assistant** plugin
1. Migrate Confluence to Atlassian Cloud
