# Small 'course' dataset for examples

A subset of rows from the midfielddata `course` table matching the IDs
in `toy_student.` A small dataset for use in examples.

## Usage

``` r
toy_course
```

## Format

Data frame with 8950 rows and 12 columns (`data.table` class). Composite
key: `{mcid, term_course, abbrev, number}.`

- `mcid`:

  Character. Anonymized student identifier that connects the four data
  tables, e.g., "MCID3111142897."

- `term_course`:

  Character. Academic year and term, encoded `YYYYT.`

- `abbrev`:

  Character. Course alphabetical identifier, e.g. "ENGR", "MATH",
  "ENGL."

- `number`:

  Character. Course numeric identifier, e.g. "101", "3429."

- `institution`:

  Character. The anonymized name of the institution the student attended
  in a given term, e.g., "Institution A", "Institution B", etc.

- `course`:

  Character. Course name, e.g., "Astrophysics III", "Calculus For Social
  Science And Business", "Corp Financial Rprtng 1", "Environmental
  Sanitation II", "Fitness and Wellness", "Introductory Astronomy 2",
  "Our Changing Environment", etc.

- `section`:

  Character. Course section identifier, from one to four characters,
  e.g., "1", "2", "01", "14", "001", "040", "785", "H02", "R01", "300E",
  "888R", etc.

- `type`:

  Character. Predominant delivery method for this section, e.g.,
  "Blended", "Distance Education", "Face-to-Face", "Online", etc.

- `faculty_rank`:

  Character. The academic rank of the person teaching the course, e.g.,
  "Assistant Professor", "Associate Professor", "Graduate Assistant",
  "Visiting Faculty", etc.

- `hours_course`:

  Numeric. Number of credit-hours for successful course completion.

- `grade`:

  Character. Course grade, e.g., "A+", "A", "A-", "B+", "I", "NG", etc.

- `discipline_midfield`:

  Character. A variable for grouping courses by academic discipline
  assigned by the pre-2023 MIDFIELD data curator, e.g., "Anthropology",
  "Business", "Computer Science", "Engineering", "Language and
  Literature", "Mathematics", "Visual and Performing Arts", etc.

## See also

Other toy-data:
[`toy_degree`](https://midfieldr.github.io/midfieldr/reference/toy_degree.md),
[`toy_student`](https://midfieldr.github.io/midfieldr/reference/toy_student.md),
[`toy_term`](https://midfieldr.github.io/midfieldr/reference/toy_term.md)
