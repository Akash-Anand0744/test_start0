########################################################################################################################
#!!
#! @input svc_component_id: Service Component ID
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.DummyFlows
flow:
  name: VMware_Create_Snapshot
  inputs:
    - svc_component_id: '[TOKEN:SVC_COMPONENT_ID]'
  workflow:
    - Get_User_Identifier:
        do_external:
          f1c8b14a-694f-4a03-a84a-c7504fe0a29b: []
        publish:
          - userIdentifier
          - document
        navigate:
          - success: Set_Status_Message
          - failure: on_failure
    - Update_Component_With_Status:
        do_external:
          db56e898-a98e-4294-845f-ccc9a64d7689:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - displayName: 'Status Message:'
            - propertyName: STATUS_MESSAGE
            - valueType: STRING
            - values: '${status_message}'
            - consumerVisible: 'true'
        navigate:
          - success: sleep_10_Sec
          - failure: Set_Status_Message_2
    - Update_Component_With_Completion:
        do_external:
          db56e898-a98e-4294-845f-ccc9a64d7689:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - displayName: 'Status Message:'
            - propertyName: STATUS_MESSAGE
            - valueType: STRING
            - values: '${status_message}'
            - consumerVisible: 'true'
        navigate:
          - success: SUCCESS
          - failure: Set_Status_Message_2
    - sleep_10_Sec:
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '10'
        navigate:
          - SUCCESS: Set_Status_Message_1
          - FAILURE: Set_Status_Message_2
    - Update_Component_With_FAILURE:
        do_external:
          db56e898-a98e-4294-845f-ccc9a64d7689:
            - componentId: '${svc_component_id}'
            - userIdentifier: '${userIdentifier}'
            - displayName: 'Status Message:'
            - propertyName: STATUS_MESSAGE
            - valueType: STRING
            - values: '${status_message}'
            - consumerVisible: 'true'
        navigate:
          - success: FAILURE
          - failure: FAILURE
    - Set_Status_Message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'Create Snapshot Action Started...!!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_Component_With_Status
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'Create Snapshot Action COMLETED...!!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_Component_With_Completion
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'Create Snapshot Action FAILED...!!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_Component_With_FAILURE
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_User_Identifier:
        x: 152
        'y': 10
      Update_Component_With_Status:
        x: 154
        'y': 397
      Update_Component_With_Completion:
        x: 803
        'y': 181
        navigate:
          b7554cc7-d262-64b3-0984-c2b2ea268b43:
            targetId: e1008642-af95-6037-44ed-2c14dcfbecd2
            port: success
      Set_Status_Message_2:
        x: 388
        'y': 276
      Update_Component_With_FAILURE:
        x: 607
        'y': 68
        navigate:
          e01d254d-0716-0f65-5c42-679ab4e6f2a2:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: failure
          89786bb4-d21c-4a42-c472-5427041317d6:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: success
      Set_Status_Message:
        x: 154
        'y': 190
      Set_Status_Message_1:
        x: 799
        'y': 395
      sleep_10_Sec:
        x: 506
        'y': 394
    results:
      FAILURE:
        3226f756-c16e-1def-e6d8-f6ffe09d745b:
          x: 370
          'y': 67
      SUCCESS:
        e1008642-af95-6037-44ed-2c14dcfbecd2:
          x: 783
          'y': 21
