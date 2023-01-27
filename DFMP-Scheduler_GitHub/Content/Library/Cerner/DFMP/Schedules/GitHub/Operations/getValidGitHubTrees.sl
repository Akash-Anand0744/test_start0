########################################################################################################################
#!!
#! @description: This Python operation checks if the input has matching GitHub Tags and returns the full GitHub Pages URL list separated by double caret symbol ^^. This list can then be used to Get the Page content for each URL.
#!
#! @input gitTreesJson: This is the Git Tress JSON input - the response returned from gitTree API.
#! @input hurl: GitHub Main Page URL
#!
#! @output allRepoPagesStrList: GitHub Pages URL list separated by double caret symbol ^^
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: getValidGitHubTrees
  inputs:
    - gitTreesJson
    - hurl
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(gitTreesJson, hurl):\n    import json\n    message = \"\"\n    result = \"False\"\n    errorType = \"\"\n    errorSeverity = \"\"\n    errorProvider = \"\"\n    errorMessage = \"\"\n    errorLogs = \"\"\n    allRepoPagesStrList = ''\n    try:\n        convgitTreesJson = json.loads(gitTreesJson)\n        treeArray = convgitTreesJson.get('tree')\n        allRepoPages = []\n        for treeElement in treeArray:\n            if \"_index.md\" in treeElement.get('path') and \"tags/\" not in treeElement.get('path'):\n                gitSubPage = treeElement.get('path')\n                if gitSubPage != \"_index.md\":\n                    subPageVal = hurl+'/'+gitSubPage[:-10].replace(\" \", \"-\").lower()\n                    allRepoPages.append(subPageVal)\n                    result = 'True'\n        allRepoPagesStrList = \"^^\".join(allRepoPages)\n    except Exception as e:\n        message = str(e)\n        result = \"False\"\n        errorMessage = message\n        errorType = 'e20000'\n        if not errorProvider:\n            errorProvider = 'GitHub'\n        errorSeverity = \"ERROR\"\n        errorLogs = \"ProviderUrl,||ErrorProvider,OO||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\"errorProvider\": errorProvider,\"errorMessage\":errorMessage,\"errorLogs\":errorLogs, \"allRepoPagesStrList\": allRepoPagesStrList}\n    \n# you can add additional helper methods below."
  outputs:
    - result
    - message
    - allRepoPagesStrList
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
