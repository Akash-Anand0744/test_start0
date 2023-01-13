########################################################################################################################
#!!
#! @input Upn: Upn(EmailID) of the submtter
#!
#! @result SUCCESS: result=="True"
#!!#
########################################################################################################################
namespace: Cerner.DFMP.SMAX.SubFlows
flow:
  name: SubFlow_SMAXComments
  inputs:
    - conn_timeout:
        default: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
        required: false
    - smaxticketID:
        required: true
    - reporter:
        required: true
    - error_log_id:
        required: false
    - Upn
    - commentData
    - is_retry
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - token
          - errorMessage
          - message
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_Person_RequestorId
          - FAILURE: on_failure
    - SMAX_getEntityDetails_from_Person_RequestorId:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${token}'
            - entity: Person
            - query_field: "${\"Upn,'\" + reporter + \"'\"}"
            - entity_fields: Id
        publish:
          - result
          - records
          - requestor_person_id: "${cs_replace(cs_replace(cs_replace(cs_replace(entity_data_json[1:-1],'\"Id\":',''),'\"',''),'}',''),'{','')}"
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
        navigate:
          - SUCCESS: set_httpClient_Body
          - FAILURE: on_failure
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/336419949/collaboration/comments/Request/757350'}"
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - request_character_set: UTF-8
            - headers: null
            - body: "${cs_replace(cs_replace(httpClient_Body, \"\\\\\\\\\\\\\", \"\\\\\"), \"\\\\\\\\n\", \"\\\\n\")}"
            - content_type: application/json; charset=UTF-8
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
          - jiraInstanceIdJSON: '${error_message}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - set_httpClient_Body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: '{"IsSystem": false,"Body": "testnnn","CommentFrom": "User","CommentTo": "Agent","Media": "UI","ActualInterface": "ESS","FunctionalPurpose": "EndUserComment","Submitter": {"UserId": "17431"}}'
        publish:
          - httpClient_Body: "${cs_replace(httpClient_Body,\"\\\\'\",\"'\")}"
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - errorLogs: '${errorLogs}'
                - isRetry: '${is_retry}'
  outputs:
    - result
    - message
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 80
        'y': 160
      SMAX_getEntityDetails_from_Person_RequestorId:
        x: 240
        'y': 160
      http_client_post:
        x: 560
        'y': 160
        navigate:
          88bca623-0929-532b-8d2a-bfcb4564176d:
            targetId: 3a81416c-195c-aea9-eb25-480ab50795ff
            port: SUCCESS
      set_httpClient_Body:
        x: 400
        'y': 160
    results:
      SUCCESS:
        3a81416c-195c-aea9-eb25-480ab50795ff:
          x: 760
          'y': 160
