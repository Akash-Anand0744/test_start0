########################################################################################################################
#!!
#! @input last_update: Keep this field as null and provide value only when testing in CST like: 2022-05-17T04:56:18.000-0500
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedulers.SMAX.Schedules
flow:
  name: Schedule_SyncJiraIssueStatus
  inputs:
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
    - last_update:
        required: false
    - smax_request_id_list:
        required: false
    - is_retry:
        required: false
    - error_log_id:
        required: false
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - token
          - errorMessage
          - message
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: get_smaxSystemProperties_json_KeyValue
          - FAILURE: on_failure
    - jiraIssueStatusUpdateSMAX:
        do:
          Cerner.DFMP.Schedulers.SMAX.Operations.jiraIssueStatusUpdateSMAX:
            - smax_Token: '${token}'
            - lastUpdate: '${lastUpdate}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - jira_IncidentCategory_FieldId: '${jira_IncidentCategory_FieldId}'
            - jira_RequestCategory_FieldId: '${jira_RequestCategory_FieldId}'
            - smax_jirasmaxid_list: '${smax_jirasmaxid_list}'
            - previous_errorLogs: '${errorLogs}'
        publish:
          - result
          - message
          - newUpdateTime
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - jiraIssueStatus
          - errorLogs
          - provider_failure
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: on_failure
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - oo_run_name: Schedule_SyncJiraIssueStatus
        publish:
          - last_run_time
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - errorLogs
        navigate:
          - SUCCESS: getUnixToCST_timestamp
          - FAILURE: on_failure
    - getUnixToCST_timestamp:
        do:
          Cerner.DigitalFactory.Common.Utility.getUnixToCST_timestamp:
            - dt: '${last_run_time}'
        publish:
          - message
          - result
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
          - cst_date
          - lastUpdate: '${cst_date}'
        navigate:
          - SUCCESS: get_Jira_INC_Category
          - FAILURE: on_failure
    - get_smaxSystemProperties_json_KeyValue:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.get_smaxSystemProperties_json_KeyValue:
            - smax_token: '${token}'
        publish:
          - smax_system_property_json
          - errorMessage
          - message
          - errorSeverity
          - errorProvider
          - errorLogs
        navigate:
          - FAILURE: on_failure
          - SUCCESS: getJiraFileds_from_SMAXConfig_Json
    - getJiraFileds_from_SMAXConfig_Json:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.getJiraFileds_from_SMAXConfig_Json:
            - smax_property_config_json: '${smax_system_property_json}'
        publish:
          - jiraSmaxIDField
          - message
          - errorMessage
        navigate:
          - FAILURE: on_failure
          - SUCCESS: check_smax_request_id_list
    - get_Jira_INC_Category:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_system_property_json}'
            - json_path: JIRA_Incident_Category_Field
        publish:
          - errorMessage: '${error_message}'
          - jira_IncidentCategory_FieldId: '${return_result}'
        navigate:
          - SUCCESS: get__Jira_Req_Category
          - FAILURE: on_failure
    - get__Jira_Req_Category:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_system_property_json}'
            - json_path: JIRA_Request_Category_Field
        publish:
          - errorMessage: '${error_message}'
          - jira_RequestCategory_FieldId: '${return_result}'
        navigate:
          - SUCCESS: jiraIssueStatusUpdateSMAX
          - FAILURE: on_failure
    - If_lastupdate_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${last_update}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - lastUpdate: '${first_string}'
        navigate:
          - SUCCESS: getOOLastruntime
          - FAILURE: get_Jira_INC_Category
    - checkAny_Error_logs:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${errorLogs}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: LogErrors_to_ErrorLogTracker
    - LogErrors_to_ErrorLogTracker:
        do:
          Cerner.DFMP.Error_Framework.SubFlows.LogErrors_to_ErrorLogTracker:
            - error_logs: '${errorLogs}'
            - smax_auth_token: '${token}'
            - is_retry: '${is_retry}'
            - error_log_id: '${error_log_id}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - getJiraIDs:
        do:
          Cerner.DFMP.Schedulers.SMAX.Operations.getJiraIDs:
            - smax_Token: '${token}'
            - smax_request_id_list: '${smax_request_id_list}'
            - smax_FieldID: '${jiraSmaxIDField}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - smax_jirasmaxid_list
          - errorLogs
          - provider_failure
        navigate:
          - SUCCESS: get_Jira_INC_Category
          - FAILURE: on_failure
    - check_smax_request_id_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_id_list}'
        publish:
          - cst_date: ''
          - last_run_time: ''
        navigate:
          - SUCCESS: If_lastupdate_isnull
          - FAILURE: getJiraIDs
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - errorLogs: '${errorLogs}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      checkAny_Error_logs:
        x: 680
        'y': 480
        navigate:
          affb27a3-d8a7-aaf8-b674-5236a569b515:
            targetId: 9d0f6f78-641a-f14c-15e6-701d2e2808f7
            port: SUCCESS
      getUnixToCST_timestamp:
        x: 440
        'y': 80
      get_smaxSystemProperties_json_KeyValue:
        x: 80
        'y': 240
      get_Jira_INC_Category:
        x: 560
        'y': 280
      LogErrors_to_ErrorLogTracker:
        x: 840
        'y': 280
        navigate:
          8c29f0c1-539e-abe3-e4b5-3b15721fa4b5:
            targetId: 9d0f6f78-641a-f14c-15e6-701d2e2808f7
            port: SUCCESS
      getOOLastruntime:
        x: 240
        'y': 80
      If_lastupdate_isnull:
        x: 240
        'y': 280
      getJiraFileds_from_SMAXConfig_Json:
        x: 80
        'y': 440
      getJiraIDs:
        x: 400
        'y': 440
      jiraIssueStatusUpdateSMAX:
        x: 680
        'y': 280
      get__Jira_Req_Category:
        x: 680
        'y': 80
      check_smax_request_id_list:
        x: 240
        'y': 440
      get_SMAXToken:
        x: 80
        'y': 80
    results:
      SUCCESS:
        9d0f6f78-641a-f14c-15e6-701d2e2808f7:
          x: 840
          'y': 440
