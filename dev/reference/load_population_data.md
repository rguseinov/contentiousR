# Load population data

Loads country-year population data from one of three sources included
with the package.

## Usage

``` r
load_population_data(
  start_year = 1945,
  end_year = 2019,
  dataset = c("wpp", "nmc", "fariss"),
  coding_system = c("cow", "gw")
)
```

## Source

**UN WPP:** United Nations, Department of Economic and Social Affairs,
Population Division (2024). World Population Prospects 2024.
<https://population.un.org/wpp/>

**NMC:** Singer, J. David, Bremer, Stuart & Stuckey, John (1972).
Capability Distribution, Uncertainty, and Major Power War, 1820-1965.
National Material Capabilities v7.0.
<https://correlatesofwar.org/data-sets/national-material-capabilities/>

**Fariss:** Fariss, C.J., Anders, T., Markowitz, J.N., & Barnum, M.
(2022). New estimates of over 500 years of historic GDP and population
data. *Journal of Conflict Resolution*, 66(3), 553-591.

## Arguments

- start_year:

  Integer. First year to include.

- end_year:

  Integer. Last year to include.

- dataset:

  Character. Dataset to load:

  `"wpp"`

  :   UN World Population Prospects, total population in thousands.
      Coverage: 1949-2023.

  `"nmc"`

  :   Correlates of War National Material Capabilities v7.0 (abridged):
      total population (`nmc_tpop`) and urban population (`nmc_upop`),
      both in thousands. Coverage: 1816-2022.

  `"fariss"`

  :   Latent population estimates (Fariss, Anders, Markowitz & Barnum
      2022). Coverage: 1500-2019.

- coding_system:

  Character. Country coding system: `"cow"` or `"gw"`.

## Value

A country-year data frame. Columns differ by dataset, each prefixed with
the source's `dataset` key:

**wpp:** `cow`/`gw`, `year`, `wpp_pop`.

**nmc:** `cow`/`gw`, `year`, `nmc_tpop`, `nmc_upop`.

**fariss:** `cow`/`gw`, `year`, `fariss_pop`.

## Details

**WPP and historical states.** WPP reports today's countries, with their
population reconstructed back to 1949 within today's borders.
`load_population_data(dataset = "wpp")` assigns each WPP country to the
state that governed it in each year, and sums them:

- States that later split are the sum of their parts while they existed:
  the USSR (365, the fifteen republics until 1991, the Baltic states
  from 1940), Yugoslavia and its successor (345: Serbia, Kosovo,
  Montenegro, and the other republics until they became states),
  Czechoslovakia (316, the panels' code; Czechia and Slovakia until
  1992), Ethiopia (with Eritrea, 1952-1992), Pakistan (with Bangladesh
  until 1970), Sudan (with South Sudan until 2010), Indonesia (with
  Timor-Leste, 1976-2001), Malaysia (with Singapore, 1963-1964), and
  Egypt (with Syria, 1959-1960, as the United Arab Republic).

- Hong Kong is added to China from 1997 and Macao from 1999.

- States formed by unification cannot be split back into their parts, so
  the parts are `NA` before unification: West and East Germany before
  1990 (Germany has data from 1990), North and South Yemen before 1990
  (Yemen, COW 679, from 1990), North and South Vietnam before 1976, and
  Tanganyika and Zanzibar before 1964.

In the year a state split, each successor that is a state that year has
its own value, and the predecessor covers the territory it kept. Only
the years in which a state is in the COW or GW state system are
returned. Territories WPP lists separately that were not part of a COW
state (for example Puerto Rico, Greenland, Western Sahara, and French
overseas departments) are not added to any state. Smaller border changes
within a state (such as the incorporation of Goa, Sikkim, or Sabah and
Sarawak) are not adjusted: WPP's figures follow today's borders.

NMC's `-9` missing-data sentinel is recoded to `NA` in `nmc_tpop` and
`nmc_upop`.

`fariss_pop` is the model's own latent-scale estimate, taken directly
from the `"latent_pop"` rows of the replication file. Its absolute units
are not independently verified here; consult Fariss et al. (2022) before
using it outside of relative/comparative analysis.

## References

United Nations, Department of Economic and Social Affairs, Population
Division. (2024). *World Population Prospects 2024*.
<https://population.un.org/wpp/>

Fariss, C. J., Anders, T., Markowitz, J. N., & Barnum, M. (2022). New
estimates of over 500 years of historic GDP and population data.
*Journal of Conflict Resolution*, 66(3), 553-591.
[doi:10.1177/00220027211054432](https://doi.org/10.1177/00220027211054432)

Singer, J. D., Bremer, S., & Stuckey, J. (1972). Capability
distribution, uncertainty, and major power war, 1820-1965. In B. Russett
(Ed.), *Peace, War, and Numbers* (pp. 19-48). Sage.

Singer, J. D. (1988). Reconstructing the Correlates of War dataset on
material capabilities of states, 1816-1985. *International
Interactions*, 14, 115-132.

## Examples

``` r
pop_wpp <- load_population_data(1990, 2015, dataset = "wpp", coding_system = "cow")

pop_nmc <- load_population_data(1900, 2015, dataset = "nmc", coding_system = "cow")
```
