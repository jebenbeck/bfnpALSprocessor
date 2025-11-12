# DTM creation

creates DTMs from a lascatalog only using ground points. The dtms are
exported to disc in tiles and optional, the results can be mosaiced to a
full-scale dataset.

## Usage

``` r
catalog_dtm(
  lascatalog,
  resolution = 1,
  algorithm = tin(),
  output_path,
  filename_convention,
  mosaic_result = F,
  mosaic_name = NULL,
  parallel = FALSE,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`. Needs to have classified ground points.

- resolution:

  spatial resolution of the resulting dataset in meters. Corresponds to
  the projection and coordinate system of the input dataset. Defaults to
  1.

- algorithm:

  an algorithm used for spatial interpolation of the point cloud data,
  uses the ones available via
  [`lidR::rasterize_terrain()`](https://rdrr.io/pkg/lidR/man/rasterize.html).
  Defaults to `tin()`.

- output_path:

  character path to the folder where the resulting tif files should be
  exported to

- filename_convention:

  character defining the filenames of the generated tif files following
  lidR basics. Defaults to the original filename

- mosaic_result:

  logical of length 1. If `TRUE`, there will be a mosaiced tif file of
  the full dataset exported to the `output_path` folder in addition to
  the tiles.

- mosaic_name:

  character representing the filename of the mosaic tif file

- parallel:

  logical of length 1. Should the computation be split over several
  cores? Defaults to FALSE.

- n_cores:

  numeric of length 1. If `parall = TRUE`, on how many cores should the
  computations be run on? Defaults to the value registered in
  `options("cores")[[1]]`, or, if this is not available, to
  `parallel::detectCores())`.

## Value

SpatRaster list

## Examples
