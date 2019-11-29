
#------------------------------------------------------------------
rm(list=ls())
#------------------------------------------------------------------
library(raster) 
library(rgdal)
source("getSeverityMaps_23_1.R")
#-------------------------------------------------------

#------------------------------------------------------------------
# reads ascii files 
parte1 <- readRDS("~/severityMaps/mapsDnbr_001to100", refhook = NULL)
parte2 <- readRDS("~/severityMaps/mapsDnbr_101to200", refhook = NULL)
parte3 <- readRDS("~/severityMaps/mapsDnbr_201to300", refhook = NULL)
parte4 <- readRDS("~/severityMaps/mapsDnbr_301to400", refhook = NULL)
parte5 <- readRDS("~/severityMaps/mapsDnbr_401to500", refhook = NULL)
parte6 <- readRDS("~/severityMaps/mapsDnbr_501to600", refhook = NULL)
parte7 <- readRDS("~/severityMaps/mapsDnbr_601to700", refhook = NULL)
parte8 <- readRDS("~/severityMaps/mapsDnbr_701to800", refhook = NULL)
parte9 <- readRDS("~/severityMaps/mapsDnbr_801to900", refhook = NULL)

mat_final <- array(0, dim = c(nrow = 900, ncol = 1000, layers = 14))

# fill mat_final with parte1, parte2,..parte9
mat_final[1:100,,]<- parte1
mat_final[100 + 1:100,,]<- parte2
mat_final[200 + 1:100,,]<- parte3
mat_final[300 + 1:100,,]<- parte4
mat_final[400 + 1:100,,]<- parte5
mat_final[500 + 1:100,,]<- parte6
mat_final[600 + 1:100,,]<- parte7
mat_final[700 + 1:100,,]<- parte8
mat_final[800 + 1:100,,]<- parte9

# now rasterize mat_final, to this end we need master.tif

master <- raster("master.tif)

# we employ matrixToRaster to yield a raster of the burnSeverity map for 2012
MapDnbr2012 <- matrixToRaster(matrix = (mat_final[,,10]), raster = master)
plot(MapDnbr2012)

#exportar tiff
writeRaster(MapDnbr2012, filename= "MapDnbr2012.tif", format="GTiff",overwrite=TRUE)




