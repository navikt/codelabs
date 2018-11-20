# WHAT

[NAVIKT codelabs](https://navikt.github.io/codelabs/) is based on [google codelabs](https://codelabs.developers.google.com/) and provide a guided, tutorial, hands-on coding experience.

# HOW

## Install 

* Install claat - see [https://github.com/googlecodelabs/tools/tree/master/claat](https://github.com/googlecodelabs/tools/tree/master/claat)
* Write a codelab! See [https://github.com/googlecodelabs](https://github.com/googlecodelabs/tools/tree/master/claat) for instructions

## Generate content from markdown & push codelab to github pages. 

* `claat export --prefix "../" -o docs codelab-name.md` 
* `cd docs && claat build` 

and commit & push files to master