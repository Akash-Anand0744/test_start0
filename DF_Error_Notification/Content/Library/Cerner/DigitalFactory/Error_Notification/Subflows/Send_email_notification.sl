########################################################################################################################
#!!
#! @input error_code: Code of the Error
#! @input error_level: Level of Error DEBUG, INFO, WARNING, ERROR, CRITICAL
#! @input error_message: Standard description of Error
#! @input error_provider: error provider like Jira, GIT,WIKI, SMAX etc. Error generated while executing action against the provider
#! @input requestor_email: Optional: mail id of the Requestor. Ignored if NULL
#! @input operator_email: Operator Email to be notified of the message
#! @input email_subject: Optional: Subject for the Email
#! @input operator_email_body: Optional: Body of the email to be sent for Operator
#! @input requestor_email_body: Optional: Body of mail for Requestor
#! @input smax_request_number: Optional: but required for flows supporting SMAX Offerings
#! @input smax_request_summary: Unable to load description
#! @input inform_user: Send notification  mail to user or not Values  Null or Not Null
#! @input no_operator_mail: whether mail to operator or not
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Subflows
flow:
  name: Send_email_notification
  inputs:
    - error_code: e9999
    - error_level: ERROR
    - error_message: Failed to connect the service and timedout
    - error_provider: OOExecution
    - requestor_email:
        default: ''
        required: false
    - operator_email: rakesh.sharma@cerner.com
    - email_subject:
        required: false
    - operator_email_body:
        required: false
    - requestor_email_body:
        required: false
    - signature: "${get_sp('Cerner.DigitalFactory.Error_Notification.signature')}"
    - smax_request_number:
        required: false
    - smax_request_summary:
        required: false
    - inform_user:
        default: ''
        required: false
    - no_operator_mail:
        required: false
  workflow:
    - string_equals_email_subject:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${email_subject}'
            - do_one_time: not done
            - error_message: "${cs_replace(error_message,'<','&lt;')}"
        publish:
          - do_one_time_out: '${do_one_time}'
          - oo_central_url: "${'%s' % (get_sp('io.cloudslang.microfocus.oo.central_url'))}"
          - oo_run_id: '${run_id}'
          - run_name: ''
          - operator_mail_subject: '${first_string}'
          - requestor_mail_subject: '${first_string}'
          - mpp_url: "${get_sp('MarketPlace.smaxURL')}"
          - mpp_tenant_id: "${get_sp('MarketPlace.tenantID')}"
          - error_message
        navigate:
          - SUCCESS: get_flow_details_flow_run_name
          - FAILURE: string_equals_Request_number
    - string_equals_operator_email_body:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${operator_email_body}'
        publish:
          - runbook_url: 'https://cernerprod.sharepoint.com/:w:/s/DigitalFactoryInternal122/EfNuhvvHNtdPtTuBpQL0bt4BZh7DeJHDCyU_NcStfzXxmw?e=aNyN2J&isSPOFile=1'
          - runbook_url_marketplace: "${get_sp('Cerner.DigitalFactory.Error_Notification.runbook_url_marketplace')}"
          - runbook_url_schedules: "${get_sp('Cerner.DigitalFactory.Error_Notification.runbook_url_schedules')}"
          - runbook_url_eod: "${get_sp('Cerner.DigitalFactory.Error_Notification.runbook_url_eod')}"
          - email_body: '${first_string}'
        navigate:
          - SUCCESS: set_operator_email_body
          - FAILURE: send_mail
    - set_operator_email_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - email_body: "${'''\\\n<html>\n  <head></head>\n  <body>\n    <p>Dear Operator,<br><br>\n\n      {operator_body_line1}. The run id of associated failed OO Flow is\n      <b> <a href=\"{oo_central_url}/#/runtimeWorkspace/runs/{run_id}\"> {run_id}</a>: {run_name} </b> <br>\n      Below is the error message:<br><br>\n      <b> {error_provider} {error_code} {error_level}: {error_message}   </b><br><br>\n\n      Kindly fix the failures and validate the services.<br><br>\n\n      Yours Sincerely,<br>\n      {signature}<br>\n      ----------------------------------------------------------------\n<pre><b>Guidelines:</b> 1. For handling Support Request / Incident creation Flow failures, {runbook_url_marketplace}\n            2. For OO Schedule execution failures, {runbook_url_schedules}\n            3. For EOD subscription request failures, {runbook_url_eod}\n</pre><br>\n\n    </p>\n  </body>\n</html>\n'''.format(error_code=error_code,error_provider=error_provider,error_level=error_level,error_message=error_message,signature=signature,run_id=run_id,run_name=run_name,oo_central_url=oo_central_url,operator_body_line1=operator_body_line1,runbook_url_marketplace=runbook_url_marketplace,runbook_url_schedules=runbook_url_schedules,runbook_url_eod=runbook_url_eod)}"
            - email_subject: '${operator_mail_subject}'
        publish:
          - email_body
          - email_subject
        navigate:
          - SUCCESS: Send_Operator_Mail
          - FAILURE: on_failure
    - send_mail:
        do:
          io.cloudslang.base.mail.send_mail:
            - hostname: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_HOST')}"
            - port: "${get_sp('Cerner.DigitalFactory.Error_Notification.SMTP_PORT')}"
            - from: "${get_sp('Cerner.DigitalFactory.Error_Notification.ERROR_EMAIL_FROM')}"
            - to: '${operator_email}'
            - subject: '${email_subject}'
            - body: '${email_body}'
        publish:
          - return_result
          - return_code
          - exception
        navigate:
          - SUCCESS: is_done_reciver
          - FAILURE: on_failure
    - string_equals_requestor_email:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${requestor_email}'
        publish:
          - do_one_time_out: done
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: string_equals_requestor_email_body
    - set_requestor_email_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - requestor_email: '${requestor_email}'
            - mpp_url: "${get_sp('MarketPlace.smaxURL')}"
            - mpp_tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - email_subject: '${requestor_mail_subject}'
            - email_body: "${'''\\\n<html>\n  <head></head>\n  <body>\n    <p>Greetings,<br><br>\n\n      Your request {smax_request_number} has encountered an issue and fulfilment has been delayed.<br>\n\n      Our Support Engineers are working on it, you may check the status of your request\n\n      <b> <a href=\"{mpp_url}/saw/ess/requestTracking/{smax_request_number}?TENANTID={mpp_tenant_id}\"> here </a></b>\n\n      <br><br></p>\n\n\n      Yours Sincerely,<br>\n      {signature} <br>\n      ----------------------------------------------------------------<br>\n\n     {note_requestor_mail}\n\n  </body>\n</html>\n'''.format(signature=signature,smax_request_number=smax_request_number,mpp_url=mpp_url,mpp_tenant_id=mpp_tenant_id,note_requestor_mail=note_requestor_mail)}"
        publish:
          - operator_email: '${requestor_email}'
          - email_subject
          - email_body
        navigate:
          - SUCCESS: send_mail
          - FAILURE: on_failure
    - string_equals_requestor_email_body:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${requestor_email_body}'
            - note_requestor_mail: "${get_sp('Cerner.DigitalFactory.Error_Notification.note_requestor_mail')}"
        publish:
          - note_requestor_mail
        navigate:
          - SUCCESS: set_requestor_email_body
          - FAILURE: send_mail
    - get_flow_details_flow_run_name:
        do:
          Cerner.DigitalFactory.Error_Notification.Subflows.get_flow_details:
            - flow_run_id: '${run_id}'
        publish:
          - run_json
          - start_time
          - run_status
          - result_status_type
          - raw_run_name: "${cs_json_query(run_json,'$.[0].executionName')}"
          - run_name: "${raw_run_name.strip('[\"').strip('\"]')}"
          - oo_central_url: "${'%s' % (get_sp('io.cloudslang.microfocus.oo.central_url'))}"
          - flow_run_id
        navigate:
          - FAILURE: on_failure
          - SUCCESS: set_subject
    - is_done_reciver:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${do_one_time_out}'
            - second_string: done
        publish:
          - do_one_time_out: done
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: string_equals_Inform_User_or_not
    - set_subject:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.set_subject:
            - smax_request_number: '${smax_request_number}'
            - smax_request_description: '${smax_request_summary}'
            - oo_run_id: '${flow_run_id}'
            - run_name: '${run_name}'
        publish:
          - result
          - message
          - operator_mail_subject
          - requestor_mail_subject
        navigate:
          - SUCCESS: string_equals_Request_number_1
          - FAILURE: on_failure
    - string_equals_Inform_User_or_not:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${inform_user}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: string_equals_requestor_email
    - string_equals_Request_number:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_number}'
        publish:
          - operator_body_line1: Exection of OO Action Flow has Failed
        navigate:
          - SUCCESS: string_equals_operator_email_body
          - FAILURE: set_subject_with_request_no
    - set_subject_with_request_no:
        do:
          io.cloudslang.base.utils.do_nothing:
            - email_subject1: "${'Request#' + smax_request_number + ': '  + email_subject}"
            - operator_body_line1: "${'''The request# <b> <a href=\"{mpp_url}/saw/Request/{smax_request_number}/general?TENANTID={mpp_tenant_id}\">{smax_request_number} </a></b> creation for end users has failed.'''.format(smax_request_number=smax_request_number,mpp_url=mpp_url,mpp_tenant_id=mpp_tenant_id)}"
        publish:
          - operator_mail_subject: '${email_subject1}'
          - requestor_mail_subject: '${email_subject1}'
          - operator_body_line1
        navigate:
          - SUCCESS: string_equals_operator_email_body
          - FAILURE: on_failure
    - string_equals_Request_number_1:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_number}'
        publish:
          - operator_body_line1: Exection of OO Action Flow has Failed
          - mpp_url: "${get_sp('MarketPlace.smaxURL')}"
          - mpp_tenant_id: "${get_sp('MarketPlace.tenantID')}"
        navigate:
          - SUCCESS: set_operator_body_line1_without_ReqNo
          - FAILURE: set_operator_body_line1_with_ReqNo
    - set_operator_body_line1_with_ReqNo:
        do:
          io.cloudslang.base.utils.do_nothing:
            - operator_body_line1: "${'''The request# <b> <a href=\"{mpp_url}/saw/Request/{smax_request_number}/general?TENANTID={mpp_tenant_id}\">{smax_request_number} </a></b> creation for end users has failed.'''.format(smax_request_number=smax_request_number,mpp_url=mpp_url,mpp_tenant_id=mpp_tenant_id)}"
        publish:
          - operator_body_line1
        navigate:
          - SUCCESS: string_equals_operator_email_body
          - FAILURE: on_failure
    - set_operator_body_line1_without_ReqNo:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - operator_body_line1: Exection of OO Action Flow has Failed
        navigate:
          - SUCCESS: string_equals_operator_email_body
          - FAILURE: on_failure
    - Send_Operator_Mail:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${no_operator_mail}'
        publish: []
        navigate:
          - SUCCESS: send_mail
          - FAILURE: string_equals_requestor_email
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_done_reciver:
        x: 920
        'y': 80
        navigate:
          6c549385-0ad9-fceb-6dd8-78fef610d6d0:
            targetId: 35cfa108-3a56-6e34-c656-ab62c07548b4
            port: SUCCESS
      set_operator_email_body:
        x: 480
        'y': 400
      string_equals_requestor_email_body:
        x: 766
        'y': 236
      set_operator_body_line1_with_ReqNo:
        x: 363
        'y': 176
      set_operator_body_line1_without_ReqNo:
        x: 360
        'y': 400
      string_equals_Inform_User_or_not:
        x: 920
        'y': 240
        navigate:
          e91e5aad-f758-035e-5c7c-5e97c4460644:
            targetId: 35cfa108-3a56-6e34-c656-ab62c07548b4
            port: SUCCESS
      string_equals_Request_number:
        x: 198
        'y': 116
      get_flow_details_flow_run_name:
        x: 41
        'y': 274
      send_mail:
        x: 680
        'y': 80
      string_equals_operator_email_body:
        x: 500
        'y': 107
      set_requestor_email_body:
        x: 671
        'y': 355
      set_subject:
        x: 200
        'y': 400
      string_equals_email_subject:
        x: 43
        'y': 103
      set_subject_with_request_no:
        x: 352
        'y': 20
      Send_Operator_Mail:
        x: 560
        'y': 560
      string_equals_requestor_email:
        x: 920
        'y': 560
        navigate:
          587e09fa-facb-e17d-418e-7fcfaa0d0185:
            targetId: 35cfa108-3a56-6e34-c656-ab62c07548b4
            port: SUCCESS
      string_equals_Request_number_1:
        x: 196
        'y': 257
    results:
      SUCCESS:
        35cfa108-3a56-6e34-c656-ab62c07548b4:
          x: 1160
          'y': 280
