########################################################################################################################
#!!
#! @description: This schedule will get the last run time from run name provided and then will list all the runs with the status provided  and then send that list to the Operator Email
#!
#! @input oo_run_name: Run Name to get the last run time
#! @input last_update: Keep this field as null and provide value only when testing in 13 digit Millisecond format like : 1657542116928 it is for 2022-07-11 07:21:56 CDT-0500
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedulers.Error_Framework.Schedules
flow:
  name: Schedule_ReProcess_SMAXFailed_Requests
  inputs:
    - oo_run_name: Schedule_ReProcess_SMAXFailed_Requests
    - last_update:
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
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: If_lastupdate_isnull
          - FAILURE: on_failure
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - central_url: "${get_sp('io.cloudslang.microfocus.oo.central_url')}"
            - oo_username: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
            - oo_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
            - oo_run_name: '${oo_run_name}'
        publish:
          - last_run_time
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - central_url
          - oo_username
          - oo_password
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_ErrorLogs
          - FAILURE: on_failure
    - IsFlowsListNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${data_json_ErrorLogs}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - data_json: "${first_string[1:-1] + ','}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: list_iterator_Record
    - SMAX_getEntityDetails_from_ErrorLogs:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: ErrorLogs_c
            - query_field: "${\"RequiredAction_c,'ReTry_c' and LastUpdateTime >=\" + last_run_time}"
            - entity_fields: 'Id,EmsCreationTime,ScheduleName_c,SMAXRequestId_c,JiraIssueId_c,ErrorProvider_c,ProviderUrl_c'
            - escape_double_quotes: 'Yes'
        publish:
          - result
          - ErrorLog_records: '${records}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - data_json_ErrorLogs: "${cs_replace(entity_data_json,'\\n','\\\\n')}"
        navigate:
          - SUCCESS: IsFlowsListNull
          - FAILURE: on_failure
    - If_lastupdate_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${last_update}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - lastUpdate: '${first_string}'
          - last_run_time: '${first_string}'
        navigate:
          - SUCCESS: getOOLastruntime
          - FAILURE: SMAX_getEntityDetails_from_ErrorLogs
    - list_iterator_Record:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${data_json}'
            - separator: '},'
        publish:
          - result_string
          - return_result
          - return_code
          - data: "${result_string + '}'}"
          - smax_request_id: ''
          - entity_id: ''
        navigate:
          - HAS_MORE: get_entity_id
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - get_entity_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data}'
            - json_path: Id
        publish:
          - entity_id: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_smax_request_id
          - FAILURE: on_failure
    - get_smax_request_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data}'
            - json_path: SMAXRequestId_c
        publish:
          - smax_request_id: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: IsSMAXRquestId_Null
          - FAILURE: IsSMAXRquestId_Null
    - get_schedule_name:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data}'
            - json_path: ScheduleName_c
        publish:
          - schedule_name: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_schedule_FlowUUID
          - FAILURE: on_failure
    - execute_OOFlow_by_FlowUUID:
        do:
          Cerner.DigitalFactory.Common.OO.Operation.execute_OOFlow_by_FlowUUID:
            - flow_uuid: '${schedule_flow_uuid}'
            - flow_inputs: "${'is_retry,Yes||smax_request_id_list,' + smax_request_id + '||error_log_id,' + entity_id}"
        publish:
          - flow_execution_id
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - SUCCESS: getOOFlowExecutionStatus_by_ExecutionId
          - FAILURE: on_failure
    - getOOFlowExecutionStatus_by_ExecutionId:
        do:
          Cerner.DigitalFactory.Common.OO.Operation.getOOFlowExecutionStatus_by_ExecutionId:
            - execution_id: '${flow_execution_id}'
        publish:
          - flow_execution_status
          - result
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - SUCCESS: IsFlow_Execution_Success
          - FAILURE: on_failure
    - SMAXBody_Update_ErrorLog_Success:
        do:
          io.cloudslang.base.utils.do_nothing:
            - entity_id: '${entity_id}'
        publish:
          - smax_data: "${'Id,' + entity_id + '||RequiredAction_c,RetrySuccess_c'}"
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateReProcessStatus
          - FAILURE: on_failure
    - SMAX_entityOperations_UpdateReProcessStatus:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: ErrorLogs_c
            - operation: UPDATE
            - smax_data: '${smax_data}'
            - is_custom_app: 'Yes'
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: list_iterator_Record
          - FAILURE: on_failure
    - get_schedule_FlowUUID:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('Cerner.DFMP.FlowUUID_mapping')}"
            - json_path: '${schedule_name}'
        publish:
          - schedule_flow_uuid: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: execute_OOFlow_by_FlowUUID
          - FAILURE: on_failure
    - IsSMAXRquestId_Null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_id}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator_Record
          - FAILURE: get_schedule_name
    - IsFlow_Execution_Success:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${flow_execution_status}'
            - second_string: SUCCESS
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SMAXBody_Update_ErrorLog_Success
          - FAILURE: SMAXBody_Update_ErrorLog_Failed
    - SMAXBody_Update_ErrorLog_Failed:
        do:
          io.cloudslang.base.utils.do_nothing:
            - entity_id: '${entity_id}'
        publish:
          - smax_data: "${'Id,' + entity_id + '||RequiredAction_c,ReTryFailed_c||OperatorNotified,No_c'}"
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateReProcessStatus
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      IsFlowsListNull:
        x: 360
        'y': 80
        navigate:
          37979296-ddf6-b64c-09a8-a1e59cdf7fa0:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      IsSMAXRquestId_Null:
        x: 640
        'y': 360
      list_iterator_Record:
        x: 360
        'y': 360
        navigate:
          9c17fc84-e43e-49d0-7a04-9310272b48b6:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: NO_MORE
      SMAX_entityOperations_UpdateReProcessStatus:
        x: 1000
        'y': 80
      getOOFlowExecutionStatus_by_ExecutionId:
        x: 1160
        'y': 440
      get_schedule_FlowUUID:
        x: 1000
        'y': 600
      SMAXBody_Update_ErrorLog_Success:
        x: 880
        'y': 240
      get_schedule_name:
        x: 800
        'y': 600
      execute_OOFlow_by_FlowUUID:
        x: 1160
        'y': 600
      SMAX_getEntityDetails_from_ErrorLogs:
        x: 200
        'y': 480
      getOOLastruntime:
        x: 40
        'y': 480
      get_entity_id:
        x: 360
        'y': 600
      If_lastupdate_isnull:
        x: 120
        'y': 240
      get_smax_request_id:
        x: 640
        'y': 600
      IsFlow_Execution_Success:
        x: 960
        'y': 440
      SMAXBody_Update_ErrorLog_Failed:
        x: 1120
        'y': 240
      get_SMAXToken:
        x: 120
        'y': 80
    results:
      SUCCESS:
        daadecb6-94a2-4eb7-986e-aeae2a6542e8:
          x: 640
          'y': 80
