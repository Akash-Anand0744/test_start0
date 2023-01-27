########################################################################################################################
#!!
#! @description: Escape " in json value field.
#!!#
########################################################################################################################
namespace: Cerner.Integrations.Jira.subFlows
flow:
  name: encode_JSON_value
  inputs:
    - jsonPath: $.fields.description
    - jsonData
  workflow:
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${jsonData}'
            - json_path: '${jsonPath}'
        publish:
          - escapedString: "${cs_replace(return_result,'\"','\\\"')}"
        navigate:
          - SUCCESS: add_value
          - FAILURE: on_failure
    - add_value:
        do:
          io.cloudslang.base.json.add_value:
            - json_input: '${jsonData}'
            - json_path: '${jsonPath}'
            - value: '${escapedString}'
        publish:
          - jsonOutStr: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      json_path_query:
        x: 250
        'y': 151
      add_value:
        x: 450
        'y': 148
        navigate:
          a8c8c772-0a0b-0145-5e51-13023bcc5be7:
            targetId: a1f853b7-f092-f4a9-8da1-af2ae361ed87
            port: SUCCESS
    results:
      SUCCESS:
        a1f853b7-f092-f4a9-8da1-af2ae361ed87:
          x: 602
          'y': 149
