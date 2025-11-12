#' DTM creation
#'
#' @description creates DTMs from a lascatalog only using ground points. The dtms are exported to disc in tiles and
#' optional, the results can be mosaiced to a full-scale dataset.
#'
#' @param lascatalog object of class `lascatalog`. Needs to have classified ground points.
#' @param resolution spatial resolution of the resulting dataset in meters. Corresponds to the projection and coordinate
#' system of the input dataset. Defaults to 1.
#' @param algorithm an algorithm used for spatial interpolation of the point cloud data, uses the ones available
#' via [lidR::rasterize_terrain()]. Defaults to `tin()`.
#' @param output_path character path to the folder where the resulting tif files should be exported to
#' @param filename_convention character defining the filenames of the generated tif files following lidR basics. Defaults
#' to the original filename
#' @param mosaic_result logical of length 1. If `TRUE`, there will be a mosaiced tif file of the full dataset exported to
#' the `output_path` folder in addition to the tiles.
#' @param mosaic_name character representing the filename of the mosaic tif file
#' @param parallel logical of length 1. Should the computation be split over several cores? Defaults to FALSE.
#' @param n_cores numeric of length 1. If `parall = TRUE`, on how many cores should the computations be run on?
#' Defaults to the value registered in `options("cores")[[1]]`, or, if this is not available, to `parallel::detectCores())`.
#' @return SpatRaster list
#' @export
#'
#' @examples
#' \dontrun{
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' ctg_dtm <- catalog_dtm(ctg, resolution = 1, algorithm = tin(), output_path = "I:/02_dtms/",
#' filename_convention = "{ORIGINALFILENAME}", mosaic_result = T, mosaic_name = "DTM_mosaic", parallel = F, n_cores = 1)
#' }

catalog_dtm <- function(lascatalog, resolution = 1, algorithm = tin(), output_path, filename_convention, mosaic_result = F,
                        mosaic_name = NULL, parallel = FALSE, n_cores = 2){

  #' apply options to lascatalog
  lidR::opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  lidR::opt_chunk_buffer(lascatalog) <- 10
  lidR::opt_chunk_size(lascatalog) <- 0
  lidR::opt_select(lascatalog) <- "xyzc" #' select only relevant attributes
  lidR::opt_filter(lascatalog) <- "-keep_class 2" #' select only ground points

  #' function to compute the dtm:
  derive_dtm = function(las){
    dtm <- lidR::rasterize_terrain(las, res = resolution, algorithm = algorithm)
    #return(dtm)
  }

  #' plan parallel processing
  if (parallel == TRUE) {
    future::plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' apply function to lascatalog:
  catalog_dtm = lidR::catalog_map(lascatalog, derive_dtm)

  #' mosaic the resulting dataset if wanted:
  if (mosaic_result == TRUE) {
    message("starting mosaicing the resulting tiles...")
    #' list of all generated tif files:
    tif_files <- list.files(output_path, pattern = "\\.tif$", full.names = TRUE)
    #' read in all rasters into a spatial raster collection:
    raster_list <- terra::sprc(tif_files)
    #' mosaic the files:
    raster_mosaic <- terra::mosaic(raster_list)
    #' export to disk:
    terra::writeRaster(raster_mosaic, paste0(output_path, "/", mosaic_name, ".tif"), filetype = "GTiff",
                       overwrite = TRUE, wopt= list(datatype = "FLT4S", filetype = "GTiff", todisk = TRUE,
                                                    gdal=c("COMPRESS=LZW", "TILED=YES")))
  }

  return(catalog_dtm)

}
