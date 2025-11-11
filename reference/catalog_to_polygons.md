# Generate footprint polygons of lascatalog objects

Takes all files in a lascatalog and returns a polygon file where each
polygon represents the bounding box of the respective las / laz file. In
Addition the resulting data is cleaned and unnecessary columns are
removed. Data can be exported as geopackage or shapefile afterwards

## Usage

``` r
catalog_to_polygons(lascatalog)
```

## Arguments

- lascatalog:

  Object of class `lascatalog`

## Value

sf polygon

## Examples
