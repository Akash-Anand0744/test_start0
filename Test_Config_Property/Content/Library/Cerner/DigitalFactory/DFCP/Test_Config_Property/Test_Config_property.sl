namespace: Cerner.DigitalFactory.DFCP.Test_Config_Property
flow:
  name: Test_Config_property
  workflow:
    - do_nothing:
        do:
          io.cloudslang.base.utils.do_nothing:
            - TestProperty: "${get_sp('Cerner.DigitalFactory.DFCP.TestProperty')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      do_nothing:
        x: 301
        'y': 182
        navigate:
          7c50006b-9c66-cb76-ea5e-8464f9f4c120:
            targetId: a7ff9771-76bf-c8b7-02ac-4d003b2ac4fb
            port: SUCCESS
    results:
      SUCCESS:
        a7ff9771-76bf-c8b7-02ac-4d003b2ac4fb:
          x: 536
          'y': 168.2222442626953
