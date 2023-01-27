########################################################################################################################
#!!
#! @input friendlyErrorMessage: Friendly Error Message to be displayed to User
#! @input errorType: error number from Error Class
#! @input errorMessage: message to be logged
#! @input errorProvider: provider that has raised exception
#! @input errorSeverity: error severity
#! @input conf: configuration of error handlers
#! @input smaxRequestNumber: smax request number if needed
#! @input smaxRequestSummary: Unable to load description
#! @input smaxRequestorEmail: smax requestor email if needed
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.DFCP.Error_Notification.Actions
flow:
  name: MainErrorHandler_WrapperForEOD
  inputs:
    - friendlyErrorMessage:
        required: false
    - errorType:
        required: false
    - errorMessage:
        required: false
    - errorProvider:
        default: OO_FLOW
        required: false
    - errorSeverity:
        default: ERROR
        required: false
    - conf: "${get_sp('Cerner.DigitalFactory.Error_Notification.config')}"
    - smaxRequestNumber:
        default: ''
        required: false
    - smaxRequestSummary:
        default: ''
        required: false
    - smaxRequestorEmail:
        default: ''
        required: false
    - svc_instance_id: '[TOKEN:SVC_INSTANCE_ID]'
    - svc_component_id: '[TOKEN:SVC_COMPONENT_ID]'
    - svc_component_type: '[TOKEN:SVC_COMPONENT_TYPE]'
    - prn_component_id:
        default: '[TOKEN:PRN_COMPONENT_ID]'
        required: false
  workflow:
    - MainErrorHandler:
        do:
          Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
            - errorType: '${errorType}'
            - errorMessage: '${errorMessage}'
            - errorProvider: '${errorProvider}'
            - errorSeverity: '${errorSeverity}'
            - conf: '${conf}'
            - smaxRequestNumber: '${smaxRequestNumber}'
            - smaxRequestSummary: '${smaxRequestSummary}'
            - smaxRequestorEmail: '${smaxRequestorEmail}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      MainErrorHandler:
        x: 317
        'y': 187.6666717529297
        navigate:
          e135825a-4180-dff4-2a87-c4183a475cd7:
            targetId: 1b18ca4c-a265-385c-64a1-9884e55684f4
            port: SUCCESS
    results:
      SUCCESS:
        1b18ca4c-a265-385c-64a1-9884e55684f4:
          x: 548
          'y': 187
