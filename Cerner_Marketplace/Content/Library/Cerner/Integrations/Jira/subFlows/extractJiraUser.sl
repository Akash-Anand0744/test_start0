namespace: Cerner.Integrations.Jira.subFlows
flow:
  name: extractJiraUser
  inputs:
    - inpString:
        required: false
  workflow:
    - is_null:
        do:
          io.cloudslang.base.utils.is_null:
            - variable: '${inpString}'
        publish: []
        navigate:
          - IS_NULL: do_nothing_1
          - IS_NOT_NULL: do_nothing
    - do_nothing:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input_0: '${inpString[0:inpString.find("@")]}'
        publish:
          - outString: '${input_0}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - do_nothing_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input_0: '${inpString}'
        publish:
          - outString: "${get_sp('MarketPlace.jiraUser')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - outString: '${outString}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      do_nothing_1:
        x: 389
        'y': 35
        navigate:
          29894bef-8821-e5de-0532-1b926998266f:
            targetId: 28c45ade-c7e3-c03b-c932-4e8a6f406db1
            port: SUCCESS
      is_null:
        x: 283
        'y': 140
      do_nothing:
        x: 432
        'y': 347
        navigate:
          a54e5f17-965e-9cbd-fa93-474fb317350d:
            targetId: 28c45ade-c7e3-c03b-c932-4e8a6f406db1
            port: SUCCESS
    results:
      SUCCESS:
        28c45ade-c7e3-c03b-c932-4e8a6f406db1:
          x: 534
          'y': 125
