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
    x = udpipe_download_model(language = "english") #download the english model
    englishmodel = udpipe_load_model(x$file_model) #load the english model
    #englishmodel = udpipe_load_model("/Users/vikram/Documents/Dropbox/Personal/Analytics/TA/_Assignments/Group Assignment/udPipe and NLP/english-ud-2.0-170801.udpipe")
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
