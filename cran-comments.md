# Purpose

Initial CRAN submission. 

# R CMD check results

0 errors | 0 warnings | 0 notes

# Test environments

* Windows Server 2022, R-devel, 64 bit
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Fedora Linux, R-devel, clang, gfortran

# Build results

The Ubuntu build using r-hub yielded a PREPERROR, but the text of the log 
yielded no errors or warnings, only NOTES. The other builds yielded no errors 
or warnings, only some NOTES generally unrelated to the package. `midfielddata` 
is a data package in a `drat` repository with an installed size of about 24Mb.

  

All builds produced these NOTES:

* checking CRAN incoming feasibility ... [7s/43s] NOTE    
Maintainer: ‘Richard Layton <graphdoctor@gmail.com>’    

* New submission    

* Suggests or Enhances not in mainstream repositories:    
  midfielddata    
  Availability using Additional_repositories specification:    
  midfielddata   yes   https://midfieldr.github.io/drat/ 



Ubuntu NOTES included:

* checking HTML version of manual ... NOTE    
  Skipping checking HTML validation: no command 'tidy' found    

Windows NOTES included: 

* checking for non-standard things in the check directory ... NOTE    
Found the following files/directories:    
  ''NULL''    

* checking for detritus in the temp directory ... NOTE    
Found the following files/directories:    
  'lastMiKTeXException'    


  

