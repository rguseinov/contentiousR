# Load conflict and mobilization data

Loads one of thirteen conflict, protest, or revolutionary episode
datasets bundled with the package. `scad`, `ucdp_prio`, `ucdp_vpp`,
`mm`, `mmad`, `arc`, and `navco3.0` are returned at the country-year
level; their event- or conflict-level source rows are aggregated inside
this function.

`navco1.3`, `beissinger`, `raqed`, and `mec` return campaign or episode
records, and `omg` returns campaign-phase records; `navco2.1` returns
campaign-year rows. These sources can contain multiple rows for one
country-year. Use `add_conflict(aggregate = TRUE)` (the default) to
collapse them to country-year.

## Usage

``` r
conflict_data(
  start_year = 1945,
  end_year = 2013,
  dataset = c("navco1.3", "navco2.1", "beissinger", "raqed", "scad", "ucdp_prio",
    "ucdp_vpp", "mm", "mmad", "mec", "omg", "arc", "navco3.0"),
  coding_system = c("cow", "gw"),
  unit = c("year", "quarter", "month", "day")
)
```

## Source

NAVCO 2.1: [doi:10.7910/DVN/MHOXDV](https://doi.org/10.7910/DVN/MHOXDV)
.

Beissinger Revolutionary Episodes:
<https://web.archive.org/web/20250331220952/https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset>.

RAQED: <https://social.hse.ru/mr/rev_bd>.

OMG: <https://www.prio.org/data/39>.

ARC 2.0: [doi:10.7910/DVN/C0PUHP](https://doi.org/10.7910/DVN/C0PUHP) .

NAVCO 3.0: [doi:10.7910/DVN/INNYEO](https://doi.org/10.7910/DVN/INNYEO)
.

SCAD:
<https://www.strausscenter.org/ccaps-research-areas/social-conflict/database/>.

UCDP: <https://ucdp.uu.se/downloads/replication_data.html>.

MMAD: <https://mmadatabase.org/>.

MEC: Chenoweth and Kang (2026),
[doi:10.1093/jopres/xjaf008](https://doi.org/10.1093/jopres/xjaf008) ;
data release
[doi:10.7910/DVN/JQWQNW](https://doi.org/10.7910/DVN/JQWQNW) .

## Arguments

- start_year:

  First year to include.

- end_year:

  Last year to include.

- dataset:

  Dataset to load. One of:

  `"navco1.3"`

  :   NAVCO 1.3 campaign onsets. Coverage: 1900-2019.

  `"navco2.1"`

  :   NAVCO 2.1 campaign-years. Coverage: 1945-2013.

  `"beissinger"`

  :   Beissinger revolutionary episode onsets. Coverage: 1900-2014.

  `"raqed"`

  :   Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)
      v1.4, HSE University. Episode records. Coverage: 2000-2026.
      Prefix: `raqed_`.

  `"scad"`

  :   SCAD 2018 social conflict events, Africa and Latin America.
      Recorded event starts: 1989-2017 (the 1989 event continues into
      the source's 1990 coverage period). Prefix: `scad_`.

  `"ucdp_prio"`

  :   UCDP/PRIO Armed Conflict Dataset v26.1. Coverage: 1946-2025.
      Prefix: `ucdp_prio_`.

  `"ucdp_vpp"`

  :   UCDP Violent Political Protest Dataset v26.1. Coverage: 1989-2025.
      Prefix: `ucdp_vpp_`. Requires the `readxl` package.

  `"mm"`

  :   Mass Mobilization Project v4 (Clark and Regan). Coverage:
      1990-2020. Prefix: `mm_`.

  `"mmad"`

  :   Mass Mobilization in Autocracies Database. Coverage: 2003-2022.
      Prefix: `mmad_`.

  `"mec"`

  :   Major Episodes of Contention. Global coverage: 1955-2018. Episode
      records; prefix: `mec_`.

  `"omg"`

  :   Opposition Movements and Groups (OMG) v1. Campaign-phase records.
      Coverage: 1789-2019, for the countries coded so far. Prefix:
      `omg_`.

  `"arc"`

  :   Anatomy of Resistance Campaigns (ARC) 2.0: protest and
      armed-conflict events from SCAD and UCDP GED with the formal
      organizations that took part, Africa, Latin America and the
      Caribbean. Coverage: 1990-2018. Prefix: `arc_`.

  `"navco3.0"`

  :   NAVCO 3.0 events on 26 countries (1990-2012): actions by
      anti-government campaigns, states, and others, with tactics,
      goals, and state responses. Prefix: `nvc3.0_`.

- coding_system:

  Country coding system: `"cow"` or `"gw"`. `ucdp_prio` and `ucdp_vpp`
  use GW codes natively; when `coding_system = "cow"` they are converted
  via `countrycode` and countries without a COW equivalent are dropped.

- unit:

  Time unit of the returned data: `"year"` (default), `"quarter"`,
  `"month"`, or `"day"`. Event datasets are aggregated to this unit, and
  campaign and episode records are placed in the period of their start
  date. Records whose source date is less precise than `unit` (a quarter
  needs a month-precise date) are dropped with a message. `"navco1.3"`,
  `"navco2.1"`, `"ucdp_prio"`, and `"ucdp_vpp"` support `"year"` only.

## Value

A data frame. `navco1.3`, `beissinger`, `raqed`, and `mec` contain one
row per campaign or episode record; `omg` contains one row per campaign
phase; `navco2.1` contains campaign-year rows. The other datasets
contain one row per country-year.

## Details

All outputs use the requested `cow` or `gw` key and `year`.
Dataset-specific columns have a stable source prefix. A missing
country-year row is not created by this loader; after
[`add_conflict()`](https://rguseinov.github.io/contentiousR/dev/reference/add_conflict.md),
an unmatched year is `NA`, not an assumed zero.

SCAD is deduplicated to one row per event before country-year
aggregation. Its UCDP placeholder rows are excluded, and documented
negative codes for unknown death counts are treated as missing.

For UCDP/PRIO, `ucdp_prio_incidence` identifies any active conflict-year
and `ucdp_prio_onset` identifies a new episode using the source's
`start_date2`. The VPP source does not include an episode-start
variable; `ucdp_vpp_incidence` should be preferred. The legacy
`ucdp_vpp_onset` column is retained as an incidence alias for
compatibility.

The Mass Mobilization source mixes exact participant counts with text
such as ranges and inequalities. `mm_participants` is the maximum among
genuinely numeric values; `mm_participants_reported` preserves the
source strings.

**Country codes.** COW codes follow the package's COW panels: the German
Federal Republic is 255 and Czechoslovakia 316 (see
[`build_states_panel()`](https://rguseinov.github.io/contentiousR/dev/reference/build_states_panel.md)),
and Yemen is 678 up to 1990 and 679 from 1991. GW codes are derived from
COW by year: Germany is GW 255 up to 1945 and 260 after; Serbia is GW
340 up to 1915 and from June 2006, and 345 (Yugoslavia) in between;
Czechoslovakia is GW 315 and the Czech Republic 316; Yemen is GW 678;
Vietnam is 816 in both systems. The Mass Mobilization data's non-COW
codes (for example 341 for Kosovo and 525 for South Sudan) are mapped to
COW first.

MEC is kept at its published episode level. Its source `byear` becomes
`year`, `ccode` becomes `cow`, and all other source columns receive the
`mec_` prefix. `mec_episode` equals one for every returned episode
record. Fourteen left-censored records have an actual `mec_bdate` before
1955 while their source `byear` is 1955.

RAQED is kept at its published episode level. `year` is the episode's
`start_year`; all other source columns receive the `raqed_` prefix.
`raqed_onset` equals one for every episode, and `raqed_type_re`,
`raqed_type_re_q`, and `raqed_type_qre` are dummies for the source
`type` (revolutionary episode, questionable revolutionary episode, and
quasi-revolutionary episode). Abkhazia, Hong Kong, Palestine, Puerto
Rico, and Western Sahara have no COW code and are omitted.

OMG is kept at its published campaign-phase level. `year` is the phase's
`start_year`. `omg_phase_onset` equals one for every phase and
`omg_onset` equals one only for the first phase of a campaign
(`omg_campaign_id`), so later phases of an ongoing campaign are not
counted as new onsets. The source identifies countries by V-Dem
`country_id`; these are converted with `countrycode`. Serbia is mapped
to COW 345 / GW 340, Yemen to COW 678 before 1990 and 679 from 1990 (GW
678), and Piedmont-Sardinia to 325. Hong Kong, Palestine, and Western
Sahara are omitted. OMG covers only the countries coded so far, so a
missing country-year is not evidence that no campaign occurred.

NAVCO 3.0 records individual actions by anti-government campaigns
(`actor_id` 2), states (1), and international, non-aligned, and local
state actors. `nvc3.0_onset` is one when at least one campaign action
occurred in the period and zero when only actions by other actors did.
`nvc3.0_n_nonviolent`, `nvc3.0_n_violent`, and `nvc3.0_n_mixed` count
campaign actions by `tactical_choice`; `nvc3.0_n_regime_change` counts
campaign actions with regime-change goals; `nvc3.0_n_concessions`
(`st_posture` 1-3), `nvc3.0_n_repression` (5-7), and
`nvc3.0_n_lethal_repression` (7) count state responses. The source
records fatalities, injuries, and participants as numbers or ranges
("100-300"); the `_low` and `_high` columns sum (fatalities, injuries)
or take the maximum (participants in campaign actions) of the range
bounds.

Mass Mobilization codes country-years in which no protest occurred as a
row with `protest = 0`; these give `mm_onset = 0` and
`mm_n_protests = 0`. They have no date, so they are absent from
country-month and country-day data.

ARC 2.0 lists one row per event, with the participating ARC organization
IDs in a comma-separated `org_id` (missing when no formal organization
was identified). Events are assigned to the year in which they start and
aggregated to country-year: `arc_n_events` (split into
`arc_n_events_scad` and `arc_n_events_ged`), `arc_n_maximalist` and
`arc_n_nonmaximalist` (by the source's `maximalist` flag; every GED
event is maximalist), `arc_n_nonviolent_scad`, `arc_n_events_org` and
`arc_share_events_org` (events with at least one identified
organization), and `arc_n_orgs` (distinct organizations active in that
country-year).

## References

Chenoweth, E., & Shay, C. W. (2020). *List of Campaigns in NAVCO 1.3*.
Harvard Dataverse.
[doi:10.7910/DVN/ON9XND](https://doi.org/10.7910/DVN/ON9XND)

Chenoweth, E., & Shay, C. W. (2019). *NAVCO 2.1 Dataset*. Harvard
Dataverse. [doi:10.7910/DVN/MHOXDV](https://doi.org/10.7910/DVN/MHOXDV)

Beissinger, M. (2022). *Revolutionary Episodes Dataset*.

Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026). New
possibilities for analysing revolution: Introducing a database of
revolutions of the 21st century. *Russian Sociological Review*, 25(1),
9-61.
[doi:10.17323/1728-192X-2026-1-9-61](https://doi.org/10.17323/1728-192X-2026-1-9-61)

Ustyuzhanin, V., Semichev, D., Grinin, L., & Korotaev, A. (2026).
*Revolutionary and Quasi-revolutionary Episodes Dataset (RAQED)
(2000-2025)*, Version 1.4. HSE University, Centre for Stability and Risk
Analysis. <https://social.hse.ru/mr/rev_bd>

Salehyan, I., Hendrix, C. S., Hamner, J., Case, C., Linebarger, C.,
Stull, E., & Williams, J. (2012). Social conflict in Africa: A new
database. *International Interactions*, 38(4), 503-511.
[doi:10.1080/03050629.2012.697426](https://doi.org/10.1080/03050629.2012.697426)

Gleditsch, N. P., Wallensteen, P., Eriksson, M., Sollenberg, M., &
Strand, H. (2002). Armed conflict 1946-2001: A new dataset. *Journal of
Peace Research*, 39(5), 615-637.
[doi:10.1177/0022343302039005007](https://doi.org/10.1177/0022343302039005007)

Svensson, I., Schaftenaar, S., & Allansson, M. (2022). Violent political
protest: Introducing a new Uppsala Conflict Data Program data set on
organized violence, 1989-2019. *Journal of Conflict Resolution*, 66(9),
1703-1730.

Clark, D. H., & Regan, P. M. (2016). *Mass Mobilization Protest Data*.
Harvard Dataverse.
[doi:10.7910/DVN/HTTWYL](https://doi.org/10.7910/DVN/HTTWYL)

Weidmann, N. B., & Rød, E. G. (2019). *The Internet and Political
Protest in Autocracies*. Oxford University Press.

Chenoweth, E., & Kang, S. (2026). The Major Episodes of Contention (MEC)
Data Project: An introduction. *Journal of Peace Research*, 63(4),
724-734.
[doi:10.1093/jopres/xjaf008](https://doi.org/10.1093/jopres/xjaf008)

Dahl, M., Dahlum, S., Fjelde, H., Gjerløw, H., Knutsen, C. H.,
Strøm-Sedgwick, C., & Wig, T. (2026). Mass mobilization in the modern
era: Introducing the Opposition Movements and Groups (OMG) dataset,
1789-2019. *Comparative Political Studies*, 59(10), 2117-2158.
[doi:10.1177/00104140251369330](https://doi.org/10.1177/00104140251369330)

Vüllers, J., Bakken, I. V., Johansen, T., Dworschak, C., Butcher, C., &
Braithwaite, J. M. (2026). (Un)organized protest: Introducing the
Anatomy of Resistance Campaigns 2.0. *Journal of Peace Research*, 63(3),
484-494.
[doi:10.1093/jopres/xjag013](https://doi.org/10.1093/jopres/xjag013)

Chenoweth, E., Pinckney, J., & Lewis, O. (2018). Days of rage:
Introducing the NAVCO 3.0 dataset. *Journal of Peace Research*, 55(4),
524-534.
[doi:10.1177/0022343318759411](https://doi.org/10.1177/0022343318759411)

## Examples

``` r
navco <- conflict_data(1990, 2010, dataset = "navco2.1", coding_system = "cow")

scad  <- conflict_data(1995, 2015, dataset = "scad",      coding_system = "cow")

ucdp  <- conflict_data(1990, 2020, dataset = "ucdp_prio", coding_system = "gw")

mec   <- conflict_data(1990, 2010, dataset = "mec",       coding_system = "cow")

raqed <- conflict_data(2000, 2025, dataset = "raqed",     coding_system = "cow")

omg   <- conflict_data(1900, 2019, dataset = "omg",       coding_system = "gw")

arc   <- conflict_data(1990, 2018, dataset = "arc",       coding_system = "cow")

navco3 <- conflict_data(2011, 2012, dataset = "navco3.0", coding_system = "cow",
                        unit = "month")
```
