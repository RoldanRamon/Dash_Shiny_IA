library(shiny)
library(shinydashboard)
library(reticulate)
library(readxl)
library(DT)

# Configure o Python
use_python("/usr/bin/python3")

# Importar o pacote Python necessário
groq <- import("groq")

# Definir UI para o aplicativo
ui <- dashboardPage(
    header = dashboardHeader(title = "Investimento com Groq API"),
    
    sidebar = dashboardSidebar(
        fileInput("file1", "Carregue a planilha Excel", accept = c(".xls", ".xlsx")),
        textInput("numeric_input", "Dinheiro para investimento", value = ""),
        sliderInput("investment_horizon", "Horizonte de tempo (anos): Qual o prazo para o investimento?", 
                    min = 1, max = 30, value = 5),
        selectInput("risk_tolerance", "Tolerância ao risco: Quanto risco você está disposto a correr?",
                    choices = c("Alto Risco, Alto Potencial de Retorno", 
                                "Médio Risco, Médio Potencial de Retorno", 
                                "Baixo Risco, Baixo Potencial de Retorno")),
        selectInput("financial_objective", "Objetivos financeiros:",
                    choices = c("Gerar renda passiva", "Aumentar patrimônio", 
                                "Financiar uma compra", "Aposentadoria")),
        actionButton("generate_button", "Gerar Resposta")
    ),
    
    body = dashboardBody(
        fluidRow(
            column(width = 12,
                   box(
                       title = "Pergunta",
                       textAreaInput("user_input", label = NULL, 
                                     placeholder = "Qual sua dúvida?", width = "100%"),
                       width = NULL
                   )
            )
        ),
        fluidRow(
            column(width = 12,
                   box(
                       title = "Resposta",
                       htmlOutput("response_output"),
                       width = NULL,
                       style = "white-space: pre-wrap;"
                   )
            )
        ),
        fluidRow(
            column(width = 12,
                   box(
                       title = "Visualização da Planilha",
                       DTOutput("table"),
                       width = NULL
                   )
            )
        )
    )
)

# Definir a lógica do servidor
server <- function(input, output) {
    # Função para carregar a planilha
    data <- reactive({
        req(input$file1)
        inFile <- input$file1
        read_excel(inFile$datapath)
    })
    
    # Exibir a planilha no Shiny com quebra de linha
    output$table <- renderDT({
        req(data())
        datatable(data(), options = list(
            autoWidth = TRUE,
            columnDefs = list(list(targets = '_all', className = 'dt-left')),
            pageLength = 10,
            scrollX = FALSE,
            white_space = 'normal'
        ), style = "bootstrap", class = "compact stripe hover nowrap")
    })
    
    # Função para converter todas as linhas da planilha em texto
    get_context_from_sheet <- function(data) {
        context <- paste(capture.output(print(data)), collapse = "\n")
        return(context)
    }
    
    # Função para lidar com a API da Groq
    observeEvent(input$generate_button, {
        # Configurar o cliente Groq com a chave de API
        client <- groq$Groq(
            api_key = Sys.getenv("GROQ_API_KEY")
        )
        
        # Função para enviar a pergunta do usuário e obter a resposta
        get_response <- function(user_question, sheet_context, numeric_value, horizon, risk, objective) {
            tryCatch({
                full_prompt <- paste("Aqui estão os dados da planilha:\n", sheet_context,
                                     "\n\nO valor numérico fornecido é:", numeric_value,
                                     "\n\nHorizonte de tempo (anos):", horizon,
                                     "\n\nTolerância ao risco:", risk,
                                     "\n\nObjetivo financeiro:", objective,
                                     "\n\nAgora responda à seguinte pergunta:\n", user_question)
                
                chat_completion <- client$chat$completions$create(
                    messages = list(
                        list(role = "user", content = full_prompt)
                    ),
                    model = "llama-3.1-70b-versatile"
                )
                
                return(chat_completion$choices[[1]]$message$content)
            }, error = function(e) {
                return(paste("Erro:", e$message))
            })
        }
        
        # Obter o contexto da planilha e as variáveis do sidebar
        sheet_context <- get_context_from_sheet(data())
        numeric_value <- input$numeric_input
        horizon <- input$investment_horizon
        risk <- input$risk_tolerance
        objective <- input$financial_objective
        
        # Obter a resposta usando a entrada do usuário e as variáveis
        resposta <- get_response(input$user_input, sheet_context, numeric_value, horizon, risk, objective)
        
        # Exibir a resposta no UI com quebra de linha
        output$response_output <- renderUI({
            pre(resposta)
        })
    })
}

# Executar a aplicação
shinyApp(ui = ui, server = server)
