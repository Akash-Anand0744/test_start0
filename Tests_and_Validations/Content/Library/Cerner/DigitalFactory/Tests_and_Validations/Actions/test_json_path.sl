namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: test_json_path
  workflow:
    - get_time:
        do:
          io.cloudslang.base.datetime.get_time: []
        publish:
          - output
          - return_code
          - exception
        navigate:
          - SUCCESS: get_millis
          - FAILURE: on_failure
    - get_newKey_from_OOConfig_1:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: |-
                {"test1_JSON":{
                "test id 1": 1221,
                "test id 2": 1221,
                "test id 3": 1221
                },
                "test2key_JSON":{
                "testkey id 1": 1221,
                "testkey id 2": 1221,
                "testkey id 3": 1221
                }}
            - json_path: test1_JSON
            - input_0: null
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: smax_config_to_jsonKeyValue
          - FAILURE: on_failure
    - smax_config_to_jsonKeyValue:
        do:
          Cerner.DigitalFactory.Tests_and_Validations.Actions.smax_config_to_jsonKeyValue:
            - input_json: |-
                {
                    "entities": [
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 06:00",
                                "LastUpdateTime": 1639569651071,
                                "Id": "92835",
                                "DisplayLabel": "jiraIssueLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47004",
                                "LastUpdateTime": 1635506615251,
                                "Id": "93335",
                                "DisplayLabel": "jiraToolFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49500",
                                "LastUpdateTime": 1637165379038,
                                "Id": "93351",
                                "DisplayLabel": "jiraSmaxIDField"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47215",
                                "LastUpdateTime": 1634123793173,
                                "Id": "93617",
                                "DisplayLabel": "toolInstanceFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47216",
                                "LastUpdateTime": 1635507705147,
                                "Id": "93771",
                                "DisplayLabel": "repoURLFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_22411",
                                "LastUpdateTime": 1635507764935,
                                "Id": "93772",
                                "DisplayLabel": "watcherFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47220",
                                "LastUpdateTime": 1634123887988,
                                "Id": "96291",
                                "DisplayLabel": "swLinkFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47251",
                                "LastUpdateTime": 1634123941447,
                                "Id": "96292",
                                "DisplayLabel": "criticalJustFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47218",
                                "LastUpdateTime": 1634124014963,
                                "Id": "96390",
                                "DisplayLabel": "artfactReqTypeFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47219",
                                "LastUpdateTime": 1634124074770,
                                "Id": "96391",
                                "DisplayLabel": "swExistInNexusFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47005",
                                "LastUpdateTime": 1631613081928,
                                "Id": "96392",
                                "DisplayLabel": "jiraToolRequestFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "test1235",
                                "LastUpdateTime": 1631706036345,
                                "Id": "96442",
                                "DisplayLabel": "test"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "DFAPPSUP",
                                "LastUpdateTime": 1631720618084,
                                "Id": "96459",
                                "DisplayLabel": "artifactoryJiraProject"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Incident",
                                "LastUpdateTime": 1631720633855,
                                "Id": "96460",
                                "DisplayLabel": "artifactoryJiraIssueTypeName"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Artifactory",
                                "LastUpdateTime": 1631720682503,
                                "Id": "96461",
                                "DisplayLabel": "artifactoryJiraFieldNameFilter"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47004",
                                "LastUpdateTime": 1632397356869,
                                "Id": "100812",
                                "DisplayLabel": "jiraToolFieldTemp"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Get Help Support Group",
                                "LastUpdateTime": 1634123448951,
                                "Id": "103723",
                                "DisplayLabel": "OperatorEmail"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 06:00",
                                "LastUpdateTime": 1639569663637,
                                "Id": "103783",
                                "DisplayLabel": "jiraIssueCommentsLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47250",
                                "LastUpdateTime": 1635507211801,
                                "Id": "103787",
                                "DisplayLabel": "JIRA_Request_Category_Field"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "1639569576112",
                                "LastUpdateTime": 1639569610391,
                                "Id": "103953",
                                "DisplayLabel": "smaxIssueCommentsLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47249",
                                "LastUpdateTime": 1634123149582,
                                "Id": "103957",
                                "DisplayLabel": "JIRA_Incident_Category_Field"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49401",
                                "LastUpdateTime": 1637171119929,
                                "Id": "118842",
                                "DisplayLabel": "jiraMarketplaceIssueTypeID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49402",
                                "LastUpdateTime": 1637171067081,
                                "Id": "118843",
                                "DisplayLabel": "jiraMarketOfferNameID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49403",
                                "LastUpdateTime": 1637171270616,
                                "Id": "118844",
                                "DisplayLabel": "jiraMarketplaceStorefrontID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 05:50",
                                "LastUpdateTime": 1639569055958,
                                "Id": "124442",
                                "DisplayLabel": "jiraIssueAttachmentlastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "10636",
                                "LastUpdateTime": 1639049124576,
                                "Id": "125695",
                                "DisplayLabel": "smaxBridgeOOID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_29335",
                                "LastUpdateTime": 1639383743203,
                                "Id": "125706",
                                "DisplayLabel": "Cloud Provider"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_22250",
                                "LastUpdateTime": 1639383766267,
                                "Id": "125707",
                                "DisplayLabel": "Tenant Name"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_29358",
                                "LastUpdateTime": 1639383896581,
                                "Id": "125708",
                                "DisplayLabel": "Tenant Id"
                            },
                            "related_properties": {}
                        }
                    ],
                    "meta": {
                        "completion_status": "OK",
                        "total_count": 29,
                        "errorDetailsList": [],
                        "errorDetailsMetaList": [],
                        "query_time": 1639569721008741
                    }
                }
        publish:
          - message
          - json_key_value: '${key_value_json}'
        navigate:
          - SUCCESS: get_newKey_from_OOConfig
    - get_newKey_from_OOConfig:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: |-
                {
                    "entities": [
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 06:00",
                                "LastUpdateTime": 1639569651071,
                                "Id": "92835",
                                "DisplayLabel": "jiraIssueLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47004",
                                "LastUpdateTime": 1635506615251,
                                "Id": "93335",
                                "DisplayLabel": "jiraToolFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49500",
                                "LastUpdateTime": 1637165379038,
                                "Id": "93351",
                                "DisplayLabel": "jiraSmaxIDField"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47215",
                                "LastUpdateTime": 1634123793173,
                                "Id": "93617",
                                "DisplayLabel": "toolInstanceFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47216",
                                "LastUpdateTime": 1635507705147,
                                "Id": "93771",
                                "DisplayLabel": "repoURLFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_22411",
                                "LastUpdateTime": 1635507764935,
                                "Id": "93772",
                                "DisplayLabel": "watcherFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47220",
                                "LastUpdateTime": 1634123887988,
                                "Id": "96291",
                                "DisplayLabel": "swLinkFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47251",
                                "LastUpdateTime": 1634123941447,
                                "Id": "96292",
                                "DisplayLabel": "criticalJustFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47218",
                                "LastUpdateTime": 1634124014963,
                                "Id": "96390",
                                "DisplayLabel": "artfactReqTypeFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47219",
                                "LastUpdateTime": 1634124074770,
                                "Id": "96391",
                                "DisplayLabel": "swExistInNexusFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47005",
                                "LastUpdateTime": 1631613081928,
                                "Id": "96392",
                                "DisplayLabel": "jiraToolRequestFieldId"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "test1235",
                                "LastUpdateTime": 1631706036345,
                                "Id": "96442",
                                "DisplayLabel": "test"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "DFAPPSUP",
                                "LastUpdateTime": 1631720618084,
                                "Id": "96459",
                                "DisplayLabel": "artifactoryJiraProject"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Incident",
                                "LastUpdateTime": 1631720633855,
                                "Id": "96460",
                                "DisplayLabel": "artifactoryJiraIssueTypeName"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Artifactory",
                                "LastUpdateTime": 1631720682503,
                                "Id": "96461",
                                "DisplayLabel": "artifactoryJiraFieldNameFilter"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47004",
                                "LastUpdateTime": 1632397356869,
                                "Id": "100812",
                                "DisplayLabel": "jiraToolFieldTemp"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "Get Help Support Group",
                                "LastUpdateTime": 1634123448951,
                                "Id": "103723",
                                "DisplayLabel": "OperatorEmail"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 06:00",
                                "LastUpdateTime": 1639569663637,
                                "Id": "103783",
                                "DisplayLabel": "jiraIssueCommentsLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47250",
                                "LastUpdateTime": 1635507211801,
                                "Id": "103787",
                                "DisplayLabel": "JIRA_Request_Category_Field"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "1639569576112",
                                "LastUpdateTime": 1639569610391,
                                "Id": "103953",
                                "DisplayLabel": "smaxIssueCommentsLastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_47249",
                                "LastUpdateTime": 1634123149582,
                                "Id": "103957",
                                "DisplayLabel": "JIRA_Incident_Category_Field"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49401",
                                "LastUpdateTime": 1637171119929,
                                "Id": "118842",
                                "DisplayLabel": "jiraMarketplaceIssueTypeID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49402",
                                "LastUpdateTime": 1637171067081,
                                "Id": "118843",
                                "DisplayLabel": "jiraMarketOfferNameID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_49403",
                                "LastUpdateTime": 1637171270616,
                                "Id": "118844",
                                "DisplayLabel": "jiraMarketplaceStorefrontID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "2021-12-15 05:50",
                                "LastUpdateTime": 1639569055958,
                                "Id": "124442",
                                "DisplayLabel": "jiraIssueAttachmentlastUpdateTime"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "10636",
                                "LastUpdateTime": 1639049124576,
                                "Id": "125695",
                                "DisplayLabel": "smaxBridgeOOID"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_29335",
                                "LastUpdateTime": 1639383743203,
                                "Id": "125706",
                                "DisplayLabel": "Cloud Provider"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_22250",
                                "LastUpdateTime": 1639383766267,
                                "Id": "125707",
                                "DisplayLabel": "Tenant Name"
                            },
                            "related_properties": {}
                        },
                        {
                            "entity_type": "SystemProperties_c",
                            "properties": {
                                "SysPropertyValue_c": "customfield_29358",
                                "LastUpdateTime": 1639383896581,
                                "Id": "125708",
                                "DisplayLabel": "Tenant Id"
                            },
                            "related_properties": {}
                        }
                    ],
                    "meta": {
                        "completion_status": "OK",
                        "total_count": 29,
                        "errorDetailsList": [],
                        "errorDetailsMetaList": [],
                        "query_time": 1639569721008741
                    }
                }
            - json_path: 'entities["properties"]["DisplayLabel"]'
            - input_0: null
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - get_millis:
        do:
          io.cloudslang.microfocus.base.datetime.get_millis: []
        publish:
          - time_millis
        navigate:
          - SUCCESS: get_newKey_from_OOConfig_1
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_newKey_from_OOConfig_1:
        x: 194
        'y': 135
      smax_config_to_jsonKeyValue:
        x: 184
        'y': 388
      get_newKey_from_OOConfig:
        x: 564
        'y': 142
        navigate:
          fdb75f8d-1a2c-a058-0bab-67f067938c3f:
            targetId: d7ef7fe6-14ab-4e8f-f1a4-77b39326a07b
            port: SUCCESS
      get_time:
        x: 330
        'y': 12
      get_millis:
        x: 325
        'y': 166
    results:
      SUCCESS:
        d7ef7fe6-14ab-4e8f-f1a4-77b39326a07b:
          x: 831
          'y': 397
