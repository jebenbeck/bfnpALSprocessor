#' Generate footprint polygons of lascatalog objects
#'
#' @description Takes all files in a lascatalog and returns a polygon file where each polygon represents the bounding box of the respective las / laz file.
#' In Addition the resulting data is cleaned and unnecessary columns are removed. Data can be exported as geopackage or shapefile afterwards
#'
#' @param lascatalog Object of class `lascatalog`
#'
#' @return sf polygon
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' catalog_to_polygons(ctg)


catalog_to_polygons <- function(lascatalog) {
  #' convert lascatalog to polygons
  ctg_polygons <- st_as_sf(lascatalog) %>%
    #' convert filename to tile name:
    mutate(Tile.name = tools::file_path_sans_ext(basename(filename)), .before = everything()) %>%
    #' remove unecessary attributes:
    select(-c(File.Signature, File.Source.ID, File.Creation.Year, File.Creation.Day.of.Year, GUID, Version.Major, Version.Minor, System.Identifier,
              Generating.Software, Header.Size, Offset.to.point.data, Number.of.variable.length.records, Point.Data.Format.ID, Point.Data.Record.Length,
              filename)) %>%
    #' rename number of points:
    rename("Number.of.points" = "Number.of.point.records") %>%
    #' restructure the columns:
    relocate(CRS, .after = Tile.name) %>%
    relocate(Number.of.points, .before = Number.of.1st.return) %>%
    relocate(starts_with("Number.of"), .before = CRS)

  return(ctg_polygons)
}
