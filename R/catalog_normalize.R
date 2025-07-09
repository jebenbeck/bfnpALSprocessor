#' Normalize point clouds
#'
#' @description This function normalizes point clouds to receive the height above ground as a additional attribute
#'
#' @param lascatalog object of class `lascatalog`. Needs to have classified ground points.
#' @param algorithm (1) An algorithm used for spatial interpolation of the point cloud data, uses the ones available
#' via [lidR::normalize_height()] or (2) the character vector "dtm" when a dtm is available and should be used. Defaults
#' to tin().
#' @param dtm_path character path pointing to raster dataset representing the DTM of the covered area
#' @param output_path character path to the folder where the new files should be exported to
#' @param filename_convention character defining the filenames of the generated laz files following lidR basics. Defaults
#' to the original filename
#' @param parallel logical of length 1. Should the computation be split over several cores? Defaults to FALSE.
#' @param n_cores numeric of length 1. If `parall = TRUE`, on how many cores should the computations be run on?
#' Defaults to the value registered in `options("cores")[[1]]`, or, if this is not available, to `parallel::detectCores())`.
#' @return lascatalog
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' ctg_normalized <- catalog_normalize(ctg, dtm_path = "D:/dtm_mosaic.tif", output_path = "D:/6_pointclouds_normalized",
#' filename_convention = "{ORIGINALFILENAME}", parallel = F, n_cores = 1)


catalog_normalize <- function(lascatalog, algorithm = tin(), dtm_path = NULL, output_path, filename_convention = "{ORIGINALFILENAME}",
                              parallel = FALSE, n_cores = 2){

  #' load dtm data
  if (algorithm == "dtm") {
    message("loading dtm...")
    dtm <- terra::rast(dtm_path)
    message("loading dtm finished")
  }

  #' apply options to lascatalog
  opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  opt_laz_compression(lascatalog) <- TRUE
  if (algorithm == "dtm") {
    opt_independent_files(lascatalog) <- TRUE
  } else {
    opt_chunk_buffer(lascatalog) <- 10
    opt_chunk_size(lascatalog) <- 0
  }

  #' function to normalize pointclouds::
  normalize = function(las){
    #' normalize the data:
    if (algorithm == "dtm") {
      las_normalized <- lidR::normalize_height(las, algorithm = dtm)
    } else {
      las_normalized <- lidR::normalize_height(las, algorithm = algorithm)
    }
    #' Create a temporary variable to store the original Z values
    temp <- las_normalized$Z
    # Switch Z and Zref
    las_normalized$Z <- las_normalized$Zref
    #' add the normalized Z values as a proper attribute for export:
    las_output <- lidR::add_lasattribute(las_normalized, x = temp, name = "NormalizedHeight", desc = "Height above ground")
    return(las_output)
  }

  #' plan parallel processing
  if (parallel == TRUE) {
    plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' apply function to lascatalog:
  normalized_catalog = lidR::catalog_map(lascatalog, normalize)
  return(normalized_catalog)
}
