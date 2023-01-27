########################################################################################################################
#!!
#! @description: request_body :Below is the reference  example for this field
#!                
#!               {
#!               "alternateContactId": "sd030442",
#!               "assignedGroup": "ES Integration Automation CTS",
#!               "assignedSupportCompany": "Cerner",
#!               "company": "Cerner",
#!               "contactId": "PPL000000932691",
#!               "impact": "4000",
#!               "incidentType": "1", 
#!               "notes": "testing for Markeptlace Integration",
#!               "operationalCategorizationTier1": "Add",
#!               "ownerSupportCompany": "Cerner",
#!               "productCategorizationTier1": "Software Infrastructure",
#!               "requestorId": "sd030442", 
#!               "status": "Assigned",
#!               "reportedSource": "10000",
#!               "summary": "testing for Markeptlace Integration",
#!               "targetDate": "2022-09-25",
#!               "urgency": "4000"
#!               }
#!
#! @input request_body: http request body for remedy API, see Description for example
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.Remedy.Operations
operation:
  name: create_RemedyIncident
  inputs:
    - rapid_url: "${get_sp('Cerner.DigitalFactory.Remedy.rapidURL')}"
    - rapid_token
    - request_body
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get the Rapid API Token for Remedy Operations\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   operation: create_RemedyIncident\r\n#   Created on 20 Sep 2022\r\n#   Inputs:\r\n#       -   rapid_url\r\n#       -   rapid_token\r\n#       -   request_body --http request body for remedy API, see Description for example\r\n#       -\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   incidentId\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n#       -   errorProvider\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(rapid_url, rapid_token, request_body):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    incidentId = ''\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        headers = {\r\n            'Content-Type': 'application/json',\r\n            'Authorization': 'Bearer ' + rapid_token\r\n        }\r\n\r\n        #payload = json.dumps(request_body)\r\n        payload = request_body\r\n\r\n        url = rapid_url + '/remedy-incident-svc/v2/incidents'\r\n\r\n        response = requests.request(\"POST\", url, headers=headers, data=payload)\r\n\r\n        if response.status_code == 200:\r\n            tresponse = json.loads(response.content)\r\n            incidentId = tresponse[\"incidentId\"]\r\n            message = response.text\r\n            result = \"True\"\r\n        else:\r\n            message = str(response.text) + ': Response code: ' + str(response.status_code)\r\n            raise Exception(message)\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        errorMessage = message\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'RAPID'\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"incidentId\": incidentId, \"message\": message, \"errorType\": errortype,\r\n            \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider}"
  outputs:
    - result
    - message
    - incidentId
    - errorType
    - errorProvider
    - errorMessage
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
