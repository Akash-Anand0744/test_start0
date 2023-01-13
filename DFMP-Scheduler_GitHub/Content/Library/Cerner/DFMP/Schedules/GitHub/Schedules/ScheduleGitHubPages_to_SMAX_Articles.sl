########################################################################################################################
#!!
#! @description: This flow is used to get GitHub Pages and create/ update/ delete SMAX KM Articles matching the repos and tags specified in SMAX Service Definitions.
#!
#! @input githubTag: This is the default GitHub Pages Tag
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Schedules
flow:
  name: ScheduleGitHubPages_to_SMAX_Articles
  inputs:
    - githubTag: "${get_sp('Cerner.DigitalFactory.MarketPlace.githubTag')}"
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - token
          - message
          - errorMessage
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: Get_GitHub_Pages_Config_from_SMAX
          - FAILURE: on_failure
    - create_list_with_tags_path:
        do:
          io.cloudslang.base.lists.add_element:
            - list: '${allRepoPages}'
            - element: "${hurl+'/tags/'+rTag}"
            - delimiter: ^
        publish:
          - allRepoPages: '${return_result}'
        navigate:
          - SUCCESS: list_iterator_GitHubPages_Tags
          - FAILURE: on_failure
    - is_tags_path_list_null:
        do:
          io.cloudslang.base.utils.is_null:
            - variable: '${allRepoPagesStrList}'
        navigate:
          - IS_NULL: iterator_over_repos_list
          - IS_NOT_NULL: list_iterator_Get_GitHubPages
    - get_GitHub_Pages_content:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: '${gitHubActualPageURL}'
            - auth_type: basic
            - username: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_user')}"
            - password:
                value: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_password')}"
                sensitive: true
        publish:
          - gitHubPage_Response_Headers: '${response_headers}'
          - gitHubActualPageResponse: '${return_result}'
          - return_result
          - errorMessage: '${error_message}'
          - return_code
          - status_code
          - response_headers
          - errorProvider: GITHUB
          - errorType: e20000
        navigate:
          - SUCCESS: prepare_SMAX_KM_Article_structure
          - FAILURE: on_failure
    - add_to_new_external_id_list:
        do:
          io.cloudslang.base.lists.add_element:
            - list: '${new_external_id_list}'
            - element: '${new_external_id}'
            - delimiter: ','
        publish:
          - new_external_id_list: '${return_result}'
        navigate:
          - SUCCESS: add_to_Service_Articles_list
          - FAILURE: on_failure
    - add_to_Service_Articles_list:
        do:
          io.cloudslang.base.lists.add_element:
            - list: '${service_article_list}'
            - element: '${service_article}'
            - delimiter: ♪♪
        publish:
          - service_article_list: '${return_result}'
        navigate:
          - SUCCESS: list_iterator_Get_GitHubPages
          - FAILURE: on_failure
    - Get_GitHub_Pages_Config_from_SMAX:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.buildConfig:
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - token: '${token}'
        publish:
          - result: '${result}'
          - message: '${message}'
          - github_pages: '${github_pages}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: SMAX_Query_Result_returned_True
          - FAILURE: on_failure
    - SMAX_Query_Result_returned_True:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${result}'
            - second_string: 'True'
            - ignore_case: 'true'
        navigate:
          - SUCCESS: FindOldArticlesForSourceSystem
          - FAILURE: on_failure
    - FindOldArticlesForSourceSystem:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.FindOldArticlesForSourceSystem:
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - token: '${token}'
            - SourceSystem: CernerGitHUB
        publish:
          - result: '${result}'
          - message: '${message}'
          - smax_ext_id_list: '${smax_ext_id_list}'
          - extid_smaxid_articlehash: '${extid_smaxid_articlehash}'
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: initialize_articles_list_variables
          - FAILURE: on_failure
    - initialize_articles_list_variables:
        do:
          io.cloudslang.base.utils.do_nothing:
            - new_article_hash_list: ''
            - service_article_list: ''
            - new_external_id_list: ''
        publish:
          - new_article_hash_list: '${new_article_hash_list}'
          - service_article_list: '${service_article_list}'
          - new_external_id_list: '${new_external_id_list}'
        navigate:
          - SUCCESS: No_ServiceDefinitions_with_github_pages_check
          - FAILURE: on_failure
    - extract_SDid_repos_tags:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.common_python_split_action:
            - reposTagsList: '${reposTagsList}'
            - defaultGitHubTag: '${githubTag}'
        publish:
          - pages: '${pages}'
          - gitRepoTags: "${gitRepoTags+'^'+defaultGitHubTag}"
          - serviceDefinitionId: '${serviceDefinitionId}'
          - allRepoPages: '${allRepoPages}'
          - gitRepoTagsCheckList: '${gitRepoTagsCheckList}'
          - repos: '${repos}'
          - result
          - message
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - SUCCESS: iterator_over_repos_list
          - FAILURE: on_failure
    - iterator_over_repos_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${repos}'
            - separator: ^
        publish:
          - eachRepoOwnerName: '${result_string}'
        navigate:
          - HAS_MORE: repoOwner_Pages_Python_split
          - NO_MORE: list_iterator_serviceId_repo_tags
          - FAILURE: on_failure
    - repoOwner_Pages_Python_split:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.repoOwner_Pages_Python_split:
            - repoOwnerNameVal: '${eachRepoOwnerName}'
            - smaxSDId: '${serviceDefinitionId}'
        publish:
          - repoOwner: '${repoOwner}'
          - repoName: '${repoName}'
          - gitPagesapi_url: '${gitPagesapi_url}'
          - result
          - message
          - errorMessage: "${errorMessage+smaxSDId+'.'}"
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs: ''
        navigate:
          - SUCCESS: Get_Main_GitHub_Page_URL
          - FAILURE: on_failure
    - Get_Main_GitHub_Page_URL:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: '${gitPagesapi_url}'
            - auth_type: basic
            - username: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_user')}"
            - password:
                value: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_password')}"
                sensitive: true
        publish:
          - returnRes: '${return_result}'
          - respHeaders: '${response_headers}'
          - errorType: e20000
          - errorMessage: '${error_message}'
          - errorProvider: GitHub
          - errorSeverity: ERROR
          - errorLogs: "${'ProviderUrl,'+url+'||ErrorProvider,GitHub||ProviderUrlBody,||ErrorMessage,'+error_message+'|||'}"
        navigate:
          - SUCCESS: get_repoURL
          - FAILURE: iterator_over_repos_list
    - Get_GitHub_Trees_URL:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_protocol')+'://'+get_sp('Cerner.DigitalFactory.MarketPlace.github_host')+'/api/v3/repos/'+repoOwner+'/'+repoName+'/contents/content/'}"
            - auth_type: basic
            - username: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_user')}"
            - password:
                value: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_password')}"
                sensitive: true
        publish:
          - GitHubContentsFolderRes: '${return_result}'
          - gittreeapi_url: "${cs_substring(return_result,return_result.find(\"git_url\")+10,return_result.find('\"download_url\"')-2)+':?recursive=true'}"
          - errorType: e20000
          - errorMessage: '${error_message}'
          - errorProvider: GitHub
          - errorSeverity: ERROR
          - errorLogs: "${'ProviderUrl,'+url+'||ErrorProvider,GitHub||ProviderUrlBody,||ErrorMessage,'+error_message+'|||'}"
        navigate:
          - SUCCESS: Get_GitHub_Recursive_Trees
          - FAILURE: on_failure
    - Get_GitHub_Recursive_Trees:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: '${gittreeapi_url}'
            - auth_type: basic
            - username: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_user')}"
            - password:
                value: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_password')}"
                sensitive: true
            - content_type: application/json
            - defaultGitHubTag: '${githubTag}'
        publish:
          - gitTrees: '${return_result}'
          - errorType: e20000
          - errorMessage: '${error_message}'
          - errorProvider: GitHub
          - errorSeverity: ERROR
          - errorLogs: "${'ProviderUrl,'+url+'||ErrorProvider,GitHub||ProviderUrlBody,||ErrorMessage,'+error_message+'|||'}"
        navigate:
          - SUCCESS: getValidGitHubTrees
          - FAILURE: on_failure
    - getValidGitHubTrees:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.getValidGitHubTrees:
            - gitTreesJson: '${gitTrees}'
            - hurl: '${hurl}'
        publish:
          - allRepoPagesStrList: '${allRepoPagesStrList}'
          - gitTreesResult: '${result}'
          - gitTreesMessage: '${message}'
          - result
          - message
          - errorMessage: '${errorMessage}'
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorLogs
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator_GitHubPages_Tags
    - prepare_SMAX_KM_Article_structure:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.prepareGitHubPages:
            - githubPagesBaseUrl: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_protocol')+'://pages.'+get_sp('Cerner.DigitalFactory.MarketPlace.github_host')}"
            - gitHubActualPageURL: '${gitHubActualPageURL}'
            - gitHubActualPageResponse: '${gitHubActualPageResponse}'
            - github_page_tagsStr: '${allRepoPages}'
            - smaxService: '${serviceDefinitionId}'
            - github_user: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_user')}"
            - github_password: "${get_sp('Cerner.DigitalFactory.MarketPlace.github_password')}"
        publish:
          - prepareGitHubPagesresult: '${result}'
          - message: '${message}'
          - service_article: '${service_article}'
          - new_external_id: '${new_external_id}'
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: If_service_article_notNull
          - FAILURE: on_failure
    - Prepare_Process_SMAX_KM_Articles:
        do:
          Cerner.DFMP.Schedules.GitHub.SubFlows.Prepare_Process_SMAX_KM_Articles:
            - SMAX_studio_app: Article
            - service_article_list: '${service_article_list}'
            - new_external_id_list: '${new_external_id_list}'
            - smax_ext_id_list: '${smax_ext_id_list}'
            - extid_smaxid_articlehash: '${extid_smaxid_articlehash}'
            - SourceSystem: CernerGitHUB
            - token: '${token}'
        publish:
          - message
          - errorMessage
          - errorProvider
          - errorSeverity
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - No_ServiceDefinitions_with_github_pages_check:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${github_pages}'
            - second_string: NONE
            - ignore_case: 'True'
        navigate:
          - SUCCESS: Prepare_Process_SMAX_KM_Articles
          - FAILURE: list_iterator_serviceId_repo_tags
    - list_iterator_GitHubPages_Tags:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${gitRepoTags}'
            - separator: ^
        publish:
          - rTag: '${result_string}'
        navigate:
          - HAS_MORE: create_list_with_tags_path
          - NO_MORE: is_tags_path_list_null
          - FAILURE: on_failure
    - list_iterator_Get_GitHubPages:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${allRepoPagesStrList}'
            - separator: ^^
        publish:
          - gitHubActualPageURL: '${result_string}'
        navigate:
          - HAS_MORE: get_GitHub_Pages_content
          - NO_MORE: iterator_over_repos_list
          - FAILURE: on_failure
    - list_iterator_serviceId_repo_tags:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${github_pages}'
            - separator: ♪♪
        publish:
          - reposTagsList: '${result_string}'
        navigate:
          - HAS_MORE: extract_SDid_repos_tags
          - NO_MORE: Prepare_Process_SMAX_KM_Articles
          - FAILURE: on_failure
    - If_service_article_notNull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${service_article}'
            - second_string: ''
            - ignore_case: 'true'
        navigate:
          - SUCCESS: list_iterator_Get_GitHubPages
          - FAILURE: add_to_new_external_id_list
    - get_repoURL:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${returnRes}'
            - json_path: html_url
        publish:
          - hurl: '${return_result[:-1]}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: Get_GitHub_Trees_URL
          - FAILURE: iterator_over_repos_list
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - errorLogs: ''
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      SMAX_Query_Result_returned_True:
        x: 320
        'y': 80
      prepare_SMAX_KM_Article_structure:
        x: 40
        'y': 440
      If_service_article_notNull:
        x: 40
        'y': 240
      list_iterator_serviceId_repo_tags:
        x: 960
        'y': 240
      list_iterator_GitHubPages_Tags:
        x: 760
        'y': 720
      FindOldArticlesForSourceSystem:
        x: 440
        'y': 80
      list_iterator_Get_GitHubPages:
        x: 440
        'y': 440
      initialize_articles_list_variables:
        x: 600
        'y': 80
      get_GitHub_Pages_content:
        x: 240
        'y': 440
      getValidGitHubTrees:
        x: 960
        'y': 720
      extract_SDid_repos_tags:
        x: 760
        'y': 280
      add_to_Service_Articles_list:
        x: 440
        'y': 240
      repoOwner_Pages_Python_split:
        x: 1280
        'y': 280
      create_list_with_tags_path:
        x: 440
        'y': 720
      Get_GitHub_Trees_URL:
        x: 1280
        'y': 720
      add_to_new_external_id_list:
        x: 240
        'y': 240
      get_repoURL:
        x: 1280
        'y': 600
      Prepare_Process_SMAX_KM_Articles:
        x: 960
        'y': 80
        navigate:
          7e631bc3-b6c8-42b5-7cc6-5c7e134490b4:
            targetId: 922b0474-ff59-f3bc-6723-e3bf7594104c
            port: SUCCESS
      No_ServiceDefinitions_with_github_pages_check:
        x: 760
        'y': 80
      Get_GitHub_Recursive_Trees:
        x: 1120
        'y': 720
      iterator_over_repos_list:
        x: 960
        'y': 440
      Get_GitHub_Pages_Config_from_SMAX:
        x: 200
        'y': 80
      Get_Main_GitHub_Page_URL:
        x: 1280
        'y': 440
      get_SMAXToken:
        x: 40
        'y': 80
      is_tags_path_list_null:
        x: 760
        'y': 560
    results:
      SUCCESS:
        922b0474-ff59-f3bc-6723-e3bf7594104c:
          x: 1280
          'y': 80
