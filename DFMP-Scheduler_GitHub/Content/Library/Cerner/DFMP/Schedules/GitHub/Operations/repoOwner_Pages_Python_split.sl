########################################################################################################################
#!!
#! @description: This Python operation builds the GitHub Pages base URL - '{0}://{1}/api/v3/repos/{2}/{3}/pages'.format(github_protocol, github_host, repoOwner, repoName), and extracts Repo name and Repo Owner name.
#!
#! @input repoOwnerNameVal: Comma delimited repo name and repo owner string.
#! @input reposDelim: Delimiter used for python split - UNUSED
#! @input github_protocol: GitHub protocol
#! @input github_host: GitHub Host
#!
#! @output repoOwner: GitHub Repo Owner Name
#! @output repoName: GitHub Repo Name
#! @output gitPagesapi_url: GitHub Pages URL per repo and repo owner name
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: repoOwner_Pages_Python_split
  inputs:
    - repoOwnerNameVal
    - reposDelim:
        required: false
    - github_protocol: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_protocol')}"
    - github_host: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_host')}"
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(repoOwnerNameVal, github_protocol, github_host):\n    message = \"\"\n    result = \"False\"\n    errorType = \"\"\n    errorSeverity = \"\"\n    errorProvider = \"\"\n    errorMessage = \"\"\n    errorLogs = \"\"\n    repoOwner = \"\"\n    repoName = \"\"\n    gitPagesapi_url = \"\"\n    \n    try:\n        repoOwnerName = repoOwnerNameVal.split(\",\")\n        repoOwner = repoOwnerName[0]\n        repoName = repoOwnerName[1]\n        gitPagesapi_url = '{0}://{1}/api/v3/repos/{2}/{3}/pages'.format(github_protocol, github_host, repoOwner, repoName)\n        result = \"True\"\n        message = \"Successful\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n        if repoOwnerNameVal.find(\",\") == -1:\n            errorMessage = \"'GITHUB Repo Owner and Page URLs' field data in Service Definition is invalid - '\"+repoOwnerNameVal+\"'. Please check and enter data in correct format in Service Definition: \"\n        else:\n            errorMessage = message\n        errorType = 'e20000'\n        if not errorProvider:\n            errorProvider = 'SMAX'\n        errorSeverity = \"ERROR\"\n        errorLogs = \"ProviderUrl,||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(errorMessage) + \"|||\"\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\"errorProvider\": errorProvider,\"errorMessage\":errorMessage,\"errorLogs\":errorLogs,\"repoOwner\": repoOwner, \"repoName\": repoName, \"gitPagesapi_url\": gitPagesapi_url}\n    # code goes here\n# you can add additional helper methods below."
  outputs:
    - repoOwner
    - repoName
    - gitPagesapi_url
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
