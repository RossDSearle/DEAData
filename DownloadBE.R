#download.file('https://data.dea.ga.gov.au/bare-earth/summary/v2.1.1/L8/x_-2/y_-12/be-l8_-2_-12_swir2.tif', 'c:/temp/xxxx.tif')

library(RCurl)
# xv <- seq(-20, 2, 1)
# xv <- seq(3, 21, 1)
xv <- seq(-20, 21, 1)
yv <- seq(-11, -50, -1)
#dtype <- 'swir1'
dtype <- 'swir2'
#dtype <- 'blue'

rootOut <- paste0('E:/BEin/', dtype) 
if(!dir.exists(rootOut)){
  dir.create(rootOut, recursive = T)
}


downloadFile <- function(url, outPath)
{
  download.file(url, outPath, quiet = T, mode='wb')
  print(paste0('Downloaded file - ', outfile))
}

downloadFiles <- function(url)
{
  
  try(  download.file(url, paste0('c:/temp/para/', basename(url)), quiet = T, mode='wb'),  silent=TRUE)
  
  #print(paste0('Downloaded file - ', paste0('c:/temp/para', basename(outPath))))
}


for (i in 1:length(xv)) {
  for (j in 1:length(yv)) {
    outfile <- paste0('be-l8_', xv[i], '_', yv[j], '_', dtype, '.tif')
    outPath <- paste0(rootOut, '/be-l8_', xv[i], '_', yv[j], '_', dtype, '.tif')
    if(!file.exists(outPath)){
      url <- paste0('https://data.dea.ga.gov.au/bare-earth/summary/v2.1.1/L8/x_', xv[i], '/y_', yv[j], '/be-l8_', xv[i], '_', yv[j], '_', dtype, '.tif')
      outPath <- paste0(rootOut, '/', outfile )
      try(  downloadFile(url, outPath),  silent=TRUE)
    }
  }
}


df <- expand.grid(xv,yv)
df<-data.frame(id=seq(1,length(xv)*length(yv),1 ))
df$dtype <- dtype

url <- paste0('https://data.dea.ga.gov.au/fractional-cover/fc-percentile/annual/v2.2.0/combined/x_', xv[i], '/y_', yv[j], '/2017/LS_FC_PC_3577_',xv[i] ,'_',yv[j] ,'_20170101_' , dtype ,'_PC_50.tif')

urls <- paste0('https://data.dea.ga.gov.au/bare-earth/summary/v2.1.1/L8/x_', df$Var1, '/y_', df$Var2, '/be-l8_', df$Var1, '_', df$Var2, '_', df$dtype, '.tif')


library(async)
asyncThreadNum <- 6
dataStreamsDF <- synchronise(async_map(urls, downloadFiles, .limit = asyncThreadNum))


library(RCurl)

downloadFile <- function(url, outPath)
{
  download.file(url, outPath, quiet = T, mode='wb')
  print(paste0('Downloaded file - ', outfile))
}


E <- 15
N <- -39

yrs <- seq(2000, 2017,1)
bands <- c('blue', 'green', 'red', 'nir', 'swir1', 'swir2')

rootOut <- 'c:/temp'

for (i in 1:length(yrs)){
  yr <- yrs[[i]]
  for (j in 1:length(bands)) {
    band <- bands[[j]]
    print(j)
    outfile <- paste0(yr, 'ls7_gm_nbart_', E, '_', N, '_', yr, '0101_', band, '.tif')
    outPath <- paste0(rootOut, '/', outfile)
    if(!file.exists(outPath)){
      url <- paste0('https://data.dea.ga.gov.au/geomedian-australia/v2.1.0/L7/x_', E, '/y_', N, '/', yr, '/01/01/ls7_gm_nbart_', E, '_', N, '_', yr, '0101_', band, '.tif')
      #outPath <- paste0(rootOut, '/', outfile )
      try(  downloadFile(url, outPath),  silent=TRUE)
    }
  }
}


  

