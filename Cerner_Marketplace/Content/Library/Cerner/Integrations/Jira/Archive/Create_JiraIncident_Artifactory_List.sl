namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraIncident_Artifactory_List
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
    - watcherFieldId: customfield_22411
    - summary
    - jiraTool: '70856'
    - repoURL:
        default: ' '
        required: false
    - jiraToolInstanceL1
    - jiraToolInstanceL2:
        required: false
    - jiraToolInstanceL3:
        required: false
    - jiraToolInstanceL4:
        required: false
    - jiraToolInstanceL5:
        required: false
    - watchers:
        required: false
    - smaxRequestID
    - jiraSmaxIdFieldId: customfield_49101
    - requestorEmail
  workflow:
    - createArtifactoryIdJSON:
        do:
          Cerner.Integrations.Jira.subFlows.createArtifactoryIdJSON:
            - instanceId1: '${jiraToolInstanceL1}'
            - instanceId2: '${jiraToolInstanceL2}'
            - instanceId3: '${jiraToolInstanceL3}'
            - instanceId4: '${jiraToolInstanceL4}'
            - instanceId5: '${jiraToolInstanceL5}'
        publish:
          - result
          - artifactoryInstanceJSON: '${message}'
          - errorType: errorType
          - errorSeverity: errorSeverity
          - errorProvider: errorProvider
          - errorMessage
        navigate:
          - SUCCESS: getSMAXSystemProperty_WatcherField
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
          - SUCCESS: set_httpClient_Body
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
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification.strip()+'\",\"description\": '+description+', \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+repoURLFieldId+'\": \"'+repoURL+'\", \"'+toolInstanceFieldId+'\": ['+artifactoryInstanceJSON+'], \"'+watcherFieldId+'\": ['+watchersJSON+'], \"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\"  } }'}"
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
    - getSMAXSystemProperty_SmaxRequestFieldID:
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
    - getSMAXSystemProperty_WatcherField:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSMAXSystemProperty:
            - propertyKey: watcherFieldId
        publish:
          - result
          - message
          - watcher_FieldID: '${SystemPropValue}'
        navigate:
          - SUCCESS: getSMAXSystemProperty_SmaxRequestFieldID
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
        x: 413
        'y': 541
        navigate:
          a836a83f-dccb-70d4-9c04-e8d7423c408d:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      set_message_ClientBody:
        x: 732
        'y': 134
      set_message_JIRA:
        x: 778.0182495117188
        'y': 365.7239685058594
      extractWathersList:
        x: 318
        'y': 11
      get_jira_url:
        x: 1045
        'y': 390
      CheckAvaiability_JIRA:
        x: 1032
        'y': 96
      get_priorityId:
        x: 635
        'y': 8
      set_message:
        x: 597
        'y': 150
      getSMAXSystemProperty_SmaxRequestFieldID:
        x: 165
        'y': 29
      createArtifactoryIdJSON:
        x: 28
        'y': 331
      get_jira_issueid:
        x: 928
        'y': 512
      getRequestAttachUploadJira:
        x: 538
        'y': 542
      convertHTMLtoJIRAMarkup:
        x: 464
        'y': 15
      set_httpClient_Body:
        x: 847
        'y': 15
      getSMAXSystemProperty_WatcherField:
        x: 45
        'y': 172
      intialize_JiraProperty:
        x: 366
        'y': 409
        navigate:
          86a6efad-0e31-7c3a-32b9-74d439f37922:
            targetId: 6c0c359f-506f-f48d-50a4-2d997b86eb8d
            port: SUCCESS
          d283a112-e7bf-d5fc-9d65-04c63fb8fdf2:
            targetId: 6c0c359f-506f-f48d-50a4-2d997b86eb8d
            port: FAILURE
      updateSMAXRequest:
        x: 701
        'y': 527
      MainErrorHandler:
        x: 538
        'y': 336
      Create_Issue_in_Jira:
        x: 1084
        'y': 249
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 287
          'y': 471
      FAILURE:
        6c0c359f-506f-f48d-50a4-2d997b86eb8d:
          x: 198
          'y': 402
