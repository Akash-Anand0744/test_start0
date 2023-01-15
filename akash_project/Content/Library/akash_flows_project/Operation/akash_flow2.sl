namespace: akash_flows_project.Operation
flow:
  name: akash_flow2
  workflow:
    - akash_flow1:
        do:
          akash_flows_project.akash_flow1: []
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
    - on_failure:
        - akash_flow1_1:
            do:
              akash_flows_project.akash_flow1: []
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      akash_flow1:
        x: 240
        'y': 160
        navigate:
          ff7681a0-c2b7-a56e-61ae-2508da008f13:
            targetId: de3c0b40-b602-58f8-382b-ac50b80f681d
            port: SUCCESS
    results:
      SUCCESS:
        de3c0b40-b602-58f8-382b-ac50b80f681d:
          x: 440
          'y': 200
