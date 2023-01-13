namespace: projs
flow:
  name: myFlow0
  inputs:
    - in_p: value
  workflow:
    - Generate_Random_Number:
        do_external:
          06fe8531-868b-4e79-aa7a-13a5e30a66ec:
            - min: '2'
            - max: '10'
            - input_1: '${"in_p"}'
        navigate:
          - success:
              next_step: SUCCESS
              ROI: '9'
          - failure: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Generate_Random_Number:
        x: 280
        'y': 120
        navigate:
          d3026dd4-a469-485d-2c99-8cbb1e3d01fc:
            targetId: 81ed255c-5bf7-5229-965d-f92e5332d48d
            port: success
    results:
      SUCCESS:
        81ed255c-5bf7-5229-965d-f92e5332d48d:
          x: 600
          'y': 120
