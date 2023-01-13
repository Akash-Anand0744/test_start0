namespace: smax_integration.confluence_integration
flow:
  name: testEvents
  workflow:
    - syncEventsOperation:
        do:
          smax_integration.confluence_integration.operations.syncEventsOperation: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      syncEventsOperation:
        x: 206
        'y': 126
        navigate:
          b521f36e-ec1e-0137-6a03-2e72666c8b1a:
            targetId: 4aa32daf-8103-03ea-7ced-2b3dcd1f3cb6
            port: SUCCESS
    results:
      SUCCESS:
        4aa32daf-8103-03ea-7ced-2b3dcd1f3cb6:
          x: 428
          'y': 122
