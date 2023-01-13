########################################################################################################################
#!!
#! @input svc_component_id: Service Component ID
#! @input svc_instance_id: Service Instance ID
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.DummyFlows
flow:
  name: VMware_Provisioning_Dummy
  inputs:
    - svc_component_id: '[TOKEN:SVC_COMPONENT_ID]'
    - svc_instance_id: '[TOKEN:SVC_INSTANCE_ID]'
  workflow:
    - Get_User_Identifier:
        do_external:
          f1c8b14a-694f-4a03-a84a-c7504fe0a29b: []
        publish:
          - userIdentifier
          - document
        navigate:
          - success: Set_Status_Message
          - failure: Set_Status_Message_2
    - sleep_10_Sec:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '10'
        navigate:
          - SUCCESS: Set_Status_Message_1
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: Server Provisioning Initiated.
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_Subscription_Status
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'Server Provisioning Completed ...!!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_DND_With_Status_1
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'Server Provisioning FAILED ...!!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_Subscription_Status_1
          - FAILURE: on_failure
    - Update_DND_With_Status:
        do_external:
          fe69637d-9835-4aea-912f-844b4bc189bf:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - onlyUpdate: 'No'
            - displayName: STATUS1
            - propertyName: STATUS1
            - valueType: String
            - values: '${status_message}'
            - trustAllRoots: 'true'
        navigate:
          - success: sleep_10_Sec
          - failure: Set_Status_Message_2
    - Update_DND_With_Status_1:
        do_external:
          fe69637d-9835-4aea-912f-844b4bc189bf:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - onlyUpdate: 'No'
            - displayName: 'Status Message:'
            - propertyName: STATUS_MESSAGE
            - valueType: STRING
            - values: '${status_message}'
        navigate:
          - success: SUCCESS
          - failure: Set_Status_Message_2
    - Update_DND_With_Status_2:
        do_external:
          fe69637d-9835-4aea-912f-844b4bc189bf:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - onlyUpdate: 'No'
            - displayName: STATUS
            - propertyName: STATUS_MESSAGE
            - valueType: STRING
            - values: '${status_message}'
        navigate:
          - success: FAILURE
          - failure: FAILURE
    - Update_Subscription_Status:
        do:
          Integrations.Cerner.DigitalFactory.SMAX_Update.Update_Subscription_Status:
            - subscription_instance_id: '${svc_instance_id}'
            - status_message: '${status_message}'
        navigate:
          - FAILURE: Set_Status_Message_2
          - SUCCESS: Update_DND_With_Status
    - Update_Subscription_Status_1:
        do:
          Integrations.Cerner.DigitalFactory.SMAX_Update.Update_Subscription_Status:
            - subscription_instance_id: '${svc_instance_id}'
            - status_message: '${status_message}'
        navigate:
          - FAILURE: Update_DND_With_Status_2
          - SUCCESS: Update_DND_With_Status_2
  outputs:
    - message: '${status_message}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Update_DND_With_Status_1:
        x: 802
        'y': 223
        navigate:
          925eb665-041e-5dbc-e636-1a692cdd18e3:
            targetId: e1008642-af95-6037-44ed-2c14dcfbecd2
            port: success
      Update_DND_With_Status_2:
        x: 553
        'y': 19
        navigate:
          f99f8831-1e0c-3fc6-1a35-bf3c547d6a16:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: failure
          d087fab6-afaf-03a6-f873-8303995c0731:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: success
      Set_Status_Message_1:
        x: 805
        'y': 423
      Set_Status_Message_2:
        x: 437
        'y': 216
      Update_Subscription_Status_1:
        x: 674
        'y': 124
      Update_DND_With_Status:
        x: 423
        'y': 429
      Get_User_Identifier:
        x: 169
        'y': 34
      Set_Status_Message:
        x: 170
        'y': 224
      sleep_10_Sec:
        x: 594
        'y': 429
      Update_Subscription_Status:
        x: 166
        'y': 419
    results:
      FAILURE:
        3226f756-c16e-1def-e6d8-f6ffe09d745b:
          x: 370
          'y': 67
      SUCCESS:
        e1008642-af95-6037-44ed-2c14dcfbecd2:
          x: 803
          'y': 26
