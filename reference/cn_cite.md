# Cite a bundled data source

Looks up the bundled bibliography (`cn_bib`) by keyword or BibTeX key
and prints the matching entries as BibTeX text, ready to paste into your
own `.bib` file.

## Usage

``` r
cn_cite(x, column = c("keywords", "bibtexkey"))
```

## Arguments

- x:

  A search string. Matched against the `keywords` field by default
  (function names such as `"add_conflict()"` or `"load_gdp_data()"`, and
  `dataset =` values such as `"archigos"` or `"mec"`), or against BibTeX
  keys when `column = "bibtexkey"`. The match is a fixed substring
  match, not a regular expression.

- column:

  Which field to search: `"keywords"` (default) or `"bibtexkey"`.

## Value

Invisibly returns the matching `bibentry` objects. Called for the side
effect of printing BibTeX text.

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
#>   author = {Erica Chenoweth and \relax CW Shay},                                                                                                     
#>   year = {2020},                                                                                                                                      
#>   publisher = {Harvard Dataverse},                                                                                                                    
#>   doi = {10.7910/DVN/ON9XND/PTMCCV},                                                                                                                  
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
#> @Misc{beissingerRevolutionaryEpisodesDataset2022,                                                                                                     
#>   title = {Revolutionary {{Episodes Dataset}}},                                                                                                       
#>   author = {M Beissinger},                                                                                                                            
#>   year = {2022},                                                                                                                                      
#>   urldate = {2025-02-15},                                                                                                                             
#>   url = {https://mbeissinger.scholar.princeton.edu/revolutionary-episodes-dataset},                                                                   
#>   keywords = {conflict_data(), add_conflict(), beissinger},                                                                                           
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Misc{ustyuzhaninRevolutionsDataset2025,                                                                                                              
#>   title = {Revolutions Dataset},                                                                                                                      
#>   author = {Vadim Ustyuzhanin and Andrey Korotayev and Daniil Semichev},                                                                              
#>   year = {2025},                                                                                                                                      
#>   publisher = {HSE University, Centre for Stability and Risk Analysis},                                                                               
#>   url = {https://social.hse.ru/en/mr/rev_bd/},                                                                                                        
#>   keywords = {conflict_data(), add_conflict(), csra},                                                                                                 
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
#>   doi = {10.1177/0022002711435330},                                                                                                                   
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
#>   url = {https://mmadatabase.org/},                                                                                                                   
#>   keywords = {conflict_data(), add_conflict(), mmad},                                                                                                 
#> }                                                                                                                                                     
#>                                                                                                                                                       
#> @Article{chenowethMajorEpisodesContention2026,                                                                                                        
#>   title = {The {{Major Episodes}} of {{Contention}} ({{MEC}}) Data Project: An Introduction},                                                         
#>   author = {Erica Chenoweth and Sooyeon Kang},                                                                                                        
#>   year = {2026},                                                                                                                                      
#>   journal = {Journal of Peace Research},                                                                                                              
#>   doi = {10.1093/jopres/xjaf008},                                                                                                                     
#>   keywords = {conflict_data(), add_conflict(), mec},                                                                                                  
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
