namespace: Cerner.DigitalFactory.Common.JIRA.Operation.Archive
operation:
  name: jira_AddUserPermission
  inputs:
    - MarketPlace_jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - MarketPlace_jiraUser: "${get_sp('MarketPlace.jiraUser')}"
    - MarketPlace_jiraPassword: "${get_sp('MarketPlace.jiraPassword')}"
    - userIds:
        required: false
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of Jira and Smax\r\n#   Author: Rajesh Singh (rajesh.singh5@microfocus.com), MicroFocus International\r\n#   Inputs:\r\n#       -  MarketPlace_jiraIssueURL\r\n#       -  MarketPlace_jiraUser\r\n#       -  MarketPlace_jiraPassword\r\n#       -  userIds\r\n#       - conn_timeout\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"OOExec\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n# main function\r\ndef execute(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, userIds, conn_timeout):\r\n    message = \"\"\r\n    result = \"False\"\r\n    jiraIssueStatus = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n\r\n    try:\r\n        import json\r\n        import requests\r\n        \r\n        for userID in userIds.split(\",\"):\r\n            \r\n            reqUrl = '{0}rest/scriptrunner/latest/custom/addUserToJiraDefault?username={1}'.format(MarketPlace_jiraIssueURL,userID)\r\n            data = {}\r\n    \r\n            basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n            headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n    \r\n            response = requests.get(reqUrl, auth=basicAuthCredentials, headers=headers, timeout=int(conn_timeout))\r\n            if response.status_code == 200:\r\n                result = \"True\"\r\n                message = \"Permission Granted. Retrying creating Jira Incident/Request\"\r\n    \r\n            else:\r\n                message = 'status code :' + str(response.status_code) + ': ' + str(response.text)\r\n                result = \"False\"\r\n                errorType = \"e20000\"\r\n                errorMessage = message\r\n                errorSeverity = \"ERROR\"\r\n                errorProvider = \"JIRA\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
