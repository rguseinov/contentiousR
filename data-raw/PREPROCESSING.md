# How the bundled data are prepared

This document describes what happens to each dataset between
its download and the copy in `inst/extdata/`. It covers
only the preparation of the bundled files. 

## Principles

1. **Official sources only.** Every file starts from the version published
   by the dataset's creators (e.g. Harvard Dataverse). The version is explicitly recorded.

2. **No manual editing.** No file is edited by hand. Each bundled file is
   produced by one script, `data-raw/extdata.R`.

3. **Values are never changed.** The preparation step does not change any observations anyhow. 
Only four kinds of change are made:
   - **Recompression:** files are stored with xz compression. R data
     files contain identical objects.
   - **Format conversion:** non-rds files are stored as an R data file (`.rds`). 
     Examples are Stata `.dta` files.
   - **Dropping columns the package does not read:** for example free-text
     event descriptions, keeping every row.
   - **Dropping workbook sheets the package does not read.**

   SIPRI, below, is the one exception to the last point: its workbook is
   also reshaped.

4. **Free text and coder identities are removed.** Notes and source citations take up
   most of the space in several files. If you need them, use original files.

5. **Size.** CRAN asks packages to stay under 5 MB. These steps keep all the
   data in the package (about 4.4 MB in total, compressed) instead of downloading it at
   run time.

6. **Verification.** After any change to the preparation, the output of
   every loader is compared with the previous version using `identical()`.
   The package tests check row counts and known values against the
   originals. For example, ARC 2.0 has 28,683 events, and Algeria in 2014
   has 56 events involving 8 organizations.

## Dataset by dataset

| Bundled file | Original | What was done | Size (original → bundled) |
|---|---|---|---|
| `NAVCO_1.3.RData` | NAVCO 1.3 (Dataverse) | Re-saved with xz compression | 18 → 15 KB |
| `NAVCO_2.1.RData` | NAVCO 2.1 (Dataverse) | Re-saved with xz compression | 166 → 112 KB |
| `navco3.0_events.rds` | `navco3-0full.xlsx`, NAVCO 3.0 (Dataverse) | Kept 9 of 37 columns: `cowcode`, `date`, `actor_id`, `camp_goals`, `tactical_choice`, `st_posture`, `fatal_casu`, `injuries`, `num_partic_event`. Dropped event descriptions, source titles, localities, actor names and codes, verb codes, free-text tactic descriptions, arbitration flags, notes, and coder initials. Dates stored as dates; counts kept as the original text (e.g. "100-300") | 20,178 → 215 KB |
| `revolutionary_episodes_beissinger.csv.xz` | Beissinger, Revolutionary Episodes | xz-compressed, unchanged | 25 → 21 KB |
| `raqed_v1.4.csv.xz` | `RAQED V1.4.xlsx` (HSE University) | Kept the "Event table" sheet (one row per episode), all columns; dates written as YYYY-MM-DD. The "Panel table" sheet (the same episodes expanded to years) is not bundled | 142 → 20 KB |
| `MEC.rds` | `MEC.dta`, Major Episodes of Contention | Stata file read with `haven::read_dta()` and saved as `.rds`. No value labels to convert | 6,842 → 161 KB |
| `omg.rds` | `omg.rds`, OMG (PRIO), campaign-phase file | Dropped 8 free-text columns: `notes`, `sources`, `coder`, `coding_note`, `demand_change_note`, `demand_demand_note`, `socialgroup_change_note`, `socialgroup_check` | 954 → 100 KB |
| `ARC_2_0_Events.rds` | `ARC_2_0_Events.rds`, ARC 2.0 (Dataverse) | Dropped `country_name` and `country_abbr` (the COW code `ccode` identifies the country) | 252 → 102 KB |
| `SCAD2018Africa_Final.csv.xz`, `SCAD2018LatinAmerica_Final.csv.xz` | SCAD 3.3 CSV files | Kept the columns the package reads: event ID, country code, start year/month/day, event type, escalation, participants, deaths, repression, government targets, female participation, LGBTQ issue. Values kept as the original text | 1,797 → 103 KB |
| `mmALL_073120.RData` | Mass Mobilization v4 | Dropped `id`, `country`, `location`, `sources`, `notes`, `startyear`, end day/month/year, `protestnumber`, `region`, `participants_category`. Kept `protest` (0 marks a country-year without protest) and the start month and day | 3,735 → 161 KB |
| `mmad_events.csv.xz` | MMAD events | xz-compressed, unchanged | 321 → 253 KB |
| `UcdpPrioConflict_v26_1.csv.xz` | UCDP/PRIO Armed Conflict v26.1 | xz-compressed, unchanged | 43 → 32 KB |
| `UCDP_VPP_Dataset_v26_1.xlsx` | UCDP Violent Political Protest v26.1 | Copied unchanged | 28 KB |
| `archigos_4.1.txt.xz` | Archigos 4.1 | xz-compressed, unchanged | 118 → 92 KB |
| `reign_leader_list.csv.xz` | REIGN leader list | xz-compressed, unchanged | 54 → 44 KB |
| `gdp_gapminder_v32.csv.xz` | Gapminder GDP per capita v32 | Kept `name`, `year`, `gdp_pcap`; all rows | 963 → 317 KB |
| `fariss_gdp.rds`, `fariss_gdppc.rds`, `fariss_pop.rds` | Fariss et al. (2022) replication files | Re-saved with xz compression | 1,202 → 841 KB |
| `wpp2024_pop.rds` | `pop1dt` from the `wpp2024` R package (UN WPP 2024) | Kept total population (`pop`, thousands) for the 237 countries and areas, dropping regional and income aggregates; columns UN country code, name, year, population. Mapping to historical states is done by `load_population_data()` | 72 KB |
| `NMC-70-abridged.rds` | `NMC-70-abridged.dta`, COW National Material Capabilities v7.0 | Stata file saved as `.rds` | 1,031 → 187 KB |
| `sipri_milex_v1.2.rds` | `SIPRI-Milex-data-1949-2025_v1.2.xlsx` | See below | 900 → 121 KB |
| `estimates_milburden_20250429.rds`, `estimates_milex_con_20250429.rds` | Barnum et al. (2025) replication files | Re-saved with xz compression | 442 → 346 KB |

### SIPRI: the one reshaped file

The SIPRI workbook has sheets in a wide layout (one column per year).
The package uses two of them: "Constant (2024) US$" and "Share of GDP". 

In version 0.1.0, the package reshaped the workbook every time you called
`load_military_expenditure_data(dataset = "sipri")`. Now the same
reshaping is done once, in advance, and the package ships the result.
You get exactly the same data as before. It just loads faster and takes
less space.

## What is *not* done at this stage

Analytical decisions done in R include:

- converting country codes (COW, Gleditsch-Ward, V-Dem, ISO, country
  names);
- treating source-specific missing-value codes (e.g. SCAD's -99) as `NA`;
- removing duplicates (e.g. SCAD events repeated across locations);
- aggregating events to country-year, country-month, or country-day;
- defining onset and incidence variables.

## Updating a dataset

1. Download the new release from the official source into
   `data-raw/source/`.
2. If the file name or the columns changed, update `data-raw/extdata.R` and
   the loader in `R/`.
3. Run `source("data-raw/extdata.R")`.
4. Compare the loader output with the previous version and run the tests
   and `R CMD check`.
5. Record the new version in `inst/COPYRIGHTS`, the citation in
   `data-raw/contentiousR_bib.bib`, and the change in `NEWS.md`.
