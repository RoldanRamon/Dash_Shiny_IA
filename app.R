library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(readxl)
library(DT)
library(reshape2)  # Para o heatmap

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
        tags$style(HTML("
            .content-wrapper {
                min-height: 100vh;
                height: auto;
                padding: 0 15px;
                margin-right: 0;
            }
            .box {
                margin-bottom: 20px;
                border: 2px solid #d3d3d3;  /* Borda dos gráficos */
                box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);  /* Sombra */
            }
        ")),
        tabBox(
            id = "tabs",
            width = 12,
            tabPanel("Pergunta",
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
            ),
            tabPanel("Gráficos",
                     fluidRow(
                         column(width = 6,
                                box(
                                    title = "FFO Yield vs Dividendo Yield",
                                    plotlyOutput("ffo_vs_dividendo_yield"),
                                    width = NULL
                                ),
                                box(
                                    title = "Liquidez vs Valor de Mercado",
                                    plotlyOutput("liquidez_vs_valor_mercado"),
                                    width = NULL
                                )
                         ),
                         column(width = 6,
                                box(
                                    title = "Cap Rate vs Preço do m2",
                                    plotlyOutput("cap_rate_vs_preco_m2"),
                                    width = NULL
                                ),
                                box(
                                    title = "Segmento de Mercado",
                                    plotlyOutput("segmento_mercado"),
                                    width = NULL
                                )
                         )
                     ),
                     fluidRow(
                         column(width = 6,
                                box(
                                    title = "Preço do m2 vs Tempo",
                                    plotlyOutput("preco_m2_vs_tempo"),
                                    width = NULL
                                ),
                                box(
                                    title = "Aluguel por m2 vs Vacância Média",
                                    plotlyOutput("aluguel_vs_vacancia"),
                                    width = NULL
                                )
                         ),
                         column(width = 6,
                                box(
                                    title = "Heatmap de Correlações",
                                    plotlyOutput("heatmap"),
                                    width = NULL
                                )
                         )
                     )
            )
        )
    )
)

# Definir a lógica do servidor
server <- function(input, output) {
    # Carregar a planilha
    data <- reactive({
        req(input$file1)
        inFile <- input$file1
        read_excel(inFile$datapath)
    })
    
    # Exibir a planilha no Shiny
    output$table <- renderDT({
        req(data())
        datatable(data(), options = list(pageLength = 10))
    })
    
    # Função para converter todas as linhas da planilha em texto
    get_context_from_sheet <- function(data) {
        context <- paste(capture.output(print(data)), collapse = "\n")
        return(context)
    }
    
    # Função para lidar com a API Groq (ajustar a implementação de API conforme necessário)
    observeEvent(input$generate_button, {
        sheet_context <- get_context_from_sheet(data())
        numeric_value <- input$numeric_input
        horizon <- input$investment_horizon
        risk <- input$risk_tolerance
        objective <- input$financial_objective
        
        resposta <- paste("Dados analisados:", sheet_context, "\nDinheiro para investimento:", numeric_value, "\nHorizonte de tempo:", horizon, "\nRisco:", risk, "\nObjetivo financeiro:", objective)
        
        output$response_output <- renderUI({
            pre(resposta)
        })
    })
    
    # Gerar gráficos com interatividade do Plotly
    output$ffo_vs_dividendo_yield <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = ffo_yield, y = dividend_yield)) + 
            geom_bar(stat = "identity") +
            labs(x = "FFO Yield", y = "Dividendo Yield") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$liquidez_vs_valor_mercado <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = liquidez, y = valor_de_mercado)) + 
            geom_point() +
            labs(x = "Liquidez", y = "Valor de Mercado") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$cap_rate_vs_preco_m2 <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = cap_rate, y = preco_do_m2)) + 
            geom_bar(stat = "identity") +
            labs(x = "Cap Rate", y = "Preço do m2") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$segmento_mercado <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = "", fill = segmento)) + 
            geom_bar(width = 1) +
            coord_polar(theta = "y") +
            labs(title = "Segmento de Mercado") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$preco_m2_vs_tempo <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = data_atualizacao, y = preco_do_m2)) + 
            geom_line() +
            labs(x = "Data de Atualização", y = "Preço do m2") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$aluguel_vs_vacancia <- renderPlotly({
        req(data())
        df <- data()
        p <- ggplot(df, aes(x = aluguel_por_m2, y = vacancia_media)) + 
            geom_bar(stat = "identity") +
            labs(x = "Aluguel por m2", y = "Vacância Média") +
            theme_minimal()
        ggplotly(p)
    })
    
    output$heatmap <- renderPlotly({
        req(data())
        df <- data()
        cor_matrix <- cor(df[, c("ffo_yield", "dividend_yield", "liquidez", "valor_de_mercado", "cap_rate", "preco_do_m2", "aluguel_por_m2", "vacancia_media")])
        p <- ggplot(melt(cor_matrix), aes(Var1, Var2, fill = value)) + 
            geom_tile() + 
            scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1)) +
            labs(x = "", y = "") +
            theme_minimal()
        ggplotly(p)
    })
}

# Executar a aplicação
shinyApp(ui = ui, server = server)
