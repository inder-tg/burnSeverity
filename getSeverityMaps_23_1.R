
# Written by Inder Tecuapetla 
# Latest update on Oct 22, 2018

LoadToEnvironment <- function(RData, env = new.env()){
  load(RData, env)
  return(env) 
}

matrixToRaster <- function(matrix, raster){
  rasterTable <- data.frame(rasterToPoints(raster)) 
  
  temp_matFinal <- c(matrix) 
  
  df <- data.frame(x = rasterTable$x, y = rasterTable$y, values = temp_matFinal)
  
  coordinates(df) <- ~ x + y
  
  gridded(df) <- TRUE
  
  raster_df <- raster(df)
  
  projection(raster_df) <- projection(raster)
  
  raster_df
}

#' Computes change-points 
#' 
#' Based on BFAST function change-point estimates of \code{data} are determined
#' Default parameters when BFAST is called: h = 0.23, max.iter = 2
#' 
#' This function returns a numeric vector with dates (with respect to the sampling framework, 
#' e.g. 1-day, 8-days, 16-days, etc,) of structural breaks.
#' 
#' Details: Sometimes max.iter may not be reched, in this case, the estimated dates
#' depend on the iteration number of BFAST, i.e. just one iteration suffices. Also,
#' by default this function returns NA, this means that no-change has been identified.
#' 
getBreaks <- function(start = 2003, end = 2016, frequency = 23, data){

  output <- NA
  
  dataTS <- ts(data, start = c(start, 1), end = c(end, frequency), frequency = frequency)
  
  getBFAST <- bfast(dataTS, h = 0.15, season = "harmonic", breaks = 5, 
                    max.iter = 2, hpc = "none", level = 0.05, type = "OLS-MOSUM")
  
  if(length(getBFAST$output) == 2){
    bfastOutput <- getBFAST$output[[2]]
  } else {
    bfastOutput <- getBFAST$output[[1]]
  }
  
  if( length(bfastOutput$bp.Vt) >=  2 ){ # in good case devuelve list (12)
    output <- bfastOutput$bp.Vt$breakpoints
  }
  
  output
}

#' This function computes dNBR, dNDVI and dates of estimated breakpoints from an NDVI pixel
#' The parameters of this function are an NDVI pixel, an NBR pixel, a vector with previously
#' estimated breakpoints and indices (afterscene, beforescene) of two referenced images. 
#' By default, afterscene = 1 and beforescene = 23.
#' 
#' This function returns a list with dNBR, dNDVI, a logical validIndices, and a numeric
#' vector validBreaks. 
#' 
getSeverityIndices <- function(pixelNDVI, pixelNBR, breaks, afterScene = 1, beforeScene = 23){
  
  validIndices <- F
  
  if(length(breaks) == 0){
    dNBR <- NA
    dNDVI <- NA
  } else {
    
    validBreaks <- breaks
    
    validIndices <- T
    
    if(length(validBreaks) != 0){ # checar caso length(validBreaks) == 0
      dNBR <- numeric(length(validBreaks))
      dNDVI <- numeric(length(validBreaks))
      
      nbrPre <- sapply(1:length(validBreaks), function(s) pixelNBR[beforeScene])
      nbrPost <- sapply(1:length(validBreaks), function(s) pixelNBR[afterScene])
      ndviPre <- sapply(1:length(validBreaks), function(s) pixelNDVI[beforeScene])
      ndviPost <- sapply(1:length(validBreaks), function(s) pixelNDVI[afterScene])
      dNBR <- nbrPre - nbrPost
      dNDVI <- ndviPre - ndviPost
    }
  }
  
  list(dNBR = dNBR, dNDVI = dNDVI, 
       validIndices = validIndices, validBreaks = validBreaks)#
}

#'
#' Rescales the date of an estimated breakpoint to the closest year. Returns a numeric.
#' 
getYear <- function(start = 2003, end = 2016, breaks, totalDays = c(0, 23*(1:14) )){
  
  year <- numeric(length(breaks))
  period <- start:end
  for(i in 1:length(year)){
    year[i] <- period[sum( totalDays - breaks[i] < 0 )]
  }
  
  year  
}

#' Computes dNBR, dNDVI, estimated dates of breakpoints from an NDVI pixel.
#' See getSeverityIndices for more details.
#' When there is at least one valid break point dNBR and dNDVI are matrices 
#' with nrow=3 and ncol=length(validBreaks)
#' 
partialFill <- function(breaks, ndvi, nbr){
  
  noChange <- F
  
  severityIndices <- getSeverityIndices(pixelNDVI = ndvi, pixelNBR = nbr, breaks = breaks)
  
  if( length(breaks) == 0 | severityIndices$validIndices == F ){
    getSeverityTemp <- numeric(3)
    noChange <- T
  } else {
    getSeverityTemp <- matrix(0, nrow = 3, ncol = length(severityIndices$validBreaks))
    
    years <- getYear(breaks = severityIndices$validBreaks) - 2003 + 1
    
    getSeverityTemp[1, 1:length(years)] <- severityIndices$dNBR
    getSeverityTemp[2, 1:length(years)] <- severityIndices$dNDVI
    getSeverityTemp[3, 1:length(years)] <- severityIndices$validBreaks
  }
  
  list(severityMatrix = getSeverityTemp, noChangePixel = noChange)
}

