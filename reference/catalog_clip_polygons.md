# Calculate statistics on lascatalog files

his function generates multiple output \*.laz files based on input
polygons (one file per polygon). The files are named after an attribute
in the input polygon dataset.

## Usage

``` r
catalog_clip_polygons(
  lascatalog,
  input_epsg,
  output_path,
  filename_convention = "{ID}",
  polygons,
  parallel = F,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`

- input_epsg:

  character EPSG-code of coordinate system

- output_path:

  character path to folder where the newly generated laz-files will be
  exported to

- filename_convention:

  character identifying the attribute in the polygon data that should be
  used to name the output files

- polygons:

  object of class `spatial polygons` featuring an attribute with the IDs
  or names of the polygons

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
