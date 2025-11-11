# Reproject lascatalog

Transforms the coordinate system of a lascatalog using
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html).
Hereby, all files will be transformed seperately and the catalog
structure will not be touched.

While this function can transform from and to any horizontal coordinate
system implemented in
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html),
it is specialized on converting point cloud data stored in [GK4 -
EPSG:31468](https://epsg.io/31468) to [UTM32N -
EPSG:25832](https://epsg.io/25832). The focus on this transformation is
based on the fact, that most of the ALS data acquired in the BFNP before
2018 is stored in GK4, as it was the default reference system back then.
As the new standard is UTM32N, all data has to be transformed in order
perform time series analysis more easily.

There are many different methods to transform coordinates between GK4
and UTM32N, the most accurate one is the "Beta2007" method which relies
on a transformation grid to change the geodetic datum. When checking the
accuracy of the methods using reference points from the bavarian
surveying agency, it could be found that the accuracy went from 0.22 m
in x and 0.12 m in y direction (median) when using the default method to
0.02 m (median) in x and y direction when using the Beta2007 grid.
Therefore, when transforming ALS data, this method shall be used and
this function makes it possible to to so.

Base `lidR` uses a ported version of
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
in which always uses the default option, which is not Beta2007 for
transformations between GK4 and UTM32N. This leads to shifts of upt to 1
m in the point cloud datasets. However, there is a workaround to
manually make the Beta2007 method the default one and therefore use it
in `lidR`.

To do so, the system has to be prepared by setting up some prerequisites
and some basic concepts need to be understood:

To transform coordinates with
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
it relies on the [PROJ library](https://proj.org/en/stable). It uses
[pipelines](https://proj.org/en/stable/usage/transformation.html#transformation-pipelines)
to define the exact transformation method that should be used.
Transformation grids to change the geodetic datum can be implemented
into the pipelines using [NTv2 grid
datasets](https://proj.org/en/stable/usage/transformation.html#grid-based-datum-adjustments).
The different transformation pipelines can be observed by calling
`options <- sf_proj_pipelines(source_crs = "EPSG:31468", target_crs = "EPSG:25832")`
and then looking at `options` via `View(options)`. Hereby, the first
entry is the one that will be used to transform the data. Usually, this
is not the Beta2007 method so we have to make it that.

In order to use grid-based transformations,
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
needs to have access to the grid file in `.tif` format. There are two
options to make that work:

1.  accessing the file through the web via [PROJ.org Datumgrid
    CDN](https://cdn.proj.org/)

2.  downloading the file and putting it into your local library To make
    it usable as the `lidR` default method, we actually have to set up
    both. In know it's weird but it is what it is.

Enabling the web-service can be done by calling
`sf_proj_network(enable = T)`. Afterwards, check, which method is
default by calling
`options <- sf_proj_pipelines(source_crs = "EPSG:31468", target_crs = "EPSG:25832")`
and then looking at `options` again. The following definition entry
should be on top:

`+proj=pipeline +step +inv +proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +step +proj=hgridshift +grids=de_adv_BETA2007.tif +step +proj=utm +zone=32 +ellps=GRS80`

That's already great! However, for some reason, `lidR` requires the grid
to be available offline so we have to download the file from [PROJ.org
Datumbgrid CDN](https://cdn.proj.org/de_adv_BETA2007.tif) and store it
in the local PROJ library folder which can be found by calling
[`sf::sf_proj_search_paths()`](https://r-spatial.github.io/sf/reference/proj_tools.html).
In my case it was
`"C:/Users/username/AppData/Local/R/win-library/4.4/sf/proj"`. After
doing that for the first time, R needs to be restarted to apply these
changes.

You only need to set up this once on your system, afterwards the code
will work properly. The function will check for you if the settings are
okay and the grid file exists at the correct place.

## Usage

``` r
catalog_reproject(
  lascatalog,
  input_epsg,
  output_epsg,
  output_path,
  parallel = FALSE,
  n_cores = 2
)
```

## Arguments

- lascatalog:

  Object of class `lascatalog`

- input_epsg:

  character featuring EPSG definition in the style of "EPSG:31468".

- output_epsg:

  character featuring EPSG definition in the style of "EPSG:31468".

- output_path:

  character featuring the output path where the transformed laz files
  will be written to.

- parallel:

  logical of length 1. Should the computation be split over several
  cores? Defaults to FALSE.

- n_cores:

  numeric of length 1. If `parall = TRUE`, on how many cores should the
  computations be run on? Defaults to the value registered in
  `options("cores")[[1]]`, or, if this is not available, to
  `parallel::detectCores())`.

## Value

lascatalog object (laz format on disk)

## Examples
