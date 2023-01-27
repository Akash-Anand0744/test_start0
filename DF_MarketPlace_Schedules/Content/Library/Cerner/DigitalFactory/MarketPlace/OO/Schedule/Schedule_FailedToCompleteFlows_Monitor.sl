########################################################################################################################
#!!
#! @description: This schedule will get the last run time from run name provided and then will list all the runs with the status provided  and then send that list to the Operator Email
#!
#! @input oo_flow_status: SYSTEM_FAILURE -- for failed to Complete
#! @input oo_run_name: Run Name to get the last run time
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.MarketPlace.OO.Schedule
flow:
  name: Schedule_FailedToCompleteFlows_Monitor
  inputs:
    - oo_flow_status
    - oo_run_name
  workflow:
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - central_url: "${get_sp('io.cloudslang.microfocus.oo.central_url')}"
            - oo_username: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
            - oo_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
            - oo_run_name: '${oo_run_name}'
            - oo_flow_status: COMPLETED
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
          - SUCCESS: getOOListOfFlows
          - FAILURE: on_failure
    - getOOListOfFlows:
        do:
          Cerner.DigitalFactory.Common.OO.getOOListOfFlows:
            - central_url: '${central_url}'
            - oo_username: '${oo_username}'
            - oo_password: '${oo_password}'
            - oo_flow_status: '${oo_flow_status}'
            - from_time: '${last_run_time}'
        publish:
          - executions_list
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
        navigate:
          - SUCCESS: IsFlowsListNull
          - FAILURE: on_failure
    - Send_email_notification:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.Send_email_notification:
            - error_message: 'Some Flows Failed to Complete, This is just a record for Information Purpose '
            - operator_email: '${operator_email}'
            - email_subject: Summary of OO Flows Failed to Complete
            - operator_email_body: '${alert_body}'
        publish:
          - errorMessage: Error in Sending Mail
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
          - SUCCESS: CreateAlertBody
          - FAILURE: on_failure
    - IsFlowsListNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${executions_list}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: getOperator_email_fmConf
    - CreateAlertBody:
        do:
          Cerner.DigitalFactory.MarketPlace.OO.Operation.CreateAlertBody:
            - central_url: '${central_url}'
            - flows_list_json: '${executions_list}'
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
      getOOLastruntime:
        x: 74
        'y': 108
      getOOListOfFlows:
        x: 74
        'y': 319
      Send_email_notification:
        x: 559
        'y': 314
        navigate:
          d7c6a2d5-a58f-8d24-6bbe-0fd0063b439a:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      getOperator_email_fmConf:
        x: 262
        'y': 317
      IsFlowsListNull:
        x: 262
        'y': 118
        navigate:
          37979296-ddf6-b64c-09a8-a1e59cdf7fa0:
            targetId: daadecb6-94a2-4eb7-986e-aeae2a6542e8
            port: SUCCESS
      CreateAlertBody:
        x: 417
        'y': 452
    results:
      SUCCESS:
        daadecb6-94a2-4eb7-986e-aeae2a6542e8:
          x: 557
          'y': 116
