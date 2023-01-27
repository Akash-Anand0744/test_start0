########################################################################################################################
#!!
#! @input svc_component_id: Service Component ID
#! @input svc_instance_id: Service Instance ID
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.DummyFlows
flow:
  name: VMware_Post_Deployment
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
          - failure: on_failure
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
            - status_message: 'VMware Post Deployment Actions Started ...!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_DND_With_Status
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'VMware Post Deployment Actions  Completed ...!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_DND_With_Status_1
          - FAILURE: Set_Status_Message_2
    - Set_Status_Message_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - status_message: 'VMware Post Deployment Actions FAILED ...!!!'
        publish:
          - status_message
        navigate:
          - SUCCESS: Update_DND_With_Status_2
          - FAILURE: on_failure
    - Update_DND_With_Status:
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
          - success: Update_Subscription_Status_1
          - failure: Set_Status_Message_2
    - Update_DND_With_Status_2:
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
          - success: FAILURE
          - failure: FAILURE
    - Update_Subscription_Status_1:
        do:
          Integrations.Cerner.DigitalFactory.SMAX_Update.Update_Subscription_Status:
            - subscription_instance_id: '${svc_instance_id}'
            - status_message: '${status_message}'
        navigate:
          - FAILURE: Set_Status_Message_2
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Update_DND_With_Status_1:
        x: 812
        'y': 205
      Update_DND_With_Status_2:
        x: 372
        'y': 52
        navigate:
          5b73aff4-bed7-6ee9-c416-5d4d38ee93a4:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: failure
          77533314-1b5a-d297-88f0-5494af1380fc:
            targetId: 3226f756-c16e-1def-e6d8-f6ffe09d745b
            port: success
      Set_Status_Message_1:
        x: 812
        'y': 341
      Set_Status_Message_2:
        x: 612
        'y': 197
      Update_Subscription_Status_1:
        x: 805
        'y': 47
        navigate:
          bf5e6e72-a30d-9291-8dee-4ca8e8b9f43c:
            targetId: e1008642-af95-6037-44ed-2c14dcfbecd2
            port: SUCCESS
      Update_DND_With_Status:
        x: 156
        'y': 349
      Get_User_Identifier:
        x: 152
        'y': 10
      Set_Status_Message:
        x: 151
        'y': 157
      sleep_10_Sec:
        x: 398
        'y': 349
    results:
      FAILURE:
        3226f756-c16e-1def-e6d8-f6ffe09d745b:
          x: 604
          'y': 60
      SUCCESS:
        e1008642-af95-6037-44ed-2c14dcfbecd2:
          x: 1109
          'y': 83
