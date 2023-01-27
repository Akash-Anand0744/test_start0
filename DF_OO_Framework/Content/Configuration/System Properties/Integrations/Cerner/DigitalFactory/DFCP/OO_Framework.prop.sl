########################################################################################################################
#!!
#! @system_property dnd_oo_user: csa user for which to get identifer
#! @system_property dnd_rest_user: dnd user having rest priviliges
#! @system_property dnd_rest_user_password: dnd rest user  password
#! @system_property csa_rest_uri: new URL for DND APIs
#! @system_property csa_api_uri: Legacy API URL  of DND
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.DFCP
properties:
  - dnd_oo_user:
      value: dnd-transport
      sensitive: false
  - dnd_rest_user:
      value: dnd-transport
      sensitive: false
  - dnd_rest_user_password:
      value: ''
      sensitive: true
  - csa_rest_uri:
      value: 'https://factorymarketdev.cerner.com:443/336419949/dnd/rest'
      sensitive: false
  - csa_api_uri:
      value: 'https://factorymarketdev.cerner.com:443/336419949/dnd'
      sensitive: false
