########################################################################################################################
#!!
#! @input input_list: key Value pair separated by double  pipe "||" like key1,value1||key2,value2||
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Actions
flow:
  name: vRA_LifeCycleDeployment
  inputs:
    - SMAXRequestID: '1234598'
    - VRADeploymentId
    - requestor: RS091868@cerner.net
    - requestor_email: rakesh.sharma@cerner.com
    - lifecycle_action
    - input_list:
        required: false
    - instance_size:
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
          - flavor: ''
          - DeployUser: ''
          - Password: ''
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
    - SMAX_entityOperations_UpdateVmDetails_c:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: VmDetails_c
            - operation: UPDATE
            - smax_data: "${'Id,'+ vm_entity_id+  '||StatusMessage_c,' + message + '||VmConfigSize_c,' + flavor + '||'}"
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
            - entity: VmDetails_c
            - query_field: "${\"VRADeploymentId_c,'\" + VRADeploymentId +\"'\"}"
            - entity_fields: 'Id,VRADeploymentId_c,ServerName_c,OsVersion_c,VmStatus_c'
        publish:
          - deploymentId
          - vm_status
          - vm_entity_id: '${entity_id}'
          - hostname
          - os_version
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_DeploymentIdandSubscriptionsStatus
    - check_deployment_action_Modify:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${lifecycle_action.split("_c")[0]}'
            - second_string: Update
            - ignore_case: 'true'
            - subject_for_mail: "${'Request# ' + SMAXRequestID +': ' + subscription_name + ' Updated'}"
            - first_line_body: "${'Your VM Subscription: ' +  DeploymentName + ' has been Updated successfully'}"
        publish:
          - subject: '${subject_for_mail}'
          - action: Update
          - new_subscription_status: Active
          - first_line_body
        navigate:
          - SUCCESS: get_InstanceSize_fmSysProps
          - FAILURE: on_failure
    - check_lifecycle_action_PowerOn_or_Off:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${lifecycle_action[0:5]}'
            - second_string: Power
            - ignore_case: 'true'
            - subject_for_mail: "${'Request# ' + SMAXRequestID +': ' + subscription_name + ' ' + lifecycle_action.strip('_c') + ' Completed'}"
            - first_line_body: "${'Requested lifecycle action : ' + lifecycle_action + ' for' +  subscription_name + ' has been completed successfully'}"
        publish:
          - subject: '${subject_for_mail}'
          - EndDate: ''
          - first_line_body
        navigate:
          - SUCCESS: vRA_DeploymentPowerOnPowerOff
          - FAILURE: check_deployment_action_Modify
    - mail_onVMDeployment:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Actions.mail_onVMDeployment:
            - requestor_email: '${requestor_email}'
            - SMAXRequestID: '${SMAXRequestID}'
            - DeploymentName: '${subscription_name}'
            - first_line_body: '${first_line_body}'
            - vm_info_list: "${'VM Lease Expire,'+ vm_leaseExpireAt +'||Host Name,' + hostname + '||Instance Size,'+ flavor + '||IP Address,' + ip_address + '||VM Power State,' + vm_state + '||'+ '||User,' + DeployUser + '||Password,' + Password + '||'}"
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
            - deployment_id: '${VRADeploymentId}'
            - action: '${action}'
            - action_info: '${action_info}'
        publish:
          - result
          - message
          - errorMessage
          - errorProvider
          - errorType
        navigate:
          - SUCCESS: vRA_checkDeploymentStatus
          - FAILURE: on_failure
    - Is_Subscription_Active:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${subscription_status}'
            - second_string: Active
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: check_lifecycle_action_PowerOn_or_Off
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
          - flavor
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateVmDetails_c
          - FAILURE: on_failure
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
    - vRA_DeploymentPowerOnPowerOff:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_DeploymentPowerOnPowerOff:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${VRADeploymentId}'
            - action: '${lifecycle_action}'
        publish:
          - result
          - first_line_body: '${message}'
          - errorMessage
          - errorProvider
          - errorType
          - message
          - flavor: ''
        navigate:
          - SUCCESS: mail_onVMDeployment
          - FAILURE: on_failure
    - get_InstanceSize_fmSysProps:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: "${get_sp('Cerner.DigitalFactory.DFMP.InstanceSize')}"
            - json_path: '${instance_size}'
        publish:
          - requested_flavor: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
        navigate:
          - SUCCESS: decode_direct_values
          - FAILURE: on_failure
    - decode_direct_values:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.decode_direct_values:
            - direct_values: '${input_list}'
        publish:
          - StartDate
          - EndDate
          - DeploymentName
          - OSVersion: '${Version}'
          - DeployUser
          - Password
          - result
          - message
          - errorType
          - os_type
        navigate:
          - SUCCESS: check_OSTypeLinux
          - FAILURE: on_failure
    - check_OSTypeLinux:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${os_type}'
            - second_string: Linux
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_action_info
          - FAILURE: set_action_info_windows
    - set_action_info:
        do:
          io.cloudslang.base.utils.do_nothing:
            - action_info: "${'{\"flavor\":\"' + requested_flavor + '\",\"sshpassword\":\"' + Password + '\", \"deploy_user\":\"' + DeployUser + '\",\"linux_version\":\"' + OSVersion + '\"}'}"
        publish:
          - action_info
        navigate:
          - SUCCESS: vRA_DeploymentActions
          - FAILURE: on_failure
    - set_action_info_windows:
        do:
          io.cloudslang.base.utils.do_nothing:
            - action_info: "${'{\"windows_version\":\"' + OSVersion + '\",\"flavor\":\"' + requested_flavor + '\", \"deploy_user\":\"' + DeployUser + '\",\"winpassword\":\"' + Password + '\"}'}"
        publish:
          - action_info
        navigate:
          - SUCCESS: vRA_DeploymentActions
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
    - get_DeploymentIdandSubscriptionsStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.SMAX.SubFlows.get_DeploymentIdandStatus:
            - SMAXRequestID: '${SMAXRequestID}'
            - smax_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - query_field: "${\"VRADeploymentId_c,'\" + VRADeploymentId +\"'\"}"
        publish:
          - subscription_status
          - subscription_name
          - DeploymentName: '${subscription_name}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: Is_Subscription_Active
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
      get_DeploymentIdandStatus:
        x: 360
        'y': 40
      check_deployment_action_Modify:
        x: 900
        'y': 117
      initialize_flow_output:
        x: 37
        'y': 287
      mail_onVMDeployment:
        x: 232
        'y': 578
      SMAX_entityOperations_UpdateVmDetails_c:
        x: 440
        'y': 600
      Is_Subscription_Cancelled:
        x: 233
        'y': 291
      vRA_checkDeploymentStatus:
        x: 598
        'y': 611
      decode_direct_values:
        x: 1069
        'y': 234
      get_InstanceSize_fmSysProps:
        x: 735
        'y': 270
      check_lifecycle_action_PowerOn_or_Off:
        x: 695
        'y': 126
      vRA_DeploymentPowerOnPowerOff:
        x: 527
        'y': 311
      Is_Subscription_Active:
        x: 556
        'y': 121
      SMAX_entityOperations_CloseRequest:
        x: 108
        'y': 460
        navigate:
          38578115-a178-cf6c-d34a-5411f345d3a1:
            targetId: 18e072b4-bde7-0133-9e88-1c85a2db458c
            port: SUCCESS
      set_action_info:
        x: 757
        'y': 451
      get_DeploymentIdandSubscriptionsStatus:
        x: 480
        'y': 40
      get_vRAToken:
        x: 241
        'y': 107
      vRA_DeploymentActions:
        x: 856
        'y': 611
      set_action_info_windows:
        x: 998
        'y': 479
      get_SMAXToken:
        x: 36
        'y': 111
      check_OSTypeLinux:
        x: 893
        'y': 361
    results:
      SUCCESS:
        18e072b4-bde7-0133-9e88-1c85a2db458c:
          x: 41
          'y': 597
