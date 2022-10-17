import pprint
from apiclient.discovery import build

SERVER = 'https://trends.googleapis.com'

API_VERSION = 'v1beta'
DISCOVERY_URL_SUFFIX = '/$discovery/rest?version=' + API_VERSION
DISCOVERY_URL = SERVER + DISCOVERY_URL_SUFFIX

def call_gtrends_cl(query):
  service = build('trends', 'v1beta',
  developerKey='AIzaSyC1ssJTcoeOkbRkgrFuWmD8UmoZIQYo9wk',
                  discoveryServiceUrl=DISCOVERY_URL)
                  
  response = service.getGraph(terms=['/m/02p92st', query],
                              restrictions_startDate='2010-01',
                              restrictions_endDate='2021-01',
                              restrictions_geo = 'CL').execute()
  return response
  
  if __name__ == '__call_gtrends_cl__':
    call_gtrends_cl()
