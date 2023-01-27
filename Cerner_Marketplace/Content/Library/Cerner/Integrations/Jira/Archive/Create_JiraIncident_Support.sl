namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraIncident_Support
  inputs:
    - projectId: '40703'
    - issueTypeId: '46'
    - reporter
    - priority
    - criticalityJustification:
        default: ''
        required: false
    - description
    - watcherFieldId:
        required: false
    - summary
    - watchers:
        required: false
    - smaxRequestID
    - JiraInstance
    - JiraProject
    - ToolRequest: '70703'
    - jiraSmaxIdFieldId
    - requestorEmail
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
    - get_priorityId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_jiraInstanceId
          - FAILURE: set_message
    - get_jiraInstanceId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.JIRAInstanceIDs')}"
            - json_path: '${JiraInstance}'
        publish:
          - JiraInstanceId: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: MainErrorHandler
    - get_jira_url:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
          - errorMessage: '${error_message}'
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
          - errorMessage: '${error_message}'
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
    - extractWathersList:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.extractWathersList:
            - watchers: '${watchers}'
            - reporter: '${reporter}'
        publish:
          - result
          - watchersJSON: '${message}'
          - errorType
          - errorSeverity
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
          - errorMessage
          - errorProvider
        navigate:
          - SUCCESS: get_priorityId
          - FAILURE: MainErrorHandler
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\":'+description+', \"customfield_47004\":{ \"id\": \"'+ToolRequest+'\" },\"customfield_47247\": {\"id\":\"'+JiraInstanceId+'\"},\"customfield_47248\": \"'+JiraProject+'\",\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\",\"'+watcherFieldId+'\": ['+watchersJSON+']} }'}"
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
          - jiraIncidentCreationResult
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - httpClient_BodyInput
          - watcherFieldId
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
    - MainErrorHandler:
        do:
          Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorProvider: '${errorProvider}'
            - smaxRequestNumber: '${smaxRequestID}'
            - smaxRequestSummary: '${summary}'
            - smaxRequestorEmail: '${requestorEmail}'
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
        x: 416
        'y': 562
        navigate:
          e3e4b4b0-a28a-f782-da2f-6d4f568ec8bb:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 817
        'y': 150
      set_message_JIRA:
        x: 832
        'y': 398.25
      extractWathersList:
        x: 261
        'y': 8
      get_jira_url:
        x: 1107
        'y': 450
      get_jiraInstanceId:
        x: 776
        'y': 1
      CheckAvaiability_JIRA:
        x: 1095
        'y': 138
      get_priorityId:
        x: 616
        'y': 1
      set_message:
        x: 626
        'y': 129
      get_jira_issueid:
        x: 1009
        'y': 581
      getRequestAttachUploadJira:
        x: 582
        'y': 557
      convertHTMLtoJIRAMarkup:
        x: 424
        'y': 2
      getSMAXSystemProperty_SmaxFieldID:
        x: 112
        'y': 64
      set_httpClient_Body:
        x: 942
        'y': 4
      getSMAXSystemProperty_WatcherField:
        x: 109
        'y': 226
      intialize_JiraProperty:
        x: 342
        'y': 355
        navigate:
          663ed4d6-c21f-036a-50fc-59d39275a478:
            targetId: c4c9ec9b-46f6-1bb8-547e-a4eaf4b5b97b
            port: FAILURE
          9bed336c-9bcf-b5ba-84a2-14ba0df15520:
            targetId: c4c9ec9b-46f6-1bb8-547e-a4eaf4b5b97b
            port: SUCCESS
      updateSMAXRequest:
        x: 755
        'y': 571
      MainErrorHandler:
        x: 633
        'y': 267
      Create_Issue_in_Jira:
        x: 1105
        'y': 297
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 125
          'y': 481
      FAILURE:
        c4c9ec9b-46f6-1bb8-547e-a4eaf4b5b97b:
          x: 114
          'y': 353
