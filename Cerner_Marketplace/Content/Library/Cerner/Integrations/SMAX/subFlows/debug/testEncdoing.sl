namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testEncdoing
  workflow:
    - getSystemEncoding:
        do:
          Cerner.Integrations.SMAX.subFlows.debug.getSystemEncoding: []
        navigate:
          - SUCCESS: SUCCESS
  results:
    - SUCCESS
extensions:
  graph:
    steps:
      getSystemEncoding:
        x: 165
        'y': 111.421875
        navigate:
          b40bb21d-6d90-f2bd-9c44-46d97e13c813:
            targetId: e6406c41-e651-331d-24e2-5400a0217ad6
            port: SUCCESS
    results:
      SUCCESS:
        e6406c41-e651-331d-24e2-5400a0217ad6:
          x: 296
          'y': 190
