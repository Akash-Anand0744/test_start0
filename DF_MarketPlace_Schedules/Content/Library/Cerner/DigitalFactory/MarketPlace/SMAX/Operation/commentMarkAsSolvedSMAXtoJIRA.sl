namespace: Cerner.DigitalFactory.MarketPlace.SMAX.Operation
operation:
  name: commentMarkAsSolvedSMAXtoJIRA
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
    - mark_as_solved_comment: "${get_sp('Cerner.DigitalFactory.MarketPlace.mark_as_solved_comment')}"
    - jiraticketID
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of comments From Smax TO Jira\r\n#    Author: Rakesh.Sharma@cerner.com\r\n#   Inputs:\r\n#       -  MarketPlace_jiraIssueURL\r\n#       -  MarketPlace_jiraUser\r\n#       -  MarketPlace_jiraPassword\r\n#       -  smax_auth_baseurl\r\n#       -  smax_user\r\n#       -  smax_password\r\n#       -  smax_tenantId\r\n#       -  smax_baseurl\r\n#       -  projectNames\r\n#       -  creator\r\n#       -  lastUpdate\r\n#       -  mark_as_solved_comment\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       \r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\nimport time\r\nimport datetime\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n# main function\r\ndef execute(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, smax_auth_baseurl, smax_user,\r\n            smax_password, smax_tenantId, smax_baseurl, projectNames, creator, lastUpdate, mark_as_solved_comment,jiraticketID):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    smaxDataU = {}\r\n    token = \"\"\r\n    commentToUpdate =mark_as_solved_comment\r\n\r\n    \r\n    try:\r\n        import requests\r\n        import json\r\n        \r\n        data ={}                                   \r\n        data[\"body\"] = commentToUpdate\r\n        inputString = json.dumps(data)\r\n\r\n        reqUrl = '{0}rest/api/2/issue/{1}/comment'.format(MarketPlace_jiraIssueURL, jiraticketID)\r\n        basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n        headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n        response = requests.post(reqUrl, auth=basicAuthCredentials, headers=headers, data=inputString)\r\n        message = response.status_code\r\n        if response.status_code == 201:\r\n            token = \"Comments updated in JIRA!\"\r\n            message = \"Comments updated in JIRA!\"\r\n            result = \"True\"\r\n        else:\r\n            token = \"Invalid Response\"\r\n            message = \"Comments not updated in JIRA!\"\r\n            result = \"False\"\r\n            errorType = \"e20000\"\r\n            errorMessage = message\r\n            errorSeverity = \"ERROR\"\r\n            errorProvider = \"JIRA\"\r\n\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}\r\n\r\n# authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    try:\r\n        import requests\r\n        basicAuthCredentials = (user, password)\r\n        data = {}\r\n        data['Login'] = user\r\n        data['Password'] = password\r\n\r\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\r\n        token = response.content.decode('ascii')\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_auth\": token}"
  outputs:
    - result
    - message
    - newUpdateTime
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
