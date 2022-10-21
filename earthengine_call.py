import os
import ee

id_path = os.path.expanduser('~/credentials/gortega-research-913f6731bbe1.json')
service_account = 'rstudio-xl1@gortega-research.iam.gserviceaccount.com'
credentials = ee.ServiceAccountCredentials(service_account, id_path)
ee.Initialize(credentials)

chilebbox = ee.Geometry.BBox(-75.6443953112,-55.61183,-66.95992,-17.5800118954)

def clipf(image):
	return image.clip(chilebbox)

def get_ee_raster_cl(raster):  
  alos = ee.ImageCollection(raster)
  clip = alos.map(clipf)
  elevation = clip.select('DSM').toBands()
  return elevation
  if __name__ == '__get_ee_raster_cl__':
    get_ee_raster_cl()
