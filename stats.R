library(raster)


inDir <- 'C:/Temp/landsat'
fls <- list.files(inDir, 'green.tif$', full.names = T)

stk <- stack(fls)

df <- data.frame()
vals <- list(length(fls))

valsa <- array(1:(length(fls) * 16000000), dim=c(16000000,length(fls)))


yrs <- seq(2000, 2017,1)
valsa <- array(NA, dim=c(16000000,length(fls)))
valsb <- array(NA, dim=c(length(fls), 16000000))
colnames(valsa) <- yrs

for (i in 1:length(fls)) {
 
  print(i)
  #vals[[i]] <- raster(fls[[i]])[]
  #valsa[, i] <- raster(fls[[i]])[]
  valsb[i,] <- raster(fls[[i]])[]
  
}


m <- apply(valsa, 1, mean)
m2 <- apply(valsb, 2, mean)

m3 <- stackApply(stk, indices =rep(1,length(fls)),  fun=maxSlope, na.rm=T)

s<-c(680, 1158, 1024, 1253,  856, 1176,  953,  953,  804,  951,  809,  824,  725, 1018,  662,  756,  847,  968)
mean(s)

str(vals)

x <- seq(1,20,1)
y <- vals[[1]][1:20]

fit4 <- lm(y~poly(x,7,raw=TRUE))

xx <- seq(1,20, length=20)
plot(x,y,pch=19,ylim=c(500,700))
lines(xx, predict(fit4, data.frame(x=xx)), col="purple")

diff(y) * -1


diff(1:10, 1)
diff(1:10, 2, 2)

maxSlope <- function(vals, na.rm=T){
  d <- diff(vals) * -1
 m <- max(d, na.rm=T)
 return(m)
}



tryCatch({
  system.time({
    no_cores <- parallel::detectCores() - 1
    raster::beginCluster(no_cores)
    myFun <- function(x, ...) {
      mean(!is.na(x))
    }
    r_week <- raster::clusterR(stk, stackApply, args=list(indices =rep(1,length(fls)),  fun=maxSlope, na.rm=T))
    
    #stackApply(stk, indices =rep(1,length(fls)),  fun=maxSlope, na.rm=T)
    
    raster::endCluster()})
}, error = function(e) {
  raster::endCluster()
  return(e)
}, finally = {
  try(raster::endCluster())
})









