# Retile lascatalog

This function retiles a lascatalog into rigid tiles without any overlap.

Often, ALS data in the BFNP is not stored in rigid tiles but in parts of
flight lines which can overlap. This is not good, because if you want to
know all points over a certain location within your AOI, you need to
consider multiple files to get all of them.

This function is basically the same as
[`lidR::catalog_retile()`](https://rdrr.io/pkg/lidR/man/catalog_retile.html)
with some default settings as for all datasets, the same settings must
be used. It restructures the lascatalog to match a common grid of 1x1 km
tiles in the UTM coordinate system by default which relates to the
common grid that is used by all datasets. Of course, this only works if
the data was first transferred to UTM32N.

## Usage

``` r
catalog_retile_template(
  lascatalog,
  tile_alignment = c(0, 0),
  tile_size = 1000,
  buffer_size = 0,
  output_path,
  filename_convention = "{XLEFT}_{YBOTTOM}",
  laz_compression = T
)
```

## Arguments

- lascatalog:

  object of class `lascatalog`, should be in crs EPSG:25832

- tile_alignment:

  list of length 2. See
  [`lidR::opt_chunk_alignment()`](https://rdrr.io/pkg/lidR/man/engine_options.html)

- tile_size:

  numeric, tile size in meter. See
  [`lidR::opt_chunk_size()`](https://rdrr.io/pkg/lidR/man/engine_options.html)

- buffer_size:

  numeric, buffer size in meter. See
  [`lidR::opt_chunk_buffer()`](https://rdrr.io/pkg/lidR/man/engine_options.html)

- output_path:

  character, path to where the resulting laz files should be exported to

- filename_convention:

  character. See
  [`lidR::opt_output_files()`](https://rdrr.io/pkg/lidR/man/engine_options.html)

- laz_compression:

  logical of length 1. See
  [`lidR::opt_laz_compression()`](https://rdrr.io/pkg/lidR/man/engine_options.html)

## Value

lascatalog

## Examples
