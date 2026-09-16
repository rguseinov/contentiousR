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
      total population (`tpop`) and urban population (`upop`), both in
      thousands. Coverage: 1816-2022.

  `"fariss"`

  :   Latent population estimates (Fariss, Anders, Markowitz & Barnum
      2022). Coverage: 1500-2019.

- coding_system:

  Character. Country coding system: `"cow"` or `"gw"`.

## Value

A country-year data frame. Columns differ by dataset:

**wpp:** `cow`/`gw`, `year`, `un_pop`.

**nmc:** `cow`/`gw`, `year`, `tpop`, `upop`.

**fariss:** `cow`/`gw`, `year`, `fariss_pop`.

## Details

The bundled UN WPP extract has three rows for some China country-years:
a combined mainland+Hong Kong+Macao+Taiwan figure, a mainland-only
figure, and a Hong Kong-only figure, all of which matched COW code 710
during country-name conversion upstream. The mainland-only figure is
consistently the median of the three, so `un_pop` is computed as the
median `pop` value within each `cow`-`year` group; for every other
country-year (a single row) this is a no-op.

NMC's `-9` missing-data sentinel is recoded to `NA` in `tpop` and
`upop`.

`fariss_pop` is the model's own latent-scale estimate, taken directly
from the `"latent_pop"` rows of the replication file. Its absolute units
are not independently verified here; consult Fariss et al. (2022) before
using it outside of relative/comparative analysis.

## Examples

``` r
pop_wpp <- load_population_data(1990, 2015, dataset = "wpp", coding_system = "cow")

pop_nmc <- load_population_data(1900, 2015, dataset = "nmc", coding_system = "cow")
```
