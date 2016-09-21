---

title: "dpSlate Identical Headers Test"

titlePage: ON

tableOfContents: ON

tocAccordion: 3 

rightPanel: OFF

leftPanel: ON

languageTabs:
  - md: Markdown
  
tocSelectors: "h1,h2,h3"

---

# Introduction 

This is a test to make sure that dpSlate can handle identical headers properly in the Table of Contents.  That is, the same header text will be used in the same document to ensure that the Table of Contents can distinguish them.

# Success Criteria

This test is successful if the markdown generates the proper HTML.  The test is successful if:

- The content below is rendered properly.
- Each header in the ToC can be found in the Text
- As you scroll down the text, each new header can be found in the Toc
- The document has two Panes, with a Table of Contents to the left but with Markdown Samples inline
- The document has a collapsable Title Page at the Top
- The title page has a copyright, publisher, and publisherAddress which comes from the `default.yml`
- The document does NOT have a search box (search boxes go away in single column documents)
- The document has a Table of contents under the Title Page
- Headers h1, h2, and h3 are shown in the Table of contents

# Test Cases

This is the first H1 in the document.

## H2

This is the first H2.

### H3

This is the first H3.

# Test Cases

This is a second instance of the same H1.

## H2

This is the second identical H2.

### H3

This is the second identical H3.


# Test Cases

This is a third instance of the same H1.

## H2

This is the third identical H2.

### H3

This is the third identical H3.
