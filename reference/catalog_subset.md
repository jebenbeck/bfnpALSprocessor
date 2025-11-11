# subset lascatalogs

This function subsets `lascatalog` objects using spatial polygon(s)
("aoi, area of interest") and returns a new `lascatalog` object with all
tiles overlapping said polygon(s). In contrast to
[`lidR::catalog_intersect()`](https://rdrr.io/pkg/lidR/man/catalog_subset.html)
it also exports this new, subsetted catalog to a specified directory
very efficiently without loading the tiles into memory by simply copying
the files directly. This is perfect for when you want to share only
sections of the full data with others to work on.

## Usage

``` r
catalog_subset(lascatalog, aoi, output_path, overwrite_files = F)
```

## Arguments

- lascatalog:

  object of class `lascatalog`.

- aoi:

  object of class `spatial polygons`

- output_path:

  character path to the folder where the new files should be exported to

- overwrite_files:

  logical of length 1. Should already existing files be overwritten or
  be ignored? Defaults to FALSE.

## Value

lascatalog

## Examples
