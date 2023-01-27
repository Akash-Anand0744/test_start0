namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: createArtifactoryIdJSON
  inputs:
    - instanceId1
    - instanceId2:
        required: false
    - instanceId3:
        required: false
    - instanceId4:
        required: false
    - instanceId5:
        required: false
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(instanceId1,instanceId2,instanceId3,instanceId4,instanceId5):\n    artifactoryIdJSON = ''\n    errorType = ''\n    errorMessage = ''\n    errorSeverity = ''\n    errorProvider = ''\n    \n    \n    try:\n        if len(instanceId1.strip()) > 0:\n            artifactoryIdJSON = '{\"id\":\"'+instanceId1.strip()+'\"}'\n        if len(instanceId2.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId2.strip()+'\"}'\n        if len(instanceId3.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId3.strip()+'\"}'\n        if len(instanceId4.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId4.strip()+'\"}'\n        if len(instanceId5.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId5.strip()+'\"}'\n            \n    except Exception as e:\n        message = e\n        result = \"False\"\n        errorType = \"e30000\"\n        errorMessage = message\n        errorSeverity = \"ERROR\"\n        errorProvider = \"SMAX\"\n        \n        \n    result = \"True\"\n    message = artifactoryIdJSON\n    \n    return{\"result\": result, \"message\": message,\"errorType\": errorType,\"errorSeverity\": errorSeverity,\"errorProvider\":errorProvider,\"errorMessage\":errorMessage}"
  outputs:
    - result
    - message
    - errorCode
    - errorMessage
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
