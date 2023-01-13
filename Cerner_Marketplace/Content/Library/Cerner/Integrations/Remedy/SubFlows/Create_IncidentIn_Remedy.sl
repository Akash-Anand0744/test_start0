namespace: Cerner.Integrations.Remedy.SubFlows
flow:
  name: Create_IncidentIn_Remedy
  inputs:
    - reporter
    - description
    - fields_append_toDescription:
        required: false
    - tool_access
    - summary
    - assigned_group_json:
        default: "${get_sp('Cerner.DigitalFactory.Remedy.assignedGroupJSON')}"
        required: false
  workflow:
    - fields_append_toDescription:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.fields_append_toDescription:
            - description: '${description}'
            - fields_append_toDescription: '${fields_append_toDescription}'
        publish:
          - description: '${newDescription}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: convertHTMLtoText
    - get_RapidToken:
        do:
          Cerner.DigitalFactory.Common.Remedy.Operations.get_RapidToken: []
        publish:
          - result
          - rapid_token: '${token}'
          - message
          - errorMessage
          - errorType
          - errorSeverity
          - errorProvider
        navigate:
          - SUCCESS: get_PeopleData
          - FAILURE: on_failure
    - get_PeopleData:
        do:
          Cerner.DigitalFactory.Common.Remedy.Operations.get_PeopleData:
            - rapid_token: '${rapid_token}'
            - associate_id: '${reporter}'
        publish:
          - result
          - peopleId: '${data}'
          - message
          - errorType
          - errorProvider
          - errorMessage
          - errorSeverity
        navigate:
          - SUCCESS: get_time
          - FAILURE: on_failure
    - create_http_request_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_Body: "${'{ \"alternateContactId\": \"' + requestor + '\", \"assignedGroup\":\"' + assigned_group + '\", \"assignedSupportCompany\": \"Cerner\", \"company\": \"Cerner\", \"contactId\": \"' + peopleId + '\",\"impact\": \"4000\",  \"incidentType\": \"1\",\"notes\": \"' + description + '\" , \"operationalCategorizationTier1\": \"Add\", \"ownerSupportCompany\": \"Cerner\",   \"productCategorizationTier1\": \"' + productCategorizationTier1 + '\",\"requestorId\": \"' +  requestor + '\",\"status\": \"Assigned\",  \"reportedSource\": \"10000\", \"summary\": \"' + summary + '\", \"targetDate\": \"' + targetDate + '\",\"urgency\": \"4000\" }'}"
        publish:
          - httpClient_Body: "${cs_replace(httpClient_Body,\"\\\\'\",\"'\")}"
        navigate:
          - SUCCESS: create_RemedyIncident
          - FAILURE: on_failure
    - create_RemedyIncident:
        do:
          Cerner.DigitalFactory.Common.Remedy.Operations.create_RemedyIncident:
            - rapid_token: '${rapid_token}'
            - request_body: '${httpClient_Body}'
        publish:
          - result
          - incidentId
          - message
          - errorType
          - errorProvider
          - errorMessage
          - errorSeverity
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - get_time:
        do:
          io.cloudslang.base.datetime.get_time: []
        publish:
          - targetDate: '${output}'
          - return_code
          - exception
        navigate:
          - SUCCESS: offset_time_by
          - FAILURE: on_failure
    - offset_time_by:
        do:
          io.cloudslang.base.datetime.offset_time_by:
            - date: '${targetDate}'
            - offset: '345600'
        publish:
          - targetDate: '${output}'
          - return_code
          - exception
        navigate:
          - SUCCESS: get_assigned_group
          - FAILURE: on_failure
    - set_Request_Parameters:
        do:
          io.cloudslang.base.utils.do_nothing:
            - productCategorizationTier1: Software Business
            - requestor: '${reporter.split("@")[0].lower()}'
            - RemedyRequestLastComment: "${get_sp('Cerner.DigitalFactory.Remedy.requestComment')}"
            - description: '${description}'
        publish:
          - productCategorizationTier1
          - requestor
          - description: "${description + '\\\\n\\\\n' + RemedyRequestLastComment}"
        navigate:
          - SUCCESS: create_http_request_body
          - FAILURE: on_failure
    - convertHTMLtoText:
        do:
          Cerner.DigitalFactory.Common.Remedy.Operations.convertHTMLtoText:
            - htmlString: '${description}'
        publish:
          - description: "${cs_replace(textString,'\\n','\\\\n')}"
          - result
          - message
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: get_RapidToken
          - FAILURE: on_failure
    - get_assigned_group:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${assigned_group_json}'
            - json_path: '${tool_access}'
        publish:
          - assigned_group: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: set_Request_Parameters
          - FAILURE: get_default_assigned_group
    - get_default_assigned_group:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${assigned_group_json}'
            - json_path: Default
        publish:
          - assigned_group: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: set_Request_Parameters
          - FAILURE: on_failure
  outputs:
    - remedy_incident_id: '${incidentId}'
    - message: '${message}'
    - errorMessage: '${errorMessage}'
    - errorType: '${errorType}'
    - errorSeverity: '${errorSeverity}'
    - errorProvider: '${errorProvider}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_PeopleData:
        x: 240
        'y': 480
      fields_append_toDescription:
        x: 120
        'y': 120
      get_RapidToken:
        x: 120
        'y': 480
      create_http_request_body:
        x: 920
        'y': 120
      convertHTMLtoText:
        x: 120
        'y': 320
      get_default_assigned_group:
        x: 400
        'y': 320
      create_RemedyIncident:
        x: 920
        'y': 360
        navigate:
          495925d6-9805-61a1-600b-3539f90efeeb:
            targetId: 8faa98b9-183b-6210-6ac7-a69349a3cf58
            port: SUCCESS
      get_time:
        x: 240
        'y': 320
      get_assigned_group:
        x: 400
        'y': 120
      set_Request_Parameters:
        x: 760
        'y': 120
      offset_time_by:
        x: 240
        'y': 120
    results:
      SUCCESS:
        8faa98b9-183b-6210-6ac7-a69349a3cf58:
          x: 920
          'y': 520
