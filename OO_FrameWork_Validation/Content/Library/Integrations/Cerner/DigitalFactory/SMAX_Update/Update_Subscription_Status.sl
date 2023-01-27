########################################################################################################################
#!!
#! @input subscription_instance_id: Subscription Instance ID where status to be updated
#! @input status_message: progress Status of the Subscription
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.SMAX_Update
flow:
  name: Update_Subscription_Status
  inputs:
    - subscription_instance_id
    - status_message
  workflow:
    - get_sso_token:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.get_sso_token:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
        publish:
          - sso_token
          - status_code
          - exception
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: query_entities
    - update_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.update_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - json_body: "${'{ \"entity_type\": \"Subscription\", \"properties\": { \"Id\": \"' +subscription_id+ '\", \"SubscriptionStatusMessage_c\": \"' +status_message+ '\" } }'}"
        publish:
          - op_status
          - error_json
          - return_result
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS
    - query_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.query_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - entity_type: Subscription
            - query: "${\"RemoteServiceInstanceID='\"+subscription_instance_id+\"'\"}"
            - fields: Id
        publish:
          - entity_json
          - error_json
          - return_result
          - op_status
          - result_count
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: get_key_value_from_json_object
          - NO_RESULTS: FAILURE
    - is_null:
        do:
          io.cloudslang.base.utils.is_null:
            - variable: '${subscription_id}'
        publish:
          - return_result: no ID found
        navigate:
          - IS_NULL: FAILURE
          - IS_NOT_NULL: update_entities
    - get_key_value_from_json_object:
        do:
          Integrations.Cerner.DigitalFactory.SMAX_Update.get_key_value_from_json_object:
            - json_object: '${entity_json}'
            - property_key: Id
        publish:
          - result
          - message
          - property_value
          - subscription_id: '${property_value}'
        navigate:
          - SUCCESS: is_null
          - FAILURE: FAILURE
  outputs:
    - op_status: '${op_status}'
    - error_json: '${error_json}'
    - return_result: '${return_result}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_sso_token:
        x: 9
        'y': 66
        navigate:
          ada4fdd0-ef0b-e445-10a7-35032efd5d0a:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: FAILURE
      update_entities:
        x: 516
        'y': 334
        navigate:
          45abd920-47a8-2525-46d2-1ab1645778e5:
            targetId: 7665edd5-3d45-c4c0-babe-622f7c331f05
            port: SUCCESS
          f2711a98-60fc-09fd-5051-89e2112c7d89:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: FAILURE
      query_entities:
        x: 180
        'y': 67
        navigate:
          aab03f8f-0556-a27a-9534-a17c58ca359b:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: FAILURE
          0d9f884b-f228-92e8-4e97-2ba7041862a2:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: NO_RESULTS
      is_null:
        x: 519
        'y': 177
        navigate:
          966bca89-8695-8b9a-ec2f-6d5d7f8cfb16:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: IS_NULL
      get_key_value_from_json_object:
        x: 331
        'y': 144
        navigate:
          49a2faf0-9bb0-e886-85e8-ca3d1a7b6828:
            targetId: c01512fd-8312-eb0c-e27d-964221f9c3f4
            port: FAILURE
    results:
      FAILURE:
        c01512fd-8312-eb0c-e27d-964221f9c3f4:
          x: 7
          'y': 338
      SUCCESS:
        7665edd5-3d45-c4c0-babe-622f7c331f05:
          x: 868
          'y': 324
