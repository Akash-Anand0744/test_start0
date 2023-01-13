namespace: Integrations.Cerner.DigitalFactory.DFCP.OO_Framework.Actions
flow:
  name: DigitalFatcory_OO_Framework
  workflow:
    - MainErrorHandler_WrapperForEOD:
        do:
          Integrations.Cerner.DigitalFactory.DFCP.Error_Notification.Actions.MainErrorHandler_WrapperForEOD: []
        navigate:
          - FAILURE: on_failure
          - SUCCESS: FAILURE
  results:
    - FAILURE
extensions:
  graph:
    steps:
      MainErrorHandler_WrapperForEOD:
        x: 502
        'y': 185
        navigate:
          92148c27-b7bb-7164-c2c3-da2d2dfa06b9:
            targetId: 9eec2f40-4b5e-9f7e-fb72-5b1b38e0d68c
            port: SUCCESS
    results:
      FAILURE:
        9eec2f40-4b5e-9f7e-fb72-5b1b38e0d68c:
          x: 498
          'y': 1
