########################################################################################################################
#!!
#! @system_property jiraAlign_smaxUpdate_list: Key Value Pair of jira API URL and SMAX Studio APP separated by  double 
#!                                             "||"
#! @system_property jira_dbQueryList: This is used for Dynamic Drop Menu, to fetch SQL query and DB details
#! @system_property akash_sp: dummy sp
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.JIRA_ALIGN
properties:
  - jira_align_host: cernertest.jiraalign.com
  - protocol: https
  - token:
      value: 'user:12845|!A)P{hA<rm1*xZYyP&|!eE<4Vy:NX4dgIdqbQl35'
      sensitive: true
  - jiraAlign_smaxUpdate_list:
      value: '/rest/align/api/2/programs,JiraPlanningGroup_c||/rest/align/api/2/portfolios,JiraPortfolioGroups_c||'
      sensitive: false
  - jira_smaxUpdate_list: 'DFAPPSUP,customfield_47805,JiraPipelineGroup_c,Request||DFAPPSUP,customfield_47644,TargetPipeline_c,Request||'
  - jira_dbQueryList:
      value: "select s.TEAM_NUMBER as id, s.TEAM_NAME as title, s.Team_Contact as description,'None' as update_date from sf_team s where s.team_contact not in ('NULL', 'Inactive', 'Inactivated') and s.Client_Viewable = 1|RTMaster|FTPTSolution_c||SELECT ip_asset_id as id, ip_solution as title,  ip_solution as description, update_dt_tm as update_date FROM MAP_IP_SOLUTION|RTMaster|IPAsset_c||SELECT sub_asset_id as id, ip_solution_detail as title,ip_solution_detail as description, update_dttm as update_date, ip_asset_id as dependson FROM MAP_IP_SOL_DTL|RTMaster|IPSubAssest_c||"
      sensitive: false
  - akash_sp:
      value: akash_sp value
      sensitive: false
