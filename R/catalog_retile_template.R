#' Retile lascatalog
#'
#' @description This function retiles a lascatalog into rigid tiles without any overlap.
#'
#' Often, ALS data in the BFNP is not stored in rigid tiles but in parts of flight lines which can overlap. This is not good, because if you want to
#' know all points over a certain location within your AOI, you need to consider multiple files to get all of them.
#'
#' This function is basically the same as [lidR::catalog_retile()] with some default settings as for all datasets, the same settings must be used.
#' It restructures the lascatalog to match a common grid of 1x1 km tiles in the UTM coordinate system by default which relates to the common grid that is used by all datasets.
#' Of course, this only works if the data was first transferred to UTM32N.
#'
#' @param lascatalog object of class `lascatalog`, should be in crs EPSG:25832
#' @param tile_alignment list of length 2. See [lidR::opt_chunk_alignment()]
#' @param tile_size numeric, tile size in meter. See [lidR::opt_chunk_size()]
#' @param buffer_size numeric, buffer size in meter. See [lidR::opt_chunk_buffer()]
#' @param output_path character, path to where the resulting laz files should be exported to
#' @param filename_convention character. See [lidR::opt_output_files()]
#' @param laz_compression logical of length 1. See [lidR::opt_laz_compression()]
#'
#' @return lascatalog
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' ctg_retiled <- catalog_retile_template(lascatalog = ctg, tile_alignment = c(0,0), tile_size = 1000, buffer_size = 0, output_path = "ALS_2017/3_pointclouds_retiled", filename_convention = "{XLEFT}_{YBOTTOM}", laz_compression = T)

catalog_retile_template <- function(lascatalog, tile_alignment = c(0,0), tile_size = 1000, buffer_size = 0, output_path,
                             filename_convention = "{XLEFT}_{YBOTTOM}", laz_compression = T){
  #' set catalog options:
  opt_chunk_alignment(lascatalog) <- tile_alignment
  opt_chunk_size(lascatalog) <- tile_size
  opt_chunk_buffer(lascatalog) <- buffer_size
  opt_laz_compression(lascatalog) <- laz_compression
  opt_output_files(lascatalog) <- paste0(output_path, "/", filename_convention)

  #' perform the retiling:
  ctg_retiled <- catalog_retile(lascatalog)
}
