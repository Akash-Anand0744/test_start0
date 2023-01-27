########################################################################################################################
#!!
#! @input errorType: error number
#! @input errorMessage: message to be logged
#! @input errorProvider: provider that has raised exception
#! @input errorSeverity: error severity
#! @input conf: configuration of error handlers
#! @input smaxRequestNumber: smax request number if needed
#! @input smaxRequestSummary: Unable to load description
#! @input smaxRequestorEmail: smax requestor email if needed
#! @input errorLogs: Error Logs Records for updating in SMAX Error Logs Tracker
#! @input isRetry: If flow is ReTry then Error Handling will not run.
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Actions
flow:
  name: MainErrorHandler
  inputs:
    - errorType:
        required: false
    - errorMessage:
        required: false
    - errorProvider:
        default: OO_FLOW
        required: false
    - errorSeverity:
        default: ERROR
        required: false
    - conf: "${get_sp('Cerner.DigitalFactory.Error_Notification.config')}"
    - smaxRequestNumber:
        default: ''
        required: false
    - smaxRequestSummary:
        default: ''
        required: false
    - smaxRequestorEmail:
        default: ''
        required: false
    - errorLogs:
        required: false
    - isRetry:
        required: false
  workflow:
    - is_not_retry:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${isRetry}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: checkInput
          - FAILURE: SUCCESS
    - checkInput:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.checkInput:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
            - conf: '${conf}'
        publish:
          - errorMessage: '${errorMessageOut}'
          - errorType: '${errorTypeOut}'
        navigate:
          - SUCCESS: ErrorLogs_IsNull
          - FAILURE: SUCCESS
    - decodeConfig:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.decodeConfig:
            - confString: '${conf}'
            - errorType: '${errorType}'
        publish:
          - errorHandlers
          - failSafe
        navigate:
          - SUCCESS: executeAllHandlers
          - FAILURE: on_failure
    - executeAllHandlers:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.executeAllHandlers:
            - errorHandlersActions: '${errorHandlers}'
            - errorNumber: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
            - errorProvider: '${errorProvider}'
            - smaxRequestNumber: '${smaxRequestNumber}'
            - smaxRequestorEmail: '${smaxRequestorEmail}'
            - smaxRequestSummary: '${smaxRequestSummary}'
            - no_operator_mail: '${no_operator_mail}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: executeFailSafe
    - executeFailSafe:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.executeAllHandlers:
            - errorHandlersActions: "${cs_replace(failSafe, '{\"name\": \"informUser\", \"data\": \"yes\"}', '{\"name\": \"informUser\", \"data\": \"\"}',1)}"
            - errorNumber: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
            - errorProvider: '${errorProvider}'
            - smaxRequestNumber: '${smaxRequestNumber}'
            - smaxRequestorEmail: '${smaxRequestorEmail}'
            - smaxRequestSummary: '${smaxRequestSummary}'
            - no_operator_mail: '${no_operator_mail}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: SUCCESS
    - ErrorLogs_IsNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${errorLogs}'
        publish: []
        navigate:
          - SUCCESS: decodeConfig
          - FAILURE: get_SMAXToken
    - LogErrors_to_ErrorLogTracker:
        do:
          Cerner.DFMP.Error_Framework.SubFlows.LogErrors_to_ErrorLogTracker:
            - error_logs: '${errorLogs}'
            - smax_auth_token: '${smax_token}'
        publish:
          - message
          - errorMessage1: '${errorMessage}'
          - errorProvider1: '${errorProvider}'
          - errorSeverity1: '${errorSeverity}'
          - errorType1: '${errorType}'
          - no_operator_mail: 'Yes'
        navigate:
          - FAILURE: Inform_Operator
          - SUCCESS: decodeConfig
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - smax_token: '${token}'
          - message
          - errorMessage1: '${errorMessage}'
          - errorSeverity1: '${errorSeverity}'
          - errorProvider1: '${errorProvider}'
          - errorType1: '${errorType}'
        navigate:
          - SUCCESS: LogErrors_to_ErrorLogTracker
          - FAILURE: decodeConfig
    - Inform_Operator:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - no_operator_mail: ''
        navigate:
          - SUCCESS: decodeConfig
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      executeFailSafe:
        x: 1000
        'y': 560
        navigate:
          39f6c2ae-cdd6-06eb-d281-5074107385cd:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: SUCCESS
          4791b2d1-6077-e731-488f-dc063b4544fd:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: FAILURE
      checkInput:
        x: 160
        'y': 160
        navigate:
          e6f65a5d-1068-0a1b-1a82-be3f2d73d5d1:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: FAILURE
      is_not_retry:
        x: 560
        'y': 40
        navigate:
          fa3379f3-fb34-e096-9cdb-e2f4c4bcf952:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: FAILURE
      LogErrors_to_ErrorLogTracker:
        x: 560
        'y': 480
      decodeConfig:
        x: 560
        'y': 320
      executeAllHandlers:
        x: 880
        'y': 320
        navigate:
          3d9cfdb6-5e79-c098-220e-7b98c0086967:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: SUCCESS
      ErrorLogs_IsNull:
        x: 160
        'y': 320
      Inform_Operator:
        x: 720
        'y': 400
      get_SMAXToken:
        x: 160
        'y': 480
    results:
      SUCCESS:
        bf6dadae-3bd5-9f61-51a3-92888df0871a:
          x: 1000
          'y': 160
