library(reticulate)

# Configure o Python
use_python("/usr/bin/python3")  # Ajuste o caminho conforme necessário

# Importar pacotes Python
pd <- import("pandas")
np <- import("numpy")
groq <- import("groq")

# Configurar o cliente Groq com a chave de API
client <- groq$Groq(
  api_key = Sys.getenv("GROQ_API_KEY")  # Certifique-se de que a chave da API está no .Renviron
)

# Gerar dados aleatórios (substituindo o exemplo de dados em Python)
dadosbruto <- np$random$uniform(100, 1000, size = as.integer(20))


# Função para enviar os dados do DataFrame como JSON e obter a resposta da previsão de vendas
get_sales_forecast <- function(dadosbruto) {
  tryCatch({
    # Formatar os dados JSON como string e construir a mensagem
    mensagem <- sprintf("Com base nos seguintes dados: %s, faça uma análise descritiva estatística de cada perfil", 
                        paste(dadosbruto, collapse = ", "))
    
    # Enviar a pergunta junto com os dados para a API da Groq
    chat_completion <- client$chat$completions$create(
      messages = list(
        list(role = "user", content = mensagem)
      ),
      model = "gemma2-9b-it"
    )
    
    # Retorna o conteúdo da resposta
    return(chat_completion$choices[[1]]$message$content)
  }, error = function(e) {
    return(paste("Erro:", e$message))
  })
}

# Obter a previsão de vendas
previsao_vendas <- get_sales_forecast(dadosbruto)

# Exibir o resultado
cat(previsao_vendas)
