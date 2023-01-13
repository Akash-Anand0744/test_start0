namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraIncident_Electric
  inputs:
    - projectId: '40703'
    - issueTypeId: '46'
    - reporter
    - priority
    - criticalityJustification:
        default: ''
        required: false
    - description
    - jiraToolFieldId: customfield_47004
    - repoURLFieldId: customfield_47216
    - toolInstanceFieldId: customfield_47215
    - watcherFieldId:
        default: customfield_22411
        required: false
    - summary
    - jiraTool:
        default: '70836'
        required: true
    - repoURL:
        default: ' '
        required: false
    - jiraToolInstances:
        required: false
    - watchers:
        required: false
    - smaxRequestID
    - jiraSmaxIdFieldId: customfield_49101
    - electricCommander:
        required: false
  workflow:
    - getSMAXSystemProperty_WatcherField:
        do:
          Cerner.Integrations.SMAX.subFlows.getSMAXSystemProperty:
            - propertyKey: watcherFieldId
        publish:
          - result
          - message
          - watcher_FieldID: '${SystemPropValue}'
          - errorType
          - errorMessage: '${message}'
        navigate:
          - SUCCESS: getSMAXSystemProperty_SmaxFieldID
          - FAILURE: MainErrorHandler
    - getSMAXSystemProperty_SmaxFieldID:
        do:
          Cerner.Integrations.SMAX.subFlows.getSMAXSystemProperty:
            - propertyKey: jiraSmaxIDField
        publish:
          - result
          - message
          - smax_FieldID: '${SystemPropValue}'
          - errorType
          - errorMessage: '${message}'
        navigate:
          - SUCCESS: extractWathersList
          - FAILURE: MainErrorHandler
    - extractWathersList:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.extractWathersList:
            - watchers: '${watchers}'
            - reporter: '${reporter}'
        publish:
          - result
          - watchersJSON: '${message}'
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: convertHTMLtoJIRAMarkup
          - FAILURE: MainErrorHandler
    - convertHTMLtoJIRAMarkup:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.convertHTMLtoJIRAMarkup:
            - htmlString: '${description}'
        publish:
          - description: '${wikiString}'
          - imageLinks
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: get_priorityId
          - FAILURE: MainErrorHandler
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: '${errorMessage}'
        publish:
          - errorType: e10000
          - errorMessage: '${message}'
          - errorProvider: JIRA
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: MainErrorHandler
          - FAILURE: on_failure
    - get_priorityId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: set_message
    - get_jira_url:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
        navigate:
          - SUCCESS: get_jira_issueid
          - FAILURE: set_message_JIRA
    - get_jira_issueid:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraIssueId: '${return_result}'
        navigate:
          - SUCCESS: updateSMAXRequest
          - FAILURE: set_message_JIRA
    - updateSMAXRequest:
        do:
          Cerner.Integrations.Jira.subFlows.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        publish: []
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: getRequestAttachUploadJira
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification.strip()+'\",\"description\": '+description+', \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+watcherFieldId+'\": ['+watchersJSON+'],\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\",\"customfield_47212\": \"'+electricCommander+'\" } }'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: CheckAvaiability_JIRA
          - FAILURE: set_message_ClientBody
    - CheckAvaiability_JIRA:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.CheckAvaiability_JIRA: []
        publish:
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: Create_Issue_in_Jira
    - Create_Issue_in_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Create_Issue_in_Jira:
            - httpClient_BodyInput: '${httpClient_Body}'
            - watcherFieldId: '${watcher_FieldID}'
        publish:
          - httpClient_BodyInput
          - watcherFieldId
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - jiraIncidentCreationResult
          - incidentHttpStatusCode
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: get_jira_url
    - getRequestAttachUploadJira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.getRequestAttachUploadJira:
            - smaxRequestId: '${smaxRequestID}'
            - jiraIssueId: '${jiraIssueId}'
        publish:
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: uploadImageInRequestDesc
          - FAILURE: MainErrorHandler
    - uploadImageInRequestDesc:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.uploadImageInRequestDesc:
            - imageLinks: '${imageLinks}'
            - jiraIssueId: '${jiraIssueId}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: MainErrorHandler
    - set_message_ClientBody:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: Invalid Http Body
        publish:
          - errorType: e10000
          - errorMessage: '${message}'
          - errorProvider: JIRA
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: MainErrorHandler
          - FAILURE: on_failure
    - set_message_JIRA:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: '${errorMessage}'
        publish:
          - errorType: e10000
          - errorMessage: '${message}'
          - errorProvider: JIRA
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: MainErrorHandler
          - FAILURE: on_failure
    - MainErrorHandler:
        do:
          Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorProvider: '${errorProvider}'
            - errorSeverity: '${errorSeverity}'
            - smaxRequestNumber: '${smaxRequestID}'
            - smaxRequestSummary: '${summary}'
            - smaxRequestorEmail: '${requestorEmail}'
            - smaxRequestDescription: '${description}'
        publish:
          - output_0: output_0
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: intialize_JiraProperty
    - intialize_JiraProperty:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - incidentHttpStatusCode: '-1'
          - jiraIncidentCreationResult: Failed
          - jiraIssueURL: ''
          - jiraIssueId: ''
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
  outputs:
    - incidentCreationCode: '${incidentHttpStatusCode}'
    - incidentCreationResultJSON: '${jiraIncidentCreationResult}'
    - jiraIssueURL: '${jiraIssueURL}'
    - jiraIssueId: '${jiraIssueId}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uploadImageInRequestDesc:
        x: 412
        'y': 605
        navigate:
          5ac40880-009a-2351-5e50-b74e5badc61c:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 807
        'y': 197
      set_message_JIRA:
        x: 982
        'y': 433
      extractWathersList:
        x: 313
        'y': 56
      get_jira_url:
        x: 1142
        'y': 593
      CheckAvaiability_JIRA:
        x: 1135
        'y': 203
      get_priorityId:
        x: 619
        'y': 54
      set_message:
        x: 613
        'y': 183
      get_jira_issueid:
        x: 926
        'y': 589
      getRequestAttachUploadJira:
        x: 590
        'y': 596
      convertHTMLtoJIRAMarkup:
        x: 466
        'y': 53
      getSMAXSystemProperty_SmaxFieldID:
        x: 153
        'y': 59
      set_httpClient_Body:
        x: 809
        'y': 57
      getSMAXSystemProperty_WatcherField:
        x: 66
        'y': 222
      intialize_JiraProperty:
        x: 345
        'y': 391
        navigate:
          a15bc0c0-c12e-9f5a-0d0d-0fd4d39b92b1:
            targetId: 671a6fd1-7377-d3f9-c54b-ff9555e96efa
            port: FAILURE
          15a894d6-3c2c-4af2-6689-2f1e0426e257:
            targetId: 671a6fd1-7377-d3f9-c54b-ff9555e96efa
            port: SUCCESS
      updateSMAXRequest:
        x: 754
        'y': 595
      MainErrorHandler:
        x: 595
        'y': 356
      Create_Issue_in_Jira:
        x: 1138
        'y': 356
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 131
          'y': 559
      FAILURE:
        671a6fd1-7377-d3f9-c54b-ff9555e96efa:
          x: 133
          'y': 397
