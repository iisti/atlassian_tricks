# Convert Git Flavored Markdown to JIRA/Confluence markdown
* https://pandoc.org/

* Install pandoc (Debian)
    ~~~
    sudo apt-get install pandoc
    ~~~

* Convert a Git Flavored Markdown to JIRA markdown with Pandoc

    ~~~
    pandoc -f gfm -t jira -o file_in_jira_markdown.txt input_file_in_git_markdown.md
    # f = from
    # t = to
    # o = output
    # the last file is input file
    ~~~
* Code blocks were automatically formatted to JAVA, but usually **noformat** is better, because sometimes the hilighting or formatting is confusing, **noformat** creates just a plain code block. The 2 commands below will covert **code blocks** to **noformat** blocks.

    ~~~
    # This format is for MacOS. Linux works probably without with the first '' quotes.
    sed -i '' 's/{code:java}/{noformat}/g' file_in_jira_markdown.txt
    sed -i '' 's/{code}/{noformat}/g' file_in_jira_markdown.txt
    ~~~

# Convert JIRA Markdown to GitHub Flavored Markdown
* Pandoc doesn't support converting from JIRA to other syntaxes (20.3.2021). J2M can be used to convert JIRA to Markdown.
  * https://github.com/FokkeZB/J2M

* Installation (Debian WSL)
    ~~~
    sudo apt-get update
    sudo apt-get install nodejs npm

    sudo npm install -g j2m
    ~~~

* Usage
    ~~~
    j2m [--toM|--toJ] [--stdin] $filename 

    Options: 
    --toM, -m:    Treat input as jira text and convert it to Markdown 
    --toJ, -j:    Treat input as markdown text and convert it to Jira 
    --stdin:      Read input from stdin. In this case the give filename is ignored 
    ~~~
    * Example
    ~~~
    j2m --toM jira_file.txt > file_in_markdown.md
    ~~~

