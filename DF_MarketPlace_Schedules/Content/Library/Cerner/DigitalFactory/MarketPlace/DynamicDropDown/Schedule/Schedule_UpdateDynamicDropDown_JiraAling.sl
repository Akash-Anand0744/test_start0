########################################################################################################################
#!!
#! @input jiraAlign_smaxUpdate_list: Key Value Pair of jira API URL and SMAX Studio APP separated by  double "||"
#! @input update_days: No of days for updating the records, It will check if any record changed in last x days
#! @input jira_smaxUpdate_list: Key Value Pair of jira custom_fieldName and SMAX Studio APP separated by  double "||"
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.MarketPlace.DynamicDropDown.Schedule
flow:
  name: Schedule_UpdateDynamicDropDown_JiraAling
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
          - NO_MORE: SUCCESS
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
          - SUCCESS: Get_JiraAlign_IdDescription_JSON
          - FAILURE: on_failure
    - Get_JiraAlign_IdDescription_JSON:
        do:
          Cerner.DigitalFactory.Common.JIRA_ALIGN.Operation.Get_JiraAlign_IdDescription_JSON:
            - api_url: '${jira_api_url}'
        publish:
          - jira_id_list: '${id_list}'
          - result
          - errorType
          - message
          - errorSeverity
          - errorProvider
          - errorMessage
          - jira_data_json: '${return_json}'
        navigate:
          - SUCCESS: updateSMAX_DynamicDropDownOptions
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
      jiraAlign_list_iterator_Key_value_list:
        x: 40
        'y': 40
        navigate:
          af212cd8-dc47-474c-2fd7-bd8df4bc9786:
            targetId: 21fde5b0-4feb-959b-04b0-1af3e8a654bd
            port: NO_MORE
      updateSMAX_DynamicDropDownOptions:
        x: 280
        'y': 40
      extract_key_value:
        x: 120
        'y': 200
      Get_JiraAlign_IdDescription_JSON:
        x: 320
        'y': 240
    results:
      SUCCESS:
        21fde5b0-4feb-959b-04b0-1af3e8a654bd:
          x: 40
          'y': 360
