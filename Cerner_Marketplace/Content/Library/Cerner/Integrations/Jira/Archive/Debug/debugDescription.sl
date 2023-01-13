namespace: Cerner.Integrations.Jira.Archive.Debug
flow:
  name: debugDescription
  workflow:
    - formatDescriptionForArtReqType:
        do:
          Cerner.Integrations.Jira.subFlows.formatDescriptionForArtReqType:
            - artifactoryRequestTypeIn: DeleteRepository_c
            - deleteRepoExplaination: test
            - descriptionIn: '<p>test</p>'
            - ReposityTypeLink: Local_c
        publish:
          - artifactoryRequestTypeOut
          - message
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      formatDescriptionForArtReqType:
        x: 166
        'y': 115
        navigate:
          f92c5301-1592-87fb-6a7d-f3a1c4fdcecc:
            targetId: da9067e3-fb7d-c649-2ec2-b078c42cf77d
            port: SUCCESS
    results:
      SUCCESS:
        da9067e3-fb7d-c649-2ec2-b078c42cf77d:
          x: 349
          'y': 135.6666717529297
