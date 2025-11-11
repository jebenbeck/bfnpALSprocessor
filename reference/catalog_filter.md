# Filter point clouds

This function filters point clouds to remove or classify noise and
outlier points

## Usage

``` r
catalog_filter(
  lascatalog,
  filter_noise = TRUE,
  algorithm_noise = ivf(5, 2),
  filter_heights = TRUE,
  bins_height = c(300, 1600),
  filter_mode = "remove",
  output_path,
  filename_convention = "{ORIGINALFILENAME}",
  parallel = FALSE,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`.

- filter_noise:

  logical of length 1. If TRUE filters noise based on the algorithm
  defined in `algorithm_noise`

- algorithm_noise:

  An algorithm used for filtering noise, see
  [`lidR::classify_noise()`](https://rdrr.io/pkg/lidR/man/classify.html).
  Defaults to ivf(5,2)

- filter_heights:

  logical of length 1. If TRUE filters outliers based on upper and lower
  heights defined by `bins_height`

- bins_height:

  numeric list of length 2, defines the lower and upper heights to be
  kept in the dataset

- filter_mode:

  character; either "remove" or "classify". When "remove": points
  filtered are removed from tha dataset, when "classify" points filtered
  are classified as noise.

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
