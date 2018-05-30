This is an app for analysing CVs of new candidates, in order to quickly assess the fit with the company. A CV can be thought of as a compilation of: 

NOUNS i.e. domains the person has worked in
VERBS i.e. the roles and responsibilities the person has been invovlved with
PROPER NOUNS i.e. the companies, organizations and places mentioned in the CV
ADJECTIVES and ADVERBS i.e. the kind and nature of work the person has experience with

This app lemmatizes the words in the CV to its root form, and then visualizes the important parts of speech (nouns, verbs, adjectives, adverbs, and proper nouns) as word clouds and cooccurrence graphs. It also calculates a sentiment score based on the NRC lexicon to provide a quick snapshot of the person - is he/she confident and trustworthy, or fearful and desperate? A sentiment analysis may throw some light on the nature of the person.

To run this app, you will need a local installation of R, which can be downloaded from https://www.r-project.org/

After installation, run the following commands in R: <br>
source('https://raw.githubusercontent.com/vikramdevatha/text-an-app/master/dependency.R') <br>
runGitHub('CV-Analyser', 'vikramdevatha')
