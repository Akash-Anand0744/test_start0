########################################################################################################################
#!!
#! @description: error_logs --  Entire error log information in below format: (field separator is double pipe '||' and Record Separator is tripple pipe '|||' as below:
#!                
#!                
#!               SMAXRequestId,1234||JiraIssueId,345477||ProviderUrl,https://test/ersd||ErrorProvider,SMAX||ProviderUrlBody,Error body content||ErrorMessage,Errror message received from the Provider
#!               |||
#!               SMAXRequestId,12545||JiraIssueId,1345477||ProviderUrl,https://test2/ersd||ErrorProvider,SMAX||ProviderUrlBody,Error body occurred content||ErrorMessage,Errror Severe message received from the Provider
#!
#! @input error_logs: error log details in field separator is double pipe '||' and Record Separator is tripple pipe '|||'s, details in the Description
#! @input is_retry: Is this action a Re-try of Failed Transaction
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Error_Framework.SubFlows
flow:
  name: LogErrors_to_ErrorLogTracker
  inputs:
    - error_logs
    - smax_auth_token
    - is_retry:
        required: false
    - error_log_id:
        required: false
  workflow:
    - error_log_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${error_logs}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - smax_data: ''
          - entity_data: 'ErrorLogs_c,CREATE,'
        navigate:
          - SUCCESS: set_message
          - FAILURE: is_not_retry
    - list_iterator_Record:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${error_logs}'
            - separator: '|||'
        publish:
          - result_string
          - return_result
          - return_code
          - data: '${result_string}'
        navigate:
          - HAS_MORE: data_isnull
          - NO_MORE: SMAX_entityOperations_MultiRecords
          - FAILURE: on_failure
    - SMAX_entityOperations_MultiRecords:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations_MultiRecords:
            - smax_auth_token: '${smax_auth_token}'
            - smax_data: '${smax_data}'
        publish:
          - result
          - message
          - entity_id
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: is_retry
          - FAILURE: on_failure
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: No Error Logs to Process
        navigate:
          - SUCCESS: is_retry
          - FAILURE: on_failure
    - Create_SMAX_Data:
        do:
          io.cloudslang.base.utils.do_nothing:
            - data: '${data}'
            - smax_data: '${smax_data}'
            - entity_data: '${entity_data}'
            - schedule_name: '${schedule_name}'
            - flow_run_id: '${run_id}'
        publish:
          - smax_data: "${smax_data + entity_data + data + '||OperatorNotified,No_c||RequiredAction,New_c||DisplayLabel,' + schedule_name + '||ScheduleName,' + schedule_name + '||OORunId,'+ flow_run_id + '|||'}"
        navigate:
          - SUCCESS: list_iterator_Record
          - FAILURE: on_failure
    - data_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${data}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator_Record
          - FAILURE: formatErrorMessage
    - get_flow_details_flow_run_name:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.get_flow_details:
            - flow_run_id: '${run_id}'
        publish:
          - run_json
          - start_time
          - run_status
          - result_status_type
          - raw_run_name: "${cs_json_query(run_json,'$.[0].executionName')}"
          - schedule_name: "${raw_run_name.strip('[\"').strip('\"]')}"
          - oo_central_url: "${'%s' % (get_sp('io.cloudslang.microfocus.oo.central_url'))}"
          - flow_run_id
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator_Record
    - is_not_retry:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${is_retry}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: get_flow_details_flow_run_name
          - FAILURE: set_entity_update
    - set_entity_update:
        do:
          io.cloudslang.base.utils.do_nothing:
            - error_log_id: '${error_log_id}'
        publish:
          - entity_data: "${'ErrorLogs_c,UPDATE, Id,'+ error_log_id + '||'}"
        navigate:
          - SUCCESS: get_flow_details_flow_run_name
          - FAILURE: on_failure
    - is_retry:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${is_retry}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - formatErrorMessage:
        do:
          Cerner.DFMP.Error_Framework.Operations.formatErrorMessage:
            - input_data: '${data}'
        publish:
          - result
          - data
          - message
          - errorType
        navigate:
          - SUCCESS: Create_SMAX_Data
          - FAILURE: on_failure
  outputs:
    - message: '${message}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvder}'
    - errorSeverity: '${errorSeverity}'
    - errorType: '${errorType}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      list_iterator_Record:
        x: 440
        'y': 520
      error_log_isnull:
        x: 80
        'y': 80
      data_isnull:
        x: 720
        'y': 440
      is_not_retry:
        x: 80
        'y': 280
      set_entity_update:
        x: 240
        'y': 280
      set_message:
        x: 440
        'y': 80
      SMAX_entityOperations_MultiRecords:
        x: 920
        'y': 520
      get_flow_details_flow_run_name:
        x: 80
        'y': 520
      is_retry:
        x: 920
        'y': 80
        navigate:
          fe383bad-5b47-9203-6a8a-08163045279c:
            targetId: 93f34aad-86aa-0e0f-012f-9921e9896d7d
            port: SUCCESS
      Create_SMAX_Data:
        x: 440
        'y': 280
      formatErrorMessage:
        x: 720
        'y': 280
    results:
      SUCCESS:
        93f34aad-86aa-0e0f-012f-9921e9896d7d:
          x: 1120
          'y': 80
