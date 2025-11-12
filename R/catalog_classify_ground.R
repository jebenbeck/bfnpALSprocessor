#' Classify ground points
#'
#' @description This function classifies ground points in ALS point clouds. It essentially is the same as [lidR::classify_ground]
#' but has pre-defined options optimized for the BFNP ALS data.
#'
#' @param lascatalog object of class `lascatalog`.
#' @param algorithm an algorithm used for spatial interpolation of the point cloud data, uses the ones available
#' via [lidR::classify_ground()] Defaults to cloth simulation function [lidR::csf()].
#' @param last_returns logical of length 1. Should the computation only be based on last returns? Defaults to TRUE
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
#' \dontrun{
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' ctg_classified <- catalog_normalize(ctg, algorithm = lidR::csf(), last_returns = T,
#' output_path = "D:/6_pointclouds_classified", filename_convention = "{ORIGINALFILENAME}", parallel = F, n_cores = 1)
#' }

catalog_classify_ground <- function(lascatalog, algorithm = lidR::csf(), last_returns = T, output_path,
                                    filename_convention = "{ORIGINALFILENAME}", parallel = FALSE, n_cores =2) {

  #' apply options to lascatalog
  lidR::opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  lidR::opt_laz_compression(lascatalog) <- TRUE
  lidR::opt_chunk_buffer(lascatalog) <- 10
  lidR::opt_chunk_size(lascatalog) <- 0

  #' plan parallel processing
  if (parallel == TRUE) {
    future::plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' classify lascatalog:
  classified_catalog <- lidR::classify_ground(lascatalog, algorithm = algorithm, last_returns = last_returns)
  return(classified_catalog)
}
