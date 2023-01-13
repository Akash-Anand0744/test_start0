########################################################################################################################
#!!
#! @result SUCCESS: result=="True"
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.SMAX.Schedules
flow:
  name: Schedule_Comments_Syn_SMAXnJIRA
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
          - token
          - errorMessage
          - message
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: check_smax_request_id_list
          - FAILURE: on_failure
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - oo_run_name: Schedule_Comments_Syn_SMAXnJIRA
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
        navigate:
          - SUCCESS: get_smaxSystemProperties_json_KeyValue
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
          - SUCCESS: get_smaxBridgeOOID
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
    - checkIfAnySmax_jirasmaxid_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_jirasmaxid_list}'
        navigate:
          - SUCCESS: checkAny_jira_smaxjiraid_list
          - FAILURE: commentsFromSMAXToJira
    - commentsFromSMAXToJira:
        do:
          Cerner.DFMP.Schedules.SMAX.Operations.commentsFromSMAXToJira:
            - smax_Token: '${token}'
            - smax_jirasmaxid_list: '${smax_jirasmaxid_list}'
            - lastUpdate: '${last_run_time}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
          - provider_failure
        navigate:
          - SUCCESS: checkAny_jira_smaxjiraid_list
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
            - smax_Token: '${token}'
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
          - errorLogs
          - provider_failure
        navigate:
          - SUCCESS: checkIfAnySmax_jirasmaxid_list
          - FAILURE: on_failure
    - checkAny_jira_smaxjiraid_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_smaxjiraid_list}'
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: commentsUpdateFromJiraToSMAX
    - LogErrors_to_ErrorLogTracker:
        do:
          Cerner.DFMP.Error_Framework.SubFlows.LogErrors_to_ErrorLogTracker:
            - error_logs: '${errorLogs}'
            - smax_auth_token: '${token}'
            - is_retry: '${is_retry}'
            - error_log_id: '${error_log_id}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
    - commentsUpdateFromJiraToSMAX:
        do:
          Cerner.DFMP.Schedules.JIRA.Operations.commentsUpdateFromJiraToSMAX:
            - lastUpdate: '${cst_date}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_Bridge_ID: '${smaxBridgeOOID}'
            - domainName: cerner.net
            - smax_Token: '${token}'
            - smax_request_id_list: '${smax_request_id_list}'
            - jira_smaxjiraid_list: '${jira_smaxjiraid_list}'
            - previous_errorLogs: '${errorLogs}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
          - provider_failure
        navigate:
          - SUCCESS: deleteCommentsInMarketplace
          - FAILURE: on_failure
    - deleteCommentsInMarketplace:
        do:
          Cerner.DFMP.Schedules.JIRA.Operations.deleteCommentsInMarketplace:
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_Bridge_ID: '${smaxBridgeOOID}'
            - smax_Token: '${token}'
            - domainName: cerner.net
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
          - provider_failure
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: on_failure
    - checkAny_Error_logs:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${errorLogs}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: LogErrors_to_ErrorLogTracker
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
        x: 760
        'y': 120
        navigate:
          0326e379-0fd6-e927-58f9-57fef2474b77:
            targetId: 3a81416c-195c-aea9-eb25-480ab50795ff
            port: SUCCESS
      commentsUpdateFromJiraToSMAX:
        x: 600
        'y': 400
      getUnixToCST_timestamp:
        x: 280
        'y': 40
      get_smaxSystemProperties_json_KeyValue:
        x: 280
        'y': 240
      deleteCommentsInMarketplace:
        x: 760
        'y': 400
      LogErrors_to_ErrorLogTracker:
        x: 920
        'y': 120
        navigate:
          1e5ab905-4f97-13c0-dbd6-f6725c8650df:
            targetId: 3a81416c-195c-aea9-eb25-480ab50795ff
            port: SUCCESS
      getOOLastruntime:
        x: 120
        'y': 40
      checkAny_jira_smaxjiraid_list:
        x: 600
        'y': 240
      getJiraFileds_from_SMAXConfig_Json:
        x: 280
        'y': 440
      commentsFromSMAXToJira:
        x: 600
        'y': 40
      getSmaxAndJiraId:
        x: 400
        'y': 240
      check_smax_request_id_list:
        x: 120
        'y': 240
      checkIfAnySmax_jirasmaxid_list:
        x: 400
        'y': 40
      get_smaxBridgeOOID:
        x: 400
        'y': 440
      get_SMAXToken:
        x: 120
        'y': 440
    results:
      SUCCESS:
        3a81416c-195c-aea9-eb25-480ab50795ff:
          x: 920
          'y': 400
