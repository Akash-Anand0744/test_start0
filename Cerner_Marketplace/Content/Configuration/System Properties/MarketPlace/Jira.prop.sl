########################################################################################################################
#!!
#! @system_property jiraDBServer: Prod JIRA DB Server is IPSQL01NEW.northamerica.cerner.net
#!!#
########################################################################################################################
namespace: MarketPlace
properties:
  - jiraUser: svcMarketDev
  - jiraPassword:
      value: hfJwCL38pjunKyR6
      sensitive: true
  - jiraIssueURL: 'https://jira3dev.cerner.com/'
  - priorityIDs: '{  "Critical_c":1, "High_c":2, "Medium_c":3, "Low_c":4, "CriticalPriority":1, "HighPriority":2, "MediumPriority":3, "LowPriority":4, "NonPrioritized_c":5}'
  - artifactoryRequestType: '{"DeploySoftware_c":"71778", "NewRepo_c":"71779", "Other_c":"71780"}'
  - artifactorySWExistsInRepo: '{"true":"71781", "false":"71782"}'
  - JIRAInstanceIDs: '{"JIRA1_c":71908, "JIRA2_c":71909, "JIRA3_c":71910, "SecureJIRA_c":71912}'
  - ArtifactRepoType: '{"Bower_c":"71783", "Chef_c":"71784", "CocoaPods_c":"71785", "Conan_c":"71786","Conda_c":"71787", "CRAN_c":"71788", "Debian_c":"71789", "Docker_c":"71790","GitLFS_c":"71791", "Go_c":"71792", "Helm":"71793", "Maven_c":"71794","Npm_c":"71795", "NuGet_c":"71796", "Opkg_c":"71797", "P2_c":"71798","PHPComposer_c":"71799", "Puppet_c":"71800", "PyPI_C":"71801", "RPM_c":"71802","RubyGems_c":"71803", "SBT_c":"71804", "Vagrant_c":"71805", "VCS_c":"71806"}'
  - ArtifactReplication: '{"ALL_c":"71807", "ASP_c":"71808", "AWSAustralia_c":"71809", "AWSCanada_c":"71810","AWSWest_c":"71811", "KCCorp_c":"71812", "Kolkata_c":"71813", "MalvernProd_c":"71814","Sweden_c":"71815", "UK_c":"71816"}'
  - ArtifactProxyExternal: '{"true":"71817", "false":"71818"}'
  - jiraDB: core
  - jiraDBUser: svcMarketProd
  - jiraDBPass:
      value: "q;@{ZFz'bXdH2?\\<"
      sensitive: true
  - jiraDBServer:
      value: REVTOOLSDEV.northamerica.cerner.net
      sensitive: false
  - jiraProjects: DFAPPSUP♪ABLREQ♪CLOUDBROKER♪EGGSUTLAB♪AUTOREVBRD♪PMA♪TDMI♪TDS♪ABLIPDOM♪ABILITIES♪CAPA
  - jiraIssueCreator: svcMarketDev
  - lastUpdateTime: '2021-09-01 12:00'
  - MarketIssueType: '{"ServiceRequestSub_c":"78317","FormField_c":"78318","BrokenLinkonOffer_c":"78319","MSearch_c":"78320","Performance_c":"78321","YourRequests_c":"78322","News_c":"78323","Articles_c":"78324","VirtualAgent_c":"78325","Other_c":"78326"}'
  - MarketStorefront: '{"MProductPlanning_c":"78327","MReportanIssue_c":"78328","MEnvironmentServices_c":"78329","MSystemHealth_c":"78330","MAnswersAndInsights_c":"78331","MDeveloperWorkbench_c":"78332","MTraining_c":"78335","MAPIStore_c":"78333"}'
  - jiraIssueTypes: Incident♪Request♪Access♪Platinum Master Approval
