# -----------------------------------------------------------------------------
rm(list=ls())
# -----------------------------------------------------------------------------
library(bfast)
source("getSeverityMaps_23_1.R")
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# --- LOAD dataCubes ---
temp_NDVI_linear <- LoadToEnvironment('NDVI_interLinearFilter_03_16.RData')
mat_NDVI_linear <- temp_NDVI_linear$ndvi_interpol_linear

temp_NBR_linear <- LoadToEnvironment('NBR_interLinearFilter_03_16.RData')
mat_NBR_linear <- temp_NBR_linear$NBR_interpol_linear

mapsDnbr <- array(0, dim = c(nrow = 100, ncol = 1000, nlayers = 14))
mapsDndvi <- array(0, dim = c(nrow = 100, ncol = 1000, nlayers = 14))
mapsChanges <- array(0, dim = c(nrow = 100, ncol = 1000, nlayers = 14))
mapNoChanges <- matrix(0, nrow = 100, ncol = 1000)

# --- actual breakpoint estimation (along with dNBR, changes and noChanges) ---

globalshift <- 0:8 * 1e2
shift <- globalshift[1] # aquí cambias el número de acuerdo al ciento que vas a correr por ejemplo
NROW <- shift + 1:1e2   #[1]corre de 1-100; [2] corre de 101-200 y asi hasta [9]corre de 801-900

shift <- globalshift[1] # must chage this number, in this example
NROW <- shift + 1:1e2   #[1] will work on rows 1-100; [2] will work on rows 101-200  and so on 'til [9] (801-900)

NCOL <- 1e3

system.time({
  for(i in NROW){
    
    getBreaksTest <- vector("list", NCOL)
    getYearsTest <- vector("list", NCOL)
    
    if(i %% 10 == 0){
      cat("i:", i, "\n")
    }
    
    getBreaksTest[1:NCOL] <- sapply(1:NCOL, function(s) getBreaks(data = mat_NDVI_linear[i, s, ]))
    
    getYearsTest[1:NCOL] <- sapply(1:NCOL, function(s) getYear(breaks = getBreaksTest[[s]]) - 2003 + 1)
    
    goodYears <- sapply(1:length(getYearsTest), function(s) sum(is.na(getBreaksTest[[s]])))
    
    getBreaksTest[which(goodYears == 1)] <- NULL
    
    getYearsTest[which(goodYears == 1)] <- NULL
    
    for(j in 1:length(getBreaksTest)){
      temp <- partialFill(breaks = getBreaksTest[[j]], ndvi = mat_NDVI_linear[i, j, ],
                          nbr = mat_NBR_linear[i, j, ])
      
      mapsDnbr[i - shift, j, getYearsTest[[j]]] <- temp$severityMatrix[1,]
      mapsDndvi[i - shift, j, getYearsTest[[j]]] <- temp$severityMatrix[2,]
      mapsChanges[i - shift, j, getYearsTest[[j]]] <- temp$severityMatrix[3,]
      
    }
    mapNoChanges[i - shift, which(goodYears==1)] <- 1
  }
})

# --- Before running code below notice that severityMaps folder is not empty ---

saveRDS(mapsDnbr, file = paste(getwd(), "/severityMaps/mapsDnbr_", 
                               NROW[1], "to", NROW[100], sep=""), ascii = T)
saveRDS(mapsDndvi, file = paste(getwd(), "/severityMaps/mapsDndvi_", 
                                NROW[1], "to", NROW[100], sep=""), ascii = T)
saveRDS(mapsChanges, file = paste(getwd(), "/severityMaps/mapsChanges_", 
                                NROW[1], "to", NROW[100], sep=""), ascii = T)
saveRDS(mapNoChanges, file = paste(getwd(), "/severityMaps/mapNoChanges_", 
                                   NROW[1], "to", NROW[100], sep=""), ascii = T)
# -----------------------------------------------------------------------------



