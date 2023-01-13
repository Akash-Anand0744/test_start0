namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testAFL_1
  workflow:
    - get_time:
        do:
          io.cloudslang.base.datetime.get_time:
            - date_format: 'yyyy-MM-dd HH:mm'
        publish:
          - output
          - return_code
          - exception
        navigate:
          - SUCCESS: do_nothing
          - FAILURE: on_failure
    - do_nothing:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input_0: "${set_sp('MarketPlace.tenantID','123456')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_time:
        x: 215
        'y': 138
      do_nothing:
        x: 405.8923645019531
        'y': 138.10763549804688
        navigate:
          03878d7f-298b-aba6-4f3c-259ae02c6b19:
            targetId: 5da80097-ea26-7ba2-bef9-0b6a0a239c34
            port: SUCCESS
    results:
      SUCCESS:
        5da80097-ea26-7ba2-bef9-0b6a0a239c34:
          x: 635.111083984375
          'y': 137.55905151367188
