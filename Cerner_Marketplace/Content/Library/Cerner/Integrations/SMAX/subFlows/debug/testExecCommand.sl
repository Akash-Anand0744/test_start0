namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testExecCommand
  workflow:
    - run_command:
        do:
          io.cloudslang.base.cmd.run_command:
            - command: df -h
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      run_command:
        x: 157
        'y': 98.421875
        navigate:
          194882ea-ad30-56ae-810e-db45b55283f2:
            targetId: b5aacfb9-3c05-b6d3-934b-a093a9e10bb0
            port: SUCCESS
    results:
      SUCCESS:
        b5aacfb9-3c05-b6d3-934b-a093a9e10bb0:
          x: 395
          'y': 101
