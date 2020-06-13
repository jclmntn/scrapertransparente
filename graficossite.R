# esse script gera os gráficos disponibilizados no site e os salva numa pasta
# denominada graficos

source('dadostransparentes.R')

# mostrando série acumulada e gerando gráfico
acumulados <- get_series()
theme_set(theme_minimal())

acumulados %>% 
  ggplot(., aes(x = Date)) +
  geom_line(aes(y = Casos, colour = 'Casos'), size = 1) +
  geom_line(aes(y = Óbitos, colour = 'Óbitos'), size = 1) +
  scale_y_continuous(labels = scales::number) +
  labs(x = 'Data',
       y = 'Número',
       title = 'Casos e óbitos acumulados',
       color = '',
       caption = 'Fonte: www.dadostransparentes.com.br')
  ggsave('graficos/acumuladooriginal.png')

# séries lado a lado

acumulados %>% 
  tidyr::gather(key = 'Série', value = 'Número', -Date) %>% 
  ggplot(., aes(x = Date)) +
  geom_line(aes(y = Número, colour = Série), size = 1, show.legend = FALSE) +
  facet_wrap(vars(Série), scales = 'free_y') +
  scale_y_continuous(labels = scales::number) +
  scale_x_date(date_breaks = "3 weeks", date_labels = "%b %w") +
  labs(x = 'Data',
       y = 'Número',
       title = 'Casos e óbitos acumulados',
       subtitle = 'As séries foram postas lado a lado',
       caption = 'Fonte: www.dadostransparentes.com.br')
  ggsave('graficos/acumuladoladoalado.png')

# mostrando série de casos novos

novos <- get_series(1)
novos %>% 
  ggplot(., aes(x = Date)) +
  geom_line(aes(y = Casos, colour = 'Casos'), size = 1) +
  geom_line(aes(y = Óbitos, colour = 'Óbitos'), size = 1) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = 'Data',
       y = 'Número',
       title = 'Casos e óbitos novos',
       color = '',
       caption = 'Fonte: www.dadostransparentes.com.br')
  ggsave('graficos/novosoriginal.png')

# séries lado a lado

novos %>% 
  tidyr::gather(key = 'Série', value = 'Número', -Date) %>% 
  ggplot(., aes(x = Date)) +
  geom_line(aes(y = Número, colour = Série), size = 1, show.legend = FALSE) +
  facet_wrap(vars(Série), scales = 'free_y') +
  scale_y_continuous(labels = scales::number) +
  scale_x_date(date_breaks = "3 weeks", date_labels = "%b %w") +
  labs(x = 'Data',
       y = 'Número',
       title = 'Casos e óbitos novos',
       subtitle = 'As séries foram postas lado a lado',
       caption = 'Fonte: www.dadostransparentes.com.br'
  ) 
  ggsave('graficos/novosladoalado.png')
