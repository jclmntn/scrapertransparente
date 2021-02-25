# scrapertransparente

Um script que coleta dados do site [dados transparentes](https://www.dadostransparentes.com.br/).

O script coleta os números das tabelas que são disponibilizadas no site e os insere num arquivo de dados separados por vírgulas. No processo, os separadores decimais "," são trocados por "." de maneira padrão, da mesma maneira que os dados são apresentados no site desde 13/06/2020.

## Funções principais

`get_casos`: contém um único argumento: `save`, o qual determina se os dados coletados no site serão salvos em um arquivo separado por vírgulas; por padrão, ele sempre o faz. Se o arquivo já estiver numa pasta dados, ele só retorna as informações coletadas num objeto `tibble`.

`get_óbitos`: é análoga à função de casos, mas coleta informações referentes a óbitos.

Tomei o cuidado para que múltiplos arquivos iguais não sejam criados. Dados só serão salvos caso uma nova atualização seja lançada no site.

`get_series`: contém um único argumento denominado `type`. Seu valor padrão é 0 e isso fará com que a função retorne um objeto `tibble` com o número de casos e óbitos acumulados e suas respectivas datas. Qualquer outro valor dentro da função retornará um objeto `tibble` com o número de casos e óbitos diários (sem acúmulo). 

`merge_x`: contém os argumentos `path` e `type`. O primeiro argumento serve para localizar o destino dos arquivos CSV disponibilizado pelo scraper, o segundo serve para indicar se o arquivo é referente a casos ou a óbitos. Talvez 

## Gráficos

Um outro script foi criado e nele alguns dos gráficos do site foram reproduzidos. A escala dos gráficos de casos e óbitos acumulados e novos foi disponibilizada em formato fixo e livre.

## Atualizações
25/02/2020 - O portal não existe mais, o que torna o wrapper/scrapper inutilizado. Agora temos muitas outras fontes de dados disponíveis na rede, mas na época o scrapper parecia fazer algum sentido (além de ter sido um projeto incrivelmente divertido de se trabalhar). Até a próxima! 

09/07/2020 - Algumas mudanças ocorreram na estrutura do site novamente e alterei algumas linhas que definem de quais listas os dados devem ser extraídos. Também tive de adicionar linhas de código que trocam os separadores decimais, já que o site mudou, de novo, a maneira que os dados são apresentados.

28/06/2020 - Adicionei os dados dos últimos dias e fiz alterações no código para acompanhar as mudanças no site. Agora os dados ficam dispostos numa aba de relatórios, então a estrutura do HTML mudou substancialmente.

17/06/2020 - Adicionei código extra que ajuda a auxiliar no diagnóstico de possíveis problemas na tendência dos dados, além de código referente a um gráfico que mostra o crescimento no n° de casos por milhão de habitantes. 

16/06/2020 - Correções nas funções que extraem óbitos e casos devido a mudanças no HTML do site (mais divs). Correções nos dados devido a algumas inconsistências (todas com base nas secretarias de cada estado). Os erros encontrados foram referentes aos números de casos e óbitos acumulados dos seguintes estados: GO, RO, DF, PE, MA, PB, SP, AL e PA.

15/06/2020 - Função `merge_x` adicionada.

## Comportamento irregular

19/06/2020 - Houve comportamento inconsistente com os dados referentes a RR no dia 18/06/2020. Às 10hrs os valores para casos acumulados em RR eram 6947 e às 17hrs os dados mudaram para 7176. 

17/06/2020 - Os dados de casos acumulados referentes ao estado de Roraima caíram do dia 15/06 para o dia 16/06.

## O que esperar do futuro?

28/06/2020 - Agora o site possui tabelas que contém dados dos últimos 21 dias. Estou trabalhando em duas novas funções para extrair esses dados.

15/06/2020 - Caso o projeto dadostransparentes seja mantido, possivelmente criarei uma ferramenta no `Shiny`. O código será disponibilizado num repositório *aberto* e separado.

## Outras informações

Esse é um projeto pessoal cuja motivação principal é o aprendizado. Não possuo nenhuma associação com a equipe do dadostransparentes. Caso tenha alguma sugestão ou dúvida, o meu e-mail é: jclmntn@gmail.com.


