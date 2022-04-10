require(tidyverse)
require(ggplot2)
require(patchwork)
require(ggsci)


d.EBC.c <- read.csv('./../../derivatives/matlab_processing/EBCcont.dat', header = FALSE) %>% 
  setNames(c('tstat','EBC')) %>% 
  as_tibble()
d.EBC.c

p.EBC <- d.EBC.c %>% 
  #filter(EBC < 100) %>% 
  ggplot(aes(y=EBC, x=tstat)) +
  geom_point(shape = 3, size = .5) +
  geom_smooth(method = 'glm', method.args = list(family = quasipoisson()), color='black', size = .1) +
  scale_x_continuous('T statistic of treatment effect of rtPA') +
  scale_y_continuous('Edge betweeness centrality') +
  theme_minimal(base_size = 6) +
  theme(legend.position = c(.8,.8)
        , legend.key.height = unit(.1,'cm')
        , legend.text = element_text(size = 2)
        , legend.title = element_text(size = 3)
        , legend.background = element_rect(fill = 'snow')
        , plot.background = element_rect(fill = "white", color = NA))

p.EBC
ggsave(filename = './../../derivatives/figures/R/TbyEBC_qb.png', units = 'cm', width = 4.5, height = 4.5, dpi = 600)


d.EBC.c %>% unique() %>% 
  glm(I(EBC) ~ tstat, data = ., family = quasipoisson(link = 'log'), ) %>% 
  tidy()

lm(tstat ~ sqrt(EBC), data =  d.EBC.c %>% unique()) %>% tidy()