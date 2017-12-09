
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

Data
----

midfieldr provides access to five datasets.

1.  `student` in the midfieldstudent package. Demographic data for 165,000 students. Each observation is a unique student.
2.  `term` in the midfieldterm package. Academic term data for 165,000 students. Each observation is one term for one student, yielding 1.1 M observations.
3.  `course` in the midfieldcourse package. Academic course data for 165,000 students. Each observation is one course for one student, yielding 5.4 M observations.
4.  `degree` in the midfieldstudent package. Graduation data for 90,000 students receiving degrees. Each observation is a unique student.
5.  `cip` in the midfieldr package. A dataset of program codes and names of academic fields of study. Each of the 1552 observations is one program at the CIP 6-digit level. ?cip for more information.
