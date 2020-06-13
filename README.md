# scrapertransparente

Um script que coleta dados do site [dados transparentes](https://www.dadostransparentes.com.br/).

O script coleta os números das tabelas que são disponibilizadas no site e os insere num arquivo de dados separados por vírgulas. No processo, os separadores decimais "," são trocados por "." de maneira padrão, mas isso pode ser modificado.

## Funções principais

`get_casos`: contém dois argumentos. O primeiro, `dec`, determina se os dados terão como separador decimal a vírgula ou o ponto. O ponto é o padrão. O segundo argumento, `save`, determina se os dados coletados no site serão salvos em um arquivo separado por vírgulas; por padrão, ele sempre o faz. Se o arquivo já estiver numa pasta dados, ele só retorna as informações coletadas num objeto `tibble`.

`get_óbitos`: é análoga à função de casos, mas coleta informações referentes a óbitos.

Tomei o cuidado para que múltiplos arquivos iguais não sejam criados. Dados só serão salvos caso uma nova atualização seja lançada no site.

`get_series`: contém um único argumento denominado `type`. Seu valor padrão é 0 e isso fará com que a função retorne um objeto `tibble` com o número de casos e óbitos acumulados e suas respectivas datas. Qualquer outro valor dentro da função retornará um objeto `tibble` número de casos e óbitos diários (sem acúmulo). 

## Gráficos

Um outro script foi criado e alguns dos gráficos do site foram reproduzidos nele. A escala dos gráficos de casos e óbitos acumulados e novos foi disponibilizada em formato fixo e livre.

## Outras informações

Esse é um projeto pessoal cuja motivação principal é o aprendizado. Não possuo nenhuma associação com a equipe do dadostransparentes. Caso tenha alguma sugestão ou dúvida, o meu e-mail é: jclmntn@gmail.com.


