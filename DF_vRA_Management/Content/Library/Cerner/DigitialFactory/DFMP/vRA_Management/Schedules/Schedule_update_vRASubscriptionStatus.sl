namespace: Cerner.DigitialFactory.DFMP.vRA_Management.Schedules
flow:
  name: Schedule_update_vRASubscriptionStatus
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - smax_token: '${token}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: get_vRAToken
          - FAILURE: on_failure
    - get_vRAToken:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.get_vRAToken: []
        publish:
          - result
          - bearerToken
          - message
          - errorType
          - errorMessage
          - errorSeverity
          - errorProvider
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: on_failure
    - get_millis_CurrentTime:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - current_date_time: '${time_millis}'
          - time_millis
        navigate:
          - SUCCESS: SMAX_getEntityDetails
    - SMAX_getEntityDetails:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - query_field: "${\"SubscriptionStatus_c,'Active' and RequestedEndDate_c <\" + current_date_time}"
            - entity_fields: 'Id,VRADeploymentId_c'
        publish:
          - result
          - records
          - data_json: '${str(entity_data_json[1:-1])}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
        navigate:
          - SUCCESS: Check_if_no_data_to_process
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${data_json}'
            - separator: '},'
        publish:
          - result_string_data_json: "${result_string + '}'}"
          - return_result
          - return_code
        navigate:
          - HAS_MORE: get_smax_subscription_id
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - Check_if_no_data_to_process:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${data_json}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - data_json: "${first_string + ','}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: list_iterator_Key_value_list
    - get_smax_subscription_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${result_string_data_json}'
            - json_path: Id
        publish:
          - smax_subscription_id: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
          - entity_id: '${return_result}'
        navigate:
          - SUCCESS: get_vra_deployment_id
          - FAILURE: on_failure
    - get_vra_deployment_id:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${result_string_data_json}'
            - json_path: VRADeploymentId_c
        publish:
          - vra_deployment_id: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
        navigate:
          - SUCCESS: vRA_checkDeploymentStatus
          - FAILURE: on_failure
    - vRA_checkDeploymentStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_checkDeploymentStatus:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${vra_deployment_id}'
        publish:
          - result
          - message
          - hostname
          - ip_address
          - errorMessage
          - errorProvider
          - errorType
          - vm_state
          - vm_leaseExpireAt
          - status_code
        navigate:
          - SUCCESS: Check_if_deployment_NOT_found
          - FAILURE: on_failure
    - Check_if_deployment_NOT_found:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${status_code}'
            - second_string: '404'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: get_millis_CurrentTime_1
          - FAILURE: list_iterator_Key_value_list
    - get_millis_CurrentTime_1:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - EndDate: '${time_millis}'
          - time_millis
          - VmStatusDate: '${time_millis}'
        navigate:
          - SUCCESS: SMAX_getEntityDetails_Entity_ID
    - SMAX_getEntityDetails_Entity_ID:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails_Entity_ID:
            - smax_auth_token: '${smax_token}'
            - entity: VmDetails_c
            - query_field: "${'SubscriptionId_c,' + entity_id}"
        publish:
          - result
          - message
          - vm_entity_ids: '${entity_ids}'
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - vm_smax_data: ''
        navigate:
          - SUCCESS: Check_if_vm_entity_id_null
          - FAILURE: on_failure
    - Check_if_vm_entity_id_null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vm_entity_ids}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - vm_smax_data: ''
          - new_subscription_status: ExpiredCancelled
          - new_end_date: ''
        navigate:
          - SUCCESS: SMAX_entityOperations_MultiRecords
          - FAILURE: list_iterator_Key_value_list_1
    - SMAX_entityOperations_MultiRecords:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations_MultiRecords:
            - smax_auth_token: '${smax_token}'
            - smax_data: "${vm_smax_data + 'SubscriptionDetails_c,UPDATE,' + 'Id,'+ entity_id+ '||SubscriptionStatus_c,' + new_subscription_status + '||StatusMessage_c,' + message + '||RequestedEndDate_c,' + new_end_date + '||EndDate_c,' + EndDate + '||'}"
        publish:
          - result
          - message
          - entity_id
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - list_iterator_Key_value_list_1:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${vm_entity_ids}'
            - separator: ','
        publish:
          - result_string
          - return_result
          - return_code
          - vm_ent_id: '${result_string}'
        navigate:
          - HAS_MORE: Prepare_VMStatusUpdateDeta
          - NO_MORE: SMAX_entityOperations_MultiRecords
          - FAILURE: on_failure
    - Prepare_VMStatusUpdateDeta:
        do:
          io.cloudslang.base.utils.do_nothing:
            - vm_ent_id: '${vm_ent_id}'
            - vm_smax_data: '${vm_smax_data}'
            - VmStatusDate: '${VmStatusDate}'
        publish:
          - vm_smax_data: "${vm_smax_data + 'VmDetails_c,UPDATE,' + 'Id,'+ vm_ent_id+ '||VmStatus_c,Cancelled||VmStatusDate_c,' + VmStatusDate + '|||'}"
        navigate:
          - SUCCESS: list_iterator_Key_value_list_1
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      vRA_checkDeploymentStatus:
        x: 360
        'y': 280
      Check_if_deployment_NOT_found:
        x: 200
        'y': 200
      get_millis_CurrentTime_1:
        x: 200
        'y': 440
      SMAX_entityOperations_MultiRecords:
        x: 920
        'y': 600
      Check_if_vm_entity_id_null:
        x: 640
        'y': 440
      Check_if_no_data_to_process:
        x: 680
        'y': 80
        navigate:
          7d744d31-d2ef-6b9a-b6a1-b4c32cb981d4:
            targetId: c4099583-5d49-ec5e-93c2-e47b2114ef37
            port: SUCCESS
      list_iterator_Key_value_list_1:
        x: 640
        'y': 600
      SMAX_getEntityDetails_Entity_ID:
        x: 360
        'y': 440
      get_vra_deployment_id:
        x: 520
        'y': 280
      get_millis_CurrentTime:
        x: 320
        'y': 80
      SMAX_getEntityDetails:
        x: 480
        'y': 80
      get_smax_subscription_id:
        x: 680
        'y': 280
      Prepare_VMStatusUpdateDeta:
        x: 440
        'y': 600
      list_iterator_Key_value_list:
        x: 920
        'y': 200
        navigate:
          6479d18d-b820-d3bd-3141-c6926c04f29d:
            targetId: c4099583-5d49-ec5e-93c2-e47b2114ef37
            port: NO_MORE
      get_vRAToken:
        x: 200
        'y': 80
      get_SMAXToken:
        x: 40
        'y': 80
    results:
      SUCCESS:
        c4099583-5d49-ec5e-93c2-e47b2114ef37:
          x: 920
          'y': 40
