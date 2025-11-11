#' subset lascatalogs
#'
#' @description This function subsets `lascatalog` objects using spatial polygon(s) ("aoi, area of interest") and
#' returns a new `lascatalog` object with all tiles overlapping said polygon(s).
#' In contrast to [lidR::catalog_intersect()] it also exports this new, subsetted catalog to a specified directory very
#' efficiently without loading the tiles into memory by simply copying the files directly.
#' This is perfect for when you want to share only sections of the full data with others to work on.
#'
#' @param lascatalog object of class `lascatalog`.
#' @param aoi object of class `spatial polygons`
#' @param output_path character path to the folder where the new files should be exported to
#' @param overwrite_files logical of length 1. Should already existing files be overwritten or be ignored? Defaults to FALSE.
#' @return lascatalog
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' area_of_interest <- st_read("/path/to/polygons")
#' ctg_subset <- catalog_subset(ctg, aoi = area_of_interest, output_path = "D:/catalog_subset", overwrite_files = F)


catalog_subset <- function(lascatalog, aoi, output_path, overwrite_files = F){

  catalog_subset <- catalog_intersect(ctg = lascatalog, aoi)         #' subset the catalog based on the polygon(s)
  catalog_subset_polygons <- st_as_sf(catalog_subset)                #' convert catalog to sf polygons to get the filenames

  #' Copy the files that are part of the subset to the new directory;
  file.copy(from = catalog_subset_polygons[["filename"]],
            to = file.path(output_path, "/", basename(catalog_subset_polygons[["filename"]])),
            overwrite = overwrite_files)  # Set to TRUE if you want to overwrite existing files

  return(catalog_subset)
}
