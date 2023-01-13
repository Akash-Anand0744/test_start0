########################################################################################################################
#!!
#! @system_property snowflakeQueryList: This is used for Dynamic Drop Menu, 4 parameter query| yes or not use second 
#!                                      query| table to fill | second query let info in description as table ||
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.snowflake
properties:
  - snowflake_user: SVC_MARKETPLACE_INTEGRATION
  - snowflake_password:
      value: VeFr477tLHks
      sensitive: true
  - snowflake_db: SFDW_DEV
  - snowflake_role: RLPRV_PLM_REPORTING
  - snowflake_schema: PLM
  - snowflake_warehouse: PLM_REPORTING_WH
  - snowflake_account: ki49020.east-us-2.azure
  - snowflakeQueryList:
      value: 'select distinct sd.ARTIFACT_ID as id, sd.name as title,sd.name as description ,GETDATE() as update_date  from service_details_v sd |yes|AlvaServices_c|select distinct sd.ARTIFACT_ID as id, sdep.environment as environment, sdep.region as region , sdep.version as version from service_details_v sd join service_deployments_v sdep on sdep.service_hash = sd.service_hash ||select SDAV.asset_version_id as id,sdav.ASSET_VERSION as title, sdav.asset_version as description, sda.asset_name as dependson, GETDATE() as update_date from sai_dl_asset sda join sai_dl_asset_version sdav on sdav.asset_id = sda.asset_id where sda.ASSET_NAME in (select distinct SD.ARTIFACT_ID from SERVICE_DETAILS_V SD)|yes|AlvaServiceVersion_c|select distinct SDAV.ASSET_VERSION as ASSET_VERSION, sdav.asset_version_id as id,sda.asset_group_name as asset_group_name,sda.asset_name as asset_name,sda.asset_type as asset_type,sda.asset_family_type as asset_family_type,sda.source_repository_url as source_repository_url,sdav.asset_version_source_repository_revision as asset_version_source_repository_revision from sai_dl_asset sda join sai_dl_asset_version sdav on sdav.asset_id = sda.asset_id where sda.ASSET_NAME in (select distinct SD.ARTIFACT_ID from SERVICE_DETAILS_V SD)||select distinct SDEP.ENVIRONMENT  as id, SDEP.ENVIRONMENT as title,SDEP.ENVIRONMENT as description from SERVICE_DEPLOYMENTS_V SDEP|no|AlvaDeployEnvironments_c|q2||'
      sensitive: false
