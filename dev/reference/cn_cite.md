# Cite a bundled data source

Looks up the bundled bibliography (`cn_bib`) by keyword or BibTeX key
and returns the matching entries. Printing the result (e.g. at the
console) shows them as BibTeX text, ready to paste into your own `.bib`
file.

## Usage

``` r
cn_cite(x, column = c("keywords", "bibtexkey"))
```

## Arguments

- x:

  A search string. Matched against the `keywords` field by default
  (function names such as `"add_conflict()"` or `"load_gdp_data()"`, and
  `dataset =` values such as `"archigos"` or `"mec"`) as an exact match
  against one comma-separated keyword, or against BibTeX keys as a fixed
  substring match when `column = "bibtexkey"`. Neither is a regular
  expression.

- column:

  Which field to search: `"keywords"` (default) or `"bibtexkey"`.

## Value

A `bibentry` object (with the additional class `cn_citation`) holding
the matching entries. Its [`print()`](https://rdrr.io/r/base/print.html)
method displays them as BibTeX; all other `bibentry` methods, such as
[`format()`](https://rdrr.io/r/base/format.html) and
[`toBibtex()`](https://rdrr.io/r/utils/toLatex.html), work as usual.

## Examples

``` r
cn_cite("archigos")
#> @Article{goemansIntroducingArchigosDataset2009,                               
#>   title = {Introducing {{Archigos}}: {{A}} Dataset of Political Leaders},     
#>   author = {Henk E Goemans and Kristian Skrede Gleditsch and Giacomo Chiozza},
#>   year = {2009},                                                              
#>   journal = {Journal of Peace research},                                      
#>   volume = {46},                                                              
#>   number = {2},                                                               
#>   pages = {269--283},                                                         
#>   publisher = {Sage Publications Sage UK: London, England},                   
#>   keywords = {load_leader_data(), add_leader_data(), archigos},               
#> }                                                                             
cn_cite("add_conflict()")
#> @Misc{chenowethListCampaignsNAVCO2020,                                                                                                                
#>   title = {List of {{Campaigns}} in {{NAVCO}} 1.3},                                                                                                   
#>   author = {Erica Chenoweth and Christopher Wiley Shay},                                                                                              
#>   year = {2020},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/ON9XND},                                                                                                                         
#>   keywords = {conflict_data(), add_conflict(), navco1.3},                                                                                             
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{chenowethNAVCO21Dataset2019,                                                                                                                    
#>   title = {{{NAVCO}} 2.1 {{Dataset}}},                                                                                                                
#>   author = {Erica Chenoweth and Christopher Wiley Shay},                                                                                              
#>   year = {2019},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/MHOXDV},                                                                                                                         
#>   keywords = {conflict_data(), add_conflict(), navco2.1},                                                                                             
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{chenowethDaysRageIntroducing2018,                                                                                                            
#>   title = {Days of Rage: Introducing the {{NAVCO}} 3.0 Dataset},                                                                                      
#>   author = {Erica Chenoweth and Jonathan Pinckney and Orion Lewis},                                                                                   
#>   year = {2018},                                                                                                                                      
#>   journal = {Journal of Peace Research},                                                                                                              
#>   volume = {55},                                                                                                                                      
#>   number = {4},                                                                                                                                       
#>   pages = {524--534},                                                                                                                                 
#>   doi = {10.1177/0022343318759411},                                                                                                                   
#>   keywords = {conflict_data(), add_conflict(), navco3.0},                                                                                             
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{chenowethNAVCO30Dataset2019,                                                                                                                    
#>   title = {{{NAVCO}} 3.0 {{Dataset}}},                                                                                                                
#>   author = {Erica Chenoweth and Jonathan Pinckney and Orion A. Lewis},                                                                                
#>   year = {2019},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/INNYEO},                                                                                                                         
#>   keywords = {conflict_data(), add_conflict(), navco3.0},                                                                                             
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{beissingerRevolutionaryEpisodesDataset2022,                                                                                                     
#>   title = {Revolutionary {{Episodes Dataset}}},                                                                                                       
#>   author = {M Beissinger},                                                                                                                            
#>   year = {2022},                                                                                                                                      
#>   urldate = {2025-02-15},                                                                                                                             
#>   url = {https://web.archive.org/web/20250331220952/https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset},                        
#>   keywords = {conflict_data(), add_conflict(), beissinger},                                                                                           
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{ustyuzhaninRevolutionaryDatabase2026,                                                                                                           
#>   title = {Revolutionary Database (2000--2024)},                                                                                                      
#>   author = {Vadim Ustyuzhanin and Dmitrii Semichev and Leonid Grinin and Andrey Korotaev},                                                            
#>   year = {2026},                                                                                                                                      
#>   note = {Version 1.102},                                                                                                                             
#>   publisher = {HSE University, Centre for Stability and Risk Analysis},                                                                               
#>   url = {https://social.hse.ru/mr/rev_bd},                                                                                                            
#>   keywords = {conflict_data(), add_conflict(), csra},                                                                                                 
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{ustyuzhaninNewPossibilitiesAnalysing2026,                                                                                                    
#>   title = {New Possibilities for Analysing Revolution: Introducing a Database of Revolutions of the 21st Century},                                    
#>   author = {Vadim Ustyuzhanin and Dmitrii Semichev and Leonid Grinin and Andrey Korotaev},                                                            
#>   year = {2026},                                                                                                                                      
#>   journal = {Russian Sociological Review},                                                                                                            
#>   volume = {25},                                                                                                                                      
#>   number = {1},                                                                                                                                       
#>   pages = {9--61},                                                                                                                                    
#>   doi = {10.17323/1728-192X-2026-1-9-61},                                                                                                             
#>   keywords = {conflict_data(), add_conflict(), raqed},                                                                                                
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{ustyuzhaninRAQED2026,                                                                                                                           
#>   title = {Revolutionary and Quasi-revolutionary Episodes Dataset ({{RAQED}}) (2000--2025)},                                                          
#>   author = {Vadim Ustyuzhanin and Dmitrii Semichev and Leonid Grinin and Andrey Korotaev},                                                            
#>   year = {2026},                                                                                                                                      
#>   note = {Version 1.4},                                                                                                                               
#>   publisher = {HSE University, Centre for Stability and Risk Analysis},                                                                               
#>   url = {https://social.hse.ru/mr/rev_bd},                                                                                                            
#>   keywords = {conflict_data(), add_conflict(), raqed},                                                                                                
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{salehyanSocialConflictAfrica2012,                                                                                                            
#>   title = {Social Conflict in {{Africa}}: {{A}} New Database},                                                                                        
#>   author = {Idean Salehyan and Cullen S Hendrix and Jesse Hamner and Christina Case and Christopher Linebarger and Emily Stull and Jennifer Williams},
#>   year = {2012},                                                                                                                                      
#>   journal = {International Interactions},                                                                                                             
#>   volume = {38},                                                                                                                                      
#>   number = {4},                                                                                                                                       
#>   pages = {503--511},                                                                                                                                 
#>   publisher = {Taylor \& Francis},                                                                                                                   
#>   doi = {10.1080/03050629.2012.697426},                                                                                                               
#>   keywords = {conflict_data(), add_conflict(), scad},                                                                                                 
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{gleditschArmedConflict194620012002,                                                                                                          
#>   title = {Armed Conflict 1946-2001: {{A}} New Dataset},                                                                                              
#>   author = {Nils Petter Gleditsch and Peter Wallensteen and Mikael Eriksson and Margareta Sollenberg and Håvard Strand},                              
#>   year = {2002},                                                                                                                                      
#>   journal = {Journal of peace research},                                                                                                              
#>   volume = {39},                                                                                                                                      
#>   number = {5},                                                                                                                                       
#>   pages = {615--637},                                                                                                                                 
#>   publisher = {Sage Publications London},                                                                                                             
#>   doi = {10.1177/0022343302039005007},                                                                                                                
#>   keywords = {conflict_data(), add_conflict(), ucdp_prio},                                                                                            
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{svenssonViolentPoliticalProtest2022,                                                                                                         
#>   title = {Violent Political Protest: Introducing a New {{Uppsala Conflict Data Program}} Data Set on Organized Violence, 1989-2019},                 
#>   author = {I Svensson and S Schaftenaar and M Allansson},                                                                                            
#>   year = {2022},                                                                                                                                      
#>   journal = {Journal of Conflict Resolution},                                                                                                         
#>   volume = {66},                                                                                                                                      
#>   number = {9},                                                                                                                                       
#>   pages = {1703--1730},                                                                                                                               
#>   keywords = {conflict_data(), add_conflict(), ucdp_vpp},                                                                                             
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{clarkMassMobilizationProtest2016,                                                                                                               
#>   title = {Mass Mobilization Protest Data},                                                                                                           
#>   author = {David H. Clark and Patrick M. Regan},                                                                                                     
#>   year = {2016},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/HTTWYL},                                                                                                                         
#>   keywords = {conflict_data(), add_conflict(), mm},                                                                                                   
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Book{weidmannInternetPoliticalProtest2019,                                                                                                           
#>   title = {The Internet and Political Protest in Autocracies},                                                                                        
#>   author = {Nils B. Weidmann and Espen Geelmuyden Rød},                                                                                               
#>   year = {2019},                                                                                                                                      
#>   publisher = {Oxford University Press},                                                                                                              
#>   doi = {10.1093/oso/9780190918309.001.0001},                                                                                                         
#>   url = {https://mmadatabase.org/},                                                                                                                   
#>   keywords = {conflict_data(), add_conflict(), mmad},                                                                                                 
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{chenowethMajorEpisodesContention2026,                                                                                                        
#>   title = {The {{Major Episodes}} of {{Contention}} ({{MEC}}) Data Project: An Introduction},                                                         
#>   author = {Erica Chenoweth and Sooyeon Kang},                                                                                                        
#>   year = {2026},                                                                                                                                      
#>   month = {jul},                                                                                                                                      
#>   journal = {Journal of Peace Research},                                                                                                              
#>   volume = {63},                                                                                                                                      
#>   number = {4},                                                                                                                                       
#>   pages = {724--734},                                                                                                                                 
#>   doi = {10.1093/jopres/xjaf008},                                                                                                                     
#>   keywords = {conflict_data(), add_conflict(), mec},                                                                                                  
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{dahlMassMobilizationModern2026,                                                                                                              
#>   title = {Mass Mobilization in the Modern Era: Introducing the Opposition Movements and Groups ({{OMG}}) Dataset, 1789--2019},                       
#>   author = {Marianne Dahl and Sirianne Dahlum and Hanne Fjelde and Haakon Gjerløw and Carl Henrik Knutsen and Carina Strøm-Sedgwick and Tore Wig},    
#>   year = {2026},                                                                                                                                      
#>   journal = {Comparative Political Studies},                                                                                                          
#>   volume = {59},                                                                                                                                      
#>   number = {10},                                                                                                                                      
#>   pages = {2117--2158},                                                                                                                               
#>   doi = {10.1177/00104140251369330},                                                                                                                  
#>   keywords = {conflict_data(), add_conflict(), omg},                                                                                                  
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{vullersUnorganizedProtestIntroducing2026,                                                                                                    
#>   title = {(Un)organized Protest: Introducing the {{Anatomy}} of {{Resistance Campaigns}} 2.0},                                                       
#>   author = {Johannes Vüllers and Ingrid Vik Bakken and Thea Johansen and Christoph Dworschak and Charles Butcher and Jessica Maves Braithwaite},      
#>   year = {2026},                                                                                                                                      
#>   journal = {Journal of Peace Research},                                                                                                              
#>   volume = {63},                                                                                                                                      
#>   number = {3},                                                                                                                                       
#>   pages = {484--494},                                                                                                                                 
#>   doi = {10.1093/jopres/xjag013},                                                                                                                     
#>   keywords = {conflict_data(), add_conflict(), arc},                                                                                                  
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{butcherAnatomyResistanceCampaigns2026,                                                                                                          
#>   title = {The {{Anatomy}} of {{Resistance Campaigns}} ({{ARC}}) Data, Version 2.0},                                                                  
#>   author = {Charles Butcher and Johannes Vüllers and Ingrid {Vik Bakken} and Thea Johansen and Christoph Dworschak},                                  
#>   year = {2026},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/C0PUHP},                                                                                                                         
#>   keywords = {conflict_data(), add_conflict(), arc},                                                                                                  
#> }                                                                                                                                                     
cn_cite("gleditschArmedConflict194620012002", column = "bibtexkey")
#> @Article{gleditschArmedConflict194620012002,                                                                            
#>   title = {Armed Conflict 1946-2001: {{A}} New Dataset},                                                                
#>   author = {Nils Petter Gleditsch and Peter Wallensteen and Mikael Eriksson and Margareta Sollenberg and Håvard Strand},
#>   year = {2002},                                                                                                        
#>   journal = {Journal of peace research},                                                                                
#>   volume = {39},                                                                                                        
#>   number = {5},                                                                                                         
#>   pages = {615--637},                                                                                                   
#>   publisher = {Sage Publications London},                                                                               
#>   doi = {10.1177/0022343302039005007},                                                                                  
#>   keywords = {conflict_data(), add_conflict(), ucdp_prio},                                                              
#> }                                                                                                                       
```
