---

title: "dpSlate Abbreviation Markdown Test"

version: "v4.2"

titlePage: ON

tableOfContents: ON

tocAccordion: 2 

rightPanel: ON

leftPanel: ON

languageTabs:
  - md: Markdown
  
tocSelectors: "h1,h2"

---

# Introduction 

This is a Markdown Abbreviation test to insure support for the abbreviation markup.

# Abbreviations 

> Abbreviations Markdown

```md

[HTML]: Hyper Text Markup Language

[W3C]: World Wide Web Consortium

[YXZ]: An Abbreviation that is not in the document

```

This test is successful if the markdown generates the proper HTML.  The test is successful if in the text below:

- each occurance of HTML in the text has a hover tool tip that defines the abbreviation.
- each occurance of W3C in the text has a hover tool tip that defines the abbreviation.

`this is an abbreviation HTML inside of back ticks`

*[HTML]: Hyper Text Markup Language

*[W3C]: World Wide Web Consortium

*[YXZ]: An Abbreviation that is not in the document

# Footnotes

> Footnotes Markdown

```md
Now is the time[^undefinedFootnote] for all goodmen[^somesamplefootnote] to come to the aid of their country.

Right after the word `time` above is a footnote reference which has not been defined.

[^somesamplefootnote]: Here is the text of the footnote itself.  Footnotes can be a large body of text.  They will appear at the end of the document with a horizontal rule above them.  Footnotes can contain _markdown_ which will be processed properly.

[^footnotewithoutaref]: Here is a definition of a footnote that does not have a reference in the text.

```

Now is the time[^undefinedFootnote] for all goodmen[^somesamplefootnote] to come to the aid of their country.

Right after the word `time` above is a footnote reference which has not been defined.

[^somesamplefootnote]: Here is the text of the footnote itself.  Footnotes can be a large body of text.  They will appear at the end of the document with a horizontal rule above them.  Footnotes can contain _markdown_ which will be processed properly.

[^footnotewithoutaref]" Here is a definition of a footnote that does not have a reference in the text.

# Test Cases

The HTML standard is maintained by the W3C.

# Footnotes

Use the `$footnotes` include to see all of the footnotes printed below:

{{$footnotes}}


# Abbreviations

Use the `$abbreviations` include to see all of the abreviations printed below:

{{$abbreviations}}