library(raster)
library(bigmemory)

bb <- readOGR('C:/Projects/Roper/Boundaries/AGDCv2_tiles_albers_fullset_with_ID.shp')
extent(bb)

att <- 'PV_PC_50'

templateR <- raster(resolution=25, ext=extent(bb),  crs=sp::CRS("+proj=aea +lat_1=-18 +lon_0=132 +lat_0=0 +x_0=0 +y_0=0 +a=6378137 +rf=298.257222101 +lat_2=45.5 "))

BMPath <- 'e:/temp'

rootTiles <- paste0('C:/Temp/fcverDirect/', att) 
rootOut <- paste0('E:/FractionalCover/', att)
if(!file.exists(rootOut)){dir.create(rootOut, recursive = T)}

x <- filebacked.big.matrix(nrow(templateR), ncol(templateR),  type="integer",  
                           separated=FALSE, 
                           backingpath = BMPath,
                           backingfile = paste0(att, '_bm.bin'),
                           descriptor=paste0(att, '_bm.desc')
)



fls <- list.files(rootTiles, full.names = T, recursive = T)



for (i in 1:length(fls)) {
  print(i)
  r1 <- raster(fls[[i]])
  origin(r1)
  m <- as.matrix(r1)
  incrd <- xyFromCell(r1,c(1))
  outCell <- cellFromXY(templateR, incrd)
  rc1 <- rowColFromCell(templateR, outCell)
  incrd2 <- xyFromCell(r1,ncell(r1))
  outCell2 <- cellFromXY(templateR, incrd2)
  rc2 <- rowColFromCell(templateR, outCell2)
  reps <- matrix( r1[], nrow=nrow(r1), ncol=ncol(r1), byrow = T)
  x[rc1[1,1]:rc2[1,1], rc1[1,2]:rc2[1,2]] <- reps
}


outName <- paste0(rootOut, '.tif')
s2 <- writeStart(templateR, filename=outName, format='GTiff', datatype = 'INT2S', overwrite=TRUE, NAvalue=-9999.0)

for (i in 1:nrow(x)) {
  
  vals <- x[i,]
  print(i)
  writeValues(s2, vals, i)
}
s2 <- writeStop(s2)














minx <- 1000000000
maxx <- -1000000000
miny <- 1000000000
maxy <- -1000000000

for (i in 1:length(fls)) {
  print(fls[[i]])
  r1 <- raster(fls[[i]])
  e <- extent(r1)
  if(e[1] < minx){minx <- e[1]}
  if(e[2] > maxx){maxx <- e[2]}
  if(e[3] < miny){miny <- e[3]}
  if(e[4] > maxy){maxy <- e[4]}
}
nr <-(maxy - miny) / cellsize 
nc <-(maxx - minx) / cellsize

x <- NULL
gc()
if(file.exists(paste0(BMPath, '/', dtype, '_bm.bin'))){unlink(paste0(BMPath, '/', dtype, '_bm.bin'))}
if(file.exists(paste0(BMPath, '/', dtype, '_bm.desc'))){unlink(paste0(BMPath, '/', dtype, '_bm.desc'))}

x <- filebacked.big.matrix(nr, nc,  type="integer",  
                           separated=FALSE, 
                           backingpath = BMPath,
                           backingfile = paste0(dtype, '_bm.bin'),
                           descriptor=paste0(dtype, '_bm.desc')
)




x <- attach.big.matrix('f:/temp/PV_bm.desc')


pr <- CRS('+proj=aea +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=132 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ')
outR <- raster(xmn=minx, xmx=maxx, ymn=miny, ymx=maxy, crs=pr  ,  resolution = 25, vals=NULL)
NAvalue( outR ) <- -9999.0


for (i in 1:length(fls)) {
  print(i)
  r1 <- raster(fls[[i]])
  origin(r1)
  m <- as.matrix(r1)
  incrd <- xyFromCell(r1,c(1))
  outCell <- cellFromXY(outR, incrd)
  rc1 <- rowColFromCell(outR, outCell)
  incrd2 <- xyFromCell(r1,ncell(r1))
  outCell2 <- cellFromXY(outR, incrd2)
  rc2 <- rowColFromCell(outR, outCell2)
  reps <- matrix( r1[], nrow=nrow(r1), ncol=ncol(r1), byrow = T)
  x[rc1[1,1]:rc2[1,1], rc1[1,2]:rc2[1,2]] <- reps
}


rasterOptions(tmpdir = 'f:/temp/rasterTemp')

outName <- paste0(rootOut, '.tif')
s2 <- writeStart(outR, filename=outName, format='GTiff', datatype = 'INT2S', overwrite=TRUE, NAvalue=-9999.0)

for (i in 1:nrow(x)) {
  
  vals <- x[i,]
  print(i)
  writeValues(s2, vals, i)
}
s2 <- writeStop(s2)

