
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bfnpALSprocessor

<!-- badges: start -->
<!-- badges: end -->

This package is used to process and harmonize all available ALS data in
the Bavarian Forest National Park and document the individual processing
steps performed for each dataset. It mainly builds ready-to-use
functions to reapeat certain processing steps to several different data
sets and relies on lidR, sf and terra.

This package includes the functions used and a full documentation of all
the processing steps applied to the available ALS data in the Bavarian
forest national park.

Install this package using
`devtools::install_github("jebenbeck/bfnpALSprocessor", dependencies = T)`

# Current status of processing:

| Dataset id  | status           | current step                  |
|-------------|------------------|-------------------------------|
| **2023-07** | almost done      | normalization                 |
| **2017-06** | finished         | \-                            |
| **2012-06** | work in progress | calculating number of returns |
