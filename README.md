# burnSeverity
Files in this repository are used in the paper "Multi-temporal abrupt change estimation on Landsat time series 
imagery: An application to analyze burn severity in La Primavera, Mexico".

## getSeverityMaps_23_1.R 
contains auxiliary functions utilized for loading RData files, rasterize matrices, estimate
abrupt changes, calculate severity (dNBR), etc.

## master.tif 
is an auxiliary file used in visualization.R

## severityMaps.R 
is essential in calculating abrupt changes in NDVI time series and severity maps. For a correct
application, data cubes (time series of satellite images) must be provided as RData files. Should you desire
a copy of 'NDVI_interLinearFilter_03_16.RData' and 'NBR_interLinearFilter_03_16.RData' please send me an email.

## visualization.R 
provides functions for the appropriate visualization of burned area and severity maps. This version
requires the files from severityMaps folder.

The folder **severityMaps** contains ascii files with the output from severityMaps.R.

Should you have further questions please contact me at itecuapetla@conabio.gob.mx

