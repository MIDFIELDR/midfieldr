
midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/midfieldcut.png" align="right"/></a>
=====================================================================================================================================

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr) [![Build Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr) [![License: GPL v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

midfieldr is a package for investigating student record data provided by registrars at US universities participating in the MIDFIELD project.

A sample of the MIDFIELD database is accessible using midfieldr. The sample comprises demographic, term, course, and degree information for 165 072 undergraduate students from 1990 to 2016. Because of their size, the sample datasets are provided in separate data packages.

midfieldr includes functions for selecting specific fields of study and aggregating, computing, and graphing student persistence metrics.

Installation
------------

midfieldr is not currently available from CRAN, but the development version can be installed from github with:

    install.packages("devtools")
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

Data
----

The sample of the MIDFIELD database that is accessible using midfieldr and its data packages includes:

-   `cip` in the midfieldr package. A tidy data frame with 1544 observations and 6 CIP variables of program codes and names at the 2, 4, and 6-digit levels. Each observation is a unique program. This dataset occupies 331 kb of memory.

-   `student` in the [midfieldstudent](https://github.com/MIDFIELDR/midfieldstudent) package. A tidy data frame with 165 072 observations and 35 demographic variables. Each observation is a unique student. This dataset occupies 49.1 Mb of memory.

-   `degree` in the [midfieldstudent](https://github.com/MIDFIELDR/midfieldstudent) package. A tidy data frame with 89 886 observations and 14 graduation variables. Each observation is a unique student. This dataset occupies 10.1 Mb of memory.

-   `term` in the [midfieldterm](https://github.com/MIDFIELDR/midfieldterm) package. A tidy data frame with 1.1 M observations and 22 academic term variables. Each observation is one term for one student. This dataset occupies 200.2 Mb of memory.

-   `course` in the [midfieldcourse](https://github.com/MIDFIELDR/midfieldcourse) package. A tidy data frame with 5.4 M observations and 17 academic course variables. Each observation is one course in one term for one student. This dataset occupies 735.1 Mb of memory.
