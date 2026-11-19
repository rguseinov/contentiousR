# List the datasets bundled with the package

Returns one row per dataset that the package's loaders and `add_*()`
functions can use, with its coverage, data type, the panel units it
supports, and the prefix of the columns it adds. Use
[`cn_cite()`](https://rguseinov.github.io/contentiousR/dev/reference/cn_cite.md)
with the `dataset` value to get the citation.

## Usage

``` r
list_datasets(
  topic = c("all", "conflict", "gdp", "population", "military", "leaders", "vdem")
)
```

## Arguments

- topic:

  Which datasets to list: `"all"` (default), `"conflict"`, `"gdp"`,
  `"population"`, `"military"`, `"leaders"`, or `"vdem"`.

## Value

A data frame with columns:

- `dataset`:

  Value to pass as `dataset =`.

- `topic`:

  Topic, as in `topic`.

- `name`:

  Name of the source.

- `version`:

  Bundled version.

- `load_function`, `add_function`:

  The loader and the panel function that use it.

- `record`:

  What one source record is: an event, an episode or campaign, a
  campaign phase, a conflict-year, or a country-year.

- `start_year`, `end_year`:

  Years covered.

- `countries`:

  Which countries the source covers.

- `units`:

  Panel units at which the data vary: annual data are repeated across
  the periods of a year in finer panels.

- `prefix`:

  Prefix of the columns added to a panel.

- `zero_fill`:

  For conflict datasets, how `add_conflict(fill_zero = TRUE)` decides
  which country-years the source covers (see
  [`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md)).

## Examples

``` r
list_datasets()
#>       dataset      topic
#> 1    navco1.3   conflict
#> 2    navco2.1   conflict
#> 3    navco3.0   conflict
#> 4  beissinger   conflict
#> 5       raqed   conflict
#> 6         mec   conflict
#> 7         omg   conflict
#> 8        scad   conflict
#> 9         arc   conflict
#> 10         mm   conflict
#> 11       mmad   conflict
#> 12  ucdp_prio   conflict
#> 13   ucdp_vpp   conflict
#> 14  gapminder        gdp
#> 15     fariss        gdp
#> 16        wpp population
#> 17        nmc population
#> 18     fariss population
#> 19      sipri   military
#> 20        nmc   military
#> 21     barnum   military
#> 22   archigos    leaders
#> 23      reign    leaders
#> 24       vdem       vdem
#>                                                              name    version
#> 1                                                       NAVCO 1.3        1.3
#> 2                                                       NAVCO 2.1        2.1
#> 3                                                       NAVCO 3.0        3.0
#> 4                     Revolutionary Episodes Dataset (Beissinger)       2022
#> 5  Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)        1.4
#> 6                              Major Episodes of Contention (MEC)        1.0
#> 7                           Opposition Movements and Groups (OMG)          1
#> 8                        Social Conflict Analysis Database (SCAD)        3.3
#> 9                           Anatomy of Resistance Campaigns (ARC)        2.0
#> 10                                      Mass Mobilization Project          4
#> 11               Mass Mobilization in Autocracies Database (MMAD)        5.0
#> 12                               UCDP/PRIO Armed Conflict Dataset       26.1
#> 13                         UCDP Violent Political Protest Dataset       26.1
#> 14                                       Gapminder GDP per capita         32
#> 15                      Latent GDP estimates (Fariss et al. 2022)       2022
#> 16                                  UN World Population Prospects       2024
#> 17                             COW National Material Capabilities        7.0
#> 18               Latent population estimates (Fariss et al. 2022)       2022
#> 19                            SIPRI Military Expenditure Database        1.2
#> 20                             COW National Material Capabilities        7.0
#> 21               Military spending estimates (Barnum et al. 2025) 2025-04-29
#> 22                                                       Archigos        4.1
#> 23            Rulers, Elections, and Irregular Governance (REIGN)       2021
#> 24              Varieties of Democracy (via the vdemdata package)   vdemdata
#>                       load_function               add_function         record
#> 1                   conflict_data()             add_conflict()       campaign
#> 2                   conflict_data()             add_conflict()  campaign-year
#> 3                   conflict_data()             add_conflict()          event
#> 4                   conflict_data()             add_conflict()        episode
#> 5                   conflict_data()             add_conflict()        episode
#> 6                   conflict_data()             add_conflict()        episode
#> 7                   conflict_data()             add_conflict() campaign phase
#> 8                   conflict_data()             add_conflict()          event
#> 9                   conflict_data()             add_conflict()          event
#> 10                  conflict_data()             add_conflict()          event
#> 11                  conflict_data()             add_conflict()          event
#> 12                  conflict_data()             add_conflict()  conflict-year
#> 13                  conflict_data()             add_conflict()      dyad-year
#> 14                  load_gdp_data()                  add_gdp()   country-year
#> 15                  load_gdp_data()                  add_gdp()   country-year
#> 16           load_population_data()           add_population()   country-year
#> 17           load_population_data()           add_population()   country-year
#> 18           load_population_data()           add_population()   country-year
#> 19 load_military_expenditure_data() add_military_expenditure()   country-year
#> 20 load_military_expenditure_data() add_military_expenditure()   country-year
#> 21 load_military_expenditure_data() add_military_expenditure()   country-year
#> 22               load_leader_data()          add_leader_data()   leader spell
#> 23               load_leader_data()          add_leader_data()   leader spell
#> 24                 load_vdem_data()                 add_vdem()   country-year
#>    start_year end_year
#> 1        1900     2019
#> 2        1945     2013
#> 3        1990     2012
#> 4        1900     2014
#> 5        2000     2026
#> 6        1955     2018
#> 7        1789     2019
#> 8        1990     2017
#> 9        1990     2018
#> 10       1990     2020
#> 11       2003     2022
#> 12       1946     2025
#> 13       1989     2025
#> 14       1800     2025
#> 15       1500     2019
#> 16       1949     2023
#> 17       1816     2022
#> 18       1500     2019
#> 19       1949     2025
#> 20       1816     2022
#> 21       1816     2023
#> 22       1875     2015
#> 23       1921     2021
#> 24       1789       NA
#>                                                      countries
#> 1                                                       Global
#> 2                                                       Global
#> 3                                                 26 countries
#> 4                                                       Global
#> 5                                                       Global
#> 6                                                       Global
#> 7                                                       Global
#> 8                                     Africa and Latin America
#> 9                      Africa, Latin America and the Caribbean
#> 10 Most countries; the source lists the country-years it codes
#> 11                                                 Autocracies
#> 12                                                      Global
#> 13                                                      Global
#> 14                                                      Global
#> 15                                                      Global
#> 16                                                      Global
#> 17                                                      Global
#> 18                                                      Global
#> 19                                                      Global
#> 20                                                      Global
#> 21                                                      Global
#> 22                                                      Global
#> 23                                                      Global
#> 24                                                      Global
#>                              units      prefix
#> 1                             year     nvc1.3_
#> 2                             year     nvc2.1_
#> 3        year, quarter, month, day     nvc3.0_
#> 4        year, quarter, month, day beissinger_
#> 5        year, quarter, month, day      raqed_
#> 6        year, quarter, month, day        mec_
#> 7        year, quarter, month, day        omg_
#> 8        year, quarter, month, day       scad_
#> 9        year, quarter, month, day        arc_
#> 10       year, quarter, month, day         mm_
#> 11       year, quarter, month, day       mmad_
#> 12                            year  ucdp_prio_
#> 13                            year   ucdp_vpp_
#> 14 year (repeated in finer panels)        gdp_
#> 15 year (repeated in finer panels)     fariss_
#> 16 year (repeated in finer panels)        wpp_
#> 17 year (repeated in finer panels)        nmc_
#> 18 year (repeated in finer panels)     fariss_
#> 19 year (repeated in finer panels)      sipri_
#> 20 year (repeated in finer panels)        nmc_
#> 21 year (repeated in finer panels)     barnum_
#> 22       year, quarter, month, day      leader
#> 23            year, quarter, month      leader
#> 24 year (repeated in finer panels)          v2
#>                                                                       zero_fill
#> 1                           All states in the panel, within start_year-end_year
#> 2                           All states in the panel, within start_year-end_year
#> 3                Countries with at least one record, within start_year-end_year
#> 4                           All states in the panel, within start_year-end_year
#> 5                           All states in the panel, within start_year-end_year
#> 6                           All states in the panel, within start_year-end_year
#> 7                           All states in the panel, within start_year-end_year
#> 8                Countries with at least one record, within start_year-end_year
#> 9                Countries with at least one record, within start_year-end_year
#> 10 Country-years listed in the source, including those coded as having no event
#> 11                   Each country from its first to its last year with a record
#> 12                          All states in the panel, within start_year-end_year
#> 13                          All states in the panel, within start_year-end_year
#> 14                                                                         <NA>
#> 15                                                                         <NA>
#> 16                                                                         <NA>
#> 17                                                                         <NA>
#> 18                                                                         <NA>
#> 19                                                                         <NA>
#> 20                                                                         <NA>
#> 21                                                                         <NA>
#> 22                                                                         <NA>
#> 23                                                                         <NA>
#> 24                                                                         <NA>
list_datasets("conflict")[, c("dataset", "start_year", "end_year", "units")]
#>       dataset start_year end_year                     units
#> 1    navco1.3       1900     2019                      year
#> 2    navco2.1       1945     2013                      year
#> 3    navco3.0       1990     2012 year, quarter, month, day
#> 4  beissinger       1900     2014 year, quarter, month, day
#> 5       raqed       2000     2026 year, quarter, month, day
#> 6         mec       1955     2018 year, quarter, month, day
#> 7         omg       1789     2019 year, quarter, month, day
#> 8        scad       1990     2017 year, quarter, month, day
#> 9         arc       1990     2018 year, quarter, month, day
#> 10         mm       1990     2020 year, quarter, month, day
#> 11       mmad       2003     2022 year, quarter, month, day
#> 12  ucdp_prio       1946     2025                      year
#> 13   ucdp_vpp       1989     2025                      year
```
