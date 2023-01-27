namespace: MarketPlace
properties:
  - smaxURL: 'https://factorymarketdev.cerner.com'
  - tenantID: '336419949'
  - smaxIntgUser: oo-bridge
  - smaxIntgUserPass:
      value: OO_Bridge_1
      sensitive: true
  - smaxAuthURL: 'https://factorymarketdev.cerner.com/auth/authentication-endpoint/authenticate/token?TENANTID=336419949'
  - akash: |-
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
