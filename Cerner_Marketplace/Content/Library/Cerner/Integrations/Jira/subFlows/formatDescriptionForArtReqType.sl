namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: formatDescriptionForArtReqType
  inputs:
    - artifactoryRequestTypeIn
    - deleteFileFolderLink:
        required: false
    - deleteRepoArtifactName:
        required: false
    - deleteRepoLink:
        required: false
    - deleteRepoExplaination:
        required: false
    - restoreArtifactName:
        required: false
    - restoreRepoLink:
        required: false
    - descriptionIn:
        required: false
    - ReposityTypeLink
  python_action:
    use_jython: false
    script: "def execute(artifactoryRequestTypeIn,deleteFileFolderLink,deleteRepoArtifactName,deleteRepoLink,deleteRepoExplaination,restoreArtifactName, restoreRepoLink,descriptionIn,ReposityTypeLink):\r\n    \r\n    description = \"\"\r\n    artifactoryRequestType=\"\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    \r\n    #descriptionIn = descriptionIn.replace(\"\\\\n\",\"\")\r\n\r\n    try:\r\n        if artifactoryRequestTypeIn ==  \"CreateRepo_c\":\r\n            description = \"Repository type:\"+ReposityTypeLink[:-2]+\"<br>\"+descriptionIn\r\n            artifactoryRequestType = \"NewRepo_c\"\r\n        elif artifactoryRequestTypeIn ==  \"DeleteFileFolder_c\":\r\n            description = \"File/Folder needing deleted: \"+deleteFileFolderLink+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestType = \"Other_c\"\r\n        elif artifactoryRequestTypeIn ==  \"DeleteRepository_c\":\r\n            if len(deleteRepoLink.strip()) > 0:\r\n                description = \"Name of the Artifact: \"+deleteRepoArtifactName+\"\\\\n Repository Link: \"+deleteRepoLink+\"\\\\n Explanation: \"+deleteRepoExplaination+\"\\\\n\"+descriptionIn\r\n            else:\r\n                description = \"Name of the Artifact: \"+deleteRepoArtifactName+\"\\\\n Explanation: \"+deleteRepoExplaination+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestType = \"Other_c\"\r\n        elif artifactoryRequestTypeIn ==  \"RestoreFileFolder_c\":\r\n            if len(restoreRepoLink.strip()) > 0:\r\n                description = \"Name of the Artifact: \"+restoreArtifactName+\"\\\\n Repository Link: \"+restoreRepoLink+\"\\\\n\"+descriptionIn\r\n            else:\r\n                description = \"Name of the Artifact: \"+restoreArtifactName+\"\\\\n\"+descriptionIn\r\n            artifactoryRequestType = \"Other_c\"\r\n        else:\r\n            description = descriptionIn\r\n            artifactoryRequestType = artifactoryRequestTypeIn\r\n\r\n            \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e30011\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        \r\n    result = \"True\"\r\n    message = \"description created successfully\"\r\n    return {\"result\": result, \"message\": message, \"descriptionOut\": description, \"artifactoryRequestTypeOut\": artifactoryRequestType,\"errorType\": errorType,\"errorSeverity\": errorSeverity,\"errorProvider\":errorProvider,\"errorMessage\":errorMessage }"
  outputs:
    - result
    - message
    - artifactoryRequestTypeOut
    - descriptionOut
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
