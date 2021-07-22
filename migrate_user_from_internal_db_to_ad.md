# Migrating users between user directories
* Bulk instructions https://confluence.atlassian.com/adminjiraserver/migrating-users-between-user-directories-938847059.html

## Migrating single user from JIRA Internal Directory into Microsoft Active Directory
* Tested migration process by creating one JIRA Internal Directory user and migrating the user into MS AD.
### Test process
1. Created **JIRA Internal Directory** user **test.jira01**.
1. Created test ticket with the **test.jira01** and added to groups.
    * User information
    ```
    Username    Full Name                   Login Details   Groups                  Directory                   Operations
    test.jira01 Test JIRA01                 Not recorded    All                     JIRA Internal Directory     Groups Project Roles Edit Delete 
                test.jira01@domain.com                      Jira_Customer_All
                                                            Jira_Customer_customer01
                                                            Jira_Internal_All

    There are currently no project role associations for this user.
    ```
1. Commented in the ticket wit the **test.jira01**.
1. Logged work with **test.jira01**.
1. Removed test.jira01 from **JIRA Internal Directory**
    * Can't be done. An error pops up:
    ```
    Delete User: test.jira01
    Cannot delete user. 'test.jira01' has associations in JIRA that cannot be removed automatically.
    Change the following and try again:

        Reported Issue: 1 issue
        Issue Comments: 1
    ```
1. Created in AD with same name and email address.
1. Added into same JIRA groups
    * Jira_Customer_customer01
    * Jira_Internal_All
1. Synchronized Crowd and JIRA directory.
1. User information after synchronization
    ```
    Username    Full Name                   Login Details       Groups                  Directory                   Operations
    test.jira01 Test JIRA01                 Count: 1            All                     Braintribe Crowd            Project Roles
                test.jira01@domain.com      Last: Today 10:28   Jira_Customer_All
                                                                Jira_Customer_customer01
                                                                Jira_Internal_All
    ```
1. User's password is now the AD password. JIRA Internal Directory Password doesn't work anymore.
1. Removed test.jira01 from group Jira_Customer_customer01, user information afterwards
    ```
    Username    Full Name                   Login Details       Groups                  Directory                   Operations
    test.jira01 Test JIRA01                 Count: 1            All                     Braintribe Crowd            Project Roles
                test.jira01@domain.com      Last: Today 10:28   Jira_Internal_All
    ```
