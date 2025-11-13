## Info ----------------------------------------------------------------------------------------------------------------


#' Harmonizing the ALS 2017-06 dataset


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



## 1. Reproject to UTM32 -----------------------------------------------------------------------------------------------


#' the data is stored in GK4 and needs to be reprojected to UTM32

#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/00_original")

#' reproject the data:
ctg_reprojected <- catalog_reproject(ctg, input_epsg = "EPSG:31468", output_epsg = "EPSG:25832", 
                                     output_path = "I:/01_point_clouds/ALS 2017-06/full_extent/01_reprojected", 
                                     parallel = T, n_cores = 10)



## 2. Retile to UTM grid -----------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2011706/full_extent/01_reprojected")

#' retile the data:
ctg_retiled <- bfnpALSprocessor::catalog_retile_template(ctg, output_path = "I:/01_point_clouds/ALS 2017-06/full_extent/02_retiled")

#' create lax files:
lidR:::catalog_laxindex(ctg_retiled)



## 3. Outlier filtering ------------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/02_retiled")

#' filter outliers:
ctg_filtered <- bfnpALSprocessor::catalog_filter(ctg, filter_noise = T, filter_heights = F, filter_mode = "remove" , 
                                                 output_path = "I:/01_point_clouds/ALS 2017-06/full_extent/03_filtered", parallel = T, n_cores = 8)

#' create lax files:
lidR:::catalog_laxindex(ctg_filtered)



## 4. DTM creation -----------------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/03_filtered")

#' perform the dtm creation:
ctg_dtm <- catalog_dtm(ctg, output_path = "I:/02_dtms/ALS 2017-06/tiles", filename_convention = "{ORIGINALFILENAME}_dtm", 
                       mosaic_result = T, mosaic_name = "dtm1_ALS_2017-06_mosaic", parallel = T, n_cores = 3)



## 5. Normalization ----------------------------------------------------------------------------------------------------

#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/03_filtered")

#' normalize the data using the best available DTM for the area (combination from different datasets)
ctg_normalized <- catalog_normalize(lascatalog = ctg, algorithm = "dtm", 
                                    dtm_path = "I:/misc/DTM1_combined_17_19_23.tif",
                                    output_path = "I:/01_point_clouds/ALS 2017-06/full_extent/04_normalized",
                                    parallel = T, n_cores = 6)


#' create lax files:
lidR:::catalog_laxindex(ctg_normalized)



## 6. Export footprint polygons ----------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/04_normalized")

#' calculate footprint polygons with statistics
ctg_statistics <- catalog_statistics(ctg, parallel = T, n_cores = 18, spatial = T)

#' export polygon file to geopackage:
st_write(ctg_statistics, dsn = "G:/misc/ALS_tiles.gpkg", layer = "ALS_2017-06", append = T)



## 7. Clip to test areas -----------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALScatalog("I:/01_point_clouds/ALS 2017-06/full_extent/04_normalized")

test_areas <- st_read("I:/misc/test_areas.gpkg", layer = "AOIs_UTM")

ctg_test_areas <- bfnpALSprocessor::catalog_clip_polygons(ctg_normalized, input_epsg = "EPSG:25832", 
                  output_path = "I:/01_point_clouds/ALS 2017-06/test_areas/filtered", filename_convention = "AOI_{name}", 
                  polygons = test_areas, parallel = T, n_cores = 8)



## 8. Accurracy evaluation ---------------------------------------------------------------------------------------------


#' load AOIs:
AOIs <- st_read("I:/misc/test_areas.gpkg", layer = "AOIs_UTM")

#' prepare the GCPs as generated using CloudCompare:
GCPs_2017 <- prepare_GCPs(input_path = "I:/misc/GCPs/2017-06",
                     output_path = "I:/misc/GCPs/2017-06",
                     filename = "GCPs_ALS_2017", polygons = AOIs)


#' merge the GCPs with the reference GCPs:
GCPs_ref <- st_read("I:/misc/GCPs/2019-2020/GCPs_ALS_2019.gpkg")
GCPs_2017 <- st_read("I:/misc/GCPs/2017-06/GCPs_ALS_2017.gpkg")

GCPs_2017_ref <- merge_GCPs(GCPs_2017, GCPs_ref, export = T, filename = "GCPs_ALS_2017_ref", output_path = "I:/misc/GCPs/2017-06")

#' generate boxplots:
GCPs_2017_ref <- st_read("I:/misc/GCPs/2017-06/GCPs_ALS_2017_ref.gpkg")

aa_create_boxplots(gcp_data = GCPs_2017_ref, export = T, filename = "Difference_GCPs_ALS_2017",
                   output_path = "I:/misc/GCPs/2017-06")

#' calculate metrics:
metrics <- aa_metrics(GCPs_2017_ref, export = T, filename = "Metrics_ALS_2017", output_path = "I:/misc/GCPs/2017-06")
metrics