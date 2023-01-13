namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_AbiliityRequest_ABLGM
  inputs:
    - projectId: '11604'
    - issueTypeId: '31100'
    - reporter
    - description
    - summary
    - smaxRequestID
    - WorkInst
    - ProjectCRJIRA
    - priority:
        required: false
    - jiraSmaxIdFieldId
    - requestorEmail
    - watchers:
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
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: MainErrorHandler
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{\"fields\":{\"project\":{\"id\":\"'+projectId+'\"},\"summary\":\"'+summary+'\",\"issuetype\":{\"id\":\"'+issueTypeId+'\"},\"reporter\":{\"name\":\"'+reporter[0:reporter.find(\"@\")]+'\"},\"description\":'+description+',\"customfield_11311\":\"'+WorkInst+'\",\"customfield_12845\":\"'+ProjectCRJIRA+'\",\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\" }}'}"
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
          - errorProvider
          - errorMessage
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
          - jiraIncidentCreationResult
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
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
        x: 332
        'y': 544
        navigate:
          4acc8bc9-b1d7-da20-3161-af641de7aedf:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 731
        'y': 147
      set_message_JIRA:
        x: 811
        'y': 366
      extractWathersList:
        x: 453
        'y': 34
      get_jira_url:
        x: 1095
        'y': 408
      CheckAvaiability_JIRA:
        x: 1080
        'y': 121
      get_jira_issueid:
        x: 969
        'y': 540
      getRequestAttachUploadJira:
        x: 508
        'y': 544
      convertHTMLtoJIRAMarkup:
        x: 607
        'y': 37
      getSMAXSystemProperty_SmaxFieldID:
        x: 306
        'y': 29
      set_httpClient_Body:
        x: 862
        'y': 42
      getSMAXSystemProperty_WatcherField:
        x: 127
        'y': 123
      intialize_JiraProperty:
        x: 308
        'y': 283
        navigate:
          147cd098-279a-a007-03e0-bda5afbedebd:
            targetId: 46333695-e29c-6e12-4634-9878ed8ab1b7
            port: FAILURE
          2837c486-c526-8aff-fc41-0cf2f249ad42:
            targetId: 46333695-e29c-6e12-4634-9878ed8ab1b7
            port: SUCCESS
      updateSMAXRequest:
        x: 678
        'y': 544
      MainErrorHandler:
        x: 561
        'y': 273
      Create_Issue_in_Jira:
        x: 1090
        'y': 266
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 81
          'y': 484
      FAILURE:
        46333695-e29c-6e12-4634-9878ed8ab1b7:
          x: 106
          'y': 268
