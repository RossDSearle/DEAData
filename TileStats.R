library(raster)
library(doParallel)
library(tictoc)


inDir <- paste0('E:/DEAProcessing/fcver/NPV_PC_50/x_-15_y_-33')
fls <- list.files(inDir, '*.tif$', full.names = T)

brk <- brick(stk)

vl <- 4000*4000
m <- matrix(1:(vl*length(fls)), nrow = vl, ncol = length(fls))

stk <- stack()
for(i in 1:length(fls)){
  print(i)
  rl <- raster(fls[i])
  vals <- as.numeric(rl[])
  m[,i] <- vals 
  m[m==255] <- NA
  #stk<-addLayer(stk, rl)
}

s <- lapply(fls, stack)

tic()
#m <- apply(brick, 1, mean)
m <- calc(brk, fun=mean)
toc()
plot(m)

inMemory(brk)

tic()
rm <- as.matrix(stk)
m <- apply(rm, 1, sd)
rout <- raster(stk[[1]])
rout <- m
toc()

plot(rout)

tic()
rmin <- min(stk, na.rm = T)
toc()

rmax <- max(stk, na.rm = T)
rdif <- rmax - rmin
rprop <- rmin/rmax
rstd <- sd(stk, na.rm = T)

plot(rprop)
plot(rdif)

rstd <- calc(stk, fun=sd)
rvar <- var(stk, na.rm = T)

tic()
m3 <- stackApply(stk, indices =rep(1,length(fls)),  fun=sd, na.rm=T)
toc()

tic()
m3 <- stackApply(stk, indices =rep(1,length(fls)),  fun=cov, na.rm=T)
toc()

plot(m3)

plot(rmin)
writeRaster(rmin, 'c:/temp/min.tif', overwrite=T)
writeRaster(rmax, 'c:/temp/max.tif', overwrite=T)



library(Rfast)

tic()

tstd <- rowVars(m,  std = T, na.rm = T, parallel = T)
tmed <- rowMedians(m, na.rm = FALSE, parallel = T)
tmin <- rowMins(m, value = T)
tmax <- rowMaxs(m, value = T)

tmean <- rowmeans(m)
summary(tmean)

tmean <- apply(m, 1, mean, na.rm = T)
toc()


rowVars(x, suma = NULL, std = FALSE, na.rm = FALSE, parallel = FALSE)






res <-as.Rfast.function("var")
