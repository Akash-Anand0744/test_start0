########################################################################################################################
#!!
#! @description: this sub flow is used to fetch data from snowflake for ALVA project
#!               inputs
#!               string store usually store in DF_Common->Configuration->SystemProperties->Cerner->DigitalFactory->snowflake
#!               string format
#!               set of 4 parameters sets split by ||
#!               each parameter in the set split by |
#!               param 1-- main query the query select must be contain 2 fields at least as id , title
#!               param 2-- string 'yes' that indicate that the record need additional query this additional query must set on param 4 the value of the table is store in Description_c field  this field must be type RICH_TEXT, if the value is not the second query is omitted
#!               param 4-- entity to update
#!               Param 4-- second query, the query select must be contain 1 fields at least as id the remaining data will be written as columns in the result table, the param id will match with the param id of the Query 1
#!               Example
#!               select distinct sd.ARTIFACT_ID as id, sd.name as title,sd.name as description ,GETDATE() as update_date  from service_details_v sd |yes|AlvaServices_c|select distinct sd.ARTIFACT_ID as id, sdep.environment as environment, sdep.region as region , sdep.version as version from service_details_v sd join service_deployments_v sdep on sdep.service_hash = sd.service_hash ||
#!
#! @input snowflake_list: This is used for Dynamic Drop Menu, 4 parameter query| yes or not use second query| table to fill | second query let info in description as table ||
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.MarketPlace.DynamicDropDown.Schedule
flow:
  name: DynamicOptionSnowflake
  inputs:
    - snowflake_list: "${get_sp('Cerner.DigitalFactory.snowflake.snowflakeQueryList')}"
  workflow:
    - list_iterator_alva:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${snowflake_list}'
            - separator: '||'
        publish:
          - result_string
          - result_code: '${return_code}'
          - result_string_1: '${return_result}'
          - snowflake_query_list: '${result_string}'
        navigate:
          - HAS_MORE: get_alva_Parameter
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - get_alva_Parameter:
        do:
          io.cloudslang.base.utils.do_nothing:
            - db_query_list: '${snowflake_query_list}'
        publish:
          - db_query: "${db_query_list.split('|')[0]}"
          - table: "${db_query_list.split('|')[1]}"
          - smax_entity: "${db_query_list.split('|')[2]}"
          - db_query_table: "${db_query_list.split('|')[3]}"
        navigate:
          - SUCCESS: snowflakeQuery
          - FAILURE: on_failure
    - snowflakeQuery:
        do:
          Cerner.DigitalFactory.Common.snowflake.Operation.snowflakeQuery:
            - sqlQuery: '${db_query}'
        publish:
          - result
          - message
          - output_json
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
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
          - SUCCESS: check_if_had_table
          - FAILURE: on_failure
    - updateSMAX_Entity:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.updateSMAX_DynamicDropDownOptions:
            - smax_dynamic_option_app: '${smax_entity}'
            - jiradata_json: '${output_json}'
            - jira_id_list: '${id_list}'
            - update_days: '1'
        publish:
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: list_iterator_alva
          - FAILURE: on_failure
    - snowflakeQuery_for_table:
        do:
          Cerner.DigitalFactory.Common.snowflake.Operation.snowflakeQuery:
            - sqlQuery: '${db_query_table}'
        publish:
          - output_json1: '${output_json}'
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: tableCreator
          - FAILURE: on_failure
    - tableCreator:
        do:
          Cerner.DigitalFactory.Common.snowflake.Operation.tableCreator:
            - output_json: '${output_json}'
            - output_json_table: '${output_json1}'
            - previous_errorLogs: '${errorLogs}'
        publish:
          - output_json: '${jsonTable}'
          - errorProvider
          - errorMessage
          - message
        navigate:
          - SUCCESS: updateSMAX_Entity
          - FAILURE: on_failure
    - check_if_had_table:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${table}'
            - second_string: 'yes'
        navigate:
          - SUCCESS: snowflakeQuery_for_table
          - FAILURE: updateSMAX_Entity
  outputs:
    - message: '${message}'
    - result: '${result}'
    - errorSeverity: '${errorSeverity}'
    - errorType: '${errorType}'
    - errorProvider: '${errorProvider}'
    - errorMessage: '${errorMessage}'
    - errorLogs: '${errorLogs}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      list_iterator_alva:
        x: 480
        'y': 80
        navigate:
          045b8c8a-351c-ed45-6f76-f706ed8a3b8b:
            targetId: d72da8f4-e083-228a-9049-306854f22c7f
            port: NO_MORE
      get_alva_Parameter:
        x: 320
        'y': 80
      snowflakeQuery:
        x: 160
        'y': 80
      ExtractIdsFromSQLOutput:
        x: 160
        'y': 280
      updateSMAX_Entity:
        x: 480
        'y': 280
      snowflakeQuery_for_table:
        x: 320
        'y': 480
      tableCreator:
        x: 480
        'y': 480
      check_if_had_table:
        x: 160
        'y': 480
    results:
      SUCCESS:
        d72da8f4-e083-228a-9049-306854f22c7f:
          x: 680
          'y': 240
