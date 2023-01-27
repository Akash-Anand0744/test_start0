namespace: Cerner.Integrations.Jira.Archive
flow:
  name: Create_JiraRequest_ArtifactoryMgmtRequest
  inputs:
    - jiraToolRequestFieldId: customfield_47005
    - swLinkFieldId: customfield_47220
    - criticalJustFieldId: customfield_47251
    - watcherFieldId
    - artfactReqTypeFieldId: customfield_47218
    - swExistInNexusFieldId: customfield_47219
    - toolInstanceFieldId:
        default: customfield_47215
        required: false
    - projectId: '40703'
    - issueTypeId: '18'
    - jiraToolRequest: '70879'
    - reporter
    - priority
    - criticalityJustification:
        default: ''
        required: false
    - artifactoryRequestType
    - summary
    - description
    - swLink:
        default: ' '
        required: false
    - watchers:
        required: false
    - smaxRequestID
    - swExistInNexus:
        default: ' '
        required: false
    - deleteFileFolderLink:
        required: false
    - restoreArtifactName:
        required: false
    - restoreRepositoryLink:
        required: false
    - deleteRepoArtifactName:
        required: false
    - deleteRepoLink:
        required: false
    - deleteRepoExplaination:
        required: false
    - jiraToolInstanceL1:
        required: false
    - jiraToolInstanceL2:
        required: false
    - jiraToolInstanceL3:
        required: false
    - jiraToolInstanceL4:
        required: false
    - jiraToolInstanceL5:
        required: false
    - ArtifactoryRepoType:
        default: ' '
        required: false
    - ServiceAccountPermission:
        default: ' '
        required: false
    - ReplicationNeeded:
        default: ' '
        required: false
    - ProxyExternalRepository:
        default: ' '
        required: false
    - ReposityTypeLink:
        required: false
    - jiraSmaxIdFieldId: customfield_49101
    - requestorEmail
  workflow:
    - formatDescriptionForArtReqType:
        do:
          Cerner.Integrations.Jira.subFlows.formatDescriptionForArtReqType:
            - artifactoryRequestTypeIn: '${artifactoryRequestType}'
            - deleteFileFolderLink: '${deleteFileFolderLink}'
            - deleteRepoArtifactName: '${deleteRepoArtifactName}'
            - deleteRepoLink: '${deleteRepoLink}'
            - deleteRepoExplaination: '${deleteRepoExplaination}'
            - restoreArtifactName: '${restoreArtifactName}'
            - restoreRepoLink: '${restoreRepositoryLink}'
            - descriptionIn: '${description}'
            - ReposityTypeLink: '${ReposityTypeLink}'
        publish:
          - result
          - message
          - artifactoryRequestType: '${artifactoryRequestTypeOut}'
          - description: '${descriptionOut}'
          - errorMessage: errorMessage
          - errorSeverity: errorSeverity
          - errorType: errorType
          - errorProvider: errorProvider
        navigate:
          - SUCCESS: get_artifactoryRequestType
          - FAILURE: MainErrorHandler
    - get_artifactoryRequestType:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.artifactoryRequestType')}"
            - json_path: '${artifactoryRequestType}'
        publish:
          - jiraArtifactReqType: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_SWExistsInNexus
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
          - SUCCESS: get_repoTypeID
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
    - get_SWExistsInNexus:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.artifactorySWExistsInRepo')}"
            - json_path: '${cs_replace(swExistInNexus," ","false",1)}'
        publish:
          - swExistInNexus: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: createArtifactoryIdJSON_optionalInstance
          - FAILURE: MainErrorHandler
    - get_repoTypeID:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.ArtifactRepoType')}"
            - json_path: '${ArtifactoryRepoType}'
        publish:
          - RepoTypeID: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_replicationID
          - FAILURE: get_replicationID
    - get_replicationID:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.ArtifactReplication')}"
            - json_path: '${ReplicationNeeded}'
        publish:
          - ReplicationID: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_proxyExternalID
          - FAILURE: get_proxyExternalID
    - get_proxyExternalID:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('MarketPlace.ArtifactProxyExternal')}"
            - json_path: '${ProxyExternalRepository}'
        publish:
          - ProxyExternalID: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: set_httpClient_Body
    - createArtifactoryIdJSON_optionalInstance:
        do:
          Cerner.Integrations.Jira.subFlows.createArtifactoryIdJSON_optionalInstance:
            - instanceId1: '${jiraToolInstanceL1}'
            - instanceId2: '${jiraToolInstanceL2}'
            - instanceId3: '${jiraToolInstanceL3}'
            - instanceId4: '${jiraToolInstanceL4}'
            - instanceId5: '${jiraToolInstanceL5}'
        publish:
          - result
          - artifactoryInstanceJSON: '${message}'
          - errorProvider: errorProvider
          - errorSeverity: errorSeverity
          - errorType: errorType
          - errorMessage: errorMessage
        navigate:
          - SUCCESS: getSMAXSystemProperty_WatcherField
          - FAILURE: MainErrorHandler
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
            - httpClient_Body: "${'{    \"fields\": {         \"project\": { \"id\": \"'+projectId+'\" }, \"summary\": \"'+summary+'\", \"issuetype\": { \"id\": \"'+issueTypeId+'\"}, \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, \"priority\": { \"id\": \"'+jiraPriorityId+'\" }, \"'+criticalJustFieldId+'\": \"'+criticalityJustification.strip()+'\",\"description\":'+description+', \"'+jiraToolRequestFieldId+'\":{ \"id\": \"'+jiraToolRequest+'\" },  \"'+toolInstanceFieldId+'\": ['+artifactoryInstanceJSON+'],\"'+swLinkFieldId+'\": \"'+swLink+'\", \"'+artfactReqTypeFieldId+'\": { \"id\": \"'+jiraArtifactReqType+'\"}, \"'+swExistInNexusFieldId+'\": { \"id\": \"'+swExistInNexus+'\"},\"customfield_47221\": { \"id\": \"'+RepoTypeID.strip()+'\" },\"customfield_47222\": \"'+ServiceAccountPermission.strip()+'\",\"customfield_47223\": { \"id\": \"'+ReplicationID.strip()+'\" },\"customfield_47224\": { \"id\": \"'+ProxyExternalID.strip()+'\" },\"'+watcherFieldId+'\": ['+watchersJSON+'],\"'+jiraSmaxIdFieldId+'\": \"'+smaxRequestID+'\"  } }'}"
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
        x: 237
        'y': 411
        navigate:
          91d2402a-4c2d-20c5-abaa-39f1feeaf08b:
            targetId: 553ef829-1fc1-c109-9bb2-9238e57b896d
            port: SUCCESS
      set_message_ClientBody:
        x: 792
        'y': 275
      set_message_JIRA:
        x: 668
        'y': 422
      extractWathersList:
        x: 631
        'y': 6
      get_jira_url:
        x: 815
        'y': 603
      CheckAvaiability_JIRA:
        x: 1082
        'y': 509
      get_priorityId:
        x: 857
        'y': 8
      createArtifactoryIdJSON_optionalInstance:
        x: 283
        'y': 5
      set_message:
        x: 733
        'y': 174
      get_proxyExternalID:
        x: 1118
        'y': 230
      getSMAXSystemProperty_SmaxRequestFieldID:
        x: 505
        'y': 4
      get_jira_issueid:
        x: 648
        'y': 583
      getRequestAttachUploadJira:
        x: 379
        'y': 485
      get_artifactoryRequestType:
        x: 42
        'y': 78
      convertHTMLtoJIRAMarkup:
        x: 738
        'y': 4
      get_repoTypeID:
        x: 971
        'y': 13
      set_httpClient_Body:
        x: 1133
        'y': 370
      get_SWExistsInNexus:
        x: 146
        'y': 7
      getSMAXSystemProperty_WatcherField:
        x: 393
        'y': 6
      intialize_JiraProperty:
        x: 234
        'y': 311
        navigate:
          92bd2656-6a07-9ed7-558e-6b110596cdf5:
            targetId: ef7773a0-edb7-a4da-abdc-0b000542335b
            port: FAILURE
          278dfb07-9f62-cbae-c7b2-11de6a505bc2:
            targetId: ef7773a0-edb7-a4da-abdc-0b000542335b
            port: SUCCESS
      updateSMAXRequest:
        x: 514
        'y': 523
      formatDescriptionForArtReqType:
        x: 26
        'y': 202
      MainErrorHandler:
        x: 558
        'y': 273
      get_replicationID:
        x: 1093
        'y': 76
      Create_Issue_in_Jira:
        x: 938
        'y': 518
    results:
      SUCCESS:
        553ef829-1fc1-c109-9bb2-9238e57b896d:
          x: 131
          'y': 429
      FAILURE:
        ef7773a0-edb7-a4da-abdc-0b000542335b:
          x: 53
          'y': 345
