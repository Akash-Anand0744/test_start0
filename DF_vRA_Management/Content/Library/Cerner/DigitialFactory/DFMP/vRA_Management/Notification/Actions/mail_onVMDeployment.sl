########################################################################################################################
#!!
#! @input vm_info_list: Key Value Pair separated by double pipe "||"
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Actions
flow:
  name: mail_onVMDeployment
  inputs:
    - requestor_email
    - SMAXRequestID
    - DeploymentName
    - first_line_body
    - vm_info_list
    - subject:
        required: false
    - action:
        default: ''
        required: false
  workflow:
    - CreateBody_VMDeployed:
        do:
          Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Operations.CreateBody_VMDeployed:
            - first_line_body: '${first_line_body}'
            - input_list: "${'DeploymentName,' + DeploymentName + '||' + vm_info_list}"
        publish:
          - mail_body
          - result
          - message
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: send_mail
          - FAILURE: on_failure
    - send_mail:
        do:
          io.cloudslang.base.mail.send_mail:
            - hostname: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_HOST')}"
            - port: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_PORT')}"
            - from: "${get_sp('Cerner.DigitalFactory.Error_Notification.ERROR_EMAIL_FROM')}"
            - to: '${requestor_email}'
            - subject: "${get('subject', 'Subscription Request# ' + SMAXRequestID +' ' + DeploymentName + ' Deployed Sucessfully')}"
            - body: '${mail_body}'
            - html_email: 'true'
        publish:
          - return_result
          - return_code
          - exception
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      send_mail:
        x: 540
        'y': 250
        navigate:
          21279cd4-3a1d-adca-4630-a4735d876ddc:
            targetId: c501231d-bd9d-8176-0c9c-d97fad75146b
            port: SUCCESS
      CreateBody_VMDeployed:
        x: 346
        'y': 246
    results:
      SUCCESS:
        c501231d-bd9d-8176-0c9c-d97fad75146b:
          x: 742
          'y': 256
