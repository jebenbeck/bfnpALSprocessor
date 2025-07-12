test <- c(300,900)
test[1]
catalog_filter <- function(lascatalog, filter_noise = TRUE, algorithm_noise = ivf(5,2), filter_heights = TRUE, filter_mode = "remove", output_path, filename_convention = "{ORIGINALFILENAME}",
                           parallel = FALSE, n_cores = 2){

  #' apply options to lascatalog
  opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  opt_laz_compression(lascatalog) <- TRUE
  opt_chunk_buffer(lascatalog) <- 10
  opt_chunk_size(lascatalog) <- 0

  if (filter_mode == "classify") {
    message("Filtered points will be classified in output")
  } else {
    message("Filtered points will be removed in output")
  }

  #' function to filter outliers:
  filtering = function(las){

    #' remove all impossible heights:
    if (filter_heights == TRUE) {
      las_classified <- lidR::filter_poi(las, Z>300 & Z<1500)
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

#' 1) Remove extreme height values
#las_filtered <- filter_poi(las, NormalizedHeight >= 0 & NormalizedHeight <= 60)

#' 2) SOR for identifying small clusters:
#las_classified <- classify_noise(las, sor(30, 2))

