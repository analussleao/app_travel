library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(shinyalert)
library(DT)

# Caminho do arquivo de dados de usuários ----------------------------------
user_data_file <- "user_data.csv"

# Carrega ou inicializa os dados de usuários -------------------------------
if (file.exists(user_data_file)) {
  user_credentials <- read.csv(user_data_file, stringsAsFactors = FALSE)
} else {
  user_credentials <- data.frame(
    username = c("admin"),
    password = c("123456"),
    name = c("Administrador"),
    role = c("admin"),
    stringsAsFactors = FALSE
  )
  write.csv(user_credentials, user_data_file, row.names = FALSE)
}

# Função de autenticação ---------------------------------------------------
authenticate_user <- function(username, password) {
  user <- user_credentials[user_credentials$username == username & 
                             user_credentials$password == password, ]
  if (nrow(user) == 1) {
    return(user)
  } else {
    return(NULL)
  }
}

# Função para criar conta --------------------------------------------------
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

# Adiciona o CSS personalizado ---------------------------------------------
custom_css <- "
/* Fundo geral do aplicativo */
body {
  background-color: #FEF9EF !important;
  color: #227C9D;
}

/* Centraliza o painel de login e criação de conta */
#login_panel, #create_account_panel {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 400px;
  background-color: #FFFFFF;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

/* Cabeçalho */
.main-header .navbar {
  background-color: #227C9D;
  border-bottom: 1px solid #FFCB77;
}
.main-header .logo {
  background-color: #227C9D;
  color: #FEF9EF;
  font-weight: bold;
}

/* Barra lateral */
.main-sidebar {
  background-color: #FEF9EF;
}
.sidebar-menu > li > a {
  color: #227C9D;
}
.sidebar-menu > li.active > a,
.sidebar-menu > li > a:hover {
  background-color: #17C3B2;
  color: #FFFFFF;
}

/* Ícones na barra lateral */
.sidebar-menu .fa {
  color: #FE6D73 !important;
}

/* Botões */
.btn-primary, .btn-logout {
  background-color: #227C9D;
  border-color: #227C9D;
  color: #FFFFFF;
}
.btn-primary:hover, .btn-logout:hover {
  background-color: #17C3B2;
  border-color: #17C3B2;
}

/* Rodapé */
.main-footer {
  background-color: #FEF9EF;
  color: #227C9D;
  border-top: 1px solid #FFCB77;
}

/* Mensagens de erro ou alertas */
.alert-message {
  color: #FE6D73;
  font-weight: bold;
}

/* Texto */
h3, h4, h5, p, label {
  color: #227C9D;
}
"

# Tela de login ------------------------------------------------------------
login_page <- fluidPage(
  id = "login_page",
  useShinyjs(),
  tags$style(HTML(custom_css)),
  div(id = "login_panel",
      wellPanel(
        h3("Login", style = "color: #227C9D; text-align: center;"),
        textInput("username", "Usuário:"),
        passwordInput("password", "Senha:"),
        actionButton("login_button", "Entrar", class = "btn-primary", style = "width: 100%;"),
        br(),
        br(),
        div(textOutput("login_message"), class = "alert-message", style = "text-align: center;"),
        br(),
        div(actionLink("create_account_link", "Criar uma nova conta", style = "color: #17C3B2; text-align: center;"))
      )
  )
)

# Tela de criação de conta -------------------------------------------------
create_account_page <- fluidPage(
  id = "create_account_page",
  useShinyjs(),
  tags$style(HTML(custom_css)),
  div(id = "create_account_panel",
      wellPanel(
        h3("Criar Conta", style = "color: #227C9D; text-align: center;"),
        textInput("new_username", "Usuário:"),
        passwordInput("new_password", "Senha:"),
        textInput("new_name", "Nome:"),
        actionButton("create_account_button", "Criar Conta", class = "btn-primary", style = "width: 100%;"),
        br(),
        br(),
        div(textOutput("create_account_message"), class = "alert-message", style = "text-align: center;"),
        br(),
        div(actionLink("back_to_login", "Voltar para o Login", style = "color: #17C3B2; text-align: center;"))
      )
  )
)

# Cabeçalho do dashboard ---------------------------------------------------
mainHeader <- dashboardHeader(
  title = "Gerenciamento de Viagens", titleWidth = 250,
  tags$li(class = "dropdown", 
          style = "padding: 8px;",
          actionButton("logout_button", "Logout", icon = icon("sign-out"), class = "btn-logout"))
)

# Barra lateral do dashboard ------------------------------------------------
mainSidebar <- dashboardSidebar(
  useShinyjs(),
  useShinyalert(),
  sidebarMenu(id = "menu",
              menuItem("Painel Inicial", icon = icon("home"), tabName = "dashboard", selected = TRUE),
              menuItem("Reservas de Viagem", icon = icon("plane"), tabName = "reservas"),
              menuItem("Guias de Destinos", icon = icon("map"), tabName = "destinos"),
              menuItem("Relatórios", icon = icon("chart-bar"), tabName = "relatorios")
              
  )
)

# Corpo principal do dashboard ----------------------------------------------
mainBody <- dashboardBody(
  tags$head(
    tags$style(HTML(custom_css))
  ),
  tabItems(
    tabItem("dashboard",
            h3(strong("Bem-vindo ao Gerenciamento de Viagens!"), align = "center", style = "color: #227C9D;"),
            br(),
            p("Aqui você pode gerenciar reservas, explorar destinos e acessar relatórios de viagens.",
              style = "color: #227C9D;"),
            br()
    ),
    tabItem("reservas",
            h4("Reservas de Viagem", style = "color: #227C9D;"),
            br(),
            p("Nesta seção, você pode gerenciar as reservas de viagem.", style = "color: #227C9D;"),
            DTOutput("tabela_reservas")
    ),
    tabItem("destinos",
            h4("Guias de Destinos", style = "color: #227C9D;"),
            br(),
            p("Explore os destinos disponíveis e obtenha guias detalhados.", style = "color: #227C9D;"),
            fluidRow(
              box(title = "Destinos Populares", width = 6, status = "primary", solidHeader = TRUE,
                  p("Exemplo: Rio de Janeiro, Paris, Tóquio")
              ),
              box(title = "Promoções Atuais", width = 6, status = "info", solidHeader = TRUE,
                  p("Exemplo: Desconto de 20% em viagens para o Caribe!")
              )
            )
    ),
    tabItem("relatorios",
            h4("Relatórios de Viagens", style = "color: #227C9D;"),
            br(),
            p("Visualize relatórios das viagens realizadas e planeje futuros itinerários.",
              style = "color: #227C9D;"),
            plotOutput("grafico_relatorio")
    )
  )
)

# Define a interface do usuário ---------------------------------------------
ui <- uiOutput("app_ui")

# Define a lógica do servidor -----------------------------------------------
server <- function(input, output, session) {
  user_data <- reactiveValues(logged_in = FALSE, user_info = NULL, page = "login")
  
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
  
  observeEvent(input$logout_button, {
    user_data$logged_in <- FALSE
    user_data$page <- "login"
  })
  
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
  
  observeEvent(input$create_account_link, {
    user_data$page <- "create_account"
  })
  
  observeEvent(input$back_to_login, {
    user_data$page <- "login"
  })
  
  output$app_ui <- renderUI({
    if (user_data$logged_in) {
      dashboardPage(mainHeader, mainSidebar, mainBody)
    } else if (user_data$page == "login") {
      login_page
    } else if (user_data$page == "create_account") {
      create_account_page
    }
  })
  
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

# Executa o aplicativo -----------------------------------------------------
shinyApp(ui, server)

