#Text Analytics - Group Assignment 2: Building a Shiny App around the Adjective
#Aakash Bawa (11910031), Sahil Khurana (11910048) & Vikram Devatha (11910049)
#date: 2-June-2018

ui <- fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      h4("Controls"), br(), 
      
      fileInput("file1", "Upload a CV (pdf, doc, docx or txt)", 
                accept=c('.pdf', '.txt', '.docx'),
                multiple=TRUE),
    
      radioButtons("radio", "Colors for the wordclouds",
                   choices = list("Dark" = "Dark2", 
                                  "Paired" = "Paired",
                                  "Set1" = "Set1",
                                  "Set2" = "Set2",
                                  "Spectral" = "Spectral"), 
                   selected = "Set1"), #default selection
      br(),
      
      sliderInput("integer1", "Number of words to plot",
                  min = 0, max = 100,
                  value = 50),
      br(),
      
      sliderInput("integer3", "Minimum frequency of words to plot",
                  min = 1, max = 10,
                  value = 5),
      
      br(),
      
      sliderInput("range1", "Range of word sizes",
                  min = 0.1, max = 5,
                  value = c(0.25,2.5)),
      br(),
      
      checkboxGroupInput("checkGroup", 
                         "Parts of speech for cooccurance plot", 
                         choices = list("Adjectives (kind and nature of work)" = "ADJ", 
                                        "Adverb (quality of work)" = "ADV",
                                        "Nouns (domains)" = "NOUN", 
                                        "Proper nouns (places & organizations)" = "PROPN",
                                        "Verbs (roles and responsibilities)" = "VERB"),
                         selected = c("ADJ", "NOUN")), #default selection
      br(),
      
      sliderInput("integer2", "Size of cooccurance plot",
                  min = 0, max = 10,
                  value = 5),
      br()
      
    ), #end of sidebarPanel
    
    mainPanel(
      #"Title for main panel",
      
      tabsetPanel(type="tabs",
                  
                  tabPanel("Read me",
                           h3('CV Analyser'),
                           p('This is an app for analysing CVs of new candidates, in order to quickly assess the fit with the company. A CV can be thought of as a compilation of:'),
                           p('NOUNS i.e. domains the person has worked in'),
                           p('VERBS i.e. the roles and responsibilities the person has been invovlved with'), 
                           p('PROPER NOUNS i.e. the companies, organizations and places mentioned in the CV'),
                           p('ADJECTIVES and ADVERBS i.e. the kind and nature of work the person has experience with'), br(),
                           p('This app lemmatizes the words in the CV to its root form, and then visualizes the important parts of speech (nouns, verbs, adjectives, adverbs, and proper nouns) as word clouds and cooccurrence graphs.'),
                           p('It also calculates a sentiment score based on the NRC lexicon to provide a quick snapshot of the person - is he/she confident and trustworthy, or fearful and desperate? A sentiment analysis may throw some light on the nature of the person.'), br(),
                           h4('App controls'),
                           p('The options on the left can be used to upload the CV, and then control the display parameters such as '),
                           p('- the color of the word clouds'),
                           p('- number of words ot plot in the wordclouds'),
                           p('- the minimum frequency of words to consider for the plot'),
                           p('- the range of word sizes for the word clouds'),
                           p('- the parts of speech to consider for making the cooccurrence graphs'),
                           p('- the size fo the cooccurrence graph')),#end of tabPanel
                  
                  tabPanel("Annotated document",
                           h3('Annotated CV'), br(),
                           p('Here is a table of the annotated CV. Only 100 rows are displayed, and the table can be downloaded as a csv file. The download button can be found at the bottom of this page.'), br(),
                           dataTableOutput('mytable1'),
                           downloadButton("downloadText", "Download Annotated CV")
                  ), #end of tabPanel
                  
                  tabPanel("Wordclouds",
                           h3('Nouns (domains of work)'), 
                           p('Here is a wordcloud of the nouns in the CV.'),
                           p('This may give a quick snapshot of the domains the candidate has worked in.'),
                           br(), plotOutput('nounwordcloud'),
                           br(), h3('Verbs (roles and responsibilities)'),
                           p('Here is a wordcloud of the verbs in the CV.'),
                           p('This may give a quick overview of the roles and responsibilities that the candidate has been invovled with.'),
                           br(), plotOutput('verbwordcloud')), #end of tabPanel
                  
                  tabPanel("Cooccurances",
                           h3('Cooccurance Graph'),
                           p('Here is a coccurance plot of the selected parts of speech. The relevant parts of speech can be selected in the controls panel to the left.'),
                           p('- Select only Nouns for a quick snapshot of the fields of expertise'),
                           p('- Select only Adjectives to see how the candidate describes him/herself'),
                           p('- To see what a candidate did in different companies or places, select Nouns (domains) and Proper nouns (places & organizations)'),
                           p('- Select Proper nouns and Verbs to see the roles and responsibilities a candidate has undertaken in different places and companies'),
                           br(), plotOutput("anndoccooc")), #end of tabPanel
                     
                    tabPanel("Sentiment",
                             h3('Sentiment'),
                             p('Here are two sentiment analyses of the candidate. The first is based on the National Research Council (NRC) emotion lexicon. The second is based on the AFINN lexicon, as labelled by Finn Arup Nielsen.'),
                             br(), 
                             h4('NRC Lexicon'), br(),
                             dataTableOutput('senttable'), br(),
                             h4('AFINN Lexicon'), br(),
                             br(), dataTableOutput('senttable2')) #end of tabPanel
                  
      ) #end of tabsetPanel
    ) #end of mainPanel
  ) #end of sidebarLayout
) #end of fluidpage
