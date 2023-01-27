namespace: Cerner.DigitalFactory.MarketPlace.JIRA.Operation
operation:
  name: fetchUpdatedJiraIssues
  inputs:
    - MarketPlace_jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - MarketPlace_jiraUser: "${get_sp('MarketPlace.jiraUser')}"
    - MarketPlace_jiraPassword: "${get_sp('MarketPlace.jiraPassword')}"
    - smax_auth_baseurl: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_password:
        sensitive: true
        default: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_baseurl: "${get_sp('MarketPlace.smaxURL')}"
    - projectNames: "${get_sp('MarketPlace.jiraProjects')}"
    - creator: "${get_sp('MarketPlace.jiraIssueCreator')}"
    - lastUpdate: "${get_sp('MarketPlace.lastUpdateTime')}"
    - smax_FieldID
    - smax_Bridge_ID
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of comments From JIRA TO SMAX\r\n#    Author: Sirisha Krishna Yalam(SY091463@cerner.net)\r\n#   Inputs:\r\n#       -  MarketPlace_jiraIssueURL\r\n#       -  MarketPlace_jiraUser\r\n#       -  MarketPlace_jiraPassword\r\n#       -  smax_auth_baseurl\r\n#       -  smax_user\r\n#       -  smax_password\r\n#       -  smax_tenantId\r\n#       -  smax_baseurl\r\n#       -  projectNames\r\n#       -  creator\r\n#       -  lastUpdate\r\n#       -  smax_FieldID\r\n#       -   conn_timeout\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - newUpdateTime\r\n################################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorMessage\": errorMessage,\"errorType\": errorType, \"errorSeverity\": errorSeverity}\r\n    \r\n\r\n\r\n# main function\r\ndef execute(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, smax_auth_baseurl, smax_user,\r\n            smax_password, smax_tenantId, smax_baseurl, projectNames, creator, lastUpdate, smax_FieldID,\r\n            smax_Bridge_ID, conn_timeout):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    data = {}\r\n    arr = []\r\n    jiraAndSMaxIDs = \"\"\r\n    newUpdateTime = \"\"\r\n\r\n    try:\r\n        # requirement external modules\r\n        install(\"requests\")\r\n        install(\"time\")\r\n        install(\"pytz\")\r\n\r\n        # Get current new update time in CST timezone ('US/Central') as Jira is returns time in this TZ\r\n        from datetime import datetime\r\n        from pytz import timezone\r\n        fmt = \"%Y-%m-%d %H:%M\"  # Format of time\r\n        # Current time in CST - 'US/Central'\r\n        now_cst = datetime.now(timezone('US/Central'))\r\n        newUpdateTime = now_cst.strftime(fmt)\r\n\r\n        import requests\r\n        import json\r\n        ids = projectNames.split(\"♪\")\r\n        payLoad = \"\"\r\n\r\n        for id in ids:\r\n            reqUrl = '{0}rest/api/2/search'.format(MarketPlace_jiraIssueURL)\r\n            data = {}\r\n            data[\"jql\"] = \"project='{0}' AND updated >'{1}' AND creator='{2}'\".format(id, lastUpdate, creator)\r\n            data[\"startAt\"] = \"0\"\r\n            data[\"maxResults\"] = \"500\"\r\n            data[\"fields\"] = [smax_FieldID, \"id\", \"project\"]\r\n            payLoad = json.dumps(data)\r\n\r\n            basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n            headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n\r\n            response = requests.post(reqUrl, auth=basicAuthCredentials, headers=headers, data=payLoad, timeout=int(conn_timeout))\r\n\r\n            if response.status_code == 200:\r\n                data = response.json()\r\n                arr = data[\"issues\"]\r\n                if (data[\"total\"] == 0):\r\n                    message = \"No more recent updated in JIRA Issues\"\r\n                    result = \"True\"\r\n                else:\r\n                    for issue in arr:\r\n                        if issue[\"fields\"][\"project\"][\"key\"] == id and issue[\"fields\"][smax_FieldID]:\r\n                            jiraAndSMaxIDs += \"♩\" + issue[\"id\"] + \"♫\" + issue[\"fields\"][smax_FieldID] + \"♪\"\r\n            else:\r\n                msg = \"Unsupported response from the Provider: \" + str(response.content)\r\n                raise Exception(msg)\r\n\r\n        if len(jiraAndSMaxIDs) > 0:\r\n            jiraAndSMaxIDs = jiraAndSMaxIDs[:-1]\r\n            jiraAndSMaxIDs = jiraAndSMaxIDs[1:]\r\n            message = \"Fetched recently updated Jira Issues\"\r\n            result = \"True\"\r\n        else:\r\n            result = \"True\"\r\n            message = \"No recent updated issues in JIRA\"\r\n\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n    return {\"result\": result, \"errorMessage\": errorMessage, \"message\": message, \"newUpdateTime\": newUpdateTime, \"jiraAndSMaxIDs\": jiraAndSMaxIDs,\r\n            \"errorType\": errorType, \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider}"
  outputs:
    - result
    - message
    - newUpdateTime
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - jiraAndSMaxIDs
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
