## Info ----------------------------------------------------------------------------------------------------------------


#' Harmonizing the ALS 2008-2009 dataset from the LDBV


### Required packages ----

library(lidR)
library(bfnpALSprocessor)
library(sf)
library(mapview)
library(future)
library(tidyverse)
library(pbapply)
library(stringr)
library(RCSF)
library(yardstick)



## 1. Retile the data --------------------------------------------------------------------------------------------------


#' las data as delivered by the LDBV should be already in the correct format but is retiled to assure filename consistency 
#' between the different datasets

#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2008-2009/full_extent/01_original")

#' retile using template:
ctg_retiled <- catalog_retile_template(ctg, output_path = "I:/01_point_clouds/ALS 2008-2009/full_extent/02_retiled")

#' create lax files:
lidR:::catalog_laxindex(ctg_retiled)



## 2. Normalize --------------------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALScatalog("I:/01_point_clouds/ALS 2008-2009/full_extent/01_retiled")

#' normalize the data using the best available DTM for the area (LDBV DTM1 from this dataset):
ctg_normalized <- catalog_normalize(ctg, algorithm = "dtm", dtm_path = "I:/02_dtms/ALS 2008-2009/dgm1_utm.tif", 
                                    output_path = "I:/01_point_clouds/ALS 2008-2009/full_extent/03_normalized", 
                                    parallel = T, n_cores = 12)

#' create lax files:
lidR:::catalog_laxindex(ctg_normalized)



## 3. Filter outliers --------------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALScatalog("I:/01_point_clouds/ALS 2008-2009/full_extent/03_normalized")


#' filter outliers:
ctg_filtered <- catalog_filter(ctg, filter_noise = T, filter_heights = F, filter_mode = "remove", 
                               output_path = "I:/01_point_clouds/ALS 2008-2009/full_extent/04_filtered",
                               parallel = T, n_cores = 12)

#' create lax files:
lidR:::catalog_laxindex(ctg_filtered)



## 4. Export footprint polygons ----------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALScatalog("I:/01_point_clouds/ALS 2008-2009/full_extent/04_filtered")

#' calculate footprint polygons with statistics
ctg_statistics <- catalog_statistics(ctg, parallel = T, n_cores = 18, spatial = T)

#' export polygon file to geopackage:
st_write(ctg_statistics, dsn = "I:/misc/ALS_tiles.gpkg", layer = "ALS 2008-2009", append = T)



## 5. Clip to test areas -----------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2008-2009/full_extent/04_filtered")

#' read in test areas:
test_areas <- st_read("G:/misc/test_areas.gpkg", layer = "AOIs_UTM")

#' clip to test areas:
ctg_AOIs <- catalog_clip_polygons(ctg, input_epsg = "EPSG:25832", output_path = "I:/01_point_clouds/ALS 2008-2009/test_areas/02_filtered",
                                  filename_convention = "AOI_{name}", polygons = test_areas)