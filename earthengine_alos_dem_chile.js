var chilebbox = ee.Geometry.BBox(-75.6443953112,-55.61183,-66.95992,-17.5800118954);
var alos = ee.ImageCollection('JAXA/ALOS/AW3D30/V3_2')
.map(function(image){return image.clip(chilebbox)});
var elevation = alos.select('DSM');
var elevationVis = {
  min: 0,
  max: 5000,
  palette: ['0000ff', '00ffff', 'ffff00', 'ff0000', 'ffffff']
};

Map.addLayer(elevation, elevationVis)

var bands = elevation.toBands()

Export.image.toDrive({
  image: bands,
  description: 'alos_dem_chile',
});
