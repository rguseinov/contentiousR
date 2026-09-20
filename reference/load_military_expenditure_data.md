# Load military expenditure data

Loads country-year military expenditure data from one of the sources
included with the package.

## Usage

``` r
load_military_expenditure_data(
  start_year = 1945,
  end_year = 2019,
  dataset = c("sipri", "nmc", "barnum"),
  coding_system = c("cow", "gw")
)
```

## Source

**SIPRI:** Stockholm International Peace Research Institute (2025).
SIPRI Military Expenditure Database.
<https://www.sipri.org/databases/milex>

**NMC:** Singer, J. David, Bremer, Stuart & Stuckey, John (1972).
Capability Distribution, Uncertainty, and Major Power War, 1820-1965.
National Material Capabilities v7.0.
<https://correlatesofwar.org/data-sets/national-material-capabilities/>

**Barnum:** Barnum, M., Fariss, C.J., Markowitz, J.N., & Morales, G.
(2025). Measuring Arms: Introducing the Global Military Spending
Dataset. *Journal of Conflict Resolution*, 69(2-3), 540-567.

## Arguments

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- dataset:

  Character. Dataset to load:

  `"sipri"`

  :   SIPRI Military Expenditure Database v1.2: spending in
      constant (2024) USD millions (`sipri_milex`) and military burden
      as a share of GDP (`sipri_milburden`, a fraction, not a
      percentage). Coverage: 1949-2025.

  `"nmc"`

  :   Correlates of War National Material Capabilities v7.0 (abridged):
      military expenditure in thousands of current USD (`nmc_milex`).
      Coverage: 1816-2022.

  `"barnum"`

  :   Global Military Spending Dataset (Barnum, Fariss, Markowitz &
      Morales 2025): military burden (`barnum_milburden`, a fraction of
      GDP) plus latent-model expenditure estimates on two unit bases
      (`barnum_sipri`, `barnum_nmc`; see Details). Coverage: 1816-2019.

- coding_system:

  Character. Country coding system: `"cow"` or `"gw"`.

## Value

A country-year data frame. Columns differ by dataset:

**sipri:** `cow`/`gw`, `year`, `sipri_milex`, `sipri_milburden`.

**nmc:** `cow`/`gw`, `year`, `nmc_milex`.

**barnum:** `cow`/`gw`, `year`, `barnum_milburden`, `barnum_sipri`,
`barnum_nmc`.

## Details

NMC's `-9` missing-data sentinel is recoded to `NA` in `nmc_milex`.

The SIPRI workbook lists a small number of rows (e.g. "Africa", "NATO")
that are regional or organizational aggregates rather than countries;
these have no matching COW/Gleditsch-Ward code and are dropped when
[`countrycode::countrycode()`](https://rdrr.io/pkg/countrycode/man/countrycode.html)
returns `NA`.

Barnum et al.'s replication files contain one row per country-year for
each of 24 underlying source indicators (SIPRI, WMEAT, NCD, IISS, and
others), each already reported in its own original currency/unit. Unlike
Fariss et al. (2022)'s GDP and population estimates, the paper does not
publish a single combined "latent" value on a real monetary scale: "the
average by itself does not have a real or direct monetary unit" (p.
550). Instead, `barnum_sipri` and `barnum_nmc` are the model's posterior
estimate of two specific indicators (the `"milex_con_2022_sipri"` and
`"milex_con_2017_nmc"` series respectively), which extends each one's
coverage back to 1816 using information from all 24 sources, still
expressed in that indicator's own original units. `barnum_milburden` is
`milexgdp` from Barnum et al.'s separate military-burden estimates file,
which is unit-free and so is published directly.

Both `"_con_"` indicators are in constant (inflation-adjusted) dollars,
unlike `nmc_milex` from `dataset = "nmc"`, which NMC documents in
current-year dollars. `barnum_nmc` is therefore not directly comparable
to `nmc_milex`: their ratio varies smoothly over time (e.g. around 2.4
for the United States in 1990, falling toward 1 by the mid-2010s), which
reflects cumulative inflation adjustment rather than disagreement
between the two sources.

## References

Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability
distribution, uncertainty, and major power war, 1820-1965. In B. Russett
(Ed.), *Peace, War, and Numbers* (pp. 19-48). Sage.

Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
material capabilities of states, 1816-1985. *International
Interactions*, 14, 115-132.

Stockholm International Peace Research Institute. (2025). *SIPRI
Military Expenditure Database*.
[doi:10.55163/CQGC9685](https://doi.org/10.55163/CQGC9685)

Barnum, M., Fariss, C. J., Markowitz, J. N., & Morales, G. (2025).
Measuring arms: Introducing the Global Military Spending Dataset.
*Journal of Conflict Resolution*, 69(2-3), 540-567.
[doi:10.1177/00220027241232964](https://doi.org/10.1177/00220027241232964)

## Examples

``` r
milex_sipri <- load_military_expenditure_data(1990, 2015, dataset = "sipri", coding_system = "cow")

milex_nmc <- load_military_expenditure_data(1900, 2015, dataset = "nmc", coding_system = "cow")
```
