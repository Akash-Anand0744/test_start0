########################################################################################################################
#!!
#! @input smaxRequestID: SMAX Request ID
#! @input reporter: Issue Reporter
#! @input watchers: Watcher(s) and NoWatcher if JIRA Project does not have watchers enabled.
#! @input requestorEmail: requestor email
#! @input description: Description of the Request or Issue
#! @input fields_append_toDescription: Fields from MarketPalce UI that needs to be appended to Description field
#! @input jira_direct_fields: JIRA Field names that exists as it is in JIRA for example, summary, description etc. Key Value Pair with delimiter (||) as Key1,Value1||Key2,Value2||
#! @input get_jira_fields_fm_smax_config: Get Jira Field names from SMAX Configuration, JIRA Custom fields will be there
#! @input get_jira_fields_fm_oo_config: Get Jira Field names from OO Configuration, JIRA Custom fields will be there
#! @input get_id_value_fm_oo_config: Get ID value for Jira Fields from OO System Properties, Fields like project, issueType, jiraTool etc. Corresponding OO System Property must exist like project_JSON, issueType_JSON , jiraTool_JSON, These ID Values will used in JIRA Json Body under jira id field
#! @input hide_fields_In_Jira: Coma separated list for Jira Fields which needs to be hidden, not visible to User
#! @input jira_issue_subtasks: jira Issue subtasks format subtask1,subtask description||subtask2,description2||
#!!#
########################################################################################################################
namespace: Cerner.Integrations.Jira
flow:
  name: Create_JiraRequest_Framework
  inputs:
    - smaxRequestID
    - reporter
    - watchers:
        required: false
    - requestorEmail
    - description
    - fields_append_toDescription:
        default: ''
        required: false
    - jira_direct_fields:
        required: false
    - get_jira_fields_fm_smax_config:
        default: ''
        required: false
    - get_jira_fields_fm_oo_config:
        default: ''
        required: false
    - get_id_value_fm_oo_config:
        default: ''
        required: false
    - hide_fields_In_Jira:
        default: ''
        required: false
    - jira_issue_subtasks:
        required: false
  workflow:
    - fields_append_toDescription:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.fields_append_toDescription:
            - description: '${description}'
            - fields_append_toDescription: '${fields_append_toDescription}'
        publish:
          - description: '${newDescription}'
          - summary: ''
          - errorType
          - errorMessage
          - errorProvider
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: jira_direct_fields_jsonKeyValue
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{    \"fields\": { \"description\": '+ description +', \"reporter\": { \"name\": \"'+reporter[0:reporter.find(\"@\")]+'\"}, ' + watchers_json + jira_direct_fields_jsonKeyValue + jira_fields_fm_oo_config_jsonKeyValue + get_jira_fields_fm_smax_config_jsonKeyValue + json_object_key_value_pair_with_ID + '\"'+jiraSmaxIDField+'\": \"'+smaxRequestID+'\"  } }'}"
        publish:
          - httpClient_Body: "${cs_replace(httpClient_Body,\"\\\\'\",\"'\")}"
        navigate:
          - SUCCESS: Create_Issue_in_Jira_Framework
          - FAILURE: set_message
    - convertHTMLtoJIRAMarkup:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.convertHTMLtoJIRAMarkup:
            - htmlString: '${description}'
            - smaxID: '${smaxRequestID}'
        publish:
          - description: '${wikiString}'
          - imageLinks
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: getJiraFileds_from_SMAXConfig_Json
          - FAILURE: intialize_JiraProperty
    - intialize_JiraProperty:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - incidentHttpStatusCode: '-1'
          - jiraIncidentCreationResult: Failed
          - jiraIssueURL: ''
          - jiraIssueId: ''
        navigate:
          - SUCCESS: MainErrorHandler
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
          - SUCCESS: intialize_JiraProperty
          - FAILURE: intialize_JiraProperty
    - jira_direct_fields_jsonKeyValue:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Create_json_object_fm_key_value_pair_List:
            - Key_value_list: '${jira_direct_fields}'
        publish:
          - jira_direct_fields_jsonKeyValue: '${json_key_value_object}'
          - message
          - summary: "${Key_value_list.split('ummary,')[1].split('||')[0]}"
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: get_smaxSystemProperties_json_KeyValue
    - get_jira_fields_fm_oo_config_create_jsonKeyValue:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.get_NewKeyValue_json_object_fm_json_input:
            - key_value_pair_list: '${get_jira_fields_fm_oo_config}'
            - json_input_object: '${jiraCustomFields_json}'
            - smax_system_property_json: '${smax_system_property_json}'
        publish:
          - jira_fields_fm_oo_config_jsonKeyValue: '${json_object_key_value_pair}'
          - message
          - errorProvider
          - errorMessage
          - errorType
          - errorSeverity
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: get_jira_fields_fm_smax_config_jsonKeyValue
    - get_smaxSystemProperties_json_KeyValue:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.get_smaxSystemProperties_json_KeyValue: []
        publish:
          - smax_system_property_json
          - errorMessage
          - message
          - errorType
          - errorProvider: SMAX
          - errorLogs
          - errorSeverity
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: get_jiraCustomFields_json
    - get_jira_fields_fm_smax_config_jsonKeyValue:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.get_NewKeyValue_json_object_fm_json_input:
            - key_value_pair_list: '${get_jira_fields_fm_smax_config}'
            - json_input_object: '${jiraCustomFields_json}'
            - smax_system_property_json: '${smax_system_property_json}'
        publish:
          - get_jira_fields_fm_smax_config_jsonKeyValue: '${json_object_key_value_pair}'
          - message
          - errorProvider
          - errorSeverity
          - errorType
          - errorMessage
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: get_ID_for_jiraFields_from_OO_Config_to_jsonObject
    - get_ID_for_jiraFields_from_OO_Config_to_jsonObject:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.get_ID_for_jiraFields_from_OO_Config_to_jsonObject:
            - get_id_value_fm_oo_config: '${get_id_value_fm_oo_config}'
            - smax_system_property_json: '${smax_system_property_json}'
            - oo_jira_customField_json_object: '${jiraCustomFields_json}'
        publish:
          - json_object_key_value_pair_with_ID
          - message
          - errorProvider
          - errorSeverity
          - errorType
          - errorMessage
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: get_jiraFields_fm_oo_config_to_list
    - getJiraFileds_from_SMAXConfig_Json:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.getJiraFileds_from_SMAXConfig_Json:
            - smax_property_config_json: '${smax_system_property_json}'
        publish:
          - jiraSmaxIDField
          - watcherFieldId
          - message
          - errorMessage
        navigate:
          - FAILURE: intialize_JiraProperty
          - SUCCESS: extractWatchersList_json
    - Create_Issue_in_Jira_Framework:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Create_Issue_in_Jira_Framework:
            - httpClient_BodyInput: '${httpClient_Body}'
            - watcherFieldId: '${watcherFieldId}'
            - hide_jira_fields: '${hide_fields_In_Jira}'
            - reporter: '${reporter}'
            - watchers: '${watchers}'
        publish:
          - httpClient_Body
          - jiraIncidentCreationResult
          - jiraIssueId
          - jiraIssueURL
          - incidentHttpStatusCode
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - jiraIssueKey
          - jiraProject
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: updateSMAXRequest
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
        publish: []
        navigate:
          - FAILURE: on_failure
          - SUCCESS: FAILURE
    - get_jiraFields_fm_oo_config_to_list:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.get_jiraFields_fm_oo_config_to_list:
            - get_list_for_jirafields: '${hide_fields_In_Jira}'
            - smax_system_property_json: '${smax_system_property_json}'
            - oo_jira_customField_json_object: '${jiraCustomFields_json}'
        publish:
          - hide_fields_In_Jira: '${jirafields_list}'
          - message
          - errorProvider
          - errorSeverity
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: convertHTMLtoJIRAMarkup
          - FAILURE: intialize_JiraProperty
    - uploadImageInRequestDesc:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.uploadImageInRequestDesc:
            - smaxURL: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - smaxAuthURL: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smaxUser: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
            - smaxPass: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
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
    - extractWatchersList_json:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.extractWatchersList_json:
            - watchers: '${watchers}'
            - reporter: '${reporter}'
            - watcherFieldId: '${watcherFieldId}'
        publish:
          - watchers_json
          - message
          - result
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: intialize_JiraProperty
    - get_jiraCustomFields_json:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input1: "${get_sp('MarketPlace.jiraCustomFields1')}"
            - input2: "${get_sp('MarketPlace.jiraCustomFields2')}"
            - input3: "${get_sp('MarketPlace.jiraCustomFields3')}"
            - input4: "${get_sp('MarketPlace.jiraCustomFields4')}"
        publish:
          - errorType: e10000
          - errorProvider: JIRA
          - errorSeverity: ERROR
          - jiraCustomFields_json: "${input1[:-1] + ',' + input2[1:-1] + ',' + input3[1:-1] + ',' + input4[1:]}"
        navigate:
          - SUCCESS: get_jira_fields_fm_oo_config_create_jsonKeyValue
          - FAILURE: intialize_JiraProperty
    - Updated_getRequestAttachUploadJira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Updated_getRequestAttachUploadJira:
            - smaxRequestId: '${smaxRequestID}'
            - jiraIssueId: '${jiraIssueId}'
            - smax_FieldID: '${jiraSmaxIDField}'
        publish:
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - SUCCESS: uploadImageInRequestDesc
          - FAILURE: on_failure
    - jira_substaks_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_issue_subtasks}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: Updated_getRequestAttachUploadJira
          - FAILURE: Create_jiraIssue_subTasks
    - Create_jiraIssue_subTasks:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.Create_jiraIssue_subTasks:
            - jira_project: '${jiraProject}'
            - jira_issue_key: '${jiraIssueKey}'
            - jira_issue_subtasks: '${jira_issue_subtasks}'
        publish:
          - jiraIncidentCreationResult
          - incidentHttpStatusCode
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - SUCCESS: Updated_getRequestAttachUploadJira
          - FAILURE: on_failure
    - updateSMAXRequest:
        do:
          Cerner.Integrations.Jira.subFlows.updateSMAXRequest:
            - jiraIssueURL: '${jiraIssueURL}'
            - jiraIssueId: '${jiraIssueId}'
            - smaxRequestID: '${smaxRequestID}'
        navigate:
          - FAILURE: MainErrorHandler
          - SUCCESS: jira_substaks_isnull
  outputs:
    - incidentCreationCode: '${incidentHttpStatusCode}'
    - incidentCreationResultJSON: '${jiraIncidentCreationResult}'
    - jiraIssueURL: '${jiraIssueURL}'
    - jiraIssueId: '${jiraIssueId}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      uploadImageInRequestDesc:
        x: 40
        'y': 320
        navigate:
          1b767911-eb4e-eb4b-44e2-5c10394c600d:
            targetId: cccdc95f-3de3-0567-f6f3-198bd9468cf8
            port: SUCCESS
      fields_append_toDescription:
        x: 40
        'y': 160
      get_jira_fields_fm_smax_config_jsonKeyValue:
        x: 866
        'y': 41
      get_jira_fields_fm_oo_config_create_jsonKeyValue:
        x: 680
        'y': 40
      Create_jiraIssue_subTasks:
        x: 200
        'y': 600
      get_jiraCustomFields_json:
        x: 520
        'y': 40
      get_smaxSystemProperties_json_KeyValue:
        x: 374
        'y': 40
      set_message:
        x: 657
        'y': 422
      getJiraFileds_from_SMAXConfig_Json:
        x: 1040
        'y': 600
      convertHTMLtoJIRAMarkup:
        x: 1040
        'y': 400
      Updated_getRequestAttachUploadJira:
        x: 40
        'y': 600
      extractWatchersList_json:
        x: 880
        'y': 600
      set_httpClient_Body:
        x: 720
        'y': 600
      intialize_JiraProperty:
        x: 600
        'y': 240
      updateSMAXRequest:
        x: 400
        'y': 600
      jira_substaks_isnull:
        x: 200
        'y': 440
      MainErrorHandler:
        x: 400
        'y': 360
        navigate:
          19dfc773-fc29-8b85-d8d5-8ed16e6b2fe0:
            targetId: ed8e76ee-b8d0-a468-be40-1cae05e5a10f
            port: SUCCESS
      jira_direct_fields_jsonKeyValue:
        x: 160
        'y': 40
      get_jiraFields_fm_oo_config_to_list:
        x: 1040
        'y': 240
      Create_Issue_in_Jira_Framework:
        x: 560
        'y': 520
      get_ID_for_jiraFields_from_OO_Config_to_jsonObject:
        x: 1040
        'y': 40
    results:
      FAILURE:
        ed8e76ee-b8d0-a468-be40-1cae05e5a10f:
          x: 280
          'y': 280
      SUCCESS:
        cccdc95f-3de3-0567-f6f3-198bd9468cf8:
          x: 200
          'y': 320
