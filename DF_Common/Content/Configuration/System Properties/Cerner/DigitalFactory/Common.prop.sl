########################################################################################################################
#!!
#! @system_property connection_timeout: API Request connection timeout value
#! @system_property contractor_AD_groups: Comma separated list of Cerner Contractors AD Groups
#! @system_property contractor_jira_script_mapping: json object list key value pair for Contractor AD Group and  JIRA 
#!                                                  Scripts for Mapping
#! @system_property AttachmentExtnFiletype_mapping: Json Object of file extn and Mime  type mapping
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory
properties:
  - connection_timeout:
      value: '120'
      sensitive: false
  - contractor_AD_groups:
      value: 'gCWEPAM,gProjectPhoenix,gLumerisContractWorkers'
      sensitive: false
  - contractor_jira_script_mapping:
      value: '{"gCWEPAM":"addUserToJiraEPAM","gLumerisContractWorkers": "addUserToJiraLumeris","gProjectPhoenix":"addUserToJiraCGMWorker"}'
      sensitive: false
  - cerner_upn_domain: cerner.net
  - AttachmentExtnFiletype_mapping:
      value: '{"csv":"text/csv","sql":"application/octet-stream","log":"nofiletype"}'
      sensitive: false
  - http_fail_status_codes: '{"jira":"400,401,403,404,405,406,409,415","smax":"400,401,403,404,405,406,409,415,504"}'
