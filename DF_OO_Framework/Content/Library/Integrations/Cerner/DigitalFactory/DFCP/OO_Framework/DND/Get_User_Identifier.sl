namespace: Integrations.Cerner.DigitalFactory.DFCP.OO_Framework.DND
flow:
  name: Get_User_Identifier
  inputs:
    - csaUser: "${get_sp('Integrations.Cerner.DigitalFactory.DFCP.dnd_oo_user')}"
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('Integrations.Cerner.DigitalFactory.DFCP.dnd_rest_uri') + '/login/Provider/' + csaUser}"
            - auth_type: basic
            - username: "${get_sp('Integrations.Cerner.DigitalFactory.DFCP.dnd_rest_user')}"
            - password:
                value: "${get_sp('Integrations.Cerner.DigitalFactory.DFCP.dnd_rest_user_password')}"
                sensitive: true
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
          - response_headers
          - xml: '${return_result}'
        navigate:
          - SUCCESS: string_equals_null
          - FAILURE: FAILURE
    - string_equals_null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${xml}'
            - ignore_case: 'true'
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: xpath_query
    - xpath_query:
        do:
          io.cloudslang.base.xml.xpath_query:
            - xml_document: '${xml}'
            - xpath_query: /person/id
        publish:
          - selected_value
          - return_result
          - error_message
          - return_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - userIdentifier
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_get:
        x: 223
        'y': 113.66667175292969
        navigate:
          e5797471-e6f0-84f2-534d-d25925d1e503:
            targetId: 3ea2948a-272d-daa1-0d30-08965e445839
            port: FAILURE
      string_equals_null:
        x: 421
        'y': 101
        navigate:
          f1382ad5-423d-b19a-4e8d-b9ad376836de:
            targetId: 3ea2948a-272d-daa1-0d30-08965e445839
            port: SUCCESS
      xpath_query:
        x: 647
        'y': 102
        navigate:
          3fbc1d1a-e25c-8bbf-9bf6-375e49bdfa40:
            targetId: f14e7675-fe2f-e760-10c8-3b02ce2bd3d0
            port: SUCCESS
          025a5b14-6214-cc09-ae48-4513e9ebf46b:
            targetId: 3ea2948a-272d-daa1-0d30-08965e445839
            port: FAILURE
    results:
      FAILURE:
        3ea2948a-272d-daa1-0d30-08965e445839:
          x: 216
          'y': 301
      SUCCESS:
        f14e7675-fe2f-e760-10c8-3b02ce2bd3d0:
          x: 656
          'y': 317
