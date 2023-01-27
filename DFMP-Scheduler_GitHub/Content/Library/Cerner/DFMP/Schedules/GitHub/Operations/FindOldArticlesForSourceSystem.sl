########################################################################################################################
#!!
#! @description: This Python operation retrieves existing External ID, articles ID and Hash from SMAX matching the Source System - in this case "CernerGitHUB".
#!
#! @input smax_baseurl: SMAX URL
#! @input tenantId: SMAX Tenant ID
#! @input token: SMAX Authentication Token
#! @input SourceSystem: Source system from where the data was retrieved for processing - CernerGitHUB
#!
#! @output smax_ext_id_list: List containing SMAX External IDs
#! @output extid_smaxid_articlehash: Content containing external ID of the retrieved article/ page, SMAX Article ID and the article hash.
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: FindOldArticlesForSourceSystem
  inputs:
    - smax_baseurl
    - tenantId
    - token
    - SourceSystem
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      #def execute():
          # code goes here
      # you can add additional helper methods below.

      def execute(smax_baseurl, tenantId, token, SourceSystem):
          message = ""
          result = "False"
          errorType = ""
          errorSeverity = ""
          errorProvider = ""
          errorMessage = ""
          errorLogs = ""
          smax_ids_n_article_hash = ""
          smax_article_hash_list = ""
          smax_ext_id_list = ""
          extid_smaxid_articlehash = ""

          try:
              import requests
              import json

              authHeaders = {"TENANTID": "keep-alive"}
              cookies = {"SMAX_AUTH_TOKEN": token}
              turl = smax_baseurl + "/rest/" + tenantId + "/ems/Article?layout=Id,SourceSystem_c,Title,PhaseId,ExternalId,ArticleHash_c&filter=SourceSystem_c%3D'" + SourceSystem + "'"
              response3 = requests.get(turl, headers=authHeaders, cookies=cookies)

              if response3.status_code == 200:
                  jdata = json.loads(response3.text)
                  if jdata["meta"]["total_count"] >0:

                      for entity in jdata['entities']:
                          if entity["properties"]["ExternalId"]:
                              #smax_article_hash_list += entity["properties"]["ArticleHash_c"] + ","
                              smax_ext_id_list += entity["properties"]["ExternalId"] + ","
                              #smax_ids_n_article_hash += '"' + entity["properties"]["ArticleHash_c"] + '":'
                              #smax_ids_n_article_hash += entity["properties"]["Id"] + ','
                              extid_smaxid_articlehash += '"' + entity["properties"]["ExternalId"] + '":'
                              extid_smaxid_articlehash += '"' + entity["properties"]["Id"] + '||' + entity["properties"]["ArticleHash_c"] + '",'
                      if smax_ext_id_list:
                          ## create list of external id list
                          smax_ext_id_list = smax_ext_id_list[:-1]
                          ## Create dictionalry of Hash and SMAX IDs for Articles
                          #smax_ids_n_article_hash = '{' + smax_ids_n_article_hash[:-1] + '}'
                          extid_smaxid_articlehash = '{' + extid_smaxid_articlehash[:-1] + '}'
                      result = "True"
                      message = "Retrieved old articles ID and Hash Successfully"
                  else:
                      result = "True"
                      message = "No Articles exists in the SMAX"
              else:
                  result = "False"
                  message = "Invalid response from Provider: " + str(response3.content)
                  errorMessage = message
                  errorType = 'e20000'
                  if not errorProvider:
                      errorProvider = 'SMAX'
                  errorSeverity = "ERROR"
                  errorLogs = "ProviderUrl," + turl + "||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage," + str(message) + "|||"

          except Exception as e:
              message = e
              result = "False"
              errorMessage = message
              errorType = 'e20000'
              if not errorProvider:
                  errorProvider = 'SMAX'
              errorSeverity = "ERROR"
              errorLogs = "ProviderUrl," + turl + "||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage," + str(message) + "|||"
          return {"result": result, "message": message, "errorType": errorType, "errorSeverity": errorSeverity,"errorProvider": errorProvider,"errorMessage":errorMessage,"errorLogs":errorLogs, "smax_ext_id_list": smax_ext_id_list, "extid_smaxid_articlehash": extid_smaxid_articlehash}
  outputs:
    - smax_ext_id_list
    - extid_smaxid_articlehash
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
