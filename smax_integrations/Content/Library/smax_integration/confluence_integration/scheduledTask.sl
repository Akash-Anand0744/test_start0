namespace: smax_integration.confluence_integration
flow:
  name: scheduledTask
  workflow:
    - syncOperation:
        do:
          smax_integration.confluence_integration.operations.syncOperation: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      syncOperation:
        x: 187
        'y': 130.421875
        navigate:
          2d57cae6-2849-7098-407e-3e4587da6bfc:
            targetId: 19815815-dad9-d5ee-eb23-f8c7a4b12435
            port: SUCCESS
    results:
      SUCCESS:
        19815815-dad9-d5ee-eb23-f8c7a4b12435:
          x: 394
          'y': 130
