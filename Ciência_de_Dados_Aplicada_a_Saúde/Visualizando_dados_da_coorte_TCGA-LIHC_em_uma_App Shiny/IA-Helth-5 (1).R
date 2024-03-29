install.packages("BiocManager")
install.packages("survival")
install.packages("survminer")
install.packages("shiny")
BiocManager::install("SummarizedExperiment")
library(shiny)
library(survival)
library(survminer)
library(SummarizedExperiment)


#carregando pacote
load("./tcgaLIHCdata_preprocessed.RData")
tcgaLIHCdata

#extraindo dados da matriz e metadados
gexp <- assay(tcgaLIHCdata)
rowAnnotation <- rowData(tcgaLIHCdata)
colAnnotation <- colData(tcgaLIHCdata)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Painel de Análise de Sobrevida"),
  
  # Sidebar with a select input 
  sidebarLayout(
    sidebarPanel(
      selectInput("variable",
                  "variable",
                  choices = (c("gender","ajcc_pathologic_tumor_stage","PFI",
                               "Tumor_Stage","Stage","mRNA"))),
      hr() ,
      helpText("Estudante: Clístenes Grizafis Bento")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("varPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Função reativa para realizar o cálculo de survfit
  survfit_calc <- reactive({
    
    # Usar criar e usar o valor na função survfit
    formula_str <- formula(paste("Surv(OS.time.months, OS) ~", input$variable))
    eval(bquote(survfit(.(formula_str),data=colAnnotation)))
  })
  
  output$varPlot <- renderPlot({
    #plotando gráfico de acordo com a seleção
    survminer::ggsurvplot(fit = survfit_calc(), data = colAnnotation)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
