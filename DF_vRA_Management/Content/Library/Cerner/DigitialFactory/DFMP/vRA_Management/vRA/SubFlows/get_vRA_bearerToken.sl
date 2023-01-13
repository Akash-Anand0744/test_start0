namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.SubFlows
flow:
  name: get_vRA_bearerToken
  workflow:
    - get_vRAToken:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.get_vRAToken: []
        publish:
          - result
          - bearerToken
          - message
          - errorType
          - errorMessage
          - errorSeverity
          - errorProvider
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_vRAToken:
        x: 216.93331909179688
        'y': 296.01666259765625
        navigate:
          8e678799-2dd6-10a5-c844-7d54841d91fc:
            targetId: 038351c2-eabc-7fb5-f90f-2e977a23c007
            port: SUCCESS
    results:
      SUCCESS:
        038351c2-eabc-7fb5-f90f-2e977a23c007:
          x: 552
          'y': 283
