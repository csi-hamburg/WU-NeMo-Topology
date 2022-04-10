d <- read.csv(paste0('./../../derivatives/NeMo_output/GGP', asz, '.csv'), header = TRUE)

data.clinical <- gdata::read.xls('./../../clinical/KeyStudyData_21-Nov-2017_short_version.xls', sheet = 1) %>%   mutate(Subject.ID = paste0(Subject.ID, '-v03')) %>% 
  filter(Subject.ID %in% unique(d$ID)) %>% droplevels() %>% 
  rename('ID' = Subject.ID
         , 'mRS' = Visit.5.MRS
         , 'age' = Demographic.data..age
         , 'NIHSS' = Visit.0.NIHSS.sum.score) %>% 
  mutate(goodOutcome = mRS <= 1) %>% 
  dplyr::select(ID, mRS, goodOutcome,age, NIHSS)

dd <- d %>% pivot_longer(starts_with('GGP'), names_to = 'temp', values_to = 'GGP') %>% 
  separate(temp, into = c('bla', 'visitGGP')) %>% 
  filter(lesionvolume_V0 > 0 & lesionvolume_V3 > 0) %>% 
  pivot_longer(starts_with('lesionvolume'), names_to = 'temp', values_to = 'lesionvolume') %>% 
  separate(temp, into = c('blubb', 'visitvol')) %>% 
  dplyr::filter(visitGGP == visitvol) %>% 
  select(-c(bla, blubb, visitvol, lesion_supratentorial, lesion_location)) %>% 
  rename(visit = visitGGP) %>% 
  mutate(lab = factor(lab, levels = c('efficiency', 'clustering'))) %>% 
  filter(!ID %in% c('1-14-006-v03','2-01-070-v03', '5-04-010-v03')) %>%  ## unsatisfactory stroke lesion segmentation
  merge(data.clinical)

remove(data.clinical, d)

save.image('prepdata.RData')
