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
      
      radioButtons("model", label = h4("Download English model?"),
             choices = list("Yes please" = "Yes", 
                            "No, I have it in my working directory" = "No"), 
             selected = "No"), #default selection
      br(),
      
      radioButtons("radio", label = h4("Colors for the wordclouds"),
                   choices = list("Accent" = "Accent", 
                                  "Dark" = "Dark2", 
                                  "Paired" = "Paired",
                                  "Set1" = "Set1",
                                  "Set2" = "Set2",
                                  "Spectral" = "Spectral"), 
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
