########################################################################################################################
#!!
#! @input jiraAlign_smaxUpdate_list: Key Value Pair of jira API URL and SMAX Studio APP separated by  double "||"
#! @input update_days: No of days for updating the records, It will check if any record changed in last x days
#! @input jira_smaxUpdate_list: Key Value Pair of jira custom_fieldName and SMAX Studio APP separated by  double "||"
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.MarketPlace.DynamicDropDown.Schedule
flow:
  name: Schedule_UpdateDynamicDropDownOPtions
  inputs:
    - jiraAlign_smaxUpdate_list: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.jiraAlign_smaxUpdate_list')}"
    - update_days: '1'
    - jira_smaxUpdate_list: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.jira_smaxUpdate_list')}"
    - jira_dbQuery_list: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.jira_dbQueryList')}"
    - alva_Query_List: "${get_sp('Cerner.DigitalFactory.snowflake.snowflakeQueryList')}"
  workflow:
    - jiraAlign_list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${jiraAlign_smaxUpdate_list}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - key_value: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value
          - NO_MORE: jira_list_iterator_Key_value_list
          - FAILURE: on_failure
    - Get_JiraAlign_IdTitleDescription_JSON:
        do:
          Cerner.DigitalFactory.Common.JIRA_ALIGN.Operation.Get_JiraAlign_IdTitleDescription_JSON:
            - api_url: '${jira_api_url}'
        publish:
          - jira_data_json: '${return_json}'
          - jira_id_list: '${id_list}'
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: updateSMAX_DynamicDropDownOptions
          - FAILURE: on_failure
    - updateSMAX_DynamicDropDownOptions:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.updateSMAX_DynamicDropDownOptions:
            - smax_dynamic_option_app: '${smax_dynamic_option_app}'
            - jiradata_json: '${jira_data_json}'
            - jira_id_list: '${jira_id_list}'
            - update_days: '${update_days}'
        publish:
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: jiraAlign_list_iterator_Key_value_list
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - jira_api_url: "${key_value.split(',',1)[0].strip()}"
          - smax_dynamic_option_app: "${key_value.split(',',1)[1].strip()}"
        navigate:
          - SUCCESS: Get_JiraAlign_IdTitleDescription_JSON
          - FAILURE: on_failure
    - jira_list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${jira_smaxUpdate_list}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - key_value: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value_1
          - NO_MORE: dbQuery_list_iterator
          - FAILURE: on_failure
    - extract_key_value_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - projectName: "${key_value.split(',',1)[0].strip()}"
          - smax_dynamic_option_app: "${key_value.split(',',3)[2].strip()}"
          - fieldName: "${key_value.split(',',2)[1].strip()}"
          - issueType: "${key_value.split(',',3)[3].strip()}"
        navigate:
          - SUCCESS: dynamicMenuFromJira
          - FAILURE: on_failure
    - updateSMAX_DynamicDropDownOptions_JIRA:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.updateSMAX_DynamicDropDownOptions:
            - smax_dynamic_option_app: '${smax_dynamic_option_app}'
            - jiradata_json: '${jira_data_json}'
            - jira_id_list: '${jira_id_list}'
            - update_days: '${update_days}'
        publish:
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: jira_list_iterator_Key_value_list
          - FAILURE: on_failure
    - dynamicMenuFromJira:
        do:
          Cerner.DigitalFactory.MarketPlace.JIRA.Operation.dynamicMenuFromJira:
            - projectName: '${projectName}'
            - fieldName: '${fieldName}'
            - issueType: '${issueType}'
        publish:
          - result
          - message
          - newUpdateTime
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - jira_id_list: '${id_list}'
          - jira_data_json: '${return_json}'
        navigate:
          - SUCCESS: updateSMAX_DynamicDropDownOptions_JIRA
          - FAILURE: on_failure
    - msSqlQuery:
        do:
          Cerner.DigitalFactory.Common.DB.Operation.msSqlQuery:
            - database: '${db_name}'
            - sqlQuery: '${db_query}'
        publish:
          - result
          - output_json
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - message
        navigate:
          - SUCCESS: ExtractIdsFromSQLOutput
          - FAILURE: on_failure
    - ExtractIdsFromSQLOutput:
        do:
          Cerner.DigitalFactory.MarketPlace.DynamicDropDown.Schedule.ExtractIdsFromSQLOutput:
            - output_json: '${output_json}'
        publish:
          - id_list
          - result
          - message
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: updateSMAX_Entity
          - FAILURE: on_failure
    - updateSMAX_Entity:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.updateSMAX_DynamicDropDownOptions:
            - smax_dynamic_option_app: '${smax_entity}'
            - jiradata_json: '${output_json}'
            - jira_id_list: '${id_list}'
            - update_days: '${update_days}'
        publish:
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: dbQuery_list_iterator
          - FAILURE: on_failure
    - dbQuery_list_iterator:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${jira_dbQuery_list}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - db_query_list: '${result_string}'
        navigate:
          - HAS_MORE: get_dbQuery_Parameter
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - get_dbQuery_Parameter:
        do:
          io.cloudslang.base.utils.do_nothing:
            - db_query_list: '${db_query_list}'
        publish:
          - db_query: "${db_query_list.split('|')[0]}"
          - db_name: "${db_query_list.split('|')[1]}"
          - smax_entity: "${db_query_list.split('|')[2]}"
        navigate:
          - SUCCESS: msSqlQuery
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler_1:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      msSqlQuery:
        x: 240
        'y': 40
      jiraAlign_list_iterator_Key_value_list:
        x: 880
        'y': 40
      extract_key_value_1:
        x: 520
        'y': 440
      updateSMAX_Entity:
        x: 120
        'y': 240
      get_dbQuery_Parameter:
        x: 400
        'y': 40
      jira_list_iterator_Key_value_list:
        x: 720
        'y': 40
      ExtractIdsFromSQLOutput:
        x: 120
        'y': 40
      updateSMAX_DynamicDropDownOptions:
        x: 1080
        'y': 40
      extract_key_value:
        x: 880
        'y': 320
      dynamicMenuFromJira:
        x: 720
        'y': 440
      Get_JiraAlign_IdTitleDescription_JSON:
        x: 1080
        'y': 320
      dbQuery_list_iterator:
        x: 560
        'y': 40
        navigate:
          aab83d94-c071-faa1-99f3-3421baa7c027:
            targetId: 21fde5b0-4feb-959b-04b0-1af3e8a654bd
            port: NO_MORE
      updateSMAX_DynamicDropDownOptions_JIRA:
        x: 720
        'y': 240
    results:
      SUCCESS:
        21fde5b0-4feb-959b-04b0-1af3e8a654bd:
          x: 400
          'y': 280
