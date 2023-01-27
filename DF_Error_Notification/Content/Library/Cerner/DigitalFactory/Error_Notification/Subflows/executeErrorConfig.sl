namespace: Cerner.DigitalFactory.Error_Notification.Subflows
flow:
  name: executeErrorConfig
  inputs:
    - actionName
    - actionParams:
        default: ''
        required: false
    - errorNumber
    - errorMessage
    - errorSeverity
    - errorProvider
    - smaxRequestNumber:
        default: ''
        required: false
    - smaxRequestSummary:
        default: ''
        required: false
    - smaxRequestorEmail:
        default: ''
        required: false
    - no_operator_mail:
        required: false
  workflow:
    - errorActionSwitch:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.errorActionSwitch:
            - actionName: '${actionName}'
            - actionParams: '${actionParams}'
        publish:
          - param1
          - param2
          - param3
          - param4
          - param5
          - param6
          - param7
          - param8
          - param9
        navigate:
          - LOGGER: Error_logger_Handler
          - EMAILER: Send_email_notification
          - INCIDENT: incident
          - MONITOR: monitor
          - SMAX_ERROR: updateErrorDetailToSMAX
          - FAILURE: on_failure
    - monitor:
        do:
          io.cloudslang.base.utils.do_nothing: []
        navigate:
          - SUCCESS: do_nothing
          - FAILURE: on_failure
    - incident:
        do:
          io.cloudslang.base.utils.do_nothing: []
        navigate:
          - SUCCESS: do_nothing
          - FAILURE: on_failure
    - do_nothing:
        do:
          io.cloudslang.base.utils.do_nothing: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - Error_logger_Handler:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.Error_logger_Handler:
            - error_code: '${errorNumber}'
            - error_message: '${errorMessage}'
            - error_provider: '${errorProvider}'
            - error_log_file: '${param2}'
            - error_level: '${errorSeverity}'
            - error_log_file_folder: '${param3}'
            - base_log_folder: '${param4}'
        navigate:
          - validation_Issue: FAILURE
          - SUCCESS: do_nothing
          - FAILURE: on_failure
    - Send_email_notification:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.Send_email_notification:
            - error_code: '${errorNumber}'
            - error_level: '${errorSeverity}'
            - error_message: '${errorMessage}'
            - error_provider: '${errorProvider}'
            - requestor_email: '${smaxRequestorEmail}'
            - operator_email: '${param1}'
            - email_subject: '${param2}'
            - operator_email_body: '${param3}'
            - requestor_email_body: '${param4}'
            - signature: '${param5}'
            - smax_request_number: '${smaxRequestNumber}'
            - smax_request_summary: '${smaxRequestSummary}'
            - inform_user: '${param6}'
            - no_operator_mail: '${no_operator_mail}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: do_nothing
    - updateErrorDetailToSMAX:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.updateErrorDetailToSMAX:
            - OOErrorDetails: '${errorMessage}'
            - OOErrorSummary: '${smaxRequestSummary}'
            - smaxRequestID: '${smaxRequestNumber}'
        publish:
          - param6: 'yes'
        navigate:
          - SOFT_FAILURE: FAILURE
          - FAILURE: on_failure
          - SUCCESS: do_nothing
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      errorActionSwitch:
        x: 120
        'y': 249
      monitor:
        x: 495
        'y': 388
      incident:
        x: 493
        'y': 522
      do_nothing:
        x: 767
        'y': 208
        navigate:
          30afd370-dde1-57ab-5762-210cfeedc47e:
            targetId: 29b7b4fb-635d-3f4e-3ac9-384792212792
            port: SUCCESS
      Error_logger_Handler:
        x: 497
        'y': 657
        navigate:
          46409cc0-864d-173e-07a1-80d296116f95:
            targetId: 97b27a81-6aff-6264-9c8b-33d5d36e766d
            port: validation_Issue
      Send_email_notification:
        x: 492
        'y': 81
      updateErrorDetailToSMAX:
        x: 489
        'y': 253
        navigate:
          7b17826a-8691-6a5b-15c8-ac9b67fcbdef:
            targetId: 97b27a81-6aff-6264-9c8b-33d5d36e766d
            port: SOFT_FAILURE
    results:
      FAILURE:
        97b27a81-6aff-6264-9c8b-33d5d36e766d:
          x: 868
          'y': 494
      SUCCESS:
        29b7b4fb-635d-3f4e-3ac9-384792212792:
          x: 1000
          'y': 203
