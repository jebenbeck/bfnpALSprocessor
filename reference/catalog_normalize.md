# Normalize point clouds

This function normalizes point clouds to receive the height above ground
as a additional attribute

## Usage

``` r
catalog_normalize(
  lascatalog,
  algorithm = tin(),
  dtm_path = NULL,
  output_path,
  filename_convention = "{ORIGINALFILENAME}",
  parallel = FALSE,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`. Needs to have classified ground points.

- algorithm:

  \(1\) An algorithm used for spatial interpolation of the point cloud
  data, uses the ones available via
  [`lidR::normalize_height()`](https://rdrr.io/pkg/lidR/man/normalize.html)
  or (2) the character vector "dtm" when a dtm is available and should
  be used. Defaults to tin().

- dtm_path:

  character path to the raster file representing the dtm. File should be
  readable by
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)

- output_path:

  character path to the folder where the new files should be exported to

- filename_convention:

  character defining the filenames of the generated laz files following
  lidR basics. Defaults to the original filename

- parallel:

  logical of length 1. Should the computation be split over several
  cores? Defaults to FALSE.

- n_cores:

  numeric of length 1. If `parall = TRUE`, on how many cores should the
  computations be run on? Defaults to the value registered in
  `options("cores")[[1]]`, or, if this is not available, to
  `parallel::detectCores())`.

## Value

lascatalog

## Examples
