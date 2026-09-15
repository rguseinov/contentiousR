# Load leader data

Loads country-year leader data from one of two datasets included with
the package. Each row in the output represents one country-year, with
the leader who held power at the end of the year. When multiple leaders
served in the same year (i.e., a leadership transition occurred), the
leader with the latest start date is retained.

## Usage

``` r
load_leader_data(
  start_year = 1945,
  end_year = 2015,
  dataset = c("archigos", "reign"),
  coding_system = c("cow", "gw")
)
```

## Source

**Archigos:** Goemans, H.E., Gleditsch, K.S., & Chiozza, G. (2009).
Introducing Archigos: A Dataset of Political Leaders. *Journal of Peace
Research*, 46(2), 269–283. <https://ksgleditsch.com/archigos.html>

**REIGN:** Bell, C. (2021). REIGN: Rulers, Elections, and Irregular
Governance Dataset. One Earth Future Foundation.
<https://oefdatascience.github.io/REIGN.github.io/>

## Arguments

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- dataset:

  Character. Dataset to load:

  `"archigos"`

  :   Archigos 4.1 (Goemans, Gleditsch & Chiozza). Leader spells with
      entry/exit mode coding. Coverage: 1875–2015.

  `"reign"`

  :   REIGN Leader List (Bell 2021). Leader spells with military
      background coding. Coverage: 1921–2021.

- coding_system:

  Character. Country coding system: `"cow"` or `"gw"`.

## Value

A country-year data frame. Columns differ by dataset:

**archigos:** `cow`/`gw`, `year`, `leader`, `entry`, `exit`,
`irregular_entry`, `irregular_exit`, `female_leader`, `yrborn`,
`posttenurefate`, `leader_tenure`.

**reign:** `cow`/`gw`, `year`, `leader`, `female_leader`, `military_bg`,
`birthyear`, `leader_tenure`.

## Examples

``` r
arch <- load_leader_data(1990, 2010, dataset = "archigos", coding_system = "cow")

reign <- load_leader_data(1990, 2010, dataset = "reign", coding_system = "gw")
```
