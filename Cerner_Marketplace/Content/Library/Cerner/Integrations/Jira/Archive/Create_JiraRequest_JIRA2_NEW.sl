namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraRequest_JIRA2_NEW
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
    - jiraSmaxIdFieldId: customfield_49101
    - requestorEmail
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
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
    - get_priorityId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.priorityIDs')}"
            - json_path: '${priority}'
        publish:
          - jiraPriorityId: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{\"fields\": {\"project\": {\"id\": \"'+projectId+'\"},\"summary\": \"'+summary+'\", \"issuetype\": {\"id\": \"'+issueTypeId+'\"},\"reporter\": {\"name\":\"'+reporter[0:reporter.find(\"@\")]+'\"},\"priority\": {\"id\": \"'+jiraPriorityId+'\" },\"customfield_47251\":\"'+criticalityJustification+'\" ,\"description\":'+description+',\"customfield_47005\": {\"id\": \"70704\"},\"customfield_22411\": ['+watchersJSON+'],\"customfield_47247\": {\"id\":\"'+JIRAInstance+'\"},\"customfield_47248\": \"'+JIRAProject+'\", \"customfield_47637\" : \"'+Justification+'\",\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\" } }'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: CheckAvaiability_JIRA
          - FAILURE: MainErrorHandler_1
    - CheckAvaiability_JIRA:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.CheckAvaiability_JIRA: []
        publish:
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - FAILURE: MainErrorHandler_1
          - SUCCESS: Create_Issue_in_Jira
    - Create_Issue_in_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Create_Issue_in_Jira:
            - httpClient_BodyInput: '${httpClient_Body}'
            - watcherFieldId: '${watcher_FieldID}'
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
          - FAILURE: MainErrorHandler_1
          - SUCCESS: get_jira_url
    - updateSMAXRequest:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        navigate:
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
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
          - FAILURE: MainErrorHandler_1
    - MainErrorHandler_1:
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
        x: 404
        'y': 442
        navigate:
          5280bd94-2e43-1425-15ef-4e3b89ea7892:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      extractWathersList:
        x: 221
        'y': 17
      get_jira_url:
        x: 1003
        'y': 276
      CheckAvaiability_JIRA:
        x: 798
        'y': 9
      get_priorityId:
        x: 526
        'y': 11
      getSMAXSystemProperty:
        x: 77
        'y': 194
      get_jira_issueid:
        x: 937
        'y': 418
      MainErrorHandler_1:
        x: 512
        'y': 217
      getRequestAttachUploadJira:
        x: 587
        'y': 442
      convertHTMLtoJIRAMarkup:
        x: 381
        'y': 11
      set_httpClient_Body:
        x: 669
        'y': 12
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
        x: 755
        'y': 434
      getSMAXSystemProperty_1:
        x: 102
        'y': 40
      Create_Issue_in_Jira:
        x: 954
        'y': 121
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 283
          'y': 441
      FAILURE:
        0800e2de-6c0c-e6eb-c260-2294c6c2a8ce:
          x: 152.01824951171875
          'y': 303.7239685058594
