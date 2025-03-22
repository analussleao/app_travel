server <- function(input, output, session) {
  # Estado do usuário (login, página atual, etc.)
  user_data <- reactiveValues(logged_in = FALSE, user_info = NULL, page = "login")
  
  # Função de autenticação
  authenticate_user <- function(username, password) {
    user <- user_credentials[user_credentials$username == username &
                               user_credentials$password == password, ]
    if (nrow(user) == 1) {
      return(user)
    } else {
      return(NULL)
    }
  }
  
  # Função para criar conta
  create_account <- function(username, password, name) {
    if (username %in% user_credentials$username) {
      return(FALSE)
    }
    new_user <- data.frame(
      username = username,
      password = password,
      name = name,
      role = "user",
      stringsAsFactors = FALSE
    )
    user_credentials <<- rbind(user_credentials, new_user)
    write.csv(user_credentials, user_data_file, row.names = FALSE)
    return(TRUE)
  }
  
  # Ações ao clicar no botão de login
  observeEvent(input$login_button, {
    user <- authenticate_user(input$username, input$password)
    if (!is.null(user)) {
      user_data$logged_in <- TRUE
      user_data$user_info <- user
    } else {
      output$login_message <- renderText({
        "Usuário ou senha inválidos."
      })
    }
  })
  
  # Ações ao clicar no botão de logout
  observeEvent(input$logout_button, {
    user_data$logged_in <- FALSE
    user_data$page <- "login"
  })
  
  # Ações ao clicar no botão de criar conta
  observeEvent(input$create_account_button, {
    success <- create_account(input$new_username, input$new_password, input$new_name)
    output$create_account_message <- renderText({
      if (success) {
        "Conta criada com sucesso! Volte para a tela de login."
      } else {
        "Erro: Nome de usuário já existe."
      }
    })
  })
  
  # Navegação para tela de criação de conta
  observeEvent(input$create_account_link, {
    user_data$page <- "create_account"
  })
  
  # Navegação para tela de login
  observeEvent(input$back_to_login, {
    user_data$page <- "login"
  })
  
  # Definição de interface do usuário dinamicamente
  output$app_ui <- renderUI({
    if (user_data$logged_in) {
      dashboardPage(mainHeader, mainSidebar, mainBody)
    } else if (user_data$page == "login") {
      login_page
    } else if (user_data$page == "create_account") {
      create_account_page
    }
  })
  
  # Renderização da tabela de reservas
  output$tabela_reservas <- renderDT({
    datatable(
      data.frame(
        Destino = c("Rio de Janeiro", "Paris", "Tóquio"),
        Data = c("2023-12-01", "2024-01-15", "2024-03-10"),
        Status = c("Confirmado", "Pendente", "Cancelado")
      ),
      options = list(
        pageLength = 5,
        dom = "t",
        autoWidth = TRUE
      ),
      class = "display compact",
      rownames = FALSE
    ) %>%
      formatStyle(
        columns = c("Destino", "Data", "Status"),
        color = "#227C9D",
        backgroundColor = "#FEF9EF",
        fontWeight = "bold"
      )
  })
  
  # Renderização do gráfico de relatórios
  output$grafico_relatorio <- renderPlot({
    barplot(
      c(10, 20, 15),
      names.arg = c("2022", "2023", "2024"),
      col = "#17C3B2",
      border = "#FFCB77",
      main = "Relatórios de Viagens por Ano",
      xlab = "Ano",
      ylab = "Número de Viagens",
      cex.main = 1.5,
      cex.lab = 1.2,
      cex.axis = 1,
      las = 1
    )
  })
}
