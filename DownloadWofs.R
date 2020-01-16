#download.file('https://data.dea.ga.gov.au/bare-earth/summary/v2.1.1/L8/x_-2/y_-12/be-l8_-2_-12_swir2.tif', 'c:/temp/xxxx.tif')
#download.file('https://data.dea.ga.gov.au/WOfS/annual_summary/v2.1.5/combined/x_1/y_-31/1986/WOFS_3577_1_-31_1986_summary_frequency.tif', 'c:/temp/xxxx.tif')

library(RCurl)
library(httr)
# xv <- seq(-20, 2, 1)
# xv <- seq(3, 21, 1)
xv <- seq(-20, 24, 1)
yv <- seq(-11, -50, -1)
yrs <- seq(1986, 2018)

rootOut <- paste0('E:/temp/wofs/filtered') 
if(!dir.exists(rootOut)){
  dir.create(rootOut, recursive = T)
}

# downloadFile <- function(url, outPath)
# {
#   download.file(url, outPath, quiet = T, mode='wb')
#   cat(paste0('Downloaded file - ', outfile))
# }
# 
# downloadFiles <- function(url)
# {
#   try(  download.file(url, paste0('c:/temp/para/', basename(url)), quiet = T, mode='wb'),  silent=TRUE)
#   print(paste0('Downloaded file - ', paste0('c:/temp/para', basename(outPath))))
# }


#download the raw yearly data
for (i in 1:length(xv)) {
  for (j in 1:length(yv)) {
    outd <- paste0(rootOut,'/x_', xv[i], '_y_', yv[j] )
    
    print(paste0(i, " ", j))
    print(outd)
    for (k in 1:length(yrs)) {
      outfile <- paste0('WOFS_3577_', xv[i], '_', yv[j], '_', yrs[k], '_summary_frequency.tif')
      outPath <- paste0(outd, '/', outfile)
      if(!file.exists(outPath)){
        url <- paste0('https://data.dea.ga.gov.au/WOfS/annual_summary/v2.1.5/combined/x_', xv[i], '/y_', yv[j], '/', yrs[k], '/WOFS_3577_', xv[i], '_', yv[j], '_', yrs[k], '_summary_frequency.tif')
        #url <- 'https://data.dea.ga.gov.au/WOfS/annual_summary/v2.1.5/combined/x_-20/y_-28/1988/WOFS_3577_-20_-28_1988_summary_frequency.tif'
        response <- GET(url=url)
         if( response$status_code == 200){
           
           if(!dir.exists(outd)){dir.create(outd, recursive = T)}
            writeBin(response$content, outPath)
         }
      }
    }
  }
}


#Download the filtered summary

for (i in 1:length(xv)) {
  for (j in 1:length(yv)) {
    outd <- paste0(rootOut,'/x_', xv[i], '_y_', yv[j] )
    
    print(paste0(i, " ", j))
   

      outfile <- paste0('wofs_filtered_summary_', xv[i], '_', yv[j], '_wofs_filtered_summary.tif')
      outPath <- paste0(outd, '/', outfile)
      if(!file.exists(outPath)){
        url <- paste0('https://data.dea.ga.gov.au/WOfS/filtered_summary/v2.1.0/combined/x_', xv[i], '/y_', yv[j],  '/wofs_filtered_summary_', xv[i], '_', yv[j], '_wofs_filtered_summary.tif')
        #url <- 'https://data.dea.ga.gov.au/WOfS/annual_summary/v2.1.5/combined/x_-20/y_-28/1988/WOFS_3577_-20_-28_1988_summary_frequency.tif'
        response <- GET(url=url)
        if( response$status_code == 200){
          print(outd)
          if(!dir.exists(outd)){dir.create(outd, recursive = T)}
          writeBin(response$content, outPath)
        }
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


  

