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
  name: Schedule_ErrorLogMonitor_and_Mailer
  inputs:
    - oo_run_name: Schedule_ErrorLogMonitor_and_Mailer
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
    - Send_email_notification:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.Send_email_notification:
            - error_message: 'Some Flows Failed to Complete, This is just a record for Information Purpose '
            - operator_email: '${operator_email}'
            - email_subject: Summary of Schedules Failed Transactions
            - operator_email_body: '${alert_body}'
        publish:
          - errorMessage: Error in Sending Mail
          - smax_data: ''
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator_Record
    - getOperator_email_fmConf:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.getOperator_email_fmConf: []
        publish:
          - operator_email
          - result
          - message
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: CreateAlertBodyErrorLogs
          - FAILURE: on_failure
    - IsFlowsListNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${data_json_ErrorLogs}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: getOperator_email_fmConf
    - SMAX_getEntityDetails_from_ErrorLogs:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: ErrorLogs_c
            - query_field: "${\"OperatorNotified_c,'No_c' and LastUpdateTime >=\" + last_run_time}"
            - entity_fields: 'Id,EmsCreationTime,ScheduleName_c,SMAXRequestId_c,JiraIssueId_c,ErrorProvider_c,ProviderUrl_c,ProviderUrlBody_c,ErrorMessage_c'
            - escape_double_quotes: 'Yes'
        publish:
          - result
          - ErrorLog_records: '${records}'
          - message
          - errorMessage
          - errorSeverity
          - errorType
          - data_json_ErrorLogs: "${cs_replace(entity_data_json,\"'\",\"\")}"
          - errorProvider
        navigate:
          - SUCCESS: IsFlowsListNull
          - FAILURE: on_failure
    - CreateAlertBodyErrorLogs:
        do:
          Cerner.DFMP.Schedulers.Error_Framework.Operations.CreateAlertBodyErrorLogs:
            - data_json: "${cs_replace(cs_replace(data_json_ErrorLogs,'\\n','\\\\n'),'\\.','\\\\\\.')}"
            - oneRunDone: '${oneRunDone}'
        publish:
          - alert_body
          - result
          - message
          - errorType
          - errorMessage
          - entity_ids
          - oneRunDone
        navigate:
          - SUCCESS: Send_email_notification
          - FAILURE: IsOneRunNotDone
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
    - SMAX_entityOperations_MultiRecords_UpdateMailSentStatus:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations_MultiRecords:
            - smax_auth_token: '${smax_token}'
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
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - list_iterator_Record:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${entity_ids}'
            - separator: ','
        publish:
          - result_string
          - return_result
          - return_code
          - data: '${result_string}'
        navigate:
          - HAS_MORE: Create_SMAX_Data
          - NO_MORE: SMAX_entityOperations_MultiRecords_UpdateMailSentStatus
          - FAILURE: on_failure
    - Create_SMAX_Data:
        do:
          io.cloudslang.base.utils.do_nothing:
            - data: '${data}'
            - smax_data: '${smax_data}'
        publish:
          - smax_data: "${smax_data + 'ErrorLogs_c,UPDATE,Id,'+ data + '||OperatorNotified,Yes_c |||'}"
        navigate:
          - SUCCESS: list_iterator_Record
          - FAILURE: on_failure
    - SMAX_getEntityDetails_from_ErrorLogs_1:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: ErrorLogs_c
            - query_field: "${\"OperatorNotified_c,'No_c' and LastUpdateTime >=\" + last_run_time}"
            - entity_fields: 'Id,EmsCreationTime,ScheduleName_c,SMAXRequestId_c,JiraIssueId_c,ErrorProvider_c,ProviderUrl_c,ProviderUrlBody_c'
            - escape_double_quotes: 'Yes'
        publish:
          - result
          - ErrorLog_records: '${records}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - data_json_ErrorLogs: "${cs_replace(entity_data_json,\"'\",\"\")}"
          - oneRunDone: 'Yes'
        navigate:
          - SUCCESS: CreateAlertBodyErrorLogs
          - FAILURE: on_failure
    - IsOneRunNotDone:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${oneRunDone}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_ErrorLogs_1
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
      list_iterator_Record:
        x: 1000
        'y': 480
      Send_email_notification:
        x: 760
        'y': 480
      IsOneRunNotDone:
        x: 640
        'y': 240
      SMAX_getEntityDetails_from_ErrorLogs:
        x: 200
        'y': 480
      getOOLastruntime:
        x: 40
        'y': 480
      If_lastupdate_isnull:
        x: 120
        'y': 240
      getOperator_email_fmConf:
        x: 360
        'y': 480
      CreateAlertBodyErrorLogs:
        x: 560
        'y': 480
      Create_SMAX_Data:
        x: 760
        'y': 280
      SMAX_getEntityDetails_from_ErrorLogs_1:
        x: 440
        'y': 240
      SMAX_entityOperations_MultiRecords_UpdateMailSentStatus:
        x: 1000
        'y': 80
        navigate:
          1e6d198f-05ff-a312-aac6-fd4c5770b37d:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      get_SMAXToken:
        x: 120
        'y': 80
    results:
      SUCCESS:
        daadecb6-94a2-4eb7-986e-aeae2a6542e8:
          x: 760
          'y': 80
