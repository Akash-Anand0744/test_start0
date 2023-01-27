namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraIncident_Artifactory_List_copy_mine_b4883c
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification.strip()+'\",\"description\": '+description+', \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+repoURLFieldId+'\": \"'+repoURL+'\", \"'+toolInstanceFieldId+'\": ['+artifactoryInstanceJSON+'], \"'+watcherFieldId+'\": ['+watchersJSON+'], \"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\"  } }'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: CheckAvaiability_JIRA
          - FAILURE: on_failure
    - CheckAvaiability_JIRA:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.CheckAvaiability_JIRA: []
        publish:
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - FAILURE: on_failure
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
          - FAILURE: on_failure
          - SUCCESS: get_jira_url
    - updateSMAXRequest:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        navigate:
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
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
          - FAILURE: on_failure
    - on_failure:
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
        x: 308
        'y': 272
        navigate:
          a836a83f-dccb-70d4-9c04-e8d7423c408d:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      extractWathersList:
        x: 258
        'y': 71
      get_jira_url:
        x: 857
        'y': 336
      CheckAvaiability_JIRA:
        x: 782
        'y': 18
      get_priorityId:
        x: 519
        'y': 12
      getSMAXSystemProperty_SmaxRequestFieldID:
        x: 140
        'y': 18
      createArtifactoryIdJSON:
        x: 26
        'y': 285
      get_jira_issueid:
        x: 725
        'y': 425
      getRequestAttachUploadJira:
        x: 407
        'y': 428
      convertHTMLtoJIRAMarkup:
        x: 377
        'y': 18
      set_httpClient_Body:
        x: 638
        'y': 23
      getSMAXSystemProperty_WatcherField:
        x: 22
        'y': 133
      updateSMAXRequest:
        x: 573
        'y': 447
      Create_Issue_in_Jira:
        x: 844
        'y': 178
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 491
          'y': 228
