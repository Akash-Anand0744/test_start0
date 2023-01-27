namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: createArtifactoryIdJSON_List
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
    script: "# do not remove the execute function\ndef execute(instanceId1,instanceId2,instanceId3,instanceId4,instanceId5):\n    artifactoryIdJSON = ''\n    \n    try:\n        if len(instanceId1.strip()) > 0:\n            artifactoryIdJSON = '{\"id\":\"'+instanceId1[1:-2].strip()+'\"}'\n        if len(instanceId2.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId2[1:-2].strip()+'\"}'\n        if len(instanceId3.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId3[1:-2].strip()+'\"}'\n        if len(instanceId4.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId4[1:-2].strip()+'\"}'\n        if len(instanceId5.strip()) > 0:\n            artifactoryIdJSON += ',{\"id\":\"'+instanceId5[1:-2].strip()+'\"}'\n            \n    except Exception as e:\n        message = e\n        result = \"False\"\n        \n    result = \"True\"\n    message = artifactoryIdJSON\n    \n    return{\"result\": result, \"message\": message }"
  outputs:
    - result
    - message
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
