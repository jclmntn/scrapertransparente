# Pegando dados do site Dados Transparentes
# magrittr para pipes, purrr para map, rvest para scraping, 
# readr para ler e salvar arquivos em csv, stringr para manipular strings
# lubridate para manipular datas
library(readr)
library(magrittr)
library(rvest)
library(purrr)
library(stringr)
library(lubridate)
library(tibble)
library(dplyr)
library(ggplot2)

# Essa função troca o separador decimal

change_separator <- function(x){
  map(x, function(x) (str_replace(str_replace(x, "\\.", ""), "\\,", "\\.")))
}

# Essa função auxilia análise das datas que estão numa variável do javascript 
date_series <- function(x){
  x %>%
    str_remove_all(., "\\'") %>% 
    paste0(., '/2020') %>% 
    dmy
}

# Essa função coleta a data da última atualização
get_update <- function(){
  url <- "https://www.dadostransparentes.com.br/"
  read_html(url) %>% 
    html_nodes('iframe') %>% 
    extract(4) %>% 
    html_attr("src") %>% 
    paste0(url, .) %>% 
    read_html() %>%
    html_table() %>% 
    extract2(1) %>% 
    str_extract(., pattern = '\\d*\\/\\d*\\/\\d*') %>%
    dmy()
}  

# Essa função extrai o número de casos e os salva
get_casos <- function(dec = ".", save = TRUE){
  
  url <- "https://www.dadostransparentes.com.br/"
  
  casos <- read_html(url) %>% 
    html_nodes('iframe') %>% 
    extract(9) %>%
    html_attr("src") %>% 
    paste0(url, .) %>% 
    read_html %>%
    html_nodes(xpath = "//*[@id=\"table\"]") %>% 
    html_table(header = NA, dec = ".")%>% 
    .[[1]]
  
  if(dec =="."){
    casos <- change_separator(casos)
    if(save == TRUE){
      is_empty <- ifelse(length(str_detect(list.files("dados"), 'casos')) == 0,
                         yes = 0, no = str_detect(list.files("dados"), 'casos'))
      date <- ifelse(is_empty, 
                     str_extract(list.files('dados'), '\\d*\\-\\d*\\-\\d*'),
                     0)
      last_file <- ifelse(test = (date > 0), 
                          yes = get_update() - max(ymd(date)), 
                          no = get_update())
      if(last_file > 0){
        name <- paste0('dados/casos', get_update(), '.csv')
        
        casos %>% 
          as_tibble() %>%
          write_csv(., name)
        
        read_csv(name)
      }else{
        as_tibble(casos)
      }
    }else{
      as_tibble(casos)
    }
  }else{
    if(save == TRUE){
      is_empty <- ifelse(length(str_detect(list.files("dados"), 'casos')) == 0,
                         yes = 0, no = str_detect(list.files("dados"), 'casos'))
      date <- ifelse(is_empty, 
                     str_extract(list.file(dados), '\\d*\\-\\d*\\-\\d*'),
                     0)
      last_file <- ifelse(test = (date > 0), 
                          yes = get_update() - max(ymd(date)), 
                          no = get_update())
      if(last_file > 0){
        casos %>% 
          as_tibble() %>%
          write_csv(., paste0('casos', get_update(), '.csv'))
        
      }else{
        as_tibble(casos)
      }
    }else{
      as_tibble(casos)
    }
  }
}

# Essa função extrai o número de casos e os salva
get_obitos <- function(dec = ".", save = TRUE){
  url <- "https://www.dadostransparentes.com.br/"
  
  obitos <- read_html(url) %>% 
    html_nodes('iframe') %>% 
    extract(10) %>%
    html_attr("src") %>% 
    paste0(url, .) %>% 
    read_html %>%
    html_nodes(xpath = "//*[@id=\"table\"]") %>% 
    html_table(header = NA, dec = ".")%>% 
    .[[1]]
  
  if(dec =="."){
    obitos <- change_separator(obitos)
    if(save == TRUE){
      is_empty <- ifelse(length(str_detect(list.files("dados"), 'obitos')) == 0,
                         yes = 0, no = str_detect(list.files("dados"), 'obitos'))
      date <- ifelse(is_empty, 
                     str_extract(list.file(dados), '\\d*\\-\\d*\\-\\d*'),
                     0)
      last_file <- ifelse(test = (date > 0), 
                          yes = get_update() - max(ymd(date)), 
                          no = get_update())
      if(last_file > 0){
        name <- paste0('dados/obitos', get_update(), '.csv')
        
        obitos %>% 
          as_tibble() %>%
          write_csv(., name)
        
        read_csv(name)
      }else{
        as_tibble(obitos)
      }
    }else{
      as_tibble(obitos)
    }
  }else{
    if(save == TRUE){
      is_empty <- ifelse(length(str_detect(list.files("dados"), 'obitos')) == 0,
                         yes = 0, no = str_detect(list.files("dados"), 'obitos'))
      date <- ifelse(is_empty, 
                     str_extract(list.file(dados), '\\d*\\-\\d*\\-\\d*'),
                     0)
      last_file <- ifelse(test = (date > 0), 
                          yes = get_update() - max(ymd(date)), 
                          no = get_update())
      if(test > 0){
        obitos %>% 
          as_tibble() %>%
          write_csv(., paste0('obitos', get_update(), '.csv'))
        
      }else{
        as_tibble(obitos)
      }
    }else{
      as_tibble(obitos)
    }
  }
}

# Essa função extrai a série de casos e óbitos diários (acumulada ou não)

get_series <- function(type = 0){
  url <- "https://www.dadostransparentes.com.br/"
  
  if(type == 0){
    object <- read_html(url) %>% 
      html_nodes('iframe') %>% 
      extract(7) %>%
      html_attr("src") %>% 
      paste0(url, .) %>% 
      read_html() %>% 
      html_node('body') %>%
      html_node('script') %>% 
      html_text() %>% 
      str_extract_all('\\[(.*?)\\]') %>% 
      extract2(1) %>% 
      .[c(1, 2, 5)] %>% 
      str_split(pattern = ",") %>% 
      map(., function(x) str_remove_all(x, '\\[*\\]*'))
    
    names(object) <- c('Casos', 'Óbitos', 'Date')
    
    object %>% 
      as_tibble() %>% 
      mutate(Casos = as.integer(Casos),
             Óbitos = as.integer(Óbitos),
             Date = suppressWarnings(date_series(Date)))
  }else{
    object <- read_html(url) %>% 
      html_nodes('iframe') %>% 
      extract(8) %>%
      html_attr("src") %>% 
      paste0(url, .) %>% 
      read_html() %>% 
      html_node('body') %>%
      html_node('script') %>% 
      html_text() %>% 
      str_extract_all('\\[(.*?)\\]') %>% 
      extract2(1) %>% 
      .[c(1, 2, 5)] %>% 
      str_split(pattern = ",") %>% 
      map(., function(x) str_remove_all(x, '\\[*\\]*'))
    
    names(object) <- c('Casos', 'Óbitos', 'Date')
    
    object %>% 
      as_tibble() %>% 
      mutate(Casos = as.integer(Casos),
             Óbitos = as.integer(Óbitos),
             Date = suppressWarnings(date_series(Date)))
  }
}


# gerando casos do dia
get_casos()

# gerando obitos do dia

get_obitos()

# gerando série acumulada

get_series()

# gerando série de casos diáris

get_series(1)

