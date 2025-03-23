library(shiny)
library(DT)
library(ggplot2)

# Caminho do arquivo de dados de usuários
user_data_file <- "user_data.csv"

# Carrega ou inicializa os dados de usuários
if (file.exists(user_data_file)) {
  user_credentials <- read.csv(user_data_file, stringsAsFactors = FALSE)
} else {
  user_credentials <- data.frame(
    username = "admin",
    password = "123456",
    name = "Administrador",
    role = "admin",
    stringsAsFactors = FALSE
  )
  write.csv(user_credentials, user_data_file, row.names = FALSE)
}

# Função para carregar arquivos da pasta "relatorios"
carregar_relatorios <- function(pasta_relatorios) {
  if (!dir.exists(pasta_relatorios)) dir.create(pasta_relatorios)
  arquivos <- list.files(pasta_relatorios, pattern = "\\.csv$", full.names = TRUE)
  if (length(arquivos) == 0) return(data.frame())
  do.call(rbind, lapply(arquivos, read.csv, stringsAsFactors = FALSE))
}

server <- function(input, output, session) {
  # Estado do usuário
  user_data <- reactiveValues(logged_in = FALSE, user_info = NULL, page = "login")
  
  # Reactive para armazenar os dados do arquivo carregado
  relatorio_data <- reactiveVal(data.frame())
  
  # Carregar relatórios ao iniciar o aplicativo
  relatorio_data(carregar_relatorios("relatorios"))
  
  # Função de autenticação
  authenticate_user <- function(username, password) {
    user <- user_credentials[user_credentials$username == username &
                               user_credentials$password == password, ]
    if (nrow(user) == 1) return(user) else return(NULL)
  }
  
  # Função para criar conta
  create_account <- function(username, password, name) {
    if (username %in% user_credentials$username) return(FALSE)
    new_user <- data.frame(username, password, name, role = "user", stringsAsFactors = FALSE)
    user_credentials <<- rbind(user_credentials, new_user)
    write.csv(user_credentials, user_data_file, row.names = FALSE)
    TRUE
  }
  
  # Ações de login
  observeEvent(input$login_button, {
    user <- authenticate_user(input$username, input$password)
    if (!is.null(user)) {
      user_data$logged_in <- TRUE
      user_data$user_info <- user
    } else {
      output$login_message <- renderText("Usuário ou senha inválidos.")
    }
  })
  
  # Ações de logout
  observeEvent(input$logout_button, {
    user_data$logged_in <- FALSE
    user_data$page <- "login"
  })
  
  # Criar conta
  observeEvent(input$create_account_button, {
    success <- create_account(input$new_username, input$new_password, input$new_name)
    output$create_account_message <- renderText(
      if (success) "Conta criada com sucesso! Volte para a tela de login."
      else "Erro: Nome de usuário já existe."
    )
  })
  
  # Navegação
  observeEvent(input$create_account_link, { user_data$page <- "create_account" })
  observeEvent(input$back_to_login, { user_data$page <- "login" })
  
  # Renderizar UI
  output$app_ui <- renderUI({
    if (user_data$logged_in) dashboardPage(mainHeader, mainSidebar, mainBody)
    else if (user_data$page == "login") login_page
    else if (user_data$page == "create_account") create_account_page
  })
  
  # Processar o arquivo de upload
  observeEvent(input$processar_relatorio, {
    req(input$relatorio_file)
    tryCatch({
      pasta_relatorios <- "relatorios"
      if (!dir.exists(pasta_relatorios)) dir.create(pasta_relatorios)
      caminho_arquivo <- file.path(pasta_relatorios, input$relatorio_file$name)
      if (file.copy(input$relatorio_file$datapath, caminho_arquivo)) {
        dados <- read.csv(caminho_arquivo, stringsAsFactors = FALSE)
        relatorio_data(dados)
        showNotification(paste("Arquivo carregado e salvo em:", caminho_arquivo), type = "message")
      } else {
        showNotification("Erro ao salvar o arquivo. Verifique as permissões.", type = "error")
      }
    }, error = function(e) {
      showNotification("Erro ao carregar o arquivo. Verifique o formato do CSV.", type = "error")
    })
  })
  
  # Renderiza o gráfico de relatórios
  output$grafico_relatorio <- renderPlot({
    req(relatorio_data())
    dados <- relatorio_data()
    resumo <- aggregate(Custo ~ Status, data = dados, sum)
    ggplot(resumo, aes(x = Status, y = Custo, fill = Status)) +
      geom_bar(stat = "identity") +
      labs(title = "Comparação de Custos por Status das Viagens",
           x = "Status da Viagem", y = "Custo Total (R$)") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  })
  
  # Renderiza a tabela de reservas
  output$tabela_reservas <- renderDT({
    datatable(relatorio_data(), options = list(pageLength = 5, autoWidth = TRUE),
              class = "display compact", rownames = FALSE)
  })
}
