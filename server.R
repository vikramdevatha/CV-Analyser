#Text Analytics - Group Assignment 2: Building a Shiny App around the Adjective
#Aakash Bawa (11910031), Sahil Khurana (11910048) & Vikram Devatha (11910049)
#date: 2-June-2018

server = function(input, output, session){
  
  Dataset = reactive({
    req(input$file1) #ensure file has been uploaded, if not, stop
    inFile <- input$file1
    ext = file_ext(sub("\\?.+", "", inFile$name)) #get the file extension
      if(ext == 'txt') { #check if file extension is txt
        text1 = readLines(inFile$datapath) #read the file
        #text1 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
        return(text1)}
      else{
        if(ext == 'pdf') { #check if file extension is pdf
          text1 = pdf_text(inFile$datapath) #read the file
          #text1 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
          return(text1)}
        else{
          if(ext == 'docx') { #check if file extension is docx or doc
            text1 = read_docx(inFile$datapath) #read the file
            #text1 = str_replace_all(text1, "<.*?>", "") # get rid of html junk
            return(text1)}
          else{
            if(ext == 'doc') { #check if file extension is docx or doc
              text1 = read_doc(inFile$datapath) #read the file
              return(text1)}
          }}}

  }) #end of Dataset
  
  anntext = reactive({
    library(udpipe) #check if this works for shinyapps
    englishmodel = udpipe::udpipe_load_model("english-ud-2.0-170801.udpipe") #load the english model
    anndoc = udpipe_annotate(englishmodel, Dataset()) #tokenizes, tags and parses the text
    anndoc = as.data.frame(anndoc) #converts the output into a data frame
    anndoc = mutate(anndoc, sentence=NULL) #drop the sentence column from the data frame
    anndoc = anndoc[, c(5,6,7,8,9,1,2,3,4,10,11,12,13)] #reorder the columns
    head(anndoc, 100) #show only a hundred rows
    return(anndoc)
  }) #end of ann.text
  
  output$downloadText = downloadHandler(
    filename = function() {
      paste("annotated_text", ".csv", sep = "") #default file name for saving
    },
    content = function(file){
      write.csv(anntext(), file, row.names=FALSE) #save the file
    }) #end of output$download.text
  
  output$mytable1 = renderDataTable({
    table = anntext()
    return(table)
  }) #end of output$mytable
  
  output$nounwordcloud = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    
    nouns = anntext() %>% subset(., upos %in% "NOUN") #subset the dataset for nouns
    nounsdf = nouns %>% group_by(lemma) %>% count(lemma, sort=TRUE) #count number of nouns
    colnames(nounsdf) = c("nouns", "count") #rename the columns
    wordcloud(nounsdf$nouns, nounsdf$count, # words, their freqs 
              scale = range1, #range of words
              min.freq=minfreq, # min.freq of words to consider
              max.words = nowords, # max #words
              colors = brewer.pal(6, color))
  }) #end of output$noun.wordcloud
  
  output$verbwordcloud = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    
    verbs = anntext() %>% subset(., upos %in% "VERB") #subset the dataset for verbs
    verbsdf = verbs %>% group_by(lemma) %>% count(lemma, sort=TRUE) #count nouns
    colnames(verbsdf) = c("verbs", "count") #rename the columns
    wordcloud(verbsdf$verbs, verbsdf$count, # words, their freqs 
              scale = range1, #range of words
              min.freq=minfreq, # min.freq of words to consider
              max.words = nowords, # max #words
              colors = brewer.pal(6, color))
  }) #output$verb.wordcloud
  
  output$anndoccooc = renderPlot({
    inFile = input$file1 #content in the uploaded file
    color = input$radio #colors for the word cloud plots
    nowords = input$integer1 #no of words to plot
    size = input$integer2 #size of cooccurance plot
    minfreq = input$integer3 #min freq of words to plot
    range1 = input$range1 #range of words in the wordcloud
    library(udpipe) #check if this works for shinyapps
    anndoccooc = udpipe::cooccurrence(x = subset(anntext(), upos %in% input$checkGroup), 
                              term = "lemma", 
                              group = c("doc_id", "paragraph_id", "sentence_id"))

    words = head(anndoccooc, nowords) #display a plot of top-30 co-occurrences
    words = igraph::graph_from_data_frame(words) # creates an igraph object for plotting

    ggraph(words, layout = "fr") +  
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = size) +
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none")
  }) #end of output$anndoccooc
  
  output$senttable = renderDataTable({
  library(tidytext) #check if this works for shinyapps
  lexicon <- tidytext::get_sentiments("nrc")
  sentiment = anntext() %>% select(token) %>% #select the word
    anti_join(stop_words, by=c("token"="word")) %>%  #remove the stop words
    left_join(lexicon, by = c("token"="word")) %>% #map with the lexicon
    filter(!is.na(sentiment)) %>% #remove words that are not matched
    group_by(sentiment) %>%
    summarise(score=n()) #summarise and rename the column
  sentiment = sentiment[order(-sentiment$score),] #sort by descending order of sentiment
  return(sentiment)
  }) #end of output$senttable
  
  output$senttable2 = renderDataTable({
    library(tidytext) #check if this works for shinyapps
    lexicon <- tidytext::get_sentiments("afinn")
    sentiment2 = anntext() %>% select(token) %>% #select the word
      anti_join(stop_words, by=c("token"="word")) %>%  #remove the stop words
      left_join(lexicon, by = c("token"="word")) %>% #map with the lexicon
      filter(!is.na(score)) %>% #remove words that are not matched
      group_by(token) %>%
      summarise(score=n()) #summarise and rename the column
    sentiment2 = sentiment2[order(-sentiment2$score),] #sort by descending order of sentiment
    return(sentiment2)
  }) #end of output$senttable
  
} #end of function
