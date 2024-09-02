library(shiny)
library(shinydashboard)
library(reticulate)

# Configure o Python
use_python("/usr/bin/python3")

# Importar o pacote Python necessário
groq <- import("groq")

# Definir UI para o aplicativo
ui <- dashboardPage(
    header = dashboardHeader(title = "Groq API Example"),
    sidebar = dashboardSidebar(disable = FALSE),
    body = dashboardBody(
        fluidRow(
            column(width = 6,
                   box(
                       textAreaInput("user_input", "Digite sua pergunta", value = "Qual sua dúvida?"),
                       actionButton("generate_button", "Gerar Resposta"),
                       width = NULL
                   )
            ),
            column(width = 6,
                   box(
                       verbatimTextOutput("response_output"),
                       width = NULL
                   )
            )
        )
    )
)

# Definir a lógica do servidor
server <- function(input, output) {
    observeEvent(input$generate_button, {
        # Configurar o cliente Groq com a chave de API
        client <- groq$Groq(
            api_key = Sys.getenv("GROQ_API_KEY")  # Certifique-se de que a chave da API está no .Renviron
        )
        
        # Função para enviar a pergunta do usuário e obter a resposta
        get_response <- function(user_question) {
            tryCatch({
                # Enviar a pergunta para a API da Groq
                chat_completion <- client$chat$completions$create(
                    messages = list(
                        list(role = "user", content = user_question)
                    ),
                    model = "gemma2-9b-it"
                )
                
                # Retorna o conteúdo da resposta
                return(chat_completion$choices[[1]]$message$content)
            }, error = function(e) {
                return(paste("Erro:", e$message))
            })
        }
        
        # Obter a resposta usando a entrada do usuário
        resposta <- get_response(input$user_input)
        
        # Exibir a resposta no UI
        output$response_output <- renderText({
            resposta
        })
    })
}

# Executar a aplicação
shinyApp(ui = ui, server = server)
