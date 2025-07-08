#' Calculate statistics on lascatalog files
#'
#' @description his function generates multiple output *.laz files based on input polygons (one file per polygon).
#' The files are named after an attribute in the input polygon dataset.
#'
#' @param lascatalog object of class `lascatalog`
#' @param input_epsg character EPSG-code of coordinate system
#' @param output_path character path to folder where the newly generated laz-files will be exported to
#' @param filename_convention character identifying the attribute in the polygon data that should be used to name the
#' output files
#' @param polygons object of class `spatial polygons` featuring an attribute with the IDs or names of the polygons
#' @param parallel logical of length 1. Should the computation be split over several cores? Defaults to FALSE.
#' @param n_cores numeric of length 1. If `parall = TRUE`, on how many cores should the computations be run on?
#' Defaults to the value registered in `options("cores")[[1]]`, or, if this is not available, to `parallel::detectCores())`.
#' @return lascatalog
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' catalog_statistics(ctg, TRUE, 3)


catalog_clip_polygons <- function(lascatalog, input_epsg, output_path, filename_convention = "{ID}", polygons,
                                  parallel = F, n_cores = 2) {

  #' check projection if needed:
  if (is.na(sf::st_crs(lascatalog))) {
    warning(paste("LasCatalog does not have an assigned projection, input_epsg", input_epsg, "will be used"), call. = F, immediate. = T)
    sf::st_crs(lascatalog) <- input_epsg
  }

  if (sf::st_crs(polygons) != sf::st_crs(lascatalog)){
    warning("CRS of input polygons and lascatalog differ. Polygons are reprojected to match input CRS")
    polygons <- sf::st_transform(polygons,  crs = input_epsg)
  }

  #' apply options to lascatalog
  opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)
  opt_laz_compression(lascatalog) <- TRUE
  opt_independent_files(lascatalog) <- TRUE

  #' plan parallel processing
  if (parallel == TRUE) {
    plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' run clipping:
  clipped_catalog <- clip_roi(lascatalog, polygons)
  return(clipped_catalog)

}
