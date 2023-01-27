namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_Issue_in_Jira
  workflow:
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue'}"
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\": '+description+', \"customfield_47005\":{ \"id\": \"'+ToolRequest+'\" }, \"'+watcherFieldId+'\": ['+watchersJSON+'],\"customfield_47247\": {\"id\":\"'+JiraInstance+'\"},\"customfield_47248\": \"'+JiraProject+'\",\"customfield_47637\":\"'+Justification+'\", \"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\"  } }'}"
            - content_type: application/json
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - jiraInstanceIdJSON: '${error_message}'
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
          - errorMessage: '${error_message}'
          - errorType: e9999
          - errorProvider: SMAX
          - errorSeverity: ERROR
          - conf: "${get_sp('Cerner.DigitalFactory.Error_Notification.config')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: Loop
    - Loop:
        do_external:
          1f0d93cd-2692-4339-81d7-9b3c6de46029:
            - count: '1'
            - to: '1'
        navigate:
          - has more: substring_check_user_permission_issue
          - no more: FAILURE
          - failure: on_failure
    - substring_check_user_permission_issue:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${jiraIncidentCreationResult}'
        navigate:
          - SUCCESS: addUserPermissions_Jira_1
          - FAILURE: on_failure
    - addUserPermissions_Jira_1:
        do:
          Cerner.Integrations.Jira.Archive.addUserPermissions_Jira: []
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_post:
        x: 241
        'y': 142
        navigate:
          9d26ee39-cd28-d201-c60a-f713dc7c633c:
            targetId: 5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f
            port: SUCCESS
      addUserPermissions_Jira_1:
        x: 640
        'y': 80
      Loop:
        x: 388
        'y': 238
        navigate:
          521f06a9-1c57-24f6-ceb5-8da4c5a1c156:
            targetId: f8528c76-39fe-7ea9-4666-871235ed3b84
            port: no more
      substring_check_user_permission_issue:
        x: 606
        'y': 300
    results:
      FAILURE:
        f8528c76-39fe-7ea9-4666-871235ed3b84:
          x: 211
          'y': 358
      SUCCESS:
        5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f:
          x: 108
          'y': 198
