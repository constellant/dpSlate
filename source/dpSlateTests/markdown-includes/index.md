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
  
tocFooters:

---

{{source/dpSlateTests/markdown-includes/includes/_intro.md}}
{{source/dpSlateTests/markdown-includes/includes/_close.md}}


# Below you should see a file error message

{{path/withnofileinmain.md}}