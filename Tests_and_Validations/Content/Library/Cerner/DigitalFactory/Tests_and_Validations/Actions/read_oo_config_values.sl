namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: read_oo_config_values
  workflow:
    - set_message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_config: "'MarketPlace.test1_JSON'"
            - tt: "${get_sp('MarketPlace.test1_JSON')}"
        publish:
          - key_config
        navigate:
          - SUCCESS: getOOConfigProperties
          - FAILURE: on_failure
    - get_OO_config_json_for_ID_Val:
        do:
          io.cloudslang.base.utils.do_nothing:
            - json_input_object: null
            - key_config: '${key_config}'
        publish:
          - json_input_object
          - output_0: '${get_sp(key_config)}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - getOOConfigProperties:
        do:
          Cerner.DigitalFactory.Tests_and_Validations.Actions.getOOConfigProperties:
            - keysuffix: PATH
        publish:
          - config_json
          - message
          - result
          - errorType
          - errormessage
        navigate:
          - SUCCESS: get_OO_config_json_for_ID_Val
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      set_message_1:
        x: 204
        'y': 107
      get_OO_config_json_for_ID_Val:
        x: 421
        'y': 359
        navigate:
          b7740cf2-d3b7-afb8-163f-8d564c9ae2da:
            targetId: 41804014-8e2a-24bc-e97f-3c7f74ae249e
            port: SUCCESS
      getOOConfigProperties:
        x: 204.93333435058594
        'y': 358.0833435058594
    results:
      SUCCESS:
        41804014-8e2a-24bc-e97f-3c7f74ae249e:
          x: 683
          'y': 360
