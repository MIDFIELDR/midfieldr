# Course data for examples

Selected variables modeled on those in the `course` practice data for
use in package examples and articles. Sampled from an early version of
the practice data, the toy data are not a current practice data sample.

## Usage

``` r
data(toy_course)
```

## Format

`data.table` with 5863 rows and 12 columns keyed by student ID:

- `mcid`:

  Character, de-identified student ID. Key column.

- `institution`:

  Character, de-identified institution name, e.g., Institution A,
  Institution B, etc.

- `term`:

  Character, academic year and term, format YYYYT. Key column.

- `course`:

  Character, course name, e.g., `Astrophysics III`,
  `Calculus For Social Science And Business`, `Corp Financial Rprtng 1`,
  `Environmental Sanitation II`, `Fitness and Wellness`,
  `Introductory Astronomy 2`, `Our Changing Environment`, etc.

- `abbrev`:

  Character, course alphabetical identifier, e.g. ENGR, MATH, ENGL. Key
  column.

- `number`:

  Character, course numeric identifier, e.g. 101, 3429. Key column.

- `section`:

  Character, course section identifier, from one to four characters,
  e.g., `1`, `2`, `01`, `14`, `001`, `040`, `785`, `H02`, `R01`, `300E`,
  `888R`, etc.

- `type`:

  Character, predominant delivery method for this section, e.g.,
  `Blended`, `Distance Education`, `Face-to-Face`, `Online`, etc.

- `faculty_rank`:

  Character, academic rank of the person teaching the course, e.g.,
  `Assistant Professor`, `Associate Professor`, `Graduate Assistant`,
  `Visiting Faculty`, etc.

- `hours_course`:

  Numeric, number of credit-hours for successful course completion.

- `grade`:

  Character, course grade, e.g., A+, A, A-, B+, I, NG, etc.

- `discipline_midfield`:

  Character, a variable for grouping courses by academic discipline
  assigned by the pre-2023 MIDFIELD data curator, e.g., `Anthropology`,
  `Business`, `Computer Science`, `Engineering`,
  `Language and Literature`, `Mathematics`,`Visual and Performing Arts`,
  etc.

## See also

Other toy-data:
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
