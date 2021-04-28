# How to retrieve a JIRA ticket via JIRA REST API and convert it into GitHub Markdown

* REST API URL for reading/retrieving tickets in JSON.
  ~~~
  https://jira.domain.com/rest/api/latest/issue/XXX-007
  ~~~
* Retrieve a ticket in JSON format.
  * Use single quotes ' instead of double quotes " around user:password. At least MacOS gives error otherwise.
  ~~~
  curl -u 'user:password' -X GET -H "Content-Type: application/json" https://jira.domain.com/rest/api/latest/issue/XXX-007
  ~~~

