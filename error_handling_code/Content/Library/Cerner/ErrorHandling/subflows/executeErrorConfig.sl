namespace: Cerner.ErrorHandling.subflows
flow:
  name: executeErrorConfig
  inputs:
    - actionName
    - actionParams
    - errorNumber
    - errorMessage
    - errorSeverity
  workflow:
    - errorActionSwitch:
        do:
          Cerner.ErrorHandling.operations.errorActionSwitch:
            - actionName: '${actionName}'
            - actionParams: '${actionParams}'
        publish:
          - param1
          - param2
          - param3
          - param4
          - param5
        navigate:
          - LOGGER: logger
          - EMAILER: emailer
          - INCIDENT: incident
          - MONITOR: monitor
          - FAILURE: on_failure
    - emailer:
        do:
          io.cloudslang.base.utils.do_nothing: []
        navigate:
          - SUCCESS: do_nothing
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
    - logger:
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
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      errorActionSwitch:
        x: 119
        'y': 250
      emailer:
        x: 467
        'y': 53
      monitor:
        x: 463
        'y': 221
      incident:
        x: 474
        'y': 420
      logger:
        x: 479
        'y': 556
      do_nothing:
        x: 767
        'y': 208
        navigate:
          30afd370-dde1-57ab-5762-210cfeedc47e:
            targetId: 29b7b4fb-635d-3f4e-3ac9-384792212792
            port: SUCCESS
    results:
      SUCCESS:
        29b7b4fb-635d-3f4e-3ac9-384792212792:
          x: 1000
          'y': 203
