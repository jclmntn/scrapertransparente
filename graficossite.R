# esse script gera os gráficos disponibilizados no site e os salva numa pasta
# denominada graficos

source('dadostransparentes.R', encoding = 'UTF-8')
library(ggplot2)
library(forcats)

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
  ggplotly()

# séries lado a lado

acumulados %>% 
  tidyr::gather(key = 'Série', value = 'Número', -Date) %>% 
  ggplot(., aes(x = Date)) +
  geom_line(aes(y = Número, colour = Série), size = 1, show.legend = FALSE) +
  facet_wrap(vars(Série), scales = 'free_y') +
  scale_y_continuous(labels = scales::number) +
  scale_x_date(date_breaks = "4 weeks", date_labels = "%b %w") +
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
  scale_x_date(date_breaks = "4 weeks", date_labels = "%b %w") +
  labs(x = 'Data',
       y = 'Número',
       title = 'Casos e óbitos novos',
       subtitle = 'As séries foram postas lado a lado',
       caption = 'Fonte: www.dadostransparentes.com.br'
  ) 
  ggsave('graficos/novosladoalado.png')

# trabalhando com o que foi coletado até hje 16/06/2020
  
casos <- merge_x('casos') %>% 
  mutate(Data = as_date(Data)) %>% 
  filter(Data == max(Data))

obitos <- merge_x('obitos') %>% 
  mutate(Data = as_date(Data)) %>% 
  filter(Data == max(Data))

# distribuição por uf
casos %>% 
  mutate(UF = fct_reorder(UF, -Acumulados)) %>% 
  ggplot(aes(x = UF, y = Acumulados)) + 
  geom_col() +
  labs(
    y = 'Número',
    title = paste('Casos acumulados', '-', format(Sys.Date(), "%d/%m/%Y" )),
    caption = 'jclmntn / dados: www.dadostransparentes.com.br'
  )


obitos %>% 
  mutate(UF = fct_reorder(UF, -Acumulados)) %>% 
  ggplot(aes(x = UF, y = Acumulados)) + 
  geom_col() +
  labs(
    y = 'Número',
    title = paste('Óbitos acumulados', '-', format(Sys.Date(), "%d/%m/%Y" )),
    caption = 'jclmntn / dados: www.dadostransparentes.com.br'
  )

# taxa de mortalidade por estado
theme_set(theme_minimal())
left_join(casos, obitos, by = 'UF') %>% 
  select(
    'Data' = Data.x, 
    UF, 'caso_acum' = Acumulados.x,
    'obito_acum' = Acumulados.y
    ) %>% 
  mutate(razao_mortalidade = (obito_acum/caso_acum),
         UF = fct_reorder(UF, -razao_mortalidade)) %>% 
  ggplot(aes(x = UF, y = razao_mortalidade)) +
  geom_col(color ='firebrick', fill = 'firebrick', alpha = 0.7) +
  labs(
    y = 'Razao entre Óbitos e Casos, %',
    title = paste('Razão entre óbitos e casos por unidade federativa', '-', format(Sys.Date(), "%d/%m/%Y" )),
    caption = 'jclmntn / dados: www.dadostransparentes.com.br'
  ) +
  scale_y_continuous(labels = scales::percent)

# graficos de diagnostico de dados


casos_total <- merge_x('casos') %>% 
  mutate(Data = as_date(Data))


casos_total %>% 
  filter(`Casos por  milhão de hab.` <=5000) %>% 
  ggplot(aes(x = Data, y = `Casos por  milhão de hab.`, colour = UF)) +
  geom_line() +
  geom_text(aes(label = UF))



obitos_total <- merge_x('obitos') %>% 
  mutate(Data = as_date(Data))


obitos_total %>% 
  ggplot(aes(x = Data, y = log(Acumulados), colour = UF)) +
  geom_line()

# identificando problemas com calculos de casos por milhão de habitantes


## grafico especial

url <- 'https://pt.wikipedia.org/wiki/Subdivis%C3%B5es_do_Brasil'

estados <- read_html(url) %>%
  html_node(css = '.wikitable') %>% 
  html_table(dec = ',') %>% 
  select(`Unidade federativa`, UF = `Abreviação`)

casos_graf <- left_join(casos_total, estados)

# É a mesma base, só que sem a unidade federativa, dessa maneira, na hora 
# que o facet for gerado, o programa mantém as outras linhas no fundo
casos_graf_fundo <- casos_graf %>% 
  select(-`Unidade federativa`)
theme_set(theme_minimal())

# Adição do ponto no final

casos_ponto_fundo <- casos_graf %>%
  group_by(UF) %>% 
  filter(Acumulados == max(Acumulados)) %>% 
  ungroup()

# Nomes 

casos_nomes <- casos_graf %>% 
  mutate(Acumulados = max(Acumulados),
         Data = min(Data)) %>% 
  group_by(UF) %>%
  filter(Acumulados == max(Acumulados))

espec <- casos_graf %>% 
  ggplot(aes(x = Data, y = log10(Acumulados))) +
  geom_line(data = casos_graf_fundo, aes(group = UF), size = 0.50, color = 'gray80') +
  geom_line(color = '#f58742', size = 1) +
  geom_point(data = casos_ponto_fundo, color = '#f58742', fill = '#f59e42') + 
  facet_wrap(vars(`Unidade federativa`), ncol = 5, scales = 'free_y') +
  geom_text(data = casos_nomes, 
            aes(label = `Unidade federativa`), 
            vjust = "inward", 
            hjust = "inward",
            fontface = 'bold',
            color = '#f58742',
            size = 2.1) +
  theme(plot.title = element_text(size = rel(1), face = "bold"),
        plot.subtitle = element_text(size = rel(0.7)),
        plot.caption = element_text(size = rel(1)),
        # turn off the strip label and tighten the panel spacing
        strip.text = element_blank(),
        panel.spacing.x = unit(-0.05, "lines"),
        panel.spacing.y = unit(0.3, "lines"),
        axis.text.y = element_text(size = rel(0.5)),
        axis.title.x = element_text(size = rel(1)),
        axis.title.y = element_text(size = rel(1)),
        axis.text.x = element_text(size = rel(0.5)),
        legend.text = element_text(size = rel(1))) +
  labs(
    y = 'Casos acumulados (escala em log10)',
    title = 'Número de Casos Acumulados de COVID-19',
    subtitle = paste0('Período de 08/06/2020 a ', format(max(casos_graf$Data), format(max(casos_graf$Data), "%d/%m/%Y"))),
    caption = 'jclmntn / dados: www.dadostransparentes.com.br'
  )

ggsave('graficos/casos_covid_uf.png', espec, width = 10, height = 12, dpi = 300)

  

## usando casos por milhão de habitantes


url <- 'https://pt.wikipedia.org/wiki/Subdivis%C3%B5es_do_Brasil'

estados <- read_html(url) %>%
  html_node(css = '.wikitable') %>% 
  html_table(dec = ',') %>% 
  select(`Unidade federativa`, UF = `Abreviação`)

casos_graf <- left_join(casos_total, estados)

# É a mesma base, só que sem a unidade federativa, dessa maneira, na hora 
# que o facet for gerado, o programa mantém as outras linhas no fundo
casos_graf_fundo <- casos_graf %>% 
  select(-`Unidade federativa`)
theme_set(theme_minimal())

# Adição do ponto no final

casos_ponto_fundo <- casos_graf %>%
  group_by(UF) %>% 
  filter(Data == max(Data)) %>% 
  ungroup()

# Nomes 

casos_nomes <- casos_graf %>% 
  mutate(`Casos por  milhão de hab.` = max(`Casos por  milhão de hab.`),
         Data = min(Data)) %>% 
  group_by(UF) %>%
  filter(`Casos por  milhão de hab.` == max(`Casos por  milhão de hab.`))

espec <- casos_graf %>% 
  ggplot(aes(x = Data, y = (`Casos por  milhão de hab.`))) +
  geom_line(data = casos_graf_fundo, aes(group = UF), size = 0.50, color = 'gray80') +
  geom_line(color = '#f58742', size = 1) +
  geom_point(data = casos_ponto_fundo, color = '#f58742', fill = '#f59e42') + 
  facet_wrap(vars(`Unidade federativa`), ncol = 5, scales = 'free_y') +
  geom_text(data = casos_nomes, 
            aes(label = `Unidade federativa`), 
            vjust = "inward", 
            hjust = "inward",
            fontface = 'bold',
            color = '#f58742',
            size = 2.1) +
  theme(plot.title = element_text(size = rel(1), face = "bold"),
        plot.subtitle = element_text(size = rel(0.7)),
        plot.caption = element_text(size = rel(1)),
        # turn off the strip label and tighten the panel spacing
        strip.text = element_blank(),
        panel.spacing.x = unit(-0.05, "lines"),
        panel.spacing.y = unit(0.3, "lines"),
        axis.text.y = element_text(size = rel(0.5)),
        axis.title.x = element_text(size = rel(1)),
        axis.title.y = element_text(size = rel(1)),
        axis.text.x = element_text(size = rel(0.5)),
        legend.text = element_text(size = rel(1))) +
  labs(
    y = 'Número de Casos por milhão de habitantes',
    title = 'Casos de COVID-19 por milhão de habitantes',
    subtitle = paste0('Período: 08/06/2020 a ', format(max(casos_graf$Data), format(max(casos_graf$Data), "%d/%m/%Y"))),
    caption = 'jclmntn / dados: www.dadostransparentes.com.br'
  )

ggsave('graficos/casos_hab_uf.png', espec, width = 10, height = 12, dpi = 300)


