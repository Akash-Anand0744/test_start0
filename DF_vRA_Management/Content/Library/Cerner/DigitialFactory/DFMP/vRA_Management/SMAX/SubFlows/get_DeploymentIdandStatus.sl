########################################################################################################################
#!!
#! @input entity_fields: Optional
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.SMAX.SubFlows
flow:
  name: get_DeploymentIdandStatus
  inputs:
    - SMAXRequestID
    - smax_token
    - entity: SubscriptionDetails_c
    - query_field: "${'RequestId_c,' + SMAXRequestID}"
    - entity_fields:
        default: 'Id,VRADeploymentId_c,SubscriptionStatus_c,SubscriptionName_c,ServerName_c,OsVersion_c'
        required: false
  workflow:
    - SMAX_getEntityDetails:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: '${entity}'
            - query_field: '${query_field}'
            - entity_fields: '${entity_fields}'
        publish:
          - result
          - records
          - data_json: '${entity_data_json[1:-1]}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
        navigate:
          - SUCCESS: Entity_ReturnJSON_Null
          - FAILURE: on_failure
    - Entity_ReturnJSON_Null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${entity_data_json}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - deployment_id: ''
          - subscription_status: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: get_OsVersion
    - get_deployment_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: VRADeploymentId_c
        publish:
          - deploymentId: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_vm_status
          - FAILURE: get_vm_status
    - get_subscription_status:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: SubscriptionStatus_c
        publish:
          - subscription_status: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_subscription_name
          - FAILURE: get_subscription_name
    - get_entity_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: Id
        publish:
          - entity_id: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - get_subscription_name:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: SubscriptionName_c
        publish:
          - subscription_name: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_entity_id
          - FAILURE: get_entity_id
    - get_hostname:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: ServerName_c
        publish:
          - hostname: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_deployment_id
          - FAILURE: get_deployment_id
    - get_OsVersion:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: OsVersion_c
        publish:
          - os_version: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_hostname
          - FAILURE: get_hostname
    - get_vm_status:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${data_json}'
            - json_path: VmStatus_c
        publish:
          - vm_status: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_subscription_status
          - FAILURE: get_subscription_status
  outputs:
    - deploymentId: '${deploymentId}'
    - subscription_status: '${subscription_status}'
    - entity_id: '${entity_id}'
    - subscription_name: '${subscription_name}'
    - hostname: '${hostname}'
    - os_version: '${os_version}'
    - vm_status: '${vm_status}'
    - errorMessage: '${errorMessage}'
    - errorType: '${errorType}'
    - errorProvider: '${errorProvder}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_subscription_name:
        x: 840
        'y': 480
      get_OsVersion:
        x: 81
        'y': 485
      get_subscription_status:
        x: 680
        'y': 480
      get_deployment_id:
        x: 360
        'y': 480
      get_entity_id:
        x: 1000
        'y': 480
        navigate:
          0b4348c9-8c39-5066-7ab0-5f4dc6fc5f34:
            targetId: 1fe60dcf-b5b8-341d-53ed-83ec05b147dc
            port: SUCCESS
      get_vm_status:
        x: 520
        'y': 480
      Entity_ReturnJSON_Null:
        x: 80
        'y': 240
        navigate:
          81177e2b-59e3-6395-b5de-8f453249fe00:
            targetId: 1fe60dcf-b5b8-341d-53ed-83ec05b147dc
            port: SUCCESS
      SMAX_getEntityDetails:
        x: 360
        'y': 80
      get_hostname:
        x: 203
        'y': 478
    results:
      SUCCESS:
        1fe60dcf-b5b8-341d-53ed-83ec05b147dc:
          x: 1000
          'y': 240
