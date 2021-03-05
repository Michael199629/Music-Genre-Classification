library(shiny)
require(tidyverse)
require(tuneR)
require(signal)
require(av)
require(ggfortify)
require(shinydashboard)
require(ggcorrplot)
library(reticulate)

source_python('~/ALY 6110/final project/Music_genre/transformer.py')
# Define UI for application that draws a histogram
mydata <- read.csv("~/ALY 6110/final project/Music_genre/Data/features_30_sec.csv")
X <- mydata[,2:59]
y <- mydata[,60]
ui <- dashboardPage(
    
    # Application title
    dashboardHeader(title = "Genres Classifier"),
    #titlePanel("Music Genres Classifier"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Visualize your music",
                     tabName = "MusicViz",
                     icon = icon("wave-square")),
            menuItem("EDA", 
                     tabName = "eda",
                     icon = icon("chart-line"))
        )
    ),
    # Sidebar with a slider input for number of bins
    dashboardBody(
        tags$head(tags$style(
            HTML('.wrapper {height: auto !important; position:relative; overflow-x:hidden; overflow-y:hidden}')
        )),
        tabItems(
            tabItem("MusicViz",
                    box(plotOutput("spectrogram"),width = 8),
                    box(selectInput("Music_Genre",
                                    label = "Music Genre",
                                    choices = c("blues",
                                                "classical",
                                                "country",
                                                "disco",
                                                "hiphop",
                                                "jazz",
                                                "metal",
                                                "pop",
                                                "reggae",
                                                "rock"),
                                    selected = "blues"),
                        sliderInput("No.song",
                                    "Which song you want to choose:",
                                    min = 1,
                                    max = 100,
                                    value = 1),width = 4),
                    
                    box(plotOutput("music"),width = 8),
                    box(fileInput("music",
                                  "Choose a WAV file",
                                  multiple = FALSE,
                                  accept = c(".wav")),
                        width = 4),
                    infoBoxOutput("result")
                        ),
            tabItem("eda",
                    fluidRow(
                        box(selectInput("features",
                                        label = "Features",
                                        choices = colnames(X),
                                        selected = "tempo"),width = 6),
                        box(selectInput("corx",
                                        label = "select type of varables",
                                        choices = c("mean","var"),
                                        selected = "mean"),width = 6)
                    ),
                    fluidRow(
                        box(plotOutput("boxplot"), width = 6),
                        box(plotOutput("cor"),width = 6)
                    ),
                    fluidRow(
                        box(plotOutput("density"),width = 6),
                        box(plotOutput("pca"),width = 6)
                    )
            )
        )
    )
)
