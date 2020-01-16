library(raster)
library(ncdf4)
library(httr)
library(XML)
library(xml2)
library(stringr)
library(htmltidy)
library(async)


# NCI Paths
# NCI THredds Root - http://dap.nci.org.au/thredds/catalog.html
# GA DataCube - http://dap.nci.org.au/thredds/remoteCatalogService?catalog=http://dapds00.nci.org.au/thredds/catalogs/fk4/catalog.xml


# Direct Download from within R Raster

rootOut <- 'c:/temp/fcverDirect'
xv <- seq(-19, 21, 1)
yv <- seq(-10, -43, -1)
#att <- 'PV_PC_50'
att <- 'NPV_PC_50'
rootOut <- 'c:/temp/fcver'


for (i in 1:length(xv)) {
   for (j in 1:length(yv)) {
      
      linkoURL <- paste0('http://dap.nci.org.au/thredds/remoteCatalogService?catalog=http://dapds00.nci.org.au/thredds/catalog/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/catalog.xml')
      doc <- htmlParse(linkoURL)
      links <- xpathSApply(doc, '//a[@href]', xmlValue)
      linksf <- links[grepl('.nc$',links)]
      
      if(length(linksf) > 0){
         outd <- paste0(rootOut,'/', att, '/x_', xv[i], '_y_', yv[j] )
         if(!dir.exists(outd)){dir.create(outd, recursive = T)}
         
         #tInf <-  getTileInfo(xv[i], yv[j], linksf[1])
         
         for (k in 1:length(linksf)) {
            fname <- linksf[k]
            outPath <- str_replace(paste0(outd, '/', att, '_', fname), '.nc', '.tif')
            if(!file.exists(outPath)){
               
               print(fname)
               url <- paste0('http://dapds00.nci.org.au/thredds/dodsC/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/', fname)
               r <- raster(url, varname = att, band = 1)
               
               #try(  downloadOpenDAP2(url, tInf),  silent=F)
               
               writeRaster(r, outPath, datatype='INT2S')
            }
         }
      }
   }
}




# rb <- brick('E:/temp/fract/x_0_y_-14/LS_FC_PC_3577_0_-14_19870101.nc', varname='BS_PC_50')
# rl <- raster('E:/temp/fract/x_0_y_-14/LS_FC_PC_3577_0_-14_19870101.nc', varname='BS_PC_50')
# plot(rl)
#  
# rnc <- nc_open('E:/temp/fract/x_0_y_-14/LS_FC_PC_3577_0_-14_19870101.nc')
#  
#  att <- ncatt_get(rnc, 'BS_PC_10', attname=NA, verbose=FALSE )
#  rnc$natts
#  rnc$format
#  rnc$id
#  rnc$groups
#  str(rnc$var[1])
#  names(rnc$var)
#  
#  data <- ncvar_get(rnc, varid='BS_PC_10')
 
 getTileInfo <- function(x, y, fname){
   
   info <- list()
   bits <- str_split(fname, '_')
   url <- paste0( 'http://dapds00.nci.org.au/thredds/dodsC/fk4/datacube/002/FC/FC-percentile/ANNUAL/', bits[[1]][5], '_', bits[[1]][6], '/', fname, '.ddx')
   XMLd <- GET(url=url)
   resp <- content(XMLd, 'text', encoding = 'UTF-8')
   doc <- htmlParse(resp)
   info$miny <- as.numeric(xpathSApply(doc, '//attribute[@name="geospatial_lat_min"]', xmlValue))
   info$maxy <- as.numeric(xpathSApply(doc, '//attribute[@name="geospatial_lat_max"]', xmlValue))
   info$minx <- as.numeric(xpathSApply(doc, '//attribute[@name="geospatial_lon_min"]', xmlValue))
   info$maxx<- as.numeric(xpathSApply(doc, '//attribute[@name="geospatial_lon_max"]', xmlValue))
   #info$datecreated <- as.numeric(xpathSApply(doc, '//attribute[@name="date_created"]', xmlValue))
   return(info)
 }
 

 

 
 for (i in 1:length(xv)) {
   for (j in 1:length(yv)) {

     linkoURL <- paste0('http://dap.nci.org.au/thredds/remoteCatalogService?catalog=http://dapds00.nci.org.au/thredds/catalog/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/catalog.xml')
     doc <- htmlParse(linkoURL)
     links <- xpathSApply(doc, '//a[@href]', xmlValue)
     linksf <- links[grepl('LS_FC_PC',links)]
     
     if(length(linksf) > 0){
       outd <- paste0(rootOut,'/', att, '/x_', xv[i], '_y_', yv[j] )
       if(!dir.exists(outd)){dir.create(outd, recursive = T)}
       
      tInf <-  getTileInfo(xv[i], yv[j], linksf[1])
       
         for (k in 1:length(linksf)) {
              fname <- linksf[k]
             outPath <- str_replace(paste0(outd, '/', fname), '.nc', '.tif')
             if(!file.exists(outPath)){
              
               print(fname)
               url <- paste0('http://dapds00.nci.org.au/thredds/dodsC/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/', fname, '.ascii?', att, '%5B0:1:0%5D%5B0:1:3999%5D%5B0:1:3999%5D')
               
                
                 try(  downloadOpenDAP2(url, tInf),  silent=F)

               
            }
         }
     }
   }
 }
 
 downloadOpenDAP2 <- function(url,tInf){
   
   response <- GET(url=url)
   if( response$status_code == 200){
   vals <- content(response, 'text', encoding = 'UTF-8')
   odData1 <- read.table(text=vals, skip=12, nrows = 4000 , sep = ',')
   odData2 <- odData1[,-1]
   m1 <- as.matrix(odData2)
   r <- raster(nrows=4000, ncols=4000, xmn=tInf$minx, xmx=tInf$maxx, ymn=tInf$miny, ymx=tInf$maxy, crs=sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"),  vals=m1)
   writeRaster(r, outPath, datatype='INT2S')
   }
 }
 
 #####   Parallel  ######
 asyncThreadNum <- 6
 
 downloadOpenDAP <- function(url,tInf){
   

   bits <- str_split(url, '[?]')
   fnameRaw <- basename(bits[[1]][1])
   outPath <- str_replace(paste0(outd, '/', fnameRaw), '.nc.ascii', '.tif')
   if(!file.exists(outPath)){
     
     print(fname)
     response <- GET(url=url)
     if( response$status_code == 200){
       
       vals <- content(response, 'text', encoding = 'UTF-8')
       odData1 <- read.table(text=vals, skip=12, nrows = 4000 , sep = ',')
       odData2 <- odData1[,-1]
       m1 <- as.matrix(odData2)
       r <- raster(nrows=4000, ncols=4000, xmn=tInf$minx, xmx=tInf$maxx, ymn=tInf$miny, ymx=tInf$maxy, crs=sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"),  vals=m1)
       
       writeRaster(r, outPath, datatype='INT2S')
     }
   }
   
 } 
 
 
 for (i in 1:length(xv)) {
   for (j in 1:length(yv)) {
     
     linkoURL <- paste0('http://dap.nci.org.au/thredds/remoteCatalogService?catalog=http://dapds00.nci.org.au/thredds/catalog/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/catalog.xml')
     doc <- htmlParse(linkoURL)
     links <- xpathSApply(doc, '//a[@href]', xmlValue)
     linksf <- links[grepl('LS_FC_PC',links)]
     
     if(length(linksf) > 0){
       outd <- paste0(rootOut,'/', att, '/x_', xv[i], '_y_', yv[j] )
       if(!dir.exists(outd)){dir.create(outd, recursive = T)}
       
       tInf <-  getTileInfo(xv[i], yv[j], linksf[1])
       
       urls <- paste0('http://dapds00.nci.org.au/thredds/dodsC/fk4/datacube/002/FC/FC-percentile/ANNUAL/', xv[i], '_', yv[j], '/', linksf, '.ascii?', att, '%5B0:1:0%5D%5B0:1:3999%5D%5B0:1:3999%5D')
       its <- synchronise(async_map(urls, downloadOpenDAP, .args = as.list(tInf), .limit = asyncThreadNum))
     }
   }
 }
 
 no_cores <- 6
 cl<-makeCluster(no_cores)
 registerDoParallel(cl)
 foreach(r=1:length(linksf),  .packages=c('raster','stringr', 'httr')) %dopar% downloadOpenDAP( urls, tInf)
 stopCluster(cl)
 

 
 
 
 
 