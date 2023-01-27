namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraRequest_JIRA3
  inputs:
    - projectId
    - issueTypeId
    - ToolRequest
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
    - Justification:
        required: false
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
    - get_priorityId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: Hide_Fields_In_Jira
          - FAILURE: set_message
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
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification+'\",\"description\": '+description+', \"customfield_47005\":{ \"id\": \"'+ToolRequest+'\" }, \"'+watcherFieldId+'\": ['+watchersJSON+'],\"customfield_47247\": {\"id\":\"'+JiraInstance+'\"},\"customfield_47248\": \"'+JiraProject+'\",\"customfield_47637\":\"'+Justification+'\", \"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\"  } }'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: CheckAvaiability_JIRA
          - FAILURE: set_message_ClientBody
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
            - hide_jira_fields: '${hide_jira_fields}'
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
    - Hide_Fields_In_Jira:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: null
        publish:
          - hide_jira_fields: 'customfield_47806,customfield_47604'
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: set_message_ClientBody
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
        x: 401
        'y': 518
        navigate:
          bce840b8-9356-8413-f5a7-fe71378adb32:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 820
        'y': 139
      set_message_JIRA:
        x: 821
        'y': 364
      extractWathersList:
        x: 230
        'y': 15
      get_jira_url:
        x: 1100
        'y': 438
      CheckAvaiability_JIRA:
        x: 1101
        'y': 152
      get_priorityId:
        x: 566
        'y': 1
      set_message:
        x: 648
        'y': 124
      get_jira_issueid:
        x: 931
        'y': 529
      getRequestAttachUploadJira:
        x: 586
        'y': 518
      convertHTMLtoJIRAMarkup:
        x: 424
        'y': 10
      getSMAXSystemProperty_SmaxFieldID:
        x: 66
        'y': 85
      set_httpClient_Body:
        x: 1034
        'y': 6
      getSMAXSystemProperty_WatcherField:
        x: 66
        'y': 263
      intialize_JiraProperty:
        x: 413
        'y': 340
        navigate:
          006d13d3-2e62-7178-1ede-360ea81a44d8:
            targetId: ed8e76ee-b8d0-a468-be40-1cae05e5a10f
            port: FAILURE
          fa42fd8a-126f-9ccd-cbd9-164261c28667:
            targetId: ed8e76ee-b8d0-a468-be40-1cae05e5a10f
            port: SUCCESS
      updateSMAXRequest:
        x: 768
        'y': 522
      MainErrorHandler:
        x: 630
        'y': 262
      Create_Issue_in_Jira:
        x: 1101
        'y': 290
      Hide_Fields_In_Jira:
        x: 761
        'y': 1
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 251
          'y': 433
      FAILURE:
        ed8e76ee-b8d0-a468-be40-1cae05e5a10f:
          x: 177
          'y': 346
