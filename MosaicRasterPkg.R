## Mosaic tiled PC rasters
library(raster)
library(rgdal)
library(sp)


att <- 'PV_PC_50'
data.directory <- paste0('C:/Temp/fcverDirect/', att)

### organism pca 1
raster_list <- list() # initialise the list of rasters

#Raster file names
rast.list = list.files(data.directory, '.tif$', recursive = T, full.names = T )

#Append rasters to list
for (i in 1:length(rast.list)){
  r1<- raster(rast.list[i])
  raster_list <- append(raster_list, r1)
  print(i)
}

# do the mosaic
mos <- do.call(raster::merge, raster_list)


writeRaster(mos, 'c:/temp/mospkg.tif', format='GTiff', overwrite=T)


