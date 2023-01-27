########################################################################################################################
#!!
#! @description: This Python operation executes the SMAX EMS Bulk REST API using the JSON body passed. SMAX operation (Create/ Update/ Delete) is part of the JSON body.
#!
#! @input smax_baseurl: SMAX URL
#! @input tenantId: SMAX Tenant ID
#! @input token: SMAX Authentication Token
#! @input dataS: SMAX EMS Bulk REST API JSON body
#!
#! @output smax_response: SMAX REST API call response
#! @output records: Number of records affected in SMAX
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: processSMAXData
  inputs:
    - smax_baseurl
    - tenantId
    - token
    - dataS
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      #def execute():
          # code goes here
      # you can add additional helper methods below.

      def execute(smax_baseurl, tenantId, token, dataS):
          message = ""
          result = "False"
          errorType = ""
          errorSeverity = ""
          errorProvider = ""
          errorMessage = ""
          errorLogs = ""
          smax_message = ''
          records = ''

          try:
              import requests
              import json

              headers = {
                  'Cookie': 'LWSSO_COOKIE_KEY=' + token,
                  'Content-Type': 'application/json',
                  'User-Agent': 'Apache-HttpClient/4.4.1'
              }

              payload = dataS
              url = smax_baseurl + "/rest/" + tenantId + "/ems/bulk"

              response = requests.request("POST", url, headers=headers, data=payload)
              message = response.text
              mresponse = json.loads(response.text)

              if response.status_code == 200:
                  result_list = mresponse["entity_result_list"]
                  i = 0
                  for rr in result_list:
                      if rr["completion_status"] == "OK":
                          i += 1

                  smax_message = "{} Records Affected!".format(i)
                  records = i
                  result = "True"
              else:
                  smax_message = "Issue Processing Records! Check syntax or body or SMAX availability"
                  result = "False"
                  errorMessage = message
                  errorType = 'e20000'
                  if not errorProvider:
                      errorProvider = 'SMAX'
                  errorSeverity = "ERROR"
                  errorLogs = "ProviderUrl," + url + "||ErrorProvider,SMAX||ProviderUrlBody,"+ dataS + "||ErrorMessage," + str(message) + "|||"


          except Exception as e:
              message = e
              result = "False"
              errorMessage = message
              errorType = 'e20000'
              if not errorProvider:
                  errorProvider = 'SMAX'
              errorSeverity = "ERROR"
              errorLogs = "ProviderUrl," + url + "||ErrorProvider,SMAX||ProviderUrlBody,"+ dataS + "||ErrorMessage," + str(message) + "|||"
          return {"result": result, "message": message, "errorType": errorType, "errorSeverity": errorSeverity,"errorProvider": errorProvider,"errorMessage":errorMessage,"errorLogs":errorLogs, "smax_response": smax_message,"records": records}
  outputs:
    - smax_response
    - records
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
