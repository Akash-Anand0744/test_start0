########################################################################################################################
#!!
#! @description: This schedule will get the last run time from run name provided and then will list all the runs with the status provided  and then send that list to the Operator Email
#!
#! @input oo_run_name: Run Name to get the last run time
#! @input last_update: Keep this field as null and provide value only when testing in 13 digit Millisecond format like : 1657542116928 it is for 2022-07-11 07:21:56 CDT-0500
#! @input task_status: Status of the Task to Monitor. for example, Running, Failed,, Canceled
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.MarketPlace.SMAX.Schedule
flow:
  name: Schedule_TaskRunningStatus_Monitor
  inputs:
    - oo_run_name: Schedule_TaskRunningStatus_Monitor
    - last_update:
        required: false
    - task_status: InProgress
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
          - SUCCESS: SMAX_getEntityDetails_from_Tasks
          - FAILURE: on_failure
    - Send_email_notification:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.Send_email_notification:
            - error_message: 'Some Flows Failed to Complete, This is just a record for Information Purpose '
            - operator_email: '${operator_email}'
            - email_subject: SMAX Tasks in Running Status For Long time
            - operator_email_body: '${alert_body}'
        publish:
          - errorMessage: Error in Sending Mail
          - smax_data: ''
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
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
          - SUCCESS: CreateAlertBodyTasks
          - FAILURE: on_failure
    - IsFlowsListNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${data_json_tasks}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: getOperator_email_fmConf
    - SMAX_getEntityDetails_from_Tasks:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: Task
            - query_field: "${\"PhaseId,'\" + task_status + \"' and EmsCreationTime <\" + last_run_time}"
            - entity_fields: 'Id,EmsCreationTime,ParentEntityId,ParentDisplayLabelKey,PhaseId,LastUpdateTime'
            - escape_double_quotes: 'Yes'
        publish:
          - result
          - ErrorLog_records: '${records}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - data_json_tasks: '${entity_data_json}'
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
          - FAILURE: SMAX_getEntityDetails_from_Tasks
    - CreateAlertBodyTasks:
        do:
          Cerner.DigitalFactory.MarketPlace.SMAX.Operation.CreateAlertBodyTasks:
            - data_json: '${data_json_tasks}'
        publish:
          - alert_body
          - result
          - message
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: Send_email_notification
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
      get_SMAXToken:
        x: 120
        'y': 80
      getOOLastruntime:
        x: 40
        'y': 480
      Send_email_notification:
        x: 760
        'y': 480
        navigate:
          cb39b4c6-ea30-b08a-2ed9-60c38f416d43:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      getOperator_email_fmConf:
        x: 360
        'y': 480
      IsFlowsListNull:
        x: 360
        'y': 80
        navigate:
          37979296-ddf6-b64c-09a8-a1e59cdf7fa0:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      SMAX_getEntityDetails_from_Tasks:
        x: 200
        'y': 480
      If_lastupdate_isnull:
        x: 120
        'y': 240
      CreateAlertBodyTasks:
        x: 600
        'y': 480
    results:
      SUCCESS:
        daadecb6-94a2-4eb7-986e-aeae2a6542e8:
          x: 760
          'y': 80
