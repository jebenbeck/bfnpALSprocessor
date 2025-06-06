
# Calculate point density of lascatalog files --------------------------------------------------------------------------


#' function takes all files in a lascatalog and returns a table with statistics on point density, covex area covered,
#' extemt, etc.


catalog_statistics <- function(lascatalog, parallel = F, n_cores = 2){

  #' set catalog options:
  opt_select(lascatalog) <- "xy" #' read only xy because they are the only attributes of interest
  opt_independent_files(lascatalog) <- TRUE

  #' function to get point density of las data:
  calc_statistics = function(chunk) {
    #return(chunk)
    las <- readLAS(chunk)
    if (is.empty(las)) return(NULL)
    #' calculate point density:
    density = density(las)
    #' calculate area covered by convex hull (not bbox):
    area = lidR::area(las)
    #' extract tile name from file (for merging information to other data later):
    tilename = tools::file_path_sans_ext(basename(chunk@files))
    #' extract extent of full tile:
    extent_tile <- chunk@bbox
    #' make data frame with necessary information:
    df <- tibble(Tile.name = tilename,
                 Point.density = density,
                 Area.covered = area,
                 Tile.max.X = extent_tile[1, 2],
                 Tile.min.X = extent_tile[1, 1],
                 Tile.max.Y = extent_tile[2, 2],
                 Tile.min.Y = extent_tile[2, 1])
    return(df)
  }

  #' plan parallel processing
  if (parallel == TRUE) {
    plan(multisession, workers = n_cores)
    message(paste("Parallel processing will be used with", n_cores, "cores"))
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' apply function to catalog:
  statistics <- catalog_apply(lascatalog, calc_statistics)
  #' merge the results to a single data frame:
  statistics_merged_df <- bind_rows(statistics)
}
