library(shiny)
require(tuneR)
require(signal)
library(ggplot2)
library(seewave)
require(ggfortify)
require(shinydashboard)
library(sparklyr)
library(ggcorrplot)
require(factoextra)
require(magrittr)
require(vtreat)
library(xgboost)
library(reticulate)

source_python('~/ALY 6110/final project/Music_genre/transformer.py')
#path = "C:/Users/Michael/Documents/ALY 6110/final project/Music_genre/Data/genres_original/blues/blues.00000.wav"
#df <- makeFeatrues(path)
# Define server logic required to draw a histogram
#getwd()

#mydata <- read.csv("~/ALY 6110/final project/Music_genre/Data/features_3_sec.csv")
#set.seed(2020)

#rows <- sample(1:nrow(mydata),nrow(mydata))
#newdata <- mydata[rows,]
#ind <- sample(2,nrow(newdata),replace = T,prob = c(0.7,0.3))

#data.train <- newdata[ind == 1,3:60] 

#feature <- setdiff(names(data.train),"label")
#data.train.label <- as.numeric(data.train[,"label"])-1

#xgb_params <- list(
#    "objective" = "multi:softprob",
#    "eval_metric" = "mlogloss",
#    "num_class" = 10
#)
#final_model <- xgboost(
#    params = xgb_params,
#    data = as.matrix(data.train[,-58]),
#    label = as.matrix(data.train.label),
#    nrounds = 175,
#    verbose = 0
#)
#xgb.save(final_model,'music_classification.model')
bst <- xgb.load('C:/Users/Michael/Documents/ALY 6110/final project/Music_genre/music_classification.model')
server <- function(input, output, session) {
    #SparkContent
    sc <- spark_connect(master = "local")
    #tbl
    mg_tbl <- spark_read_csv(sc,
                             name = "music_genres",
                             path = "~/ALY 6110/final project/Music_genre/Data/features_3_sec.csv")
    
    
    
    #mydata <- read.csv("~/ALY 6110/final project/Music_genre/Data/features_3_sec.csv")
    #X <- mydata[,3:59]
    #y <- mydata[,60]
    
    output$spectrogram <- renderPlot({
        p <- "C:/Users/Michael/Documents/ALY 6110/final project/Music_genre"
        
        fdir <- list.dirs(
            path = paste(p,"Data/genres_original",input$Music_Genre,sep = "/"))
        fname <- list()
        fname <- list.files(path = fdir)
        num <- as.numeric(input$No.song)
        file1.dir <- paste(fdir,fname[num],sep = "/")
        
        data <- readWave(file1.dir)
        snd <- data@left - mean(data@left)
        # create spectrogram
        spec <- signal::specgram(x = snd, n = 1024, Fs = data@samp.rate, overlap = 1024 * 0.75)
        
        # normalize and rescale to dB
        P <- abs(spec$S)
        P <- P/max(P)
        
        out <- pmax(1e-6, P)
        dim(out) <- dim(P)
        out <- log10(out) / log10(1e-6)
        
        # plot spectrogram
        image(x = spec$t, y = spec$f, z = t(out), ylab = 'Freq [Hz]', xlab = 'Time [s]', useRaster=TRUE)
        #fft_data <- read_audio_fft(file1.dir, end_time = 30)
        #dim(fft_data)
        #plot(fft_data)
    })
    output$music <- renderPlot({
        file <- input$music
        data2 <- readWave(file$datapath)
        snd2 <- data2@left - mean(data2@left)
        # create spectrogram
        spec2 <- signal::specgram(x = snd2, n = 1024, Fs = data2@samp.rate, overlap = 1024 * 0.75)
        
        # normalize and rescale to dB
        P2 <- abs(spec2$S)
        P2 <- P2/max(P2)
        
        out2 <- pmax(1e-6, P2)
        dim(out2) <- dim(P2)
        out2 <- log10(out2) / log10(1e-6)
        
        # plot spectrogram
        image(x = spec2$t, y = spec2$f, z = t(out2), ylab = 'Freq [Hz]', xlab = 'Time [s]', useRaster=TRUE)
        #fft_data <- read_audio_fft(file1.dir, end_time = 30)
        #dim(fft_data)
        #plot(fft_data)
    })
    output$result <- renderInfoBox({
        
        if (input$music$size > 0){
            pred_path <- input$music$datapath
        } else {
            pred_path <- "C:/Users/Michael/Documents/ALY 6110/final project/Music_genre/Data/genres_original/blues/blues.00000.wav"
        }
        #pred_path <- "C:/Users/Michael/Documents/ALY 6110/final project/Music_genre/Data/genres_original/blues/blues.00000.wav"
        data2 <- makeFeatrues(pred_path)
        
        #datafile <- read.csv("~/ALY 6110/final project/Music_genre/Data/features_30_sec.csv")
        #data2 <- datafile %>%  
        #    dplyr::filter(filename == input$music$name)
        #data2 <- file
        pred <- predict(bst,as.matrix(data2))
        #data2.label <- as.numeric(data2[,"label"])-1
        prediction <- matrix(pred,nrow = 10,
                             ncol = length(pred)/10) %>% 
            t() %>% 
            data.frame() %>% 
            #filename = data2[,1],
            #label = data2.label +1,
            mutate(max_prob = max.col(.,"last"))
        outresult <- switch(prediction$max_prob,"blues","classical","country","disco","hiphop",
                            "jazz", "metal", "pop", "reggae", "rock")
        infoBox(
            "Classify Results", paste(round(100*max(prediction[,1:10]),digits = 2),"% ",outresult,sep = "") , icon = icon("drum-steelpan")
        )
    })
    
    
    output$boxplot <- renderPlot({
    
        mg_tbl %>% 
            select(input$features,label) %>%
            ggplot(aes(x = label,y = .data[[input$features]], fill = label))+
            geom_boxplot() +
            ggtitle(paste(input$features,"boxplot for genres", sep = " "))+
            xlab("Music Genres")+
            ylab(input$features)
        
        
        
        #ggplot(data = mydata, aes(x = label, y = mydata[,input$features],fill = label)) +
        #    geom_boxplot() +
        #    ggtitle(paste(input$features,"boxplot for genres", sep = " "))+
        #    xlab("Music Genres")+
        #    ylab(input$features)
    })
    
    output$cor <- renderPlot({
        mg_tbl %>% 
            select(grep(pattern = input$corx,colnames(mg_tbl),value = TRUE)) %>% 
            ml_corr(method = "pearson") %>% 
            ggcorrplot(type = "full",
                       outline.color = "white",
                       tl.cex = 6, tl.srt = 90) +
            ggtitle(paste("Correlation heatmap for the", input$corx, "variables",sep = " "))
        
        
        
        
        #cor.x <- X[,grep(input$corx,colnames(X))]
        #corM <- cor(cor.x)
        #ggcorrplot(corM,type = "full",
         #          outline.color = "white",
         #          tl.cex = 6, tl.srt = 90) +
         #   ggtitle(paste("Correlation heatmap for the", input$corx, "variables",sep = " "))
    })
    
    output$pca <- renderPlot({
        
        mg_tbl %>% 
            select(-filename,-length,-label) %>% 
            collect() %>% 
            prcomp(scale = TRUE) %>% 
            autoplot(data = collect(mg_tbl),colour = 'label') +
            ggtitle("PCA plot of genres")
        
        #res.pca <- prcomp(X,scale = TRUE)
        #pca.plot <- autoplot(res.pca,data = mydata,colour = 'label') +
        #    ggtitle("PCA plot")
        #pca.plot 
    })
    
    output$density <- renderPlot({
        mg_tbl %>% 
            select(input$features,label) %>% 
            ggplot(aes(x = .data[[input$features]],fill=label)) +
            geom_density(alpha = 0.3) + 
            ggtitle("Density plot of tempo")
    })

}
