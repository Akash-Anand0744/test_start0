########################################################################################################################
#!!
#! @description: This Python operation is used for checking if both SMAX Service Articles list variable and External ID list variable is null to be able to process further.
#!
#! @input service_article_Strlist: List of SMAX Service ID and article
#! @input new_external_id_Strlist: List of external Article IDs
#!
#! @output result: Returns result as "True" if both variables are not null. Else result is "False"
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: check_service_article_external_ID_not_null
  inputs:
    - service_article_Strlist:
        required: false
    - new_external_id_Strlist:
        required: false
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      def execute(service_article_Strlist, new_external_id_Strlist):
          if service_article_Strlist and new_external_id_Strlist:
              result = 'True'
          else:
              result = 'False'
          return {"result": result}
          # code goes here
      # you can add additional helper methods below.
  outputs:
    - result
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
