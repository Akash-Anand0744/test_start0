namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraRequest_AgileSolutionMgmt
  inputs:
    - projectId
    - issueTypeId
    - reporter
    - priority
    - criticalityJustification:
        default: ''
        required: false
    - description
    - watcherFieldId:
        required: false
    - summary
    - jiraToolInstances:
        required: false
    - watchers:
        required: false
    - smaxRequestID
    - JIRAInstance:
        required: false
    - JIRAProject:
        required: false
    - Justification:
        default: '                        '
        required: false
    - jiraSmaxIdFieldId
    - requestorEmail
    - ToolRequest
  workflow:
    - getSMAXSystemProperty:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSMAXSystemProperty:
            - propertyKey: watcherFieldId
        publish:
          - result
          - message
          - watcher_FieldID: '${SystemPropValue}'
        navigate:
          - SUCCESS: getSMAXSystemProperty_1
          - FAILURE: MainErrorHandler
    - getSMAXSystemProperty_1:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSMAXSystemProperty:
            - propertyKey: jiraSmaxIDField
        publish:
          - result
          - message
          - smax_FieldID: '${SystemPropValue}'
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
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: get_priorityId
          - FAILURE: MainErrorHandler
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{\"fields\": {\"project\": {\"id\": \"'+projectId+'\"},\"summary\": \"'+summary+'\", \"issuetype\": {\"id\": \"'+issueTypeId+'\"},\"reporter\": {\"name\":\"'+reporter[0:reporter.find(\"@\")]+'\"},\"priority\": {\"id\": \"'+jiraPriorityId+'\" },\"customfield_47251\":\"'+criticalityJustification+'\" ,\"description\":'+description+',\"customfield_47005\": {\"id\": \"'+ToolRequest+'\"},\"customfield_22411\": ['+watchersJSON+'],\"customfield_47247\": {\"id\":\"'+JIRAInstance+'\"},\"customfield_47248\": \"'+JIRAProject+'\", \"customfield_47637\" : \"'+Justification+'\",\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\" } }'}"
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
            - hide_jira_fields: '${hide_jira_fields}'
        publish:
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - jiraIncidentCreationResult
          - httpClient_BodyInput
          - watcherFieldId
          - incidentHttpStatusCode
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: get_jira_url
    - updateSMAXRequest:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: getRequestAttachUploadJira
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
        x: 378
        'y': 508
        navigate:
          5280bd94-2e43-1425-15ef-4e3b89ea7892:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 666
        'y': 154
      set_message_JIRA:
        x: 783
        'y': 329
      extractWathersList:
        x: 221
        'y': 17
      get_jira_url:
        x: 1037
        'y': 349
      CheckAvaiability_JIRA:
        x: 1004
        'y': 14
      get_priorityId:
        x: 526
        'y': 11
      set_message:
        x: 546
        'y': 147
      getSMAXSystemProperty:
        x: 77
        'y': 194
      get_jira_issueid:
        x: 937
        'y': 418
      getRequestAttachUploadJira:
        x: 565
        'y': 540
      convertHTMLtoJIRAMarkup:
        x: 381
        'y': 11
      set_httpClient_Body:
        x: 830
        'y': 1
      intialize_JiraProperty:
        x: 310.01824951171875
        'y': 283.7239685058594
        navigate:
          04258964-e837-902d-c569-4045bea8fbd8:
            targetId: 0800e2de-6c0c-e6eb-c260-2294c6c2a8ce
            port: SUCCESS
          1248947e-7d40-4120-788c-d420bd713430:
            targetId: 0800e2de-6c0c-e6eb-c260-2294c6c2a8ce
            port: FAILURE
      updateSMAXRequest:
        x: 722
        'y': 515
      MainErrorHandler:
        x: 511
        'y': 311
      getSMAXSystemProperty_1:
        x: 102
        'y': 40
      Create_Issue_in_Jira:
        x: 1026
        'y': 177
      Hide_Fields_In_Jira:
        x: 667
        'y': 1
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 283
          'y': 441
      FAILURE:
        0800e2de-6c0c-e6eb-c260-2294c6c2a8ce:
          x: 152.01824951171875
          'y': 303.7239685058594
