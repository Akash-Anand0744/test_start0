namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testIfcondition
  workflow:
    - do_nothing_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - result: '0'
        publish:
          - output_0: |-
              ${if result == 0:
                  "hiTest"}
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      do_nothing_1:
        x: 180.80322265625
        'y': 135.05091857910156
        navigate:
          3d834aab-e930-85d1-9ee8-b6c3986da59e:
            targetId: d35eab96-3b5c-12d7-562d-66d8c2aaf853
            port: SUCCESS
    results:
      SUCCESS:
        d35eab96-3b5c-12d7-562d-66d8c2aaf853:
          x: 430.9837951660156
          'y': 115.64814758300781
