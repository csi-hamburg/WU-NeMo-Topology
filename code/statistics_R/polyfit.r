require(tidyverse)
require(ggplot2)
d.polyfit <- read.csv('./../NeMo_analysis_matlab/polyfit.dat', header = FALSE) %>% 
  setNames(c('x','y')) %>% 
  as_tibble()

p.polyfit <- d.polyfit %>% 
  ggplot(aes(x=x, y=y)) +
  geom_point(shape = 1, size = .3) +
  geom_smooth(method = 'lm', formula = y ~ x + I(x^2), se = TRUE, color = 'black', size = .1) +
  scale_x_continuous('Structural disconnection at baseline') +
  scale_y_continuous('T statistic of treatment effect of rtPA') +
  theme_minimal(base_size = 6) +
  theme(legend.position = c(.8,.8)
        , legend.key.height = unit(.1,'cm')
        , legend.text = element_text(size = 2)
        , legend.title = element_text(size = 3)
        , legend.background = element_rect(fill = 'snow')
        , plot.background = element_rect(fill = "white", color = NA))
ggsave(filename = './../../derivatives/figures/R/polyfit.png', units = 'cm', width = 9, height = 4.5, dpi = 600)


lm(y ~ x + I(x^2), d = d.polyfit) %>% summary()
