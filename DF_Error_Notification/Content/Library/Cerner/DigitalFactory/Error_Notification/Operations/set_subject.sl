namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: set_subject
  inputs:
    - smax_request_number:
        required: false
    - smax_request_description:
        required: false
    - oo_run_id
    - run_name
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for Writing Logs in logfile for Error Logger\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       -  smax_request_number\r\n#       -  smax_request_description\r\n#       -  oo_run_id\r\n#       -  run_name\r\n#\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - operator_mail_subject\r\n#       - requestor_mail_subject\r\n#   Created On: 08 Ocp 2021\r\n#\r\n#  -------------------------------------------------------------\r\n#   Modified On\t:\r\n#   Modified By\t:\r\n#   Modification:\r\n#################################################################\r\n\r\ndef execute(smax_request_number, smax_request_description, oo_run_id, run_name):\r\n    message = \"\"\r\n    result = \"True\"\r\n    subject = \"\"\r\n    requestor_mail_subject = \"\"\r\n    operator_mail_subject = \"\"\r\n\r\n    try:\r\n        if smax_request_number:\r\n            subject = 'Request#' + str(smax_request_number) + ': '\r\n        if smax_request_description:\r\n            subject += smax_request_description\r\n            # set subject for requestor\r\n            requestor_mail_subject = subject + ' Encountered an Issue'\r\n        # if request number and request dscription null then set default subject for requestor\r\n        if smax_request_number and not smax_request_description:\r\n             requestor_mail_subject = subject + ' Encountered an Issue'\r\n        if not smax_request_number and not smax_request_description:\r\n            requestor_mail_subject = 'Your MarketPlace Request Encountered an Issue'\r\n        \r\n        # set subject for operator\r\n        if run_name:\r\n            if subject:\r\n                operator_mail_subject = subject + ': Flow ' + run_name + ' Execution FAILED'\r\n            else:\r\n                operator_mail_subject = 'Flow run id:' + str(oo_run_id) + ': ' + run_name + ' Execution FAILED'\r\n\r\n        # set success message\r\n        message = 'Subject defined successfully'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n\r\n    return {\"result\": result, \"message\": message, \"operator_mail_subject\": operator_mail_subject, \"requestor_mail_subject\": requestor_mail_subject}\r\n# you can add additional helper methods below."
  outputs:
    - result
    - message
    - operator_mail_subject
    - requestor_mail_subject
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
