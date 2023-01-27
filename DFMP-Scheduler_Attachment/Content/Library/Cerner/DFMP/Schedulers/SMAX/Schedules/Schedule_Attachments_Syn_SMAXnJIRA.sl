namespace: Cerner.DFMP.Schedules.SMAX.Schedules
flow:
  name: Schedule_Attachments_Syn_SMAXnJIRA
  inputs:
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
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
          - smax_token: '${token}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: check_smax_request_id_list
          - FAILURE: on_failure
    - getJiraFileds_from_SMAXConfig_Json:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.getJiraFileds_from_SMAXConfig_Json:
            - smax_property_config_json: '${smax_system_property_json}'
        publish:
          - jiraSmaxIDField
          - message
          - errorMessage: '${errorMessage}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_smaxBridgeOOID
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - oo_run_name: Schedule_Attachments_Syn_SMAXnJIRA
        publish:
          - last_run_time
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - errorLogs
        navigate:
          - SUCCESS: getUnixToCST_timestamp
          - FAILURE: on_failure
    - get_smaxSystemProperties_json_KeyValue:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.get_smaxSystemProperties_json_KeyValue:
            - smax_token: '${smax_token}'
        publish:
          - smax_system_property_json
          - errorMessage
          - message
          - errorType
          - errorProvider: SMAX
          - errorLogs
        navigate:
          - FAILURE: on_failure
          - SUCCESS: getJiraFileds_from_SMAXConfig_Json
    - getUnixToCST_timestamp:
        do:
          Cerner.DigitalFactory.Common.Utility.getUnixToCST_timestamp:
            - dt: '${last_run_time}'
        publish:
          - result
          - message
          - cst_date
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: get_smaxSystemProperties_json_KeyValue
          - FAILURE: on_failure
    - get_smaxBridgeOOID:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_system_property_json}'
            - json_path: smaxBridgeOOID
        publish:
          - smaxBridgeOOID: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: getSmaxAndJiraId
          - FAILURE: on_failure
    - check_smax_request_id_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_id_list}'
        publish:
          - cst_date: ''
          - last_run_time: ''
        navigate:
          - SUCCESS: getOOLastruntime
          - FAILURE: get_smaxSystemProperties_json_KeyValue
    - getSmaxAndJiraId:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getSmaxAndJiraId:
            - smax_Token: '${smax_token}'
            - smax_request_id_list: '${smax_request_id_list}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - lastUpdateJira: '${cst_date}'
            - lastUpdateSmax: '${last_run_time}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - jira_smaxjiraid_list
          - smax_jirasmaxid_list
        navigate:
          - SUCCESS: checkIfAnySmax_jirasmaxid_list
          - FAILURE: on_failure
    - checkIfAnySmax_jirasmaxid_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_jirasmaxid_list}'
        navigate:
          - SUCCESS: checkAny_jira_smaxjiraid_list
          - FAILURE: attachmentsFromSMAXtoJIRA
    - checkAny_jira_smaxjiraid_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_smaxjiraid_list}'
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: attachmentsFromJIRAtoSMAX
    - attachmentsFromSMAXtoJIRA:
        do:
          Cerner.DFMP.Schedules.SMAX.Operations.attachmentsFromSMAXtoJIRA:
            - lastUpdate: '${last_run_time}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_authToken: '${smax_token}'
            - smax_jirasmaxid_list: '${smax_jirasmaxid_list}'
        publish:
          - result
          - message
          - errorType
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: checkAny_jira_smaxjiraid_list
          - FAILURE: on_failure
    - attachmentsFromJIRAtoSMAX:
        do:
          Cerner.DFMP.Schedules.JIRA.Operations.attachmentsFromJIRAtoSMAX:
            - lastUpdate: '${cst_date}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_authToken: '${smax_token}'
            - jira_smaxjiraid_list: '${jira_smaxjiraid_list}'
            - smax_request_id_list: ' '
            - previous_errorLogs: '${errorLogs}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: attachmentsDeletedFromJIRAtoSMAX
          - FAILURE: on_failure
    - LogErrors_to_ErrorLogTracker:
        do:
          Cerner.DFMP.Error_Framework.SubFlows.LogErrors_to_ErrorLogTracker:
            - error_logs: '${errorLogs}'
            - smax_auth_token: '${smax_token}'
            - is_retry: '${is_retry}'
            - error_log_id: '${error_log_id}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
    - checkAny_Error_logs:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${errorLogs}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: LogErrors_to_ErrorLogTracker
    - attachmentsDeletedFromJIRAtoSMAX:
        do:
          Cerner.DFMP.Schedules.JIRA.Operations.attachmentsDeletedFromJIRAtoSMAX:
            - lastUpdate: '${cst_date}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_authToken: '${smax_token}'
            - jira_smaxjiraid_list: '${jira_smaxjiraid_list}'
            - previous_errorLogs: '${errorLogs}'
        publish:
          - result
          - message
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - errorLogs: '${errorLogs}'
                - isRetry: '${is_retry}'
  outputs:
    - result
    - message
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      checkAny_Error_logs:
        x: 920
        'y': 240
        navigate:
          d98aad0c-cfc1-9fec-4aa9-3da5dde93512:
            targetId: 191eb07f-eab4-e1e4-21be-a502961602c7
            port: SUCCESS
      getUnixToCST_timestamp:
        x: 320
        'y': 480
      get_smaxSystemProperties_json_KeyValue:
        x: 320
        'y': 240
      LogErrors_to_ErrorLogTracker:
        x: 1160
        'y': 40
        navigate:
          11b841b3-18c6-4e49-68a3-42052150257e:
            targetId: 191eb07f-eab4-e1e4-21be-a502961602c7
            port: SUCCESS
      getOOLastruntime:
        x: 160
        'y': 480
      attachmentsDeletedFromJIRAtoSMAX:
        x: 920
        'y': 40
      checkAny_jira_smaxjiraid_list:
        x: 720
        'y': 240
      getJiraFileds_from_SMAXConfig_Json:
        x: 320
        'y': 40
      attachmentsFromJIRAtoSMAX:
        x: 720
        'y': 40
      attachmentsFromSMAXtoJIRA:
        x: 720
        'y': 480
      getSmaxAndJiraId:
        x: 520
        'y': 240
      check_smax_request_id_list:
        x: 160
        'y': 240
      checkIfAnySmax_jirasmaxid_list:
        x: 520
        'y': 480
      get_smaxBridgeOOID:
        x: 520
        'y': 40
      get_SMAXToken:
        x: 160
        'y': 40
    results:
      SUCCESS:
        191eb07f-eab4-e1e4-21be-a502961602c7:
          x: 1160
          'y': 240
