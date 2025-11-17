## Info ----------------------------------------------------------------------------------------------------------------


#' Harmonizing the ALS 2002-09 dataset

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



## 1. Convert ASCII files to LAZ ---------------------------------------------------------------------------------------


#' Take all LiDAR Point clouds stored in ASC format from folder and convert them to LAZ. Simultanously, all arguments are
#' renamed to meet LAS standards. In addition, return number and number of returns are also added (just to separate first
#' and last returns)


convert_asc_to_laz_ALS2002 <- function(input_path, output_path, n_files, return_number, n_cores){

  #' Create the output directory if it doesn't exist
  if (!dir.exists(output_path)) {
    dir.create(output_path)
  }

  #' Get a list of all .asc files in the input directory
  asc_files <- list.files(input_path, pattern = "\\.asc$", full.names = TRUE)

  #' subset of list:
  if (n_files > 0) {
    asc_files <- asc_files[1:n_files]
  }

  #' Get a list of all already processed files in the output directory
  processed_files <- list.files(output_path, pattern = "\\.laz$", full.names = FALSE)
  processed_files <- tools::file_path_sans_ext(processed_files) # Remove extensions for comparison

  #' Filter asc_files to skip already processed ones
  asc_files_to_process <- asc_files[!tools::file_path_sans_ext(basename(asc_files)) %in% processed_files]

  #' Define a function to process a single ASC file
  process_asc_file <- function(asc_file, return_number, output_path) {

    #' Extract the filename without the path and extension
    file_name <- tools::file_path_sans_ext(basename(asc_file))

    #' Step 1: Read the ASC file and change structure:
    point_data <- read.table(asc_file, header = FALSE, sep = " ", stringsAsFactors = FALSE) %>%
      #' convert to data frame:
      as.data.frame() %>%
      #' rename columns of input data:
      rename(c(X = "V1", Y = "V2", Z = "V3")) %>%
      #' assign return number. This is not for certain but can assure that only last return points are selected where it is
      #' relevant in lidR. las specification needs this to work properly. Select 1 for first and 2 for last
      mutate(ReturnNumber = as.integer(return_number),
             NumberOfReturns = as.integer(2))

    #' Step 3: Create a LAS object from the data frame
    las_data <- LAS(point_data)

    #' Set the coordinate reference system (adjust as needed)
    st_crs(las_data) <- 31468

    #' Step 4: Export the LAS object to a LAS file
    output_file <- file.path(output_path, paste0(file_name, ".laz"))
    writeLAS(las_data, output_file)

    #' Return the output file path for logging purposes
    return(output_file)
  }

  #' Use pbapply for processing all ASC files in parallel:
  cluster <- parallel::makeCluster(n_cores)

  parallel::clusterExport(cluster, varlist = c("process_asc_file", "readLAS", "writeLAS", "basename", "read.table", "LAS",
                                               "colnames", "st_crs"))
  parallel::clusterEvalQ(cluster, library(lidR)) # Load lidR on all nodes
  parallel::clusterEvalQ(cluster, library(tidyverse)) # Load tidyverse on all nodes

  #' apply to list:
  output_files <- pblapply(asc_files_to_process, process_asc_file, return_number = return_number, output_path = output_path)

  #' end session:
  parallel::stopCluster(cluster)

}


# convert last pulse data:
convert_asc_to_laz_ALS2002(input_path = "D:/ALS 2002-09/D/last", output_path = "D:/ALS 2002-09/D/laz", n_files = 0,
                           return_number = 2, n_cores = 2)

# convert first pulse data:
convert_asc_to_laz_ALS2002(input_path = "D:/ALS 2002-09/D/first", output_path = "D:/ALS 2002-09/D/laz", n_files = 0,
                           return_number = 1, n_cores = 2)



## 2. Convert to UTM 32 ------------------------------------------------------------------------------------------------


#' the data is stored in GK4 and needs to be reprojected to UTM32

#' read in lascatalog:
ctg <- readALSLAScatalog("D:/ALS 2002-09/D/laz")

#' reproject the data:
ctg_reprojected <- catalog_reproject(ctg, input_epsg = "EPSG:31468", output_epsg = "EPSG:25832",
                                     output_path = "D:/ALS 2002-09/D/laz_UTM32",
                                     parallel = F, n_cores = 10)



## 3. Retile to UTM grid -----------------------------------------------------------------------------------------------


#' read in lascatalog:
ctg <- readALSLAScatalog("D:/ALS 2002-09/D/laz_UTM32")

#' retile the data:
ctg_retiled <- bfnpALSprocessor::catalog_retile_template(ctg, output_path = "D:/ALS 2002-09/D/laz_UTM32_retiled")
plot(ctg_retiled, mapview = T)

#' create lax files:
lidR:::catalog_laxindex(ctg_retiled)

