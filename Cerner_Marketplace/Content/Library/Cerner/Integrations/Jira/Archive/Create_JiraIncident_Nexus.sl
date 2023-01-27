namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraIncident_Nexus
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
        default: '70856'
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
    - requestorEmail
  workflow:
    - getSMAXSystemProperty_WatcherField:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSMAXSystemProperty:
            - propertyKey: watcherFieldId
        publish:
          - result
          - message
          - watcher_FieldID: '${SystemPropValue}'
          - errorType
          - errorMessage: '${message}'
        navigate:
          - SUCCESS: getSMAXSystemProperty_SmaxRequestFieldID
          - FAILURE: MainErrorHandler_1
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
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"customfield_47251\": \"'+criticalityJustification.strip()+'\",\"description\":'+description+', \"'+jiraToolFieldId+'\":{ \"id\": \"'+jiraTool+'\" }, \"'+watcherFieldId+'\": ['+watchersJSON+'],\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\" } }'}"
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
          - httpClient_BodyInput
          - jiraIncidentCreationResult
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
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: MainErrorHandler_1
    - getSMAXSystemProperty_SmaxRequestFieldID:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSMAXSystemProperty:
            - propertyKey: jiraSmaxIDField
        publish:
          - result
          - message
          - smax_FieldID: '${SystemPropValue}'
          - errorType
          - errorMessage: '${message}'
        navigate:
          - SUCCESS: extractWathersList
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
        x: 415
        'y': 449
        navigate:
          7f756ca7-7e08-7081-7880-125dd7b70245:
            targetId: 2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c
            port: SUCCESS
      extractWathersList:
        x: 302
        'y': 11
      get_jira_url:
        x: 901
        'y': 347
      CheckAvaiability_JIRA:
        x: 895
        'y': 60
      get_priorityId:
        x: 592
        'y': 5
      getSMAXSystemProperty_SmaxRequestFieldID:
        x: 164
        'y': 28
      get_jira_issueid:
        x: 819
        'y': 427
      MainErrorHandler_1:
        x: 517
        'y': 242
      getRequestAttachUploadJira:
        x: 542
        'y': 439
      convertHTMLtoJIRAMarkup:
        x: 441
        'y': 9
      set_httpClient_Body:
        x: 746
        'y': 6
      getSMAXSystemProperty_WatcherField:
        x: 50
        'y': 144
      intialize_JiraProperty:
        x: 311
        'y': 278
        navigate:
          b5d39872-ccf2-5986-c3cc-368fcf9cd532:
            targetId: 53315322-26c0-427d-8c22-c9aa402fc6ef
            port: FAILURE
          6e6cf29f-2ff4-0279-b9cd-85368c7ea7d3:
            targetId: 53315322-26c0-427d-8c22-c9aa402fc6ef
            port: SUCCESS
      updateSMAXRequest:
        x: 681
        'y': 432
      Create_Issue_in_Jira:
        x: 905
        'y': 200
    results:
      SUCCESS:
        2e3e4a91-f4e1-ebf1-c5c8-4806ce62a06c:
          x: 279
          'y': 431
      FAILURE:
        53315322-26c0-427d-8c22-c9aa402fc6ef:
          x: 115
          'y': 337
