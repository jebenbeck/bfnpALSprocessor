## Info ----------------------------------------------------------------------------------------------------------------


#' Harmonizing the ALS 2019-2020 dataset privided by the LDBV


### Required packages ----


library(lidR)
library(sf)
library(mapview)
library(future)
library(tidyverse)
library(pbapply)
library(stringr)
library(bfnpALSprocessor)
library(RCSF)
library(ggplot2)



## 1. Retile to UTM32 grid ---------------------------------------------------------------------------------------------


#' Even though the tiling should be fine, catalog is retiled to assure filename consistency between the different datasets

#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2019-2020/full extent/00_original")

#' retile based on template
ctg_retiled <- catalog_retile_template(lascatalog = ctg, output_path = "I:/01_point_clouds/ALS 2019-2020/full extent/01_retiled")



## 2. Normalization ----------------------------------------------------------------------------------------------------

ctg <- readALScatalog("I:/01_point_clouds/ALS 2019-2020/full extent/01_retiled")

#' data gets normalized based on the official state DTM that was derived from this specific pointcloud: 
ctg_normalized <- catalog_normalize(ctg, algorithm = "dtm", dtm_path = "I:/02_dtms/ALS 2019-2020/DTM1_Bayern_NPV_5km.tif", 
                                    output_path = "I:/01_point_clouds/ALS 2019-2020/full extent/02_normalized", 
                                    parallel = T, n_cores = 12)


#' create lax files:
lidR:::catalog_laxindex(ctg_normalized)



## 3. Export footprint polygons ----------------------------------------------------------------------------------------

#' import lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2019-2020/full_extent/02_normalized")

#' make footprint polygons including statistics:
ctg_statistics <- catalog_statistics(ctg, parallel = T, n_cores = 18, spatial = T)

#' export polygon file to geopackage:
st_write(ctg_statistics, dsn = "I:/misc/ALS_tiles.gpkg", layer = "ALS 2019-2020", append = T)



## 4. Clip test areas --------------------------------------------------------------------------------------------------


#' read AOIs:
test_areas <- st_read("G:/misc/test_areas.gpkg", layer = "AOIs_UTM")

#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2019-2020/full_extent/02_normalized")

ctg_AOIs <- catalog_clip_polygons(ctg, input_epsg = "EPSG:25832", output_path = "I:/01_point_clouds/ALS 2019-2020/test_areas", 
                                  filename_convention = "AOI_{name}", polygons = test_areas)

