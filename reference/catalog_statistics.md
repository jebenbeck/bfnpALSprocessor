# Calculate statistics on lascatalog files

Takes all files in a lascatalog and returns a table with statistics on
point density, covex area covered, extemt, etc. for every tile

## Usage

``` r
catalog_statistics(lascatalog, parallel = F, n_cores = 2, spatial = FALSE)
```

## Arguments

- lascatalog:

  Object of class `lascatalog`

- parallel:

  logical of length 1. Should the computation be split over several
  cores? Defaults to FALSE.

- n_cores:

  numeric of length 1. If `parall = TRUE`, on how many cores should the
  computations be run on? Defaults to the value registered in
  `options("cores")[[1]]`, or, if this is not available, to
  `parallel::detectCores())`.

- spatial:

  logical of length 1. Should the output be a spatial dataset (sf) with
  polygons representing the catalog tiles?

## Value

data frame

## Examples
