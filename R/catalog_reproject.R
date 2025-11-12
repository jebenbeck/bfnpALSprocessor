#' Reproject lascatalog
#'
#' @description Transforms the coordinate system of a lascatalog using [sf::st_transform()].
#' Hereby, all files will be transformed seperately and the catalog structure will not be touched.
#'
#' While this function can transform from and to any horizontal coordinate system implemented in [sf::st_transform()], it is specialized on converting point cloud data stored
#' in \href{https://epsg.io/31468}{GK4 - EPSG:31468} to \href{https://epsg.io/25832}{UTM32N - EPSG:25832}.
#' The focus on this transformation is based on the fact, that most of the ALS data acquired in the BFNP before 2018 is stored in GK4, as it was the default reference system back then.
#' As the new standard is UTM32N, all data has to be transformed in order perform time series analysis more easily.
#'
#' There are many different methods to transform coordinates between GK4 and UTM32N, the most accurate one is the "Beta2007" method
#' which relies on a transformation grid to change the geodetic datum. When checking the accuracy of the methods using reference points
#' from the bavarian surveying agency, it could be found that the accuracy went from 0.22 m in x and 0.12 m in y direction (median)
#' when using the default method to 0.02 m (median) in x and y direction when using the Beta2007 grid. Therefore, when transforming ALS data,
#' this method shall be used and this function makes it possible to to so.
#'
#' Base `lidR` uses a ported version of [sf::st_transform()] in which always uses the default option, which is not Beta2007 for
#' transformations between GK4 and UTM32N. This leads to shifts of upt to 1 m in the point cloud datasets. However, there is a workaround to
#' manually make the Beta2007 method the default one and therefore use it in `lidR`.
#'
#' To do so, the system has to be prepared by setting up some prerequisites and some basic concepts need to be understood:
#'
#' To transform coordinates with [sf::st_transform()] it relies on the \href{https://proj.org/en/stable}{PROJ library}.
#' It uses \href{https://proj.org/en/stable/usage/transformation.html#transformation-pipelines}{pipelines} to define the exact transformation method that should be used.
#' Transformation grids to change the geodetic datum can be implemented into the pipelines using \href{https://proj.org/en/stable/usage/transformation.html#grid-based-datum-adjustments}{NTv2 grid datasets}.
#' The different transformation pipelines can be observed by calling `options <- sf_proj_pipelines(source_crs = "EPSG:31468", target_crs = "EPSG:25832")` and then looking at `options` via `View(options)`.
#' Hereby, the first entry is the one that will be used to transform the data. Usually, this is not the Beta2007 method so we have to make it that.
#'
#' In order to use grid-based transformations, [sf::st_transform()] needs to have access to the grid file in `.tif` format.
#' There are two options to make that work:
#' 1) accessing the file through the web via \href{https://cdn.proj.org/}{PROJ.org Datumgrid CDN}
#' 2) downloading the file and putting it into your local library
#' To make it usable as the `lidR` default method, we actually have to set up both. In know it's weird but it is what it is.
#'
#' Enabling the web-service can be done by calling `sf_proj_network(enable = T)`. Afterwards, check, which method is default by calling
#' `options <- sf_proj_pipelines(source_crs = "EPSG:31468", target_crs = "EPSG:25832")` and then looking at `options` again. The following definition entry should be on top:
#'
#' `+proj=pipeline +step +inv +proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +step +proj=hgridshift +grids=de_adv_BETA2007.tif +step +proj=utm +zone=32 +ellps=GRS80`
#'
#' That's already great! However, for some reason, `lidR` requires the grid to be available offline so we have to download the file from \href{https://cdn.proj.org/de_adv_BETA2007.tif}{PROJ.org Datumbgrid CDN}
#' and store it in the local PROJ library folder which can be found by calling [sf::sf_proj_search_paths()]. In my case it was `"C:/Users/username/AppData/Local/R/win-library/4.4/sf/proj"`.
#' After doing that for the first time, R needs to be restarted to apply these changes.
#'
#' You only need to set up this once on your system, afterwards the code will work properly. The function will check for you if the settings are okay and the grid file exists at the correct place.
#'
#'
#' @param lascatalog Object of class `lascatalog`
#' @param input_epsg character featuring EPSG definition in the style of "EPSG:31468".
#' @param output_epsg character featuring EPSG definition in the style of "EPSG:31468".
#' @param output_path character featuring the output path where the transformed laz files will be written to.
#' @param parallel logical of length 1. Should the computation be split over several cores? Defaults to FALSE.
#' @param n_cores numeric of length 1. If `parall = TRUE`, on how many cores should the computations be run on?
#' Defaults to the value registered in `options("cores")[[1]]`, or, if this is not available, to `parallel::detectCores())`.
#'
#' @return lascatalog object (laz format on disk)
#' @export
#'
#' @examples
#' ctg <- readALSLAScatalog("/path/to/lazfiles")
#' catalog_reproject(lascatalog = ctg, input_epsg = "EPSG:31468", output_epsg = "EPSG:25832", output_path = "path/to/output", parallel = TRUE, n_cores = 3)

catalog_reproject <- function(lascatalog, input_epsg, output_epsg, output_path, parallel = FALSE, n_cores = 2)  {

  #' check projection if needed:
  if (is.na(st_crs(lascatalog))) {
    warning(paste("LasCatalog does not have an assigned projection, input_epsg", input_epsg, "will be used"), call. = F, immediate. = T)
    st_crs(lascatalog) <- input_epsg
  }

  #' apply options to lascatalog
  opt_output_files(lascatalog) <- paste0(output_path, "/{ORIGINALFILENAME}")
  opt_laz_compression(lascatalog) <- TRUE
  opt_chunk_buffer(lascatalog) <- 0
  opt_chunk_size(lascatalog) <- 0
  opt_independent_files(lascatalog) <- TRUE

  #' special check if transformation is from GK4 to UTM32
  if (input_epsg == "EPSG:31468" & output_epsg == "EPSG:25832") {
    #' activate network connection
    sf_proj_network(enable = T)
    message("Proj connection to network enabled:", sf_proj_network())
    #' get transformation options available with grid:
    options <- sf_proj_pipelines(source_crs = "EPSG:31468", target_crs = "EPSG:25832")
    message ("Transformation option in use:", options[1,]$definition)
    #' ckech if transformation grid exists:
    if (file.exists(paste0(sf_proj_search_paths(), "/de_adv_BETA2007.tif")) == T) {
      message ("BETA 2007 transformation grid found and will be used")
    } else {
      warning("BETA 2007 transformation grid not found, accurracy of transformation will be compromized", call. = F, immediate. = T)
    }
  }

  #' function to reproject las data:
  reproject = function(las){
    las_trans = sf::st_transform(las, crs = output_epsg)
    return(las_trans)
  }

  #' plan parallel processing
  if (parallel == TRUE) {
    plan(multisession, workers = n_cores)
    message("Parallel processing will be used with", n_cores, "cores")
  } else {
    warning("No parallel processing in use", call. = F, immediate. = T)
  }

  #' apply function to lascatalog:
  reprojected_catalog = catalog_map(lascatalog, reproject)
  return(reprojected_catalog)
}
