# Classify ground points

This function classifies ground points in ALS point clouds. It
essentially is the same as
[lidR::classify_ground](https://rdrr.io/pkg/lidR/man/classify.html) but
has pre-defined options optimized for the BFNP ALS data.

## Usage

``` r
catalog_classify_ground(
  lascatalog,
  algorithm = lidR::csf(),
  last_returns = T,
  output_path,
  filename_convention = "{ORIGINALFILENAME}",
  parallel = FALSE,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`.

- algorithm:

  an algorithm used for spatial interpolation of the point cloud data,
  uses the ones available via
  [`lidR::classify_ground()`](https://rdrr.io/pkg/lidR/man/classify.html)
  Defaults to cloth simulation function
  [`lidR::csf()`](https://rdrr.io/pkg/lidR/man/gnd_csf.html).

- last_returns:

  logical of length 1. Should the computation only be based on last
  returns? Defaults to TRUE

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
