library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyalert)
library(DT)

# Tela de login
login_page <- fluidPage(
  id = "login_page",
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
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

# Tela de criação de conta
create_account_page <- fluidPage(
  id = "create_account_page",
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
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

mainHeader <<- dashboardHeader(
  title = tags$div(
    tags$img(src = "luneta.png", height = "50px", style = "margin-right: 10px;"), # Imagem da luneta
    "Luneta Viagens"
  ),
  titleWidth = 250,
  tags$li(class = "dropdown", 
          style = "padding: 8px;",
          actionButton("logout_button", "Logout", icon = icon("sign-out"), class = "btn-logout"))
)


# Barra lateral do dashboard
mainSidebar <<- dashboardSidebar(
  useShinyjs(),
  useShinyalert(),
  sidebarMenu(id = "menu",
              menuItem("Painel Inicial", icon = icon("home"), tabName = "dashboard", selected = TRUE),
              menuItem("Reservas de Viagem", icon = icon("plane"), tabName = "reservas"),
              menuItem("Guias de Destinos", icon = icon("map"), tabName = "destinos"),
              menuItem("Relatórios", icon = icon("chart-bar"), tabName = "relatorios")
  )
)

# Corpo principal do dashboard
mainBody <<- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
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

# Definição da interface
ui <<- uiOutput("app_ui")
