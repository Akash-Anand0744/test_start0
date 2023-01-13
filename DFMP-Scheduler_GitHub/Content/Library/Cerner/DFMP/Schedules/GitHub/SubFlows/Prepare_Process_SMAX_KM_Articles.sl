########################################################################################################################
#!!
#! @description: This subflow checks if GitHub Pages retrieved should be created or updated or deleted in SMAX. Depending on the conditions met, SMAX Articles are either created or updated or deleted within this subflow.
#!
#! @input SMAX_studio_app: SMAX entity where records should be added/ updated/ deleted
#! @input service_article_list: List of delimited SMAX KM Articles to process
#! @input new_external_id_list: List of new external IDs for Articles
#! @input smax_ext_id_list: List of external IDs for existing Articles in SMAX
#! @input extid_smaxid_articlehash: List of existing IDs, existing SMAX article ID and associated Hash
#! @input SourceSystem: Source system from where the data was retrieved for processing
#! @input token: SMAX Authentication token
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.SubFlows
flow:
  name: Prepare_Process_SMAX_KM_Articles
  inputs:
    - SMAX_studio_app
    - service_article_list: 'null'
    - new_external_id_list: 'null'
    - smax_ext_id_list: 'null'
    - extid_smaxid_articlehash: 'null'
    - SourceSystem
    - token
  workflow:
    - Is_service_article_list_empty:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.checkEmpty:
            - inputCheck: '${service_article_list}'
        publish:
          - empty_check_result: '${result}'
        navigate:
          - IS_EMPTY: Is_smax_ext_id_list_empty
          - NOT_EMPTY: for_each_article
    - check_payload_result:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${result}'
            - second_string: 'True'
            - ignore_case: 'true'
        navigate:
          - SUCCESS: SMAX_CreateUpdate_Article_API
          - FAILURE: for_each_article
    - Is_smax_ext_id_list_empty:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.checkEmpty:
            - inputCheck: '${smax_ext_id_list}'
        publish:
          - emptyCheck_result: '${result}'
        navigate:
          - IS_EMPTY: SUCCESS
          - NOT_EMPTY: for_each_article_deleteList
    - for_each_article:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${service_article_list}'
            - separator: ♪♪
        publish:
          - articleData: '${result_string}'
        navigate:
          - HAS_MORE: extract_data_fields_SMAX_KMArticle
          - NO_MORE: Is_smax_ext_id_list_empty
          - FAILURE: on_failure
    - extract_data_fields_SMAX_KMArticle:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.extract_data_fields_SMAX_KMArticle:
            - article: '${articleData}'
        publish:
          - result: '${result}'
          - message: '${message}'
          - service: '${service}'
          - new_ext_id: '${new_ext_id}'
          - title: '${title}'
          - article_hash: '${article_hash}'
          - article_body: '${article_body}'
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: Is_new_ext_id_In_smax_ext_id_list
          - FAILURE: on_failure
    - Is_new_ext_id_In_smax_ext_id_list:
        do:
          io.cloudslang.base.lists.contains:
            - container: '${smax_ext_id_list}'
            - sublist: '${new_ext_id}'
            - ignore_case: 'false'
        navigate:
          - SUCCESS: build_SMAX_KM_Article_Update_payload
          - FAILURE: build_SMAX_KM_Article_Create_payload
    - build_SMAX_KM_Article_Create_payload:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.build_SMAX_KM_Article_CreateOrUpdate_payload:
            - SMAX_studio_app: '${SMAX_studio_app}'
            - service: '${service}'
            - new_ext_id: '${new_ext_id}'
            - new_external_id_list: '${new_external_id_list}'
            - smax_ext_id_list: '${smax_ext_id_list}'
            - extid_smaxid_articlehash: '${extid_smaxid_articlehash}'
            - title: '${title}'
            - article_body: '${article_body}'
            - article_hash: '${article_hash}'
            - SourceSystem: '${SourceSystem}'
            - SMAX_Operation: CREATE
        publish:
          - result
          - message: '${message}'
          - SMAXPayload: '${smaxDataPayload}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: check_payload_result
          - FAILURE: on_failure
    - build_SMAX_KM_Article_Update_payload:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.build_SMAX_KM_Article_CreateOrUpdate_payload:
            - SMAX_studio_app: '${SMAX_studio_app}'
            - service: '${service}'
            - new_ext_id: '${new_ext_id}'
            - new_external_id_list: '${new_external_id_list}'
            - smax_ext_id_list: '${smax_ext_id_list}'
            - extid_smaxid_articlehash: '${extid_smaxid_articlehash}'
            - title: '${title}'
            - article_body: '${article_body}'
            - article_hash: '${article_hash}'
            - SourceSystem: '${SourceSystem}'
            - SMAX_Operation: UPDATE
        publish:
          - result
          - message: '${message}'
          - SMAXPayload: '${smaxDataPayload}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
        navigate:
          - SUCCESS: check_payload_result
          - FAILURE: on_failure
    - SMAX_CreateUpdate_Article_API:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.processSMAXData:
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - token: '${token}'
            - dataS: '${SMAXPayload}'
        publish:
          - result
          - message
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - smax_response
          - records
          - errorLogs
        navigate:
          - SUCCESS: for_each_article
          - FAILURE: on_failure
    - for_each_article_deleteList:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${smax_ext_id_list}'
        publish:
          - ext_id: '${result_string}'
        navigate:
          - HAS_MORE: Is_ext_id_In_new_external_id_list
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - build_SMAX_KM_Article_Delete_payload:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.build_SMAX_KM_Article_Delete_payload:
            - SMAX_studio_app: '${SMAX_studio_app}'
            - ext_id: '${ext_id}'
            - smax_ext_id_list: '${smax_ext_id_list}'
            - extid_smaxid_articlehash: '${extid_smaxid_articlehash}'
            - SourceSystem: '${SourceSystem}'
        publish:
          - result: '${result}'
          - message: '${message}'
          - smaxDataDelete: '${smaxDataDelete}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: SMAX_Delete_Article_API
          - FAILURE: on_failure
    - Is_ext_id_In_new_external_id_list:
        do:
          io.cloudslang.base.lists.contains:
            - container: '${new_external_id_list}'
            - sublist: '${ext_id}'
            - ignore_case: 'false'
        publish:
          - response: '${response}'
          - return_result: '${return_result}'
        navigate:
          - SUCCESS: for_each_article_deleteList
          - FAILURE: build_SMAX_KM_Article_Delete_payload
    - SMAX_Delete_Article_API:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.processSMAXData:
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - token: '${token}'
            - dataS: '${smaxDataDelete}'
        publish:
          - result: '${result}'
          - message: '${message}'
          - smax_response: '${smax_response}'
          - records: '${records}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: for_each_article_deleteList
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
  outputs:
    - message: '${message}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - errorType: '${errorType}'
    - errorLogs: '${errorLogs}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      build_SMAX_KM_Article_Update_payload:
        x: 680
        'y': 200
      build_SMAX_KM_Article_Delete_payload:
        x: 680
        'y': 600
      check_payload_result:
        x: 800
        'y': 400
      SMAX_CreateUpdate_Article_API:
        x: 480
        'y': 320
      SMAX_Delete_Article_API:
        x: 480
        'y': 640
      for_each_article:
        x: 280
        'y': 120
      build_SMAX_KM_Article_Create_payload:
        x: 880
        'y': 40
      Is_service_article_list_empty:
        x: 40
        'y': 120
      extract_data_fields_SMAX_KMArticle:
        x: 480
        'y': 40
      Is_ext_id_In_new_external_id_list:
        x: 520
        'y': 480
      Is_smax_ext_id_list_empty:
        x: 40
        'y': 440
        navigate:
          f63642f2-7831-60e4-d08c-7ee38599e9e7:
            targetId: 9b0bd13a-3414-ed11-806b-9383ae9730cf
            port: IS_EMPTY
      for_each_article_deleteList:
        x: 280
        'y': 440
        navigate:
          4ef4ea20-7e6e-57f4-1ed2-a7b0a6b43d1f:
            targetId: 9b0bd13a-3414-ed11-806b-9383ae9730cf
            port: NO_MORE
      Is_new_ext_id_In_smax_ext_id_list:
        x: 680
        'y': 40
    results:
      SUCCESS:
        9b0bd13a-3414-ed11-806b-9383ae9730cf:
          x: 320
          'y': 640
