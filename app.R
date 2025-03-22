library(shiny)

# Chama os arquivos ui.R e server.R
source("ui.R")
source("server.R")

# Executa o aplicativo
shinyApp(ui = ui, server = server)
