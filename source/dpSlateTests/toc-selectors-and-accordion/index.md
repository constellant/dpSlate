---

title: "dpSlate tocSelector and tocAccordion Test"

version: "V4.1" 

titlePage: ON

tableOfContents: ON

tocAccordion: 4

rightPanel: OFF

leftPanel: ON

documentSearch: ON

languageTabs:
  - shell: Sample
  - python: Python
  - ruby: Ruby
  
tocSelectors: "h1,h2,h3,h4,h5,h6"

---

# Introduction 

This test will examine the tocSelector and tocAccordion directives.  The document will have three groups of six headers below called "Header 1" through "Header 6" in the body of the document.  If sucessful, then:

1.  All three groups of the six headers will be displayed properly.
2.  Clicking on the second group of the six headers will position the document into the second set of six headers (that is they are unique)
2.  Only the "Headers 1" through "Headers 4" will be displayed when the document opens, but when you click on the "Header 4" the "Header 5" is displayed in the Table of Contents
2.  When you click on the "Header 5" in the Table of Contents, then the "Header 6" is displayed.


# H1 Header

The is the text for Header 1.

## H2 Header

The is the text for Header 2.

### H3 Header

The is the text for Header 3.

#### H4 Header

The is the text for Header 4.

##### H5 Header

The is the text for Header 5.

###### H6 Header

The is the text for Header 6.

# H1 Header

The is the text for second, Header 1.

## H2 Header

The is the text for second, Header 2.

### H3 Header

The is the text for second, Header 3.

#### H4 Header

The is the text for second, Header 4.

##### H5 Header

The is the text for second, Header 5.

###### H6 Header

The is the text for second, Header 6.

# H1 Header

The is the text for third, Header 1.

## H2 Header

The is the text for third, Header 2.

### H3 Header

The is the text for third, Header 3.

#### H4 Header

The is the text for third, Header 4.

##### H5 Header

The is the text for third, Header 5.

###### H6 Header

The is the text for third, Header 6.

