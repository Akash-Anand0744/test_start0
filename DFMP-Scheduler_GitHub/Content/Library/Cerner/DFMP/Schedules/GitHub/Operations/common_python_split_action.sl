########################################################################################################################
#!!
#! @description: This Python operation extracts GitHub repo related parameters separated by multiple delimiters - ♪ and comma "," and double pipe "||"
#!
#! @input reposTagsList: Delimited list string to extract GitHub related parameters.
#!
#! @output pages: Variable containing string of SMAX Service Definition ID, GitHub repo & repo owner names and GitHub Tags
#! @output gitRepoTags: GitHub Tags separated by caret ^
#! @output serviceDefinitionId: SMAX Service Definition ID
#! @output allRepoPages: All Repo Pages info - UNUSED.
#! @output gitRepoTagsCheckList: Repo Tags check list to validate pages against - UNUSED
#! @output repos: GitHub Repo and Repo Owner name
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: common_python_split_action
  inputs:
    - reposTagsList
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      def execute(reposTagsList):
          message = ""
          result = "False"
          errorType = ""
          errorSeverity = ""
          errorProvider = ""
          errorMessage = ""
          errorLogs = ""
          try:
              pages = reposTagsList.split("♪")
              gitRepoTags = pages[1].split(",")
              gitRepoTags = '^'.join(gitRepoTags)
              reposList = pages[0]
              repos = reposList.split("||")
              sdIdRepo = repos[0]
              sdIdRepoList = sdIdRepo.split(",")
              serviceDefinitionId = sdIdRepoList[0]
              sdIdRepoList.pop(0)
              repos.pop(0)
              repos.insert(0, ",".join(sdIdRepoList))
              repos = '^'.join(repos)
              allRepoPages = ''
              gitRepoTagsCheckList = ''
              result = "True"
          except Exception as e:
              message = e
              result = "False"
              errorMessage = message
              errorType = 'e30000'
              if not errorProvider:
                  errorProvider = 'OO'
              errorSeverity = "ERROR"
              errorLogs = "ProviderUrl,||ErrorProvider,OO||ProviderUrlBody,||ErrorMessage," + str(message) + "|||"
          return {"result": result, "message": message, "errorType": errorType, "errorSeverity": errorSeverity,"errorProvider": errorProvider,"errorMessage":errorMessage,"errorLogs":errorLogs,"pages": pages, "gitRepoTags": gitRepoTags, "serviceDefinitionId": serviceDefinitionId, "allRepoPages": allRepoPages, "gitRepoTagsCheckList": gitRepoTagsCheckList, "repos": repos}

          # code goes here
      # you can add additional helper methods below.
  outputs:
    - pages
    - gitRepoTags
    - serviceDefinitionId
    - allRepoPages
    - gitRepoTagsCheckList
    - repos
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
