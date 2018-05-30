if (!require(dplyr)) {install.packages("dplyr")}; library(dplyr)
if (!require(udpipe)) {install.packages("udpipe")}; library(udpipe)
if (!require(textrank)) {install.packages("textrank")}; library(textrank)
if (!require(lattice)) {install.packages("lattice")}; library(lattice)
if (!require(igraph)) {install.packages("igraph")}; library(igraph)
if (!require(ggraph)) {install.packages("ggraph")}; library(ggraph)
if (!require(ggplot2)) {install.packages("ggplot2")}; library(ggplot2)
if (!require(wordcloud)) {install.packages("wordcloud")}; library(wordcloud)
if (!require(RColorBrewer)) {install.packages("RColorBrewer")}; library(RColorBrewer)
if (!require(stringr)) {install.packages("stringr")}; library(stringr)
if (!require(textreadr)) {install.packages("textreadr")}; library(textreadr)
if (!require(tools)) {install.packages("tools")}; library(tools)
if (!require(shiny)) {install.packages("shiny")}; library(shiny)
if (!require(shinyjs)) {install.packages("shinyjs")}; library(shinyjs)


ui <- fluidPage(
  #titlePanel("Natural Language Processing"),
  
  sidebarLayout(
    sidebarPanel(
      
      fileInput("file1", "Upload a file (pdf, docx or txt)", 
                accept=c('.pdf', '.txt', '.docx'),
                multiple=TRUE),
      
      fileInput("file2", "Upload another file (pdf, docx or txt)", 
                accept=c('.pdf', '.txt', '.docx'),
                multiple=TRUE),
      
      radioButtons("radio", label = h4("Colors for the wordclouds"),
                   choices = list("Accent" = "Accent", 
                                  "Dark2" = "Dark2", 
                                  "Paired" = "Paired",
                                  "Pastel1" = "Pastel1",
                                  "Pastel2" = "Pastel2",
                                  "Paired" = "Paired"), 
                   selected = "Accent"), #default selection
      br(),
      
      sliderInput("integer1", "Number of words to plot",
                  min = 0, max = 100,
                  value = 50),
      br(),
      
      sliderInput("integer3", "Min freq of words to plot",
                  min = 1, max = 10,
                  value = 5),
      
      br(),
      
      sliderInput("range1", "Range of word sizes",
                  min = 0.1, max = 5,
                  value = c(0.25,2.5)),
      br(),
      
      checkboxGroupInput("checkGroup", 
                         label = h4("Parts of speech for cooccurance plot"), 
                         choices = list("Adjective" = "ADJ", 
                                        "Noun" = "NOUN", 
                                        "Proper noun" = "PROPN",
                                        "Adverb" = "ADV",
                                        "Verb" = "VERB"),
                         selected = c("ADJ", "NOUN")), #default selection
      br(),
      
      sliderInput("integer2", "Size of co-occurance plot",
                  min = 0, max = 10,
                  value = 5)
      
    ), #end of sidebarPanel
    
    mainPanel(
      #"Title for main panel",
      
      tabsetPanel(type="tabs",
                  
                  tabPanel("Read me",
                           h3('About this app'),
                           p("Need to write what this app does here")), #end of tabPanel
                  
                  tabPanel("Annotated document",
                           h3('Annotated document'),
                           p('Table of the annotated document as a dataframe'),
                           dataTableOutput('mytable1'),
                           downloadButton("downloadText", "Download Annotated Text")
                  ), #end of tabPanel
                  
                  tabPanel("Wordclouds",
                           h3('Nouns'),
                           p('Here is a wordcloud of the nouns in the uploaded document'),
                           br(), plotOutput('nounwordcloud'),
                           br(), h3('Verbs'),
                           p('Here is a wordcloud of the verbs in the uploaded document'),
                           br(), plotOutput('verbwordcloud')), #end of tabPanel
                  
                  tabPanel("Cooccurances",
                           h3('Co-occurances'),
                           p('Here is a coccurance plot of the selected parts of speech'),
                           br(), plotOutput("anndoccooc")) #end of tabPanel
                  
      ) #end of tabsetPanel
    ) #end of mainPanel
  ) #end of sidebarLayout
) #end of fluidpage




server = function(input, output, session){
  
  Dataset = reactive({
    inFile <- input$file1
    ext = file_ext(sub("\\?.+", "", inFile$name))
    if(is.null(inFile)) {return(NULL)}
    else{
      if(ext == 'txt') { #check if file extension is txt
        text1 = readLines(inFile$datapath) #read the file
        text2 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
        return(text2)}
      else{
        if(ext == 'pdf') { #check if file extension is pdf
          text1 = pdf_text(inFile$datapath) #read the file
          text2 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
          return(text2)}
        else{
          if(ext == 'docx') { #check if file extension is docx
            text1 = read_docx(inFile$datapath) #read the file
            text2 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
            return(text2)}}}
    }
  }) #end of Dataset
  
  englishmodel = reactive({
    englishmodel = udpipe_load_model("/Users/vikram/Documents/Dropbox/Personal/Analytics/TA/_Assignments/Group Assignment/udPipe and NLP/english-ud-2.0-170801.udpipe")
    #to make the app download the english model and load it at clients end
    #x = udpipe_download_model(language = "english") #download the english model
    #english_model = udpipe_load_model(x$file_model) #load the english model
    return(englishmodel)
  }) #end of english model
  
  anntext = reactive({
    anndoc = udpipe_annotate(englishmodel(), Dataset()) #tokenizes, tags and parses the text
    anndoc = as.data.frame(anndoc) #converts the output into a data frame
    anndoc = mutate(anndoc, sentence=NULL) #drop the sentence column from the data frame
    head(anndoc, 100) #show only a hundred rows and store in a new variable
    return(anndoc)
  }) #end of ann.text
  
  output$downloadText = downloadHandler(
    # Tell the client browser what name to use when saving the file
    filename = function() {
      paste("annotated_text", ".csv", sep = "")
    },
    
    content = function(file){
      write.csv(anntext(), file, row.names=FALSE)
    }) #end of output$download.text
  
  output$mytable1 = renderDataTable({
    inFile <- input$file1
    if(is.null(inFile)) {return(NULL)}
    else{
      table = anntext()
      return(table)
    }
  }) #end of output$mytable
  
  output$nounwordcloud = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    
    if(is.null(inFile)) {return(NULL)}
    else{
      nouns = anntext() %>% subset(., upos %in% "NOUN")
      nounsdf = nouns %>% group_by(lemma) %>% count(lemma, sort=TRUE) #count number of nouns
      colnames(nounsdf) = c("nouns", "count") #rename the columns
      wordcloud(nounsdf$nouns, nounsdf$count, # words, their freqs 
                scale = range1, #range of words
                min.freq=minfreq, # min.freq of words to consider
                max.words = nowords, # max #words
                colors = brewer.pal(6, color))
    }
  }) #end of output$noun.wordcloud
  
  output$verbwordcloud = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    
    if(is.null(inFile)) {return(NULL)}
    else{
      verbs = anntext() %>% subset(., upos %in% "VERB")
      verbsdf = verbs %>% group_by(lemma) %>% count(lemma, sort=TRUE) #count nouns
      colnames(verbsdf) = c("verbs", "count") #rename the columns
      wordcloud(verbsdf$verbs, verbsdf$count, # words, their freqs 
                scale = range1, #range of words
                min.freq=minfreq, # min.freq of words to consider
                max.words = nowords, # max #words
                colors = brewer.pal(6, color))
    } #end of else
  }) #output$verb.wordcloud
  
  output$anndoccooc = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    
    if(is.null(inFile)) {return(NULL)}
    else{
      anndoccooc = cooccurrence(x = subset(anntext(), upos %in% input$checkGroup), 
                                term = "lemma", 
                                group = c("doc_id", "paragraph_id", "sentence_id"))
      
      words = head(anndoccooc, nowords) #display a plot of top-30 co-occurrences
      words = igraph::graph_from_data_frame(words) # creates an igraph object for plotting
      
      ggraph(words, layout = "fr") +  
        geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
        geom_node_text(aes(label = name), col = "darkgreen", size = size) +
        theme_graph(base_family = "Arial Narrow") +  
        theme(legend.position = "none")
    } #end of else
  }) #end of output$ann.doc.cooc
} #end of function



shinyApp(ui=ui, server=server)
