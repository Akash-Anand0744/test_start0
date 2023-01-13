namespace: Cerner.ErrorHandling.actions
flow:
  name: MainErrorHandler
  inputs:
    - errorType:
        required: false
    - errorMessage:
        required: false
    - errorSeverity:
        default: ERROR
        required: false
    - conf: "${get_sp('Cerner.ErrorHandling.config')}"
  workflow:
    - checkInput:
        do:
          Cerner.ErrorHandling.operations.checkInput:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
            - conf: '${conf}'
        navigate:
          - SUCCESS: decodeConfig
          - FAILURE: SUCCESS
    - decodeConfig:
        do:
          Cerner.ErrorHandling.operations.decodeConfig:
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
          Cerner.ErrorHandling.subflows.executeAllHandlers:
            - errorHandlersActions: '${errorHandlers}'
            - errorNumber: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: executeFailSafe
    - executeFailSafe:
        do:
          Cerner.ErrorHandling.subflows.executeAllHandlers:
            - errorHandlersActions: '${failSafe}'
            - errorNumber: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      checkInput:
        x: 121
        'y': 78
        navigate:
          66aa6c8d-1f97-3170-96a6-84d1cf2f1a25:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: FAILURE
      executeAllHandlers:
        x: 504
        'y': 171
        navigate:
          3d9cfdb6-5e79-c098-220e-7b98c0086967:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: SUCCESS
      executeFailSafe:
        x: 505
        'y': 308
        navigate:
          39f6c2ae-cdd6-06eb-d281-5074107385cd:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: SUCCESS
          4791b2d1-6077-e731-488f-dc063b4544fd:
            targetId: bf6dadae-3bd5-9f61-51a3-92888df0871a
            port: FAILURE
      decodeConfig:
        x: 282
        'y': 172
    results:
      SUCCESS:
        bf6dadae-3bd5-9f61-51a3-92888df0871a:
          x: 809
          'y': 78
