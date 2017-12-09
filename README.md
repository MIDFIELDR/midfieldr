
midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/midfieldcut.png" align="right"/></a>
=====================================================================================================================================

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr) [![Build Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr)

midfieldr is a package for investigating student record data provided by registrars at US universities participating in the MIDFIELD project.

A sample of the MIDFIELD database is accessible using midfieldr. The sample comprises demographic, term, course, and degree information for 165,000 undergraduate students from 1990 to 2016. Because of their size, the sample datasets are provided in separate data packages.

midfieldr includes functions for aggregating, computing, and graphing student persistence metrics.

Installation
------------

midfieldr is not currently available from CRAN, but the development version can be installed from github with:

    # install.packages("devtools")
    devtools::install_github("MIDFIELDR/midfieldr")

Usage
-----

The basic units for computing persistence metrics are the individual student, course, term, program, or institution.

For investigating graduation rates

-   `gather_start()`
-   `gather_grad()`
-   `tally_gradrate()`
-   `graph_gradrate()`

For investigating stickiness

-   `gather_ever()`
-   `gather_grad()`
-   `tally_stickiness()`
-   `graph_stickiness()`
