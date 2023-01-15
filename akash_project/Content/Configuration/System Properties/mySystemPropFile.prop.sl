########################################################################################################################
#!!
#! @input flow_properties: flow_properties for akash_flows_project.akash_flow1
#!!#
########################################################################################################################
namespace: akash_flows_project
flow:
  name: akash_flow1
  inputs:
    - flow_properties: value1_for_akash_flow1
  workflow:
    - random_number_generator:
        do:
          io.cloudslang.base.math.random_number_generator:
            - min: '1'
            - max: '10'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      random_number_generator:
        x: 280
        'y': 160
        navigate:
          b36dffef-4b25-481a-b77d-8361f74d272d:
            targetId: 9345c3cd-ffdf-c50f-36d7-54c2044459fe
            port: SUCCESS
    results:
      SUCCESS:
        9345c3cd-ffdf-c50f-36d7-54c2044459fe:
          x: 480
          'y': 160
