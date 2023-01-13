########################################################################################################################
#!!
#! @input input_list: key Value pair separated by double  pipe "||" like key1,value1||key2,value2||
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Actions
flow:
  name: vRA_ManageDeployment
  inputs:
    - SMAXRequestID: '1234598'
    - VRADeploymentId
    - requestor: RS091868@cerner.net
    - requestor_email: rakesh.sharma@cerner.com
    - deployment_action
    - input_list:
        required: false
    - new_end_date:
        default: ''
        required: false
  workflow:
    - initialize_flow_output:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - hostname: ''
          - ip_address: ''
          - vm_leaseExpireAt: ''
          - vm_state: ''
        navigate:
          - SUCCESS: get_SMAXToken
          - FAILURE: on_failure
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
    - SMAX_entityOperations_UpdateSubscription:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - operation: UPDATE
            - smax_data: "${'Id,'+ entity_id+ '||SubscriptionStatus_c,' + new_subscription_status + '||StatusMessage_c,' + message + '||RequestedEndDate_c,' + new_end_date + '||EndDate_c,' + EndDate + '||'}"
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: mail_onVMDeployment
          - FAILURE: on_failure
    - get_DeploymentIdandStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.SMAX.SubFlows.get_DeploymentIdandStatus:
            - SMAXRequestID: '${SMAXRequestID}'
            - smax_token: '${smax_token}'
            - query_field: "${\"VRADeploymentId_c,'\" + VRADeploymentId + \"'\"}"
        publish:
          - deploymentId
          - subscription_status
          - entity_id
          - DeploymentName: '${subscription_name}'
          - subscription_name
          - hostname
          - errorMessage
          - errorType
          - errorProvider
        navigate:
          - FAILURE: on_failure
          - SUCCESS: Is_Subscription_Active
    - check_deployment_action_Modify:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${deployment_action.split("_c")[0]}'
            - second_string: Modify
            - ignore_case: 'true'
            - subject_for_mail: "${'Request# ' + SMAXRequestID +': ' + subscription_name + ' Modified'}"
            - first_line_body: "${'Your VM Subscription: ' +  DeploymentName + ' has been modified successfully'}"
        publish:
          - subject: '${subject_for_mail}'
          - action: ChangeLease
          - new_subscription_status: Active
          - first_line_body
        navigate:
          - SUCCESS: vRA_DeploymentActions
          - FAILURE: on_failure
    - check_deployment_action_Cancel:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${deployment_action.split("_c")[0]}'
            - second_string: Cancel
            - ignore_case: 'true'
            - subject_for_mail: "${'Request# ' + SMAXRequestID +': ' + subscription_name + ' Cancelled'}"
            - first_line_body: "${'Your VM Subscription: ' +  DeploymentName + ' has been cancelled successfully'}"
        publish:
          - action: Delete
          - subject: '${subject_for_mail}'
          - new_subscription_status: Cancelled
          - EndDate: ''
          - first_line_body
        navigate:
          - SUCCESS: vRA_DeploymentActions
          - FAILURE: check_deployment_action_Modify
    - mail_onVMDeployment:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Actions.mail_onVMDeployment:
            - requestor_email: '${requestor_email}'
            - SMAXRequestID: '${SMAXRequestID}'
            - DeploymentName: '${subscription_name}'
            - first_line_body: '${first_line_body}'
            - vm_info_list: "${'VM Lease Expire,'+ vm_leaseExpireAt +'||Host Name,' + hostname + '||IP Address,' + ip_address + '||VM Power State,' + vm_state + '||'}"
            - subject: '${subject}'
            - action: '${action}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SMAX_entityOperations_CloseRequest
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
          - SUCCESS: get_DeploymentIdandStatus
          - FAILURE: on_failure
    - vRA_DeploymentActions:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_DeploymentActions:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${deploymentId}'
            - action: '${action}'
            - action_info: '${new_end_date}'
        publish:
          - result
          - message
          - errorMessage
          - errorProvider
          - errorType
        navigate:
          - SUCCESS: check_deployment_action_Cancel_1
          - FAILURE: on_failure
    - Is_Subscription_Active:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${subscription_status}'
            - second_string: Active
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: check_deployment_action_Cancel
          - FAILURE: Is_Subscription_Cancelled
    - vRA_checkDeploymentStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_checkDeploymentStatus:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${VRADeploymentId}'
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
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateSubscription
          - FAILURE: on_failure
    - check_deployment_action_Cancel_1:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${deployment_action.split("_c")[0]}'
            - second_string: Cancel
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: vRA_checkDeploymentStatus
    - get_millis_CurrentTime:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - EndDate: '${time_millis}'
          - time_millis
          - VmStatusDate: '${time_millis}'
        navigate:
          - SUCCESS: SMAX_getEntityDetails_Entity_ID
    - Is_Subscription_Cancelled:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${subscription_status}'
            - second_string: Cancelled
            - ignore_case: 'true'
            - subject: "${'Request# ' + SMAXRequestID +': ' + subscription_name + 'Already Cancelled'}"
            - first_line_body: "${'Your VM Subscription: ' +  DeploymentName + ' is already in  cancelled state'}"
        publish:
          - action: Cancelled
          - errorType: '10000'
          - errorMessage: "${'Subscription is in incomplete State: ' + Subscription_status}"
          - subject
          - first_line_body
        navigate:
          - SUCCESS: mail_onVMDeployment
          - FAILURE: on_failure
    - SMAX_entityOperations_CloseRequest:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - operation: UPDATE
            - smax_data: "${'Id,'+ SMAXRequestID + '||Solution, Request fulfilled through vRA Automation||CompletionCode,CompletionCodeFulfilledByVRA_c'}"
            - is_custom_app: 'No'
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - SMAX_getEntityDetails_Entity_ID:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails_Entity_ID:
            - smax_auth_token: '${smax_token}'
            - entity: VmDetails_c
            - query_field: "${'SubscriptionId_c,' + entity_id}"
        publish:
          - result
          - message
          - entity_ids
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - vm_smax_data: ''
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${entity_ids}'
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
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
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
          - SUCCESS: mail_onVMDeployment
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - smaxRequestNumber: '${SMAXRequestID}'
                - smaxRequestSummary: '${DeploymentName}'
                - smaxRequestorEmail: '${requestor_email}'
  outputs:
    - VMName: '${hostname}'
    - IPAddress: '${ip_address}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      check_deployment_action_Cancel:
        x: 800
        'y': 80
      get_DeploymentIdandStatus:
        x: 440
        'y': 80
      check_deployment_action_Modify:
        x: 1080
        'y': 80
      initialize_flow_output:
        x: 40
        'y': 280
      mail_onVMDeployment:
        x: 360
        'y': 280
      Is_Subscription_Cancelled:
        x: 640
        'y': 280
      vRA_checkDeploymentStatus:
        x: 800
        'y': 360
      SMAX_entityOperations_UpdateSubscription:
        x: 480
        'y': 360
      SMAX_entityOperations_MultiRecords:
        x: 360
        'y': 640
      SMAX_getEntityDetails_Entity_ID:
        x: 800
        'y': 640
      check_deployment_action_Cancel_1:
        x: 960
        'y': 440
      Is_Subscription_Active:
        x: 640
        'y': 80
      get_millis_CurrentTime:
        x: 960
        'y': 640
      Prepare_VMStatusUpdateDeta:
        x: 640
        'y': 440
      SMAX_entityOperations_CloseRequest:
        x: 200
        'y': 280
        navigate:
          a67709f6-7a54-1068-475a-351df22bb993:
            targetId: 18e072b4-bde7-0133-9e88-1c85a2db458c
            port: SUCCESS
      list_iterator_Key_value_list:
        x: 640
        'y': 640
      get_vRAToken:
        x: 240
        'y': 80
      vRA_DeploymentActions:
        x: 960
        'y': 280
      get_SMAXToken:
        x: 40
        'y': 80
    results:
      SUCCESS:
        18e072b4-bde7-0133-9e88-1c85a2db458c:
          x: 200
          'y': 560
