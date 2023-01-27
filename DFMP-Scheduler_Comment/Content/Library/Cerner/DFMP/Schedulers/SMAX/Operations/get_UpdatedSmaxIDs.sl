namespace: Cerner.DFMP.Schedules.SMAX.Operations
operation:
  name: get_UpdatedSmaxIDs
  inputs:
    - smax_Token
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_Url: "${get_sp('MarketPlace.smaxURL')}"
    - lastUpdate: "${get_sp('MarketPlace.lastUpdateTime')}"
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
  python_action:
    use_jython: false
    script: "import sys, os\r\nimport subprocess\r\nimport time\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n# main function\r\ndef execute(smax_Token, smax_tenantId, smax_Url, lastUpdate, conn_timeout):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    smaxDataU = {}\r\n    smaxAndJiraIDs = \"\"\r\n    #currentTime = str(time.time())\r\n    #newUpdateTime = (currentTime[:10] + currentTime[11:])[0: 13]\r\n    lastupdateTime = lastUpdate\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        authHeaders = {\"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\": smax_Token}\r\n\r\n        reqUrl = smax_Url + \"/rest/\" + smax_tenantId + \"/ems/Request?layout=Id,DisplayLabel,Priority,JiraIssueId_c&filter=LastUpdateTime>\" + lastupdateTime\r\n\r\n        response = requests.get(reqUrl, headers=authHeaders, cookies=cookies, timeout=int(conn_timeout))\r\n\r\n        if response.status_code == 200:\r\n            entityJsonArray = json.loads(response.content)\r\n            if entityJsonArray[\"entities\"] == []:\r\n                message = \"No recent issues in SMAX\"\r\n                result = \"True\"\r\n            else:\r\n                for entity in entityJsonArray[\"entities\"]:\r\n                    # if entity[\"properties\"][\"Id\"] != \"\":\r\n                    try:\r\n                        smaxAndJiraIDs += \"♩\" + entity[\"properties\"][\"JiraIssueId_c\"] + \"♫\" + entity[\"properties\"][\"Id\"] + \"♪\"\r\n                    except KeyError:\r\n                        print(\"The JiraIssue ID does not exist!\")\r\n        else:\r\n            message = \"Unsupported Response from the Provider \" + str(response.content)\r\n            raise Exception(message)\r\n        if smaxAndJiraIDs:\r\n            smaxAndJiraIDs = smaxAndJiraIDs[:-1]\r\n            smaxAndJiraIDs = smaxAndJiraIDs[1:]\r\n     except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage,\r\n            \"newUpdateTime\": newUpdateTime,\"smaxAndJiraIDs\": smaxAndJiraIDs}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - newUpdateTime
    - smaxAndJiraIDs
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
