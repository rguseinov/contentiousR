# Load leader data

Loads leader data from one of two datasets included with the package, by
country-year or, with `unit`, by country-quarter, country-month, or
country-day. Each row holds the leader in power at the end of the
period: when several leaders served in the same period (a leadership
transition), the one who took office last is kept. Periods are assigned
from the leaders' dates of entry and exit, so a leader who left office
in February is no longer listed from March on.

## Usage

``` r
load_leader_data(
  start_year = 1945,
  end_year = 2015,
  dataset = c("archigos", "reign"),
  coding_system = c("cow", "gw"),
  unit = c("year", "quarter", "month", "day")
)
```

## Source

**Archigos:** Goemans, H.E., Gleditsch, K.S., & Chiozza, G. (2009).
Introducing Archigos: A Dataset of Political Leaders. *Journal of Peace
Research*, 46(2), 269–283.
<https://web.archive.org/web/20241206095059/http://ksgleditsch.com/archigos.html>

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

- unit:

  Time unit: `"year"` (default), `"quarter"`, `"month"`, or `"day"`.
  `"reign"` supports up to `"month"`, as it does not record the day a
  leader left office.

## Value

A data frame with one row per country and period. Columns differ by
dataset:

**archigos:** `cow`/`gw`, `year`, `leader`, `entry`, `exit`,
`irregular_entry`, `irregular_exit`, `female_leader`, `yrborn`,
`posttenurefate`, `leader_tenure`.

**reign:** `cow`/`gw`, `year`, `leader`, `female_leader`, `military_bg`,
`birthyear`, `leader_tenure`.

`leader_tenure` counts the calendar years in office, including the
current one, at every unit. Finer units add the time keys (`quarter`, or
`month` and `day`) and `leader_tenure_quarters`, `leader_tenure_months`,
or `leader_tenure_days`: the periods in office, including the current
one.

## Details

REIGN gives the year and month (not the day) a leader left office; a
REIGN spell is taken to run to the last day of its exit month. Leaders
still in office when the REIGN data end (August 2021) have no exit date
in the source and are kept in office through that month.

## References

Goemans, H. E., Gleditsch, K. S., & Chiozza, G. (2009). Introducing
Archigos: A dataset of political leaders. *Journal of Peace Research*,
46(2), 269-283.

Bell, C., Besaw, C., & Frank, M. (2021). *The Rulers, Elections, and
Irregular Governance (REIGN) Dataset*.

## Examples

``` r
arch <- load_leader_data(1990, 2010, dataset = "archigos", coding_system = "cow")

reign <- load_leader_data(1990, 2010, dataset = "reign", coding_system = "gw")

# Leaders by month: Egypt, 2011
monthly <- load_leader_data(2011, 2011, coding_system = "cow", unit = "month")
monthly[monthly$cow == 651, c("year", "month", "leader")]
#> # A tibble: 12 × 3
#>     year month leader 
#>    <int> <int> <chr>  
#>  1  2011     1 Mubarak
#>  2  2011     2 Tantawi
#>  3  2011     3 Tantawi
#>  4  2011     4 Tantawi
#>  5  2011     5 Tantawi
#>  6  2011     6 Tantawi
#>  7  2011     7 Tantawi
#>  8  2011     8 Tantawi
#>  9  2011     9 Tantawi
#> 10  2011    10 Tantawi
#> 11  2011    11 Tantawi
#> 12  2011    12 Tantawi
```
