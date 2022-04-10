require(tidyverse)
require(ggplot2)
require(patchwork)
require(ggsci)

z <- 1.96
nn <- 1e4

path <- "./../../derivatives/matlab_processing/"
files <- dir(path = path, pattern = "p_t_n.*\\.dat")

data <- files %>% 
  map(~file.path(path, .)) %>% 
  map(read_csv, col_names=FALSE) %>%  
  map(setNames, c('t', 'p', 'n')) %>% 
  bind_rows(.id = 'source') %>% 
  mutate(source = as.numeric(source)
         , file = map_chr(source, ~files[.])
         , file = factor(forcats::fct_relevel(as.factor(file), 'p_t_n_vol0_dvol.dat', 'p_t_n_dvol.dat', 'p_t_n_vol0.dat'), ordered = TRUE))
  
data %>% print(n=Inf)

breaks <- 10^(-10:10)
minor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))

t.plot <- c(1.0, 1.5, 2.1)


p.pvalue <- data %>% 
  mutate(pmin = (p+z^2/(2*nn)) / (1+z^2/nn) - z/(1+z^2/nn)*sqrt(p*(1-p)/nn+z^2/(4*nn^2))
         , pmax = (p+z^2/(2*nn)) / (1+z^2/nn) + z/(1+z^2/nn)*sqrt(p*(1-p)/nn+z^2/(4*nn^2))) %>% 
  ggplot(aes(x=t, y=p)) +
  geom_ribbon(aes(ymin = pmin, ymax = pmax, group = file, alpha = file), size = .2, color='black') +
  geom_line(aes(linetype = file, size = file)) +
  geom_point(shape = 21, fill = 'white', size = .3, alpha = 1, stroke=.25) + 
  geom_point(data = subset(data, t%in% t.plot), aes(), fill='black', shape = 21, size = .3, stroke=.25) +
  geom_hline(yintercept = 0.05, size = .1) +
  annotate(geom='text', x=1, y=0.06, label='P 0.05', hjust = -0.25, vjust=0, size = 2) +
  annotation_logticks(sides = 'l', size = .1) +
  scale_x_continuous('Network-based statistics threshold') + 
  scale_y_continuous('P value (FWER)', trans = 'log10'
                     ,breaks = breaks, minor_breaks = minor_breaks, labels = scales::number_format(accuracy = 0.0001)) +
  scale_color_discrete(labels = files) +
  scale_alpha_manual(values = c(.5, rep(.2, length(files)-1))) +
  scale_size_manual(values = c(.3, rep(.15, length(files)-1))) +
  scale_linetype_manual('Adjustment for lesion volume', values = c('solid', 'longdash', 'twodash', 'dotted')) +
  guides(fill='none', color='none', alpha = 'none', linetype = 'none', size = 'none') + 
  theme_minimal()
p.pvalue

segs <- lapply(t.plot, function(tt){c(geom_segment(data = data %>% filter(t==tt), aes(x=t, xend=t, y=0, yend=n), color='grey', linetype = 'dashed')
                                      ,geom_segment(data = data %>% filter(t==tt), aes(x=min(data$t), xend=t, y=n, yend=n), color='grey', linetype = 'dashed')
                                      , geom_text(data = data %>% filter(t==tt), aes(label=n, x = min(data$t)), hjust = 1.5)
                                      , geom_text(data = data %>% filter(t==tt) %>% dplyr::select(t) %>% unique(), aes(label=t, x=t, y = 0), vjust = 1.5, inherit.aes = FALSE))})
require(ggsci)
p.n <- data %>% 
  ggplot(aes(x=t, y=n)) +
  geom_line(aes(linetype = file, size = file)) +
  geom_point(aes(), fill = 'white', shape = 21, size = .3, alpha = 1, stroke=.25) + 
  geom_point(data = subset(data, t%in% t.plot), aes(), fill='black', shape = 21, size = .3, stroke=.25) +
  scale_x_continuous('Network-based statistics threshold') + 
  scale_y_continuous('# Edges', labels = scales::number_format(accuracy = 1)) +
  scale_linetype_manual('Adjustment for lesion volume', values = c('solid', 'longdash', 'twodash', 'dotted'), labels = c(expression('V'[0]~'+'~Delta~'V')
                                                                                                                         , expression(Delta~'V')
                                                                                                                         , expression('V'[0])
                                                                                                                         , 'none')) +
  scale_alpha_manual(values = c(.5, rep(.2, length(files)-1))) +
  scale_size_manual(values = c(.3, rep(.15, length(files)-1))) +
  #scale_fill_manual(values = c('grey', 'white')) +
  guides(fill='none', alpha='none', size = 'none') + 
  theme_minimal() +
  theme(legend.position = c(.5, .5)
        , legend.background = element_rect(fill = 'snow'))
p.n
require(patchwork)
p.n + p.pvalue + plot_layout(ncol = 1, guides = 'keep') & theme_minimal(base_size=6) & theme(legend.position = c(.75,.85)
                                                                                             , legend.key.height = unit(.1,'cm')
                                                                                             , legend.key.width = unit(1, 'cm')
                                                                                             , legend.text = element_text(size = 4)
                                                                                             , legend.text.align = 0
                                                                                             , legend.title = element_text(size = 4)
                                                                                             , legend.background = element_rect(fill = 'snow')
                                                                                             , plot.background = element_rect(fill = "white", color = NA))
ggsave(filename = './../../derivatives/figures/R/NBS_p_n_vert.png', units = 'cm', width = 4.5, height = 9, dpi = 600)
