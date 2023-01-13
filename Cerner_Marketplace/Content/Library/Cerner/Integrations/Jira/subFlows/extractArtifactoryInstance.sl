namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: extractArtifactoryInstance
  inputs:
    - artifactoryIds
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(artifactoryIds):\n    artifactoryIdJSON = ''\n    try:\n        if len(artifactoryIds.strip()) > 0:\n            if artifactoryIds.find(\",\") == -1:\n                artifactoryIdJSON = '{\"id\":\"'+artifactoryIds.strip()+'\"}'\n                \n            else:\n                artifactoryIds = artifactoryIds[1:-1]\n                #print(artifactoryIds)\n                artifactoryList = artifactoryIds.split(',')\n                for artifactory in artifactoryList:\n                    artifactoryIdJSON += '{\"id\":\"'+artifactory.strip()+'\"},'\n                artifactoryIdJSON = artifactoryIdJSON[0:-1]   \n    except Exception as e:\n        message = e\n        result = \"False\"\n        \n    result = \"True\"\n    message = artifactoryIdJSON\n    \n    return{\"result\": result, \"message\": message }\n    \n    \n# you can add additional helper methods below."
  outputs:
    - result
    - message
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
