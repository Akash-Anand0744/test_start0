########################################################################################################################
#!!
#! @system_property requestComment: Comment for Remedy Incidents  to be appended to each
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Remedy
properties:
  - rapidURL: 'https://rapid-staging.cerner.com:8243'
  - consumerKey: EAzYkPWdgvIiJ69DwmfskZZxWkwa
  - consumerSecret:
      value: eXMKasC8ZfcouUi7f5VC6fJXxMga
      sensitive: true
  - requestComment:
      value: This request originates from the Factory Marketplace and manager approval is included with submission
      sensitive: false
  - assignedGroupJSON: '{"Default":"ITSS_Software_Asset_Mgmt_CTS","Cloud Desktops|Yes":"AT_Cloud_Desktops_CTS","Cloud Desktops|No":"ITSS_End_User_Devices_CTS","PPM":"ES BusSvcs Project Del CTS","Service accounts":"Ent_Security_Access_CTS"}'
  - remedyaskURL: 'https://askcert.cerner.com/dwp/app/#/activity'
  - remedyReqResolutionComment: 'Directly follow up in ASK further progress/updates. If this request was logged on your behalf, please follow up with the associate who logged this ticket for any ASK request updates'
