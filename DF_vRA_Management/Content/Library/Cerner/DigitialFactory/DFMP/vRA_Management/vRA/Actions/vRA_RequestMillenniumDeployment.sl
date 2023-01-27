########################################################################################################################
#!!
#! @input get_values_fm_OOSysProps: Key Value Pair and Value from OOSysProps
#! @input direct_values: Key Value Pair Direct Values
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Actions
flow:
  name: vRA_RequestMillenniumDeployment
  inputs:
    - SMAXRequestID: '1234598'
    - requestor: RS091868
    - requestor_email: rakesh.sharma@cerner.com
    - get_values_fm_OOSysProps: 'Project_c,IOD-BETA||OSType_c,Linux||InstanceSize_c,Micro||'
    - direct_values: 'StartDate_c,1636527027243||EndDate_c,1636528027243||DeploymentName_c,Test Linux POC Marketplace vCenter||Version_c,Oracle Linux 7.9||DeployUser_c,RS091868||Password_c,testpasswd||'
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
          - os_type: ''
        navigate:
          - SUCCESS: get_values_fm_OOSysProps
          - FAILURE: on_failure
    - get_values_fm_OOSysProps:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.SubFlows.get_values_fm_OOSysProps:
            - get_values_fm_OOSysProps: '${get_values_fm_OOSysProps}'
        publish:
          - projectid
          - vRACatalogItemId
          - flavor
          - message
          - project
          - vra_catalog
        navigate:
          - SUCCESS: decode_direct_values
          - FAILURE: on_failure
    - decode_direct_values:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.decode_direct_values:
            - direct_values: '${direct_values}'
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
        navigate:
          - SUCCESS: get_SMAXToken
          - FAILURE: on_failure
    - set_httpClient_Body_for_vRADeployment:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{\"deploymentName\": \"' + DeploymentName + '\",\"reason\": null,\"projectId\": \"' + projectid + '\",\"bulkRequestCount\": 1,\"ownedBy\":\"' + requestor + '\",\"inputs\": { \"linux_version\": \"' + OSVersion + '\",\"flavor\": \"' + flavor + '\",\"deploy_user\": \"' + DeployUser + '\",\"sshpassword\": \"' + Password + '\" }}'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: vRA_RequestDeployment
          - FAILURE: on_failure
    - vRA_RequestDeployment:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_RequestDeployment:
            - vRA_bearer_token: '${bearerToken}'
            - catalog_id: '${vRACatalogItemId}'
            - body: '${httpClient_Body}'
        publish:
          - result
          - deploymentId
          - message
          - errorMessage
          - errorProvider
          - errorType
          - hostname: ''
          - ip_address: ''
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateSubscription_2
          - FAILURE: MainErrorHandler_1
    - get_DeploymentIdandStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.SMAX.SubFlows.get_DeploymentIdandStatus:
            - SMAXRequestID: '${SMAXRequestID}'
            - smax_token: '${smax_token}'
            - query_field: "${\"RequestId_c,'\" + SMAXRequestID +\"'\"}"
        publish:
          - deploymentId
          - subscription_status
          - entity_id
          - errorMessage
          - errorType
          - errorProvider
        navigate:
          - FAILURE: on_failure
          - SUCCESS: check_entity_id_isnull
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
    - check_deployment_id_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${deploymentId}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: check_OSTypeLinux
          - FAILURE: vRA_checkDeploymentStatus
    - SMAX_entityOperations_CreateSubscriptionRecord:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - operation: CREATE
            - smax_data: "${'RequestId_c,'+ SMAXRequestID + '||UserAssociateId_c,' + requestor + '||Project_c,' + project + '||SubscriptionName_c,' + DeploymentName + '||RequestedStartDate_c,' + StartDate + '||RequestedEndDate_c,' + EndDate + '||StartDate_c,' + StartDate + '||VmConfigSize_c,' + flavor + '||SubscriptionStatus_c,New||OsVersion_c,' + OSVersion + '||'}"
        publish:
          - entity_id
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: check_OSTypeLinux
          - FAILURE: on_failure
    - vRA_checkDeploymentStatus:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_checkDeploymentStatus:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${deploymentId}'
        publish:
          - result
          - message
          - hostname
          - ip_address
          - errorMessage
          - vm_state
          - errorProvider
          - errorType
          - vm_leaseExpireAt
          - os_type
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: MainErrorHandler_1
    - check_entity_id_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${entity_id}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SMAX_entityOperations_CreateSubscriptionRecord
          - FAILURE: check_deployment_id_isnull
    - SMAX_entityOperations_UpdateSubscription_1:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - operation: UPDATE
            - smax_data: "${'Id,'+ entity_id+ '||SubscriptionStatus_c,Failed||ServerName_c,'+hostname +'||IPAddress_c,' + ip_address + '||VRADeploymentId_c,' +deploymentId +'||DisplayLabel,'+ hostname + '||StatusMessage_c,' + message + '||OsType_c,' + os_type}"
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - mail_onVMDeployment:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Actions.mail_onVMDeployment:
            - requestor_email: '${requestor_email}'
            - SMAXRequestID: '${SMAXRequestID}'
            - DeploymentName: '${DeploymentName}'
            - first_line_body: "${'Your requested VM Subscription: ' + DeploymentName + ' has been deployed Sucessfully'}"
            - vm_info_list: "${'VM Lease Expire,'+ vm_leaseExpireAt +'||Host Name,' + hostname + '||IP Address,' + ip_address + '||OS Version,' + OSVersion + '||VM Power State,' + vm_state + '||User,' + DeployUser + '||Password,' + Password + '||'}"
            - subject: "${'Subscription Request# ' + SMAXRequestID +' ' + DeploymentName + ' Deployed Sucessfully'}"
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
    - check_OSTypeLinux:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vra_catalog}'
            - second_string: Linux
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_httpClient_Body_for_vRADeployment
          - FAILURE: set_httpClient_Body_for_vRADeployment_Windows
    - set_httpClient_Body_for_vRADeployment_Windows:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{\"deploymentName\": \"' + DeploymentName + '\",\"reason\": null,\"projectId\": \"' + projectid + '\",\"bulkRequestCount\": 1,\"ownedBy\":\"' + requestor + '\",\"inputs\": { \"windows_version\": \"' + OSVersion + '\",\"flavor\": \"' + flavor + '\",\"deploy_user\": \"' + DeployUser + '\",\"winpassword\": \"' + Password + '\" }}'}"
        publish:
          - httpClient_Body
        navigate:
          - SUCCESS: vRA_RequestDeployment
          - FAILURE: on_failure
    - MainErrorHandler_1:
        do:
          Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorProvider: '${errorProvider}'
            - errorSeverity: '${errorSeverity}'
            - smaxRequestNumber: '${SMAXRequestID}'
            - smaxRequestSummary: '${DeploymentName}'
            - smaxRequestorEmail: '${requestor_email}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SMAX_entityOperations_UpdateSubscription_1
    - vRA_DeploymentActions:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations.vRA_DeploymentActions:
            - vRA_bearer_token: '${bearerToken}'
            - deployment_id: '${deploymentId}'
            - action: ChangeOwner
            - action_info: '${requestor.split("@")[0]}'
        publish:
          - result
          - message
          - errorMessage
          - errorProvider
          - errorType
        navigate:
          - SUCCESS: mail_onVMDeployment
          - FAILURE: MainErrorHandler_1
    - SMAX_entityOperations_UpdateSubscription_2:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: SubscriptionDetails_c
            - operation: UPDATE
            - smax_data: "${'Id,'+ entity_id+ '||SubscriptionStatus_c,Provision||VRADeploymentId_c,' +deploymentId +'||StatusMessage_c,' + message}"
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: vRA_checkDeploymentStatus
          - FAILURE: on_failure
    - SMAX_entityOperations_CloseRequest:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - operation: UPDATE
            - smax_data: "${'Id,'+ SMAXRequestID + '||CompletionCode,CompletionCodeFulfilledByVRA_c||Solution, <p>Request fulfilled through vRA Automation</p><p>VM LeaseExpire: ' + vm_leaseExpireAt +'<br>Host Name: ' + hostname + '<br>IP Address: ' + ip_address + '<br>OS Version: ' + OSVersion + '</p>||'}"
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
    - SMAX_entityOperations_MultiRecords:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations_MultiRecords:
            - smax_auth_token: '${smax_token}'
            - smax_data: "${'SubscriptionDetails_c,UPDATE,' + 'Id,'+ entity_id+ '||SubscriptionStatus_c,Active||ServerName_c,'+hostname +'||IPAddress_c,' + ip_address + '||VRADeploymentId_c,' +deploymentId +'||DisplayLabel,'+ DeploymentName + '||StatusMessage_c,' + message + '||OsType_c,' + os_type + '|||' + 'VmDetails_c,CREATE,' + 'SubscriptionId_c,'+ entity_id+ '||VmStatus_c,Active||ServerName_c,'+hostname +'||IPAddress_c,' + ip_address + '||VRADeploymentId_c,' +deploymentId +'||DisplayLabel,'+ hostname + '||OsType_c,' + os_type + '||OsVersion_c,' + OSVersion + '||UserAssociateId_c,' + requestor + '||Project_c,' + project + '||VmConfigSize_c,' + flavor + '||VmStatus_c,Active||VmStatusDate_c,' + VmStatusDate}"
        publish:
          - result
          - message
          - entity_id
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: vRA_DeploymentActions
          - FAILURE: on_failure
    - get_millis_CurrentTime:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - VmStatusDate: '${time_millis}'
          - time_millis
        navigate:
          - SUCCESS: SMAX_entityOperations_MultiRecords
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
    - vRADeploymentId: '${deploymentId}'
    - VMName: '${hostname}'
    - IPAddress: '${ip_address}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_DeploymentIdandStatus:
        x: 173
        'y': 244
      initialize_flow_output:
        x: 40
        'y': 456
      mail_onVMDeployment:
        x: 520
        'y': 600
      vRA_checkDeploymentStatus:
        x: 840
        'y': 360
      set_httpClient_Body_for_vRADeployment:
        x: 672
        'y': 41
      get_values_fm_OOSysProps:
        x: 164
        'y': 388
      decode_direct_values:
        x: 38
        'y': 288
      set_httpClient_Body_for_vRADeployment_Windows:
        x: 674
        'y': 175
      SMAX_entityOperations_MultiRecords:
        x: 840
        'y': 520
      SMAX_entityOperations_CreateSubscriptionRecord:
        x: 320
        'y': 40
      MainErrorHandler_1:
        x: 1092
        'y': 402
      check_entity_id_isnull:
        x: 330
        'y': 244
      check_deployment_id_isnull:
        x: 499
        'y': 246
      get_millis_CurrentTime:
        x: 520
        'y': 400
      SMAX_entityOperations_CloseRequest:
        x: 320
        'y': 600
        navigate:
          c1caac16-851c-9f97-085d-1b12ad05351d:
            targetId: 18e072b4-bde7-0133-9e88-1c85a2db458c
            port: SUCCESS
      vRA_RequestDeployment:
        x: 836
        'y': 36
      SMAX_entityOperations_UpdateSubscription_1:
        x: 1091
        'y': 218
        navigate:
          11a2ba95-43b5-8ab5-bf07-8c0c3c6fe3b0:
            targetId: cbc44b7d-046d-dca6-6b1f-c3258f7e0c26
            port: SUCCESS
      SMAX_entityOperations_UpdateSubscription_2:
        x: 843
        'y': 186
      get_vRAToken:
        x: 167
        'y': 110
      vRA_DeploymentActions:
        x: 1080
        'y': 600
      get_SMAXToken:
        x: 33
        'y': 100
      check_OSTypeLinux:
        x: 490
        'y': 51
    results:
      FAILURE:
        cbc44b7d-046d-dca6-6b1f-c3258f7e0c26:
          x: 1083
          'y': 37
      SUCCESS:
        18e072b4-bde7-0133-9e88-1c85a2db458c:
          x: 320
          'y': 400
