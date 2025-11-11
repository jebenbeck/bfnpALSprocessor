#' Filter point clouds
#'
#' @description This function filters point clouds to remove or classify noise and outlier points
#'
#' @param lascatalog object of class `lascatalog`.
#' @param filter_noise logical of length 1. If TRUE filters noise based on the algorithm defined in `algorithm_noise`
#' @param algorithm_noise An algorithm used for filtering noise, see [lidR::classify_noise()]. Defaults to ivf(5,2)
#' @param filter_heights logical of length 1. If TRUE filters outliers based on upper and lower heights defined by `bins_height`
#' @param bins_height numeric list of length 2, defines the lower and upper heights to be kept in the dataset
#' @param filter_mode character; either "remove" or "classify". When "remove": points filtered are removed from tha dataset,
#' when "classify" points filtered are classified as noise.
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
#' ctg_normalized <- catalog_normalize(ctg, filter_noise = TRUE, algorithm_noise = ivf(5,2), filter_heights = TRUE,
#' bins_height = c(300, 1600), filter_mode = "remove", output_path = "D:/6_pointclouds_normalized",
#' filename_convention = "{ORIGINALFILENAME}", parallel = F, n_cores = 1)

catalog_filter <- function(lascatalog, filter_noise = TRUE, algorithm_noise = ivf(5,2), filter_heights = TRUE,
                           bins_height = c(300, 1600), filter_mode = "remove", output_path,
                           filename_convention = "{ORIGINALFILENAME}", parallel = FALSE, n_cores = 2){

  #' apply options to lascatalog
  lidR::opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  lidR::opt_laz_compression(lascatalog) <- TRUE
  lidR::opt_chunk_buffer(lascatalog) <- 10
  lidR::opt_chunk_size(lascatalog) <- 0

  if (filter_mode == "classify") {
    message("Filtered points will be classified in output")
  } else {
    message("Filtered points will be removed in output")
  }

  #' function to filter outliers:
  filtering = function(las){

    #' remove all impossible heights:
    if (filter_heights == TRUE) {
      las_classified <- lidR::filter_poi(las, Z>bins_height[1] & Z<bins_height[2])
    }

    #' Filtering for outliers:
    if (filter_noise == TRUE) {
      las_classified <- lidR::classify_noise(las_classified, algorithm = algorithm_noise)
    }

    if (filter_mode == "classify") {
      return(las_classified)
    } else {
      #' remove the points classified as noise:
      las_filtered <- lidR::filter_poi(las_classified, Classification != LASNOISE)
      return(las_filtered)
    }
  }

  #' plan parallel processing
  if (parallel == TRUE) {
    plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' apply function to lascatalog:
  filtered_catalog = lidR::catalog_map(lascatalog, filtering)
  return(filtered_catalog)
}

#' Other filtering methods that could still be implemented:

#' 1) Remove extreme height values from normalized height:
#las_filtered <- filter_poi(las, NormalizedHeight >= 0 & NormalizedHeight <= 60)

#' 2) SOR for identifying small clusters of points:
#las_classified <- classify_noise(las, sor(30, 2))
