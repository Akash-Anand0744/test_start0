########################################################################################################################
#!!
#! @input requestor_email: Optional: mail id of the Requestor. Ignored if NULL
#! @input operator_email: Operator Email to be notified of the message
#! @input error_code: Code of the Error
#! @input error_level: Level of Error DEBUG, INFO, WARNING, ERROR, CRITICAL
#! @input error_message: Standard description of Error
#! @input error_provider: error provider like Jira, GIT,WIKI, SMAX etc. Error generated while executing action against the provider
#! @input email_subject: Optional: Subject for the Email
#! @input email_body: Optional: Body of the email to be sent
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Subflows
flow:
  name: Send_mail_notification
  inputs:
    - requestor_email:
        required: false
    - operator_email: rakesh.sharma@cerner.com
    - error_code: e9999
    - error_level: ERROR
    - error_message: Failed to connect the service and timedout
    - error_provider: OOExecution
    - email_subject:
        required: false
    - email_body:
        required: false
    - signature: Digital Factory SMAX Support Team
  workflow:
    - string_equals_email_subject:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${email_subject}'
        navigate:
          - SUCCESS: set_subject
          - FAILURE: string_equals_email_body
    - string_equals_email_body:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${email_body}'
        navigate:
          - SUCCESS: set_body
          - FAILURE: send_mail
    - set_subject:
        do:
          io.cloudslang.base.utils.do_nothing:
            - email_subject: '${error_level + ": While Executing the Action"}'
        publish:
          - email_subject
        navigate:
          - SUCCESS: string_equals_email_body
          - FAILURE: on_failure
    - set_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - email_body: "${'''\\\n<html>\n  <head></head>\n  <body>\n    <p>Greetings,<br><br>\n\n      Error occurred while executing the Actions. Below is the error message:<br><br>\n      <b> {error_provider} {error_code} {error_level}: {error_message}   </b><br><br>\n\n      Yours Sincerely,<br>\n      {signature}\n    </p>\n  </body>\n</html>\n'''.format(error_code=error_code,error_provider=error_provider,error_level=error_level,error_message=error_message,signature=signature)}"
        publish:
          - email_body
        navigate:
          - SUCCESS: send_mail
          - FAILURE: on_failure
    - send_mail:
        do:
          io.cloudslang.base.mail.send_mail:
            - hostname: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_HOST')}"
            - port: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_PORT')}"
            - from: "${get_sp('Cerner.DigitalFactory.Error_Notification.ERROR_EMAIL_FROM')}"
            - to: '${operator_email}'
            - cc: '${requestor_email}'
            - subject: '${email_subject}'
            - body: '${email_body}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      string_equals_email_subject:
        x: 152
        'y': 53
      string_equals_email_body:
        x: 393
        'y': 52
      set_subject:
        x: 147
        'y': 287
      set_body:
        x: 394
        'y': 280
      send_mail:
        x: 667
        'y': 54
        navigate:
          5203dd7b-d44c-579a-d6ea-025c827a0d7c:
            targetId: 35cfa108-3a56-6e34-c656-ab62c07548b4
            port: SUCCESS
    results:
      SUCCESS:
        35cfa108-3a56-6e34-c656-ab62c07548b4:
          x: 666
          'y': 290
