
midfieldr <a href="https://engineering.purdue.edu/MIDFIELD" target="blank"><img src="man/figures/midfieldcut.png" align="right"/></a>
=====================================================================================================================================

<!-- [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/midfieldr)](http://cran.r-project.org/package=midfieldr) -->
[![Build Status](https://travis-ci.org/MIDFIELDR/midfieldr.svg?branch=master)](https://travis-ci.org/MIDFIELDR/midfieldr) [![License: GPL v3](man/figures/License-GPL-v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

midfieldr is a package for investigating student record data provided by registrars at US universities participating in the MIDFIELD project.

A sample of the MIDFIELD database is accessible using midfieldr. The sample comprises demographic, term, course, and degree information for 57,006 undergraduate students from 1987 to 2016. Because of their size, the sample datasets are provided in separate data packages.

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

-   `midfieldstudents` in the [midfieldstudents](https://github.com/MIDFIELDR/midfieldstudents) package. A tidy data frame with 57,006 observations and 15 demographic variables. Each observation is a unique student. This dataset occupies 9.6 Mb of memory.

-   `midfielddegrees` in the [midfieldstudents](https://github.com/MIDFIELDR/midfieldstudents) package. A tidy data frame with 28,605 observations and 5 graduation variables. Each observation is a unique student. This dataset occupies 2.2 Mb of memory.

-   `terms` in the [midfieldterms](https://github.com/MIDFIELDR/midfieldterms) package. A tidy data frame with 1.1 M observations and 22 academic term variables. Each observation is one term for one student. This dataset occupies 200.2 Mb of memory.

-   `courses` in the [midfieldcourses](https://github.com/MIDFIELDR/midfieldcourses) package. A tidy data frame with 5.4 M observations and 17 academic course variables. Each observation is one course in one term for one student. This dataset occupies 735.1 Mb of memory.
