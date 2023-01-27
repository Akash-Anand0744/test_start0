namespace: Cerner.ErrorHandling.subflows
flow:
  name: executeAllHandlers
  inputs:
    - errorHandlersActions
    - errorNumber
    - errorMessage
    - errorSeverity: DEBUG
  workflow:
    - init:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input_0: '0'
        publish:
          - handlerIndex: '${input_0}'
        navigate:
          - SUCCESS: errorActionLoop
          - FAILURE: on_failure
    - errorActionLoop:
        do:
          Cerner.ErrorHandling.operations.errorActionLoop:
            - actionsString: '${errorHandlersActions}'
            - index: '${handlerIndex}'
        publish:
          - handlerIndex: '${nextIndex}'
          - actionParams
          - actionName
        navigate:
          - SUCCESS: executeErrorConfig
          - NOMORE: SUCCESS
          - FAILURE: on_failure
    - executeErrorConfig:
        do:
          Cerner.ErrorHandling.subflows.executeErrorConfig:
            - actionName: '${actionName}'
            - actionParams: '${actionParams}'
            - errorNumber: '${errorNumber}'
            - errorMessage: '${errorMessage}'
            - errorSeverity: '${errorSeverity}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: errorActionLoop
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      init:
        x: 130
        'y': 107
      errorActionLoop:
        x: 333
        'y': 99
        navigate:
          15a5a3ca-d8f1-24c5-771d-36788929bd1a:
            targetId: f2e488a5-d91a-ea95-b5d3-1a079c5df4b7
            port: NOMORE
      executeErrorConfig:
        x: 332
        'y': 336
    results:
      SUCCESS:
        f2e488a5-d91a-ea95-b5d3-1a079c5df4b7:
          x: 650
          'y': 104
