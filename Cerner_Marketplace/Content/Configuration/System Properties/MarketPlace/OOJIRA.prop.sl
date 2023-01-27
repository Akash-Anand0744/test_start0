########################################################################################################################
#!!
#! @input is_onboarding_access_management: Is this Onboarding Access Management Offering, Allowed Values 'Yes' or 'No'. Default Value is 'No'
#! @input offering_name: Name of the Offering for creating new Requests
#! @input project_tool_mapping: jira project and jira tool mapping, project,tool1,tool2,||project,tool||project,default||  --tool value as default for project being default for tools
#! @input request_tools: Comma separated list of JiraTools and first value should be the Jira tool field name like Key1,value1,value2,value3, etc.
#! @input smaxRequestID: SMAX Request ID
#! @input reporter: Issue Reporter
#! @input watchers: Watcher(s) and NoWatcher if JIRA Project does not have watchers enabled.
#! @input requestorEmail: requestor email
#! @input description: Description of the Request or Issue
#! @input summary: Summary title of the Request
#! @input fields_append_toDescription: Fields that will be appended to Description field. Prefix all fields with toolname and "!" like tool!key1,value1||tool!key2,value2|| --tool value as Common if value common for all tools
#! @input request_common_fields: Common request fields for all Tools like Project, priority, issuetype etc.  Add "id." as prefix to Key for sending ID values to Jira, Key Value Pair with delimiter (||) as Key1,Value1||Key2,Value2||
#! @input get_jira_fields_fm_smax_config: Get Jira Custom Fields from SMAX Configuration, Prefix all fields with toolname and "!" like tool!fieldname1,value1||tool!fieldname2,value2||
#! @input get_jira_fields_fm_oo_config: Get Jira Custom Fields from OO System Properties, Prefix all fields with toolname and "!" like tool!fieldname1,value1||tool!fieldname2,value2||
#! @input get_id_value_fm_oo_config: Get ID value for Jira Fields from OO System Properties, Fields like project, issueType, jiraTool etc. Corresponding OO System Property must exist like project_JSON, issueType_JSON , jiraTool_JSON,Prefix all fields with toolname and "!" like tool!fieldname1,value1||tool!fieldname2,value2||
#! @input hide_fields_In_Jira: Coma separated list for Jira Fields which needs to be hidden, not visible to User, Prefix all fields with toolname and "!" like tool!fieldname1,value1||tool!fieldname2,value2||
#!!#
########################################################################################################################
namespace: Cerner.Integrations.SMAX.Actions
flow:
  name: Create_MultipleSMAXnJiraRequests_Framework
  inputs:
    - is_onboarding_access_management: 'No'
    - offering_name: Associate and Contractor Onboarding-Template
    - project_tool_mapping
    - request_tools
    - smaxRequestID
    - reporter
    - watchers:
        required: false
    - requestorEmail
    - description
    - summary
    - fields_append_toDescription:
        default: ''
        required: false
    - request_common_fields:
        required: true
    - get_jira_fields_fm_smax_config:
        default: ''
        required: false
    - get_jira_fields_fm_oo_config:
        default: ''
        required: false
    - get_id_value_fm_oo_config:
        default: ''
        required: false
    - hide_fields_In_Jira:
        default: ''
        required: false
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - smax_token: '${token}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - requestCreationStatus: INPROGRESS
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_MultipleSMAXnJiraRequests
          - FAILURE: on_failure
    - Create_JiraRequest_Framework:
        do:
          Cerner.Integrations.Jira.Create_JiraRequest_Framework:
            - smaxRequestID: '${smax_request_id_tool}'
            - reporter: '${reporter}'
            - watchers: '${watchers_tool}'
            - requestorEmail: '${requestorEmail}'
            - description: '${description_tool}'
            - fields_append_toDescription: '${fields_append_toDescription_tool}'
            - jira_direct_fields: '${jira_direct_fields_tool}'
            - get_jira_fields_fm_smax_config: '${get_jira_fields_fm_smax_config_tool + request_common_fields_tool}'
            - get_jira_fields_fm_oo_config: '${get_jira_fields_fm_oo_config_tool}'
            - get_id_value_fm_oo_config: '${get_id_value_fm_oo_config_tool}'
            - hide_fields_In_Jira: '${hide_fields_In_Jira_tool}'
        publish:
          - incidentCreationCode
          - incidentCreationResultJSON
          - jiraIssueURL
          - jiraIssueId: "${cs_replace(cs_replace(cs_json_query(incidentCreationResultJSON,'key'),'[\"',''),'\"]','')}"
        navigate:
          - FAILURE: set_request_status
          - SUCCESS: set_jira_remedy_issue_urls
    - SMAX_getEntityDetails_from_MultipleSMAXnJiraRequests:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: MultipleSMAXnJiraRequests_c
            - query_field: "${\"ParentRequestId_c,'\" + smaxRequestID +\"'\"}"
            - entity_fields: 'Id,ParentRequestId_c,RequestId_c,RequestTool_c,JiraIssueId_c'
        publish:
          - result
          - MultipleSMAXnJIra_records: '${records}'
          - data_json_MultipleSMAXnJiraRequests: '${entity_data_json[1:-1]}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
          - resolution_comment: '<table><tr> <th style="width:60px">MP Request#</th>   <th style="width:200px">Requested Jira Tool</th><th style="width:200px">Jira#/Remedy#</th></tr>'
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_GetOffeing_ID
          - FAILURE: on_failure
    - MultipleSMAXnJIra_Entity_ReturnRecords_Null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${MultipleSMAXnJIra_records}'
            - second_string: '0'
            - ignore_case: 'true'
        publish:
          - smax_request_already_created: ''
        navigate:
          - SUCCESS: prepareValues_for_jiraToolRequest_1
          - FAILURE: string_occurrence_counter_ifSMAXRequestCreated
    - list_iterator_RequestTools:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${jira_tool_value}'
            - separator: ','
        publish:
          - result_string
          - return_result
          - return_code
          - jira_request_tool: '${result_string.strip()}'
        navigate:
          - HAS_MORE: getProjectTool
          - NO_MORE: is_onboarding_access_mgmt
          - FAILURE: on_failure
    - extract_jiraToolkey_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: "${request_tools.strip(']').strip('[')}"
        publish:
          - jira_tool_key: "${key_value.split(',',1)[0].strip()}"
          - jira_tool_value: "${cs_replace(cs_replace(key_value.split(',',1)[1].strip(),']',''),'[','')}"
        navigate:
          - SUCCESS: If_jira_tool_is_null
          - FAILURE: on_failure
    - SMAX_entityOperations_CreateRequest:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - operation: CREATE
            - smax_data: "${'RequestsOffering,' + Offering_Id + '||Description,' + description_tool + '||DisplayLabel,' + summary_tool+ '||Summary_c,' + summary_tool+ '||Priority,MediumPriority'  + '||JiraToolRequest_c,' + jira_request_tool+ '||RequestType,ServiceRequest||RequestedByPerson,' +requestor_person_id + '||'}"
            - is_custom_app: 'No'
        publish:
          - result
          - smax_request_id_tool: '${entity_id}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: SMAX_entityOperations_CreateAssociateOnBoarding_record
          - FAILURE: on_failure
    - SMAX_entityOperations_CreateAssociateOnBoarding_record:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: MultipleSMAXnJiraRequests_c
            - operation: CREATE
            - smax_data: "${'ParentRequestId_c,' +smaxRequestID + '||RequestId_c,' +smax_request_id_tool + '||RequestTool_c,' + jira_request_tool+ '||RequestSummary_c,' +summary_tool + '||DisplayLabel,'+summary_tool + '||RequestDescription_c,'+ description_tool + '||'}"
            - is_custom_app: 'Yes'
        publish:
          - result
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - message
          - associate_onboarding_entity_id: '${entity_id}'
        navigate:
          - SUCCESS: Is_tool_Remedy
          - FAILURE: on_failure
    - SMAX_entityOperations_UpdateAssociateOnBoarding_record:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: MultipleSMAXnJiraRequests_c
            - operation: UPDATE
            - smax_data: "${'Id,' +associate_onboarding_entity_id + '||JiraIssueId_c,' +jiraIssueId + '||'}"
            - is_custom_app: 'Yes'
            - resolution_comment: '${resolution_comment}'
            - smax_request_id_tool: '${smax_request_id_tool}'
            - jira_request_tool: '${jira_request_tool}'
            - jiraIssueId: '${jiraIssueId}'
            - smax_request_tool_url: "${'<a href=\"{0}/saw/ess/requestTracking/{1}\">{1}</a>'.format(get_sp('Cerner.DigitalFactory.SMAX.smaxURL'),smax_request_id_tool)}"
            - jira_request_tool_url: '${jira_request_tool_url}'
        publish:
          - result
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - resolution_comment: "${resolution_comment + '<tr><td>{0}</td><td>{1}</td> <td>{2}</td></tr>'.format(smax_request_tool_url,jira_request_tool.split('|')[0],jira_request_tool_url)}"
          - associate_onboarding_entity_id: '${entity_id}'
        navigate:
          - SUCCESS: list_iterator_RequestTools
          - FAILURE: on_failure
    - string_occurrence_counter_ifSMAXRequestCreated:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: '${data_json_MultipleSMAXnJiraRequests}'
            - string_to_find: '${jira_request_tool}'
        publish:
          - return_result
          - return_code
          - error_message
        navigate:
          - SUCCESS: list_iterator_RequestTools_SMAXRecords
          - FAILURE: prepareValues_for_jiraToolRequest_1
    - list_iterator_RequestTools_SMAXRecords:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${data_json_MultipleSMAXnJiraRequests}'
            - separator: '},'
        publish:
          - result_string
          - return_result
          - return_code
          - SMAXRecord: "${result_string + '}'}"
        navigate:
          - HAS_MORE: get_SMAXRecord_fieldValues
          - NO_MORE: list_iterator_RequestTools_SMAXRecords_1
          - FAILURE: on_failure
    - get_SMAXRecord_fieldValues:
        do:
          io.cloudslang.base.utils.do_nothing:
            - SMAXRecord: "${cs_replace(SMAXRecord,'}}','}')}"
        publish:
          - smax_request_tool: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'RequestTool_c'),']',''),'[',''),'\"','')}"
          - smax_request_id_tool: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'RequestId_c'),']',''),'[',''),'\"','')}"
          - associate_onboarding_entity_id: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'Id'),']',''),'[',''),'\"','')}"
          - jiraIssueId: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'JiraIssueId_c'),']',''),'[',''),'\"','')}"
        navigate:
          - SUCCESS: Entity_ReturnRecords_tool_found
          - FAILURE: on_failure
    - Entity_ReturnRecords_tool_found:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_request_tool}'
            - second_string: '${smax_request_tool}'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: Entity_ReturnRecords_tool_jiraIssueIdNotNUll
          - FAILURE: list_iterator_RequestTools_SMAXRecords
    - Entity_ReturnRecords_tool_jiraIssueIdNotNUll:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jiraIssueId}'
            - second_string: ''
            - ignore_case: 'true'
            - smax_request_already_created: 'Yes'
        publish:
          - smax_request_already_created
        navigate:
          - SUCCESS: prepareValues_for_jiraToolRequest_1
          - FAILURE: Is_tool_Remedy_1
    - SMAX_entityOperations_CloseRequest:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - operation: UPDATE
            - smax_data: "${'Id,'+ smaxRequestID + '||CompletionCode,CompletionCodeFulfilledInJira_c||Solution,' + resolution_comment + '||Status,RequestStatusComplete||CloseTime,' + EndDate + '||Summary_c,' + parent_offering_name + '||'}"
            - is_custom_app: 'No'
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - requestCreationStatus: SUCCESS
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - SMAX_getEntityDetails_from_GetOffeing_ID:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: Offering
            - query_field: "${\"DisplayLabel,'\" + offering_name + \"' and Status='Internal'\"}"
            - entity_fields: Id
        publish:
          - result
          - records
          - Offering_Id: "${cs_replace(cs_replace(cs_replace(cs_replace(entity_data_json[1:-1],'\"Id\":',''),'\"',''),'}',''),'{','')}"
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
        navigate:
          - SUCCESS: SMAX_getEntityDetails_from_Person_RequestorId
          - FAILURE: on_failure
    - SMAX_getEntityDetails_from_Person_RequestorId:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
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
          - SUCCESS: extract_jiraToolkey_value
          - FAILURE: on_failure
    - set_resolution_comment:
        do:
          io.cloudslang.base.utils.do_nothing:
            - resolution_comment: '${resolution_comment}'
            - jira_request_tool: "${jira_request_tool.split('|')[0]}"
            - smax_request_id_tool: '${smax_request_id_tool}'
            - smax_request_tool_url: "${'<a href=\"{0}/saw/ess/requestTracking/{1}\">{1}</a>'.format(smax_url,smax_request_id_tool)}"
            - jiraIssueId: '${jiraIssueId}'
            - jira_request_tool_url: "${'<a href=\"' +  get_sp('MarketPlace.jiraIssueURL') + 'browse/{0}\">{0}</a>'.format(jiraIssueId)}"
        publish:
          - resolution_comment: "${resolution_comment + '<tr><td>{0}</td><td>{1}</td> <td>{2}</td></tr>'.format(smax_request_tool_url,jira_request_tool,jira_request_tool_url)}"
        navigate:
          - SUCCESS: list_iterator_RequestTools
          - FAILURE: on_failure
    - set_request_status:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - requestCreationStatus: FAILED
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
    - get_millis_CurrentTime:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - EndDate: '${time_millis}'
          - time_millis
          - VmStatusDate: '${time_millis}'
        navigate:
          - SUCCESS: SMAX_getEntityDetails_GetParentOfferingName
    - If_jira_tool_is_null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_tool_value.strip()}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_resolution_comment_1_1
          - FAILURE: list_iterator_RequestTools
    - set_resolution_comment_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - resolution_comment_last: "${get_sp('MarketPlace.access_mgmt_resolution_comment')}"
            - resolution_comment: '${resolution_comment}'
        publish:
          - resolution_comment: "${resolution_comment + '<br>' + resolution_comment_last}"
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: on_failure
    - set_resolution_comment_1_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - resolution_comment: "${get_sp('MarketPlace.OnBoarding_resolution_comment')}"
        publish:
          - resolution_comment
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: on_failure
    - Is_tool_Remedy:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${project_tool.lower()}'
            - second_string: remedy
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: Create_IncidentIn_Remedy
          - FAILURE: Create_JiraRequest_Framework
    - Create_IncidentIn_Remedy:
        do:
          Cerner.Integrations.Remedy.SubFlows.Create_IncidentIn_Remedy:
            - reporter: '${reporter}'
            - description: '${description_tool}'
            - fields_append_toDescription: '${fields_append_toDescription_tool}'
            - tool_access: '${jira_request_tool}'
            - summary: '${summary_tool}'
        publish:
          - remedy_incident_id
          - message
          - errorMessage
          - errorType
          - errorSeverity
          - errorProvider
          - jiraIssueId: '${remedy_incident_id}'
          - remedy_resolution_comment: "${'Remedy Incident ticket# <a href=\"' + get_sp('Cerner.DigitalFactory.Remedy.remedyaskURL') + '\">' + remedy_incident_id + '</a> has been created successfully. ' +  get_sp('Cerner.DigitalFactory.Remedy.remedyReqResolutionComment')}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_millis_CurrentTime_1
    - prepareValues_for_jiraToolRequest_1:
        do:
          Cerner.Integrations.SMAX.Operation.prepareValues_for_jiraToolRequest:
            - jira_tool_key: '${jira_tool_key}'
            - jira_request_tool: "${jira_request_tool.split('|')[0]}"
            - project_tool_mapping: '${project_tool_mapping}'
            - watchers: '${watchers}'
            - summary: '${summary}'
            - description: '${description}'
            - fields_append_toDescription: '${fields_append_toDescription}'
            - request_common_fields: '${request_common_fields}'
            - get_jira_fields_fm_smax_config: '${get_jira_fields_fm_smax_config}'
            - get_jira_fields_fm_oo_config: '${get_jira_fields_fm_oo_config}'
            - get_id_value_fm_oo_config: '${get_id_value_fm_oo_config}'
            - hide_fields_In_Jira: '${hide_fields_In_Jira}'
        publish:
          - watchers_tool
          - get_jira_fields_fm_smax_config_tool
          - get_jira_fields_fm_oo_config_tool
          - get_id_value_fm_oo_config_tool
          - hide_fields_In_Jira_tool
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - request_common_fields_tool
          - summary_tool
          - description_tool
          - jira_direct_fields_tool
          - fields_append_toDescription_tool
        navigate:
          - SUCCESS: Is_smax_request_already_created
          - FAILURE: on_failure
    - Is_smax_request_already_created:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_already_created}'
            - second_string: 'Yes'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: Is_tool_Remedy
          - FAILURE: SMAX_entityOperations_CreateRequest
    - SMAX_entityOperations_CloseChildRequest:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_entityOperations:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - operation: UPDATE
            - smax_data: "${'Id,'+ smax_request_id_tool + '||CompletionCode,CompletionCodeFulfilledInJira_c||Solution,' + remedy_resolution_comment + '||Status,RequestStatusComplete||CloseTime,' + EndDate + '||RemedyIncidentId_c,' +remedy_incident_id+ '||'}"
            - is_custom_app: 'No'
        publish:
          - result
          - entity_id
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - requestCreationStatus: SUCCESS
          - jiraIssueURL: "${get_sp('Cerner.DigitalFactory.Remedy.remedyaskURL')}"
        navigate:
          - SUCCESS: set_jira_remedy_issue_urls
          - FAILURE: on_failure
    - get_millis_CurrentTime_1:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - EndDate: '${time_millis}'
          - time_millis
        navigate:
          - SUCCESS: SMAX_entityOperations_CloseChildRequest
    - is_onboarding_access_mgmt:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${is_onboarding_access_management}'
            - second_string: 'Yes'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_resolution_comment_for_Onbaording
          - FAILURE: set_resolution_comment_1
    - set_resolution_comment_for_Onbaording:
        do:
          io.cloudslang.base.utils.do_nothing:
            - resolution_comment_last: "${get_sp('MarketPlace.onboarding_resolution_comment')}"
            - resolution_comment: '${resolution_comment}'
        publish:
          - resolution_comment: "${resolution_comment + '<br>' + resolution_comment_last}"
        navigate:
          - SUCCESS: get_millis_CurrentTime
          - FAILURE: on_failure
    - SMAX_getEntityDetails_GetParentOfferingName:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.SMAX_getEntityDetails:
            - smax_auth_token: '${smax_token}'
            - entity: Request
            - query_field: "${\"Id,'\" + smaxRequestID +\"'\"}"
            - entity_fields: RequestsOffering.DisplayLabel
        publish:
          - result
          - records
          - parent_offering_name: "${cs_replace(cs_replace(cs_replace(cs_replace(entity_data_json[1:-1],'\"RequestsOffering.DisplayLabel\":',''),'\"',''),'}',''),'{','')}"
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
          - entity_data_json
        navigate:
          - SUCCESS: SMAX_entityOperations_CloseRequest
          - FAILURE: on_failure
    - list_iterator_RequestTools_SMAXRecords_1:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${data_json_MultipleSMAXnJiraRequests}'
            - separator: '},'
        publish:
          - result_string
          - return_result
          - return_code
          - SMAXRecord: "${result_string + '}'}"
        navigate:
          - HAS_MORE: get_SMAXRecord_fieldValues_1
          - NO_MORE: prepareValues_for_jiraToolRequest_1
          - FAILURE: on_failure
    - get_SMAXRecord_fieldValues_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - SMAXRecord: "${cs_replace(SMAXRecord,'}}','}')}"
        publish:
          - smax_request_tool: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'RequestTool_c'),']',''),'[',''),'\"','')}"
          - JiraIssueId: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'JiraIssueId_c'),']',''),'[',''),'\"','')}"
          - smax_request_id_tool: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'RequestId_c'),']',''),'[',''),'\"','')}"
          - associate_onboarding_entity_id: "${cs_replace(cs_replace(cs_replace(cs_json_query(SMAXRecord,'Id'),']',''),'[',''),'\"','')}"
        navigate:
          - SUCCESS: Entity_ReturnRecords_tool_found_1
          - FAILURE: on_failure
    - Entity_ReturnRecords_tool_found_1:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_request_tool}'
            - second_string: '${smax_request_tool}'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: Entity_ReturnRecords_tool_jiraIssueIdNotNUll
          - FAILURE: list_iterator_RequestTools_SMAXRecords_1
    - set_jira_remedy_issue_urls:
        do:
          io.cloudslang.base.utils.do_nothing:
            - jira_request_tool_url: "${'<a href=\"{0}\">{1}</a>'.format(jiraIssueURL,jiraIssueId)}"
        publish:
          - jira_request_tool_url
        navigate:
          - SUCCESS: SMAX_entityOperations_UpdateAssociateOnBoarding_record
          - FAILURE: on_failure
    - getProjectTool:
        do:
          Cerner.Integrations.Remedy.Operations.getProjectTool:
            - input_data: '${project_tool_mapping}'
            - project_tool: "${jira_request_tool.split('|')[0]}"
        publish:
          - result
          - project_tool: '${key}'
          - value
          - message
          - errorType
        navigate:
          - SUCCESS: MultipleSMAXnJIra_Entity_ReturnRecords_Null
          - FAILURE: on_failure
    - Is_tool_Remedy_1:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${project_tool.lower()}'
            - second_string: remedy
            - ignore_case: 'true'
            - jira_request_tool_url: "${'<a href=\"{0}\">{1}</a>'.format(jiraIssueURL,jiraIssueId)}"
        publish:
          - jira_request_tool_url
        navigate:
          - SUCCESS: set_jira_remedy_issue_urls_1
          - FAILURE: set_resolution_comment
    - set_jira_remedy_issue_urls_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - jira_request_tool_url: "${'<a href=\"' + get_sp('Cerner.DigitalFactory.Remedy.remedyaskURL') + '{0}\">{0}</a>'.format(jiraIssueId)}"
        publish:
          - jira_request_tool_url
        navigate:
          - SUCCESS: set_resolution_comment
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - smaxRequestNumber: '${smaxRequestID}'
                - smaxRequestSummary: '${summary}'
                - smaxRequestorEmail: '${requestorEmail}'
            publish:
              - requestCreationStatus: FAILED
  outputs:
    - requestCreationStatus: '${requestCreationStatus}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      list_iterator_RequestTools_SMAXRecords_1:
        x: 880
        'y': 400
      SMAX_entityOperations_UpdateAssociateOnBoarding_record:
        x: 520
        'y': 40
      Is_tool_Remedy_1:
        x: 800
        'y': 720
      If_jira_tool_is_null:
        x: 400
        'y': 600
      Entity_ReturnRecords_tool_found:
        x: 720
        'y': 640
      Create_IncidentIn_Remedy:
        x: 1200
        'y': 120
      set_jira_remedy_issue_urls_1:
        x: 680
        'y': 800
      get_SMAXRecord_fieldValues:
        x: 600
        'y': 520
      get_millis_CurrentTime_1:
        x: 1080
        'y': 120
      SMAX_getEntityDetails_GetParentOfferingName:
        x: 160
        'y': 280
      set_resolution_comment:
        x: 520
        'y': 720
      SMAX_entityOperations_CloseChildRequest:
        x: 920
        'y': 120
      string_occurrence_counter_ifSMAXRequestCreated:
        x: 720
        'y': 320
      set_resolution_comment_for_Onbaording:
        x: 400
        'y': 440
      MultipleSMAXnJIra_Entity_ReturnRecords_Null:
        x: 760
        'y': 200
      is_onboarding_access_mgmt:
        x: 400
        'y': 320
      set_resolution_comment_1_1:
        x: 240
        'y': 600
      extract_jiraToolkey_value:
        x: 400
        'y': 720
      list_iterator_RequestTools_SMAXRecords:
        x: 720
        'y': 440
      prepareValues_for_jiraToolRequest_1:
        x: 1080
        'y': 280
      SMAX_getEntityDetails_from_Person_RequestorId:
        x: 40
        'y': 720
      SMAX_entityOperations_CreateRequest:
        x: 1200
        'y': 720
      Entity_ReturnRecords_tool_jiraIssueIdNotNUll:
        x: 1080
        'y': 720
      SMAX_getEntityDetails_from_MultipleSMAXnJiraRequests:
        x: 40
        'y': 280
      Is_tool_Remedy:
        x: 1320
        'y': 360
      SMAX_entityOperations_CreateAssociateOnBoarding_record:
        x: 1320
        'y': 720
      set_jira_remedy_issue_urls:
        x: 680
        'y': 40
      Entity_ReturnRecords_tool_found_1:
        x: 880
        'y': 600
      get_millis_CurrentTime:
        x: 240
        'y': 440
      SMAX_getEntityDetails_from_GetOffeing_ID:
        x: 40
        'y': 480
      Is_smax_request_already_created:
        x: 1200
        'y': 360
      SMAX_entityOperations_CloseRequest:
        x: 240
        'y': 80
        navigate:
          0732f46d-8ca1-5c94-4acd-b41d857df45a:
            targetId: 6b328459-5f42-7d0c-7363-a0a6f98782b7
            port: SUCCESS
      get_SMAXRecord_fieldValues_1:
        x: 1000
        'y': 480
      set_resolution_comment_1:
        x: 400
        'y': 200
      getProjectTool:
        x: 600
        'y': 200
      list_iterator_RequestTools:
        x: 520
        'y': 320
      Create_JiraRequest_Framework:
        x: 1320
        'y': 40
      set_request_status:
        x: 1520
        'y': 40
        navigate:
          4a3873aa-c662-dfb1-929f-388739842687:
            targetId: 86d04ff9-2009-c496-7fec-2f470deb7282
            port: FAILURE
          0ce58376-0ccb-daa8-a2d7-f8c4d0baf4a1:
            targetId: 86d04ff9-2009-c496-7fec-2f470deb7282
            port: SUCCESS
      get_SMAXToken:
        x: 40
        'y': 80
    results:
      FAILURE:
        86d04ff9-2009-c496-7fec-2f470deb7282:
          x: 1520
          'y': 360
      SUCCESS:
        6b328459-5f42-7d0c-7363-a0a6f98782b7:
          x: 400
          'y': 80
