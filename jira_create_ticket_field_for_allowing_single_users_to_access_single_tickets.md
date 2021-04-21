# Create Field for allowing single customer users to access single tickets.
* Source https://community.atlassian.com/t5/Jira-articles/How-to-allow-a-user-to-see-specific-tickets-w-o-issue-security/ba-p/870195

1. Administration -> Issues -> Custom Fields
1. Add Custom Field
1. Advanced -> User Picker (multiple users)
    * Name: Allow Users
    * Description: Allow users defined in this Field.
1. Add the “Allow users” Field to a Screen:
    * Administration -> Issues -> Custom Fields -> Allow Users, click the  cogwheel for settings -> Screens, select screens
1. Check ticket if Field has appeared if not:
    * Select Admin -> Where is my field? -> Search for “Allow Users, the tool should show what’s wrong.
    * In this setup there’s issue with “Field Screen”:
        ~~~
        The field 'Allow Users' is not present on the screen 'Default Screen' configured for this issue.
        To solve this problem, go to Screen 'Default Screen' configuration and add the field to the screen.
        Alternatively, you can configure different screen for that issue by modifying the screen schemes associated with this issue:
                • the Screen Scheme 'Company Screen Scheme', or
                • the Issue Type Screen Scheme 'Company Issue Type Screen Scheme'
        ~~~
    * Go to Administration -> Screens -> Default Screen ->  Select Field -> Allow Users
1. In the ticket, click Edit and add users to Allow Users field.
1. The newly added Field should show up users in the right “People section”, not in the “Details section”
1. Go to Project -> Administration -> Permissions -> Edit Permissions (Browse Projects, etc) -> Add “User Custom Field Value”
1. If Issue Security has been configured, the “User Custom Field Value” needs to be added in the desired security levels.
    * Project -> Administration -> Issue Security -> Actions -> Edit Issue Security -> Add the “User Custom Field Value” to desired security levels.
1. Now the users defined in the “Allow Users” should see the ticket.

### Permissions
* Field "Allow Users"
* Permissions set in Project -> Administration -> Permissions -> Check that there's own Customer "Scheme"
  * Add permissions for *User Custom Field Value (Allow Users)*

**Project Permissions**
* Browse Projects
    * Ability to browse projects and the issues within them.

**Issue Permissions**
* Create Issues
    * Ability to create issues.

* Edit Issues
    * Ability to edit issues.

* Transition Issues
    * Ability to transition issues.

* Schedule Issues
    * Ability to view or edit an issue's due date.

* Assign Issues
    * Ability to assign issues to other people.

* Assignable User
    * Users with this permission may be assigned to issues.

* Resolve Issues
    * Ability to resolve and reopen issues. This includes the ability to set a fix version.

* Close Issues
    * Ability to close issues. Often useful where your developers resolve issues, and a QA department closes them.

* Modify Reporter
    * Ability to modify the reporter when creating or editing an issue.

* Link Issues
    * Ability to link issues together and create linked issues. Only useful if issue linking is turned on.

**Voters & Watchers Permissions**
* View Voters and Watchers
    * Ability to view the voters and watchers of an issue.

* Manage Watchers
    * Ability to manage the watchers of an issue.

**Comments Permissions**
* Add Comments
    * Ability to comment on issues.

* Edit Own Comments
    * Ability to edit own comments made on issues.

**Attachments Permissions**
* Create Attachments
    * Users with this permission may create attachments.

* Delete Own Attachments
    * Users with this permission may delete own attachments.

### Time Tracking / Work Logs
* If JIRA project uses *Field Security Scheme*, the field *Allow Users* field needs to be allowed in the security scheme, so that the Work Log field shows up for the users in *Allow Users* field.
* How to enable:
  * JIRA project -> Administration -> Summary -> Field Security Scheme -> Click to edit -> Add rule into *Time tracking*
  * *User Custom Field Value*, *Allow Users*, *Allow*
