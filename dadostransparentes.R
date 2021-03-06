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

# Essa função auxilia análise das datas que estão numa variável do javascript 
# date_series <- function(x){
#   x %>%
#     str_remove_all(., "\\'") %>% 
#     paste0(., '/2020') %>% 
#     dmy
# }

# Essa função coleta a data da última atualização
get_update <- function(){
  url <- "https://www.dadostransparentes.com.br/"
  read_html(url) %>% 
    html_nodes('iframe') %>% 
    extract(6) %>% 
    html_attr("src") %>% 
    paste0(url, .) %>% 
    read_html() %>%
    html_table() %>% 
    extract2(1) %>% 
    str_extract(., pattern = '\\d*\\/\\d*\\/\\d*') %>%
    dmy()
}  

# Essa função extrai o número de casos e os salva
get_casos <- function(save = TRUE){
  
  url_dados <- "https://www.dadostransparentes.com.br/relatorios.php"
  url_global <- 'https://www.dadostransparentes.com.br/'
  
  casos <- read_html(url_dados) %>% 
    html_nodes('iframe') %>% 
    extract(2) %>%
    html_attr("src") %>% 
    paste0(url_global, .) %>% 
    read_html %>%
    html_nodes(xpath = "//*[@id=\"example\"]") %>% 
    html_table(header = NA, dec = ",")%>% 
    .[[1]] %>% 
    mutate(across(2:6, ~str_replace_all(str_replace_all(., "\\.", ""), ",", "\\.")))
  
  if(save == TRUE){
    is_empty <- length(str_detect(list.files("dados"), 'casos')) == 0
    
    existent <- str_detect(list.files('dados'), 'casos')
    
    date <- ifelse(is_empty, 
                   0,
                   max(ymd(str_extract(list.files('dados')[existent], '\\d*\\-\\d*\\-\\d*'))))
    last_file <- ifelse(test = (date > 0), 
                        yes = get_update() - as_date(date), 
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
}

# Essa função extrai o número de casos e os salva
get_obitos <- function(save = TRUE){
  url_dados <- "https://www.dadostransparentes.com.br/relatorios.php"
  url_global <- 'https://www.dadostransparentes.com.br/'
  
  obitos <- read_html(url_dados) %>% 
    html_nodes('iframe') %>% 
    extract(3) %>%
    html_attr("src") %>% 
    paste0(url_global, .) %>% 
    read_html %>%
    html_nodes(xpath = "//*[@id=\"example\"]") %>% 
    html_table(header = NA, dec = ",")%>% 
    .[[1]] %>% 
    mutate(across(2:6, ~str_replace_all(str_replace_all(., "\\.", ""), ",", "\\.")))
  
  if(save == TRUE){
    is_empty <- length(str_detect(list.files("dados"), 'obitos')) == 0
    existent <- str_detect(list.files('dados'), 'obitos')
    
    date <- ifelse(is_empty, 
                     0,
                   max(ymd(str_extract(list.files('dados')[existent], '\\d*\\-\\d*\\-\\d*'))))
    last_file <- ifelse(test = (date > 0), 
                          yes = get_update() - as_date(date), 
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
}

# Essa função extrai a série de casos e óbitos diários (acumulada ou não)

get_series <- function(type = 0){
  url <- "https://www.dadostransparentes.com.br/"
  
  if(type == 0){
    object <- read_html(url) %>% 
      html_nodes('iframe') %>% 
      extract(9) %>%
      html_attr("src") %>% 
      paste0(url, .) %>% 
      read_html() %>% 
      html_node('body') %>%
      html_node('script') %>% 
      html_text() %>% 
      str_extract_all('\\[(.*?)\\]') %>% 
      extract2(1) %>% 
      .[c(1, 2, 4)] %>% 
      str_split(pattern = ",") %>% 
      map(., function(x) str_remove_all(x, '\\[*\\]*'))
    
    names(object) <- c('Casos', 'Óbitos', 'Date')
    
    object %>% 
      as_tibble() %>% 
      mutate(Casos = as.integer(Casos),
             Óbitos = as.integer(Óbitos),
             Date = ymd(str_remove_all(Date, "\\'")))
  }else{
    object <- read_html(url) %>% 
      html_nodes('iframe') %>% 
      extract(10) %>%
      html_attr("src") %>% 
      paste0(url, .) %>% 
      read_html() %>% 
      html_node('body') %>%
      html_node('script') %>% 
      html_text() %>% 
      str_extract_all('\\[(.*?)\\]') %>% 
      extract2(1) %>% 
      .[c(1, 2, 4)] %>% 
      str_split(pattern = ",") %>% 
      map(., function(x) str_remove_all(x, '\\[*\\]*'))
    
    names(object) <- c('Casos', 'Óbitos', 'Date')
    
    object %>% 
      as_tibble() %>% 
      mutate(Casos = as.integer(Casos),
             Óbitos = as.integer(Óbitos),
             Date = ymd(str_remove_all(Date, "\\'")))
  }
}

# Essa função junta os csvs num único tibble

merge_x <- function(type, path = 'dados'){
  files <- str_detect(list.files(path), type)
  objeto <- map(
    list.files(path)[files], 
    function(x) read_csv(paste0(path, '/', x)) %>% 
      mutate(Data = str_extract(x, '[\\d-]+'),
             Tipo = type)
  ) %>% 
    bind_rows()
  objeto
}




## descontinuada
# Essa função troca o separador decimal (modifiquei para que ela troque somente)
# ponto por vírgula, fica como exemplo para caso alguém a considere útil (14/06/2020)

# change_separator <- function(x){
#   map(x, function(x) str_replace(x, "\\.", "\\,"))
# }


# Essa função auxilia análise das datas que estão numa variável do javascript 
# perdeu sua função porque as datas foram disponibilizadas no formado
# yyyy-mm-dd (14/06/2020)

# date_series <- function(x){
#   x %>%
#     str_remove_all(., "\\'") %>% 
#     paste0(., '/2020') %>% 
#     dmy
# }
