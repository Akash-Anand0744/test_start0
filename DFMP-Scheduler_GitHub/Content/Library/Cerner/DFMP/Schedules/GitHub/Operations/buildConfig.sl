########################################################################################################################
#!!
#! @description: This Python operation retrieves the SMAX Service Definition IDs where GitHub repos and tags fields are not null along with the corresponding repos and tags separated by ♪.
#!
#! @input smax_baseurl: SMAX base URL
#! @input tenantId: SMAX Tenant ID
#! @input token: SMAX authentication Token
#!
#! @output github_pages: List of SMAX Service Definition IDs, associated GitHub repos and tags separated by ♪
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: buildConfig
  inputs:
    - smax_baseurl
    - tenantId
    - token
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      #def execute():
          # code goes here
      # you can add additional helper methods below.

      def execute(smax_baseurl, tenantId, token):
          message = ""
          result = "False"
          errorType = ""
          errorSeverity = ""
          errorProvider = ""
          errorMessage = ""
          errorLogs = ""
          github_pages = ""

          try:
              import requests
              import json

              authHeaders = {"TENANTID": "keep-alive"}
              cookies = {"SMAX_AUTH_TOKEN": token}
              #turl = smax_baseurl + "/rest/" + tenantId + "/ems/ServiceDefinition?layout=Id,DisplayLabel,Category,MarketPlaceGitHubTag_c,GitHubRepoAndOwnerPageURL_c&filter=GitHubRepoAndOwnerPageURL_c%21%3D''"
              turl = smax_baseurl + "/rest/" + tenantId + "/ems/ServiceDefinition?layout=Id,DisplayLabel,Category,MarketPlaceGitHubTag_c,GitHubRepoAndOwnerPageURL_c&filter=(GitHubRepoAndOwnerPageURL_c%21%3D''+and+MarketPlaceGitHubTag_c%21%3D'')"
              response3 = requests.get(turl, headers=authHeaders, cookies=cookies)

              if response3.status_code == 200:
                  jdata = json.loads(response3.text)
                  for ent in jdata['entities']:
                      github_pages += ent["properties"]["Id"] + ","
                      github_pages += ent["properties"]["GitHubRepoAndOwnerPageURL_c"]
                      github_pages += "♪" + ent["properties"]["MarketPlaceGitHubTag_c"] + "♪♪"

                  result = "True"
              else:
                  result = "False"
                  message = "Invalid response from Provider: " + str(response3.content)
                  errorMessage = message
                  errorType = 'e20000'
                  if not errorProvider:
                      errorProvider = 'SMAX'
                  errorSeverity = "ERROR"
                  errorLogs = "ProviderUrl," + turl + "||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage," + str(message) + "|||"

              if len(github_pages) > 0:
                  github_pages = github_pages[:-2]
                  message = "Successfully retrieved Github Repo and pages info"
              else:
                  message = "No Github pages to sync to SMAX"
                  github_pages = "NONE"
          except Exception as e:
              message = e
              result = "False"
              errorMessage = message
              errorType = 'e20000'
              if not errorProvider:
                  errorProvider = 'SMAX'
              errorSeverity = "ERROR"
              errorLogs = "ProviderUrl," + turl + "||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage," + str(message) + "|||"
          return {"result": result, "message": message, "errorType": errorType, "errorSeverity": errorSeverity,"errorProvider": errorProvider,"errorMessage":errorMessage,"errorLogs":errorLogs, "github_pages": github_pages}
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
    - github_pages
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
