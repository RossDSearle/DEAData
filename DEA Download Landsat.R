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