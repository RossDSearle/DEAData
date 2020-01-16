

library(devtools)
install_github("r-lib/async")

library(RCurl)
library(async)
library(stringr)


asyncThreadNum <- 6


xv <- seq(-20, 21, 1)
yv <- seq(-11, -50, -1)
yrs <- seq(2000, 2017,1)

dtype <- 'BS'
dtype <- 'PV'


downloadFile <- function(url, outPath)
{
  download.file(url, outPath, quiet = T, mode='wb')
  print(paste0('Downloaded file - ', outfile))
}

downloadFiles <- function(url, outDir, i)
{
  yr <- str_split(url, '/')[[1]][11]
  print(basename(url))
  outD <- paste0(outDir, '/', yr)
  if(!dir.exists(outD)){
    dir.create(outD, recursive = T)
  }
    if(!file.exists(paste0(outD, '/', basename(url)))){
      try(  download.file(url, paste0(outD, '/', basename(url)), quiet = T, mode='wb'),  silent=TRUE)
    }
}


rootOut <- paste0('f:/temp/DEADownloads/', dtype) 
df <- expand.grid(xv,yv, yrs)
df$dtype <- dtype

urls <- paste0('https://data.dea.ga.gov.au/fractional-cover/fc-percentile/annual/v2.2.0/combined/x_', df$Var1, '/y_', df$Var2, '/', df$Var3,'/LS_FC_PC_3577_',df$Var1 ,'_',df$Var2 ,'_', df$Var3, '0101_' , dtype ,'_PC_50.tif')

#urls <- paste0('https://data.dea.ga.gov.au/bare-earth/summary/v2.1.1/L8/x_', df$Var1, '/y_', df$Var2, '/be-l8_', df$Var1, '_', df$Var2, '_', df$dtype, '.tif')

res <- synchronise(async_map(urls, downloadFiles, .args = c(outDir=rootOut), .limit = asyncThreadNum))



