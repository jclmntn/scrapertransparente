# Pegando dados do site Dados Transparentes

# Para manipular os dados, usar pipes e funcao map
library(tidyverse)

# Para ler o HTML do site
library(rvest)

# Definindo url e nomes
url_casos <- 'http://www.dadostransparentes.com.br/tabela1.php'
url_obitos <- 'http://www.dadostransparentes.com.br/tabela2.php'
nomes <- c('casos', 'obitos')

# colococando as url em listas para utilizar na fun??o map
links <- list(url_casos, url_obitos)

# aqui eu uso fun??es do rvest e tibble para ler o conteudo do site
# o xpath foi obtido inspecionando os elementos do site

get_web_data <- function(x){
  read_html(x) %>% 
    html_nodes(xpath = "//*[@id=\"table\"]") %>% 
    html_table(header = NA, dec = ",") %>% 
    .[[1]] %>% 
    map(., function(x) (str_replace(str_replace(x, "\\.", ""), "\\,", "\\."))) %>% 
    as_tibble()
}


# usando fun??es do purr para criar os dois objetos e salv?-los em csvs

dados <- map(links, get_web_data)

# salvando csvs

map2(
  dados, 
  nomes, 
  function(x, y) write_csv(x, paste0("dados/", y, lubridate::today(), '.csv' ))
  )

# teste

# read_csv(paste0('casos', lubridate::today(), '.csv'))
