---

title: "dpSlate Markdown Include Test "

version: "V4.2" 

titlePage: ON

tableOfContents: ON

tocAccordion: 3

rightPanel: ON

leftPanel: ON

documentSearch: ON

languageTabs:
  - shell: Sample
  - python: Python
  - ruby: Ruby
  
tocSelectors: "h1,h2,h3"

---

# Header from Main File

{{ source/dpSlateTests/markdown-includes/includes/_intro.md  }}
{{source/dpSlateTests/markdown-includes/includes/_close.md}}


# Below you should see a file error message

{{path/withnofileinmain.md}}

# Below are tests of special includes

dpSlate also can use the include markdown to display settings variables (a.k.a., YAML Page directives).  These are in the form of `=variable` Below are some Page directives

`=version` is:  {{ =version }}

`=copyright` is:  {{=copyright}}

`=undefined` is:  {{  =undefined }}