---

title: "dpSlate User's Guide"

version: "V4.2" 

copyright: "Copyright &copy; 2013-2015 Perigee Capital, LLC., Portions Copyright 2008-2013 by Concur Technologies, Inc. All Rights Reserved."

publisher: "DeveloperProgram.com"

publisherAddress: "Perigee Capital LLC., 2300 Greenhill Drive, Suite 400, Round Rock, TX 78664, USA"

comments: "dpSlate is Licensed under the Apache License, Version 2.0 (the License); you may not use this file except in compliance with the License. You may obtain a copy of the License on the site http://www.apache.org at /licenses/LICENSE-2.0.  Unless required by applicable law or agreed to in writing, the dpSlate software distributed under the License is distributed on an AS IS BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.  The Perigee Capital, DevelopProgram.com, DP.com, dpSlate, and the dp.com Logo are trademarks of Perigee Capital, LLC."

titlePage: ON

tableOfContents: ON

tocAccordion: 1

rightPanel: ON

leftPanel: ON

documentSearch: ON

languageTabs:
  - shell: Examples
  
tocSelectors: "h1,h2,h3"
  
tocFooters:

---

# Introduction 

dpSlate is an HTML authoring tool that help authors more effectively communicate to an audience.  Originally designed specifically to author API reference manuals, it has been expanded to create a much wider selection of documents.  As a result of enhancements to dpSlate, it can now be used to create many different types of documents including:

* Overviews
* Getting Started Guides
* Tutorials
* Technical Reference Manuals
* Sample Apps

To accommodate the need to deal with different types of documents, dpSlate allows the document author to control the structure of how the document will be formatted.  Each dpSlate document can have up to three different panels that the author can turn on or off as required:

* _Left Hand Panel_ - used for document meta-data such as a title page, document search, and table of contents.

* _Center Panel_ - used for the contents of the document.

* _Right Hand Panel_ used for code samples and other technical reference materials. 

## Three Panel Mode

> dpSlate Document with all three panels on

> ![dpSlate with Three Panels](/static/images/dpSlateHelp/threePanel.png)

When all three panels are turned on, the dpSlate document will look as shown.  The three panels are for the document meta-data (left), body of the document, and supporting materials to the right.

## Two Panel Mode

> dpSlate Document with two panels on

> ![dpSlate with Two Panels](/static/images/dpSlateHelp/twoPanel.png)


When the right panel is turned off, the supporting materials that were in the right hand panel are not brought into the center panel at the appropriate place.  The left hand panel is not imacted.

## One Panel Mode

> dpSlate Document with one panel on

> ![dpSlate with One Panels](/static/images/dpSlateHelp/onePanel.png).

Finally, when the left hand panel is turned off, the document becomes a single column document with the meta-data at the top and the body of the document below.  

-> When the Left Hand Panel is turned off, the Right Hand Panel will also be turned off at the same time.
 

# Getting Started

dpSlate can be used either stand alone on a PC or can be used to automatically publish documents to your portal if it is powered by dpEngine.  When you use dpSlate, you need to determine if you want to work in _Stand Alone Mode_ or _dpEngine Mode_.  

## Installing Stand Alone Mode  

> What Version of Ruby is Installed?

```shell
$ ruby -v

ruby 2.0.0p247 (2013-06-27 revision 41674)

```

> Install the Dependencies

```shell
$ cd dpSlate
$ bundle install
```

> Start Your Test Server

```shell
$ bundle exec middleman server
== The Middleman is loading
== The Middleman is standing watch at http://0.0.0.0:4567
== Inspect your site configuration at http://0.0.0.0:4567/__middleman/

```

 1. Login to Github and fork this repository on Github (https://github.com/pnerger/dpSlate)
 2. Clone *your forked repository* (not our original one) to your hard drive with `git clone https://github.com/{YOURUSERNAME}/dpSlate.git`
 3. `cd dpSlate`
 4. Install all dependencies: `bundle install`
 5. Start the test server: `bundle exec middleman server`
 
 ___OR___

 1. Login to Github and download the dpSlate Zip file (https://github.com/pnerger/dpSlate)
 2. unzip the zip file into the directory that you want to work in.
 3. cd to that directory.
 4. Install all dependencies: `bundle install`
 5. Start the test server: `bundle exec middleman server`

You can now see the docs using your browser at <http://localhost:4567>. And as you edit and save your `source/index.md`, your server should automatically update! Whoa! That was fast!

When you use dpSlate in a standalone mode, your markdown source will be in your `/source` subdirectory in your dpSlate folder while the generated output will be stored in the `/site` directory in your dpSlate folder.

## Using with dpEngine

> Directory structure of the _dpSlate source repo_ on Bitbucket

```
\source
    _defaults.yml - this file contains your site defaults for YAML directives
    \xyz
        _defaults.yml - this file contains default YAML directives for everything below it
        \abc
            _defaults.yml - this file contains default YAML directives for the adjacent markdown file
            index.md - this is your source document
    \static
        \images
             \xyz
                \abc
                   image1.png - these are your images for your document
        \css
        \data
        \fonts
        \includes
            \xyz
                \abc
                    _partial1.md - these are your partials for inclusion into your document
```

> Directory structure of the _content repo_ on Bitbucket

``` 
\site
	\xyz
		\abc
			index.gsp - this is your formatted document for your portal
    \static
        \images
			 \xyz
				\abc
				    image1.png - these are your compressed images
        \css
        \data
        \fonts

```

If you have a portal that is powered by dpEngine, there is nothing to install for dpSlate works automatically with dpEngine.  

When you use dpEngine, your web portal content is stored in a version of Git called Bitbucket in your _content repo_.  But for your dpSlate documents, you will store your markdown documents in your _dpSlate source repo_. You will be provided with access to Bitbucket for your portal's repository.  Your portal will contain a number of folders that in turn contain the documents that will be published to your portal.  To the right, the file structure of the repo is illustrated.

When you create a dpSlate markdown file in the `\site` directory or any of its subdirectories in your dpSlate source repo, the markdown will automatically be converted into dpEngine grails server page (_i.e._, `.gsp`)  and placed in the \site folder in your content repo..  When this happens, the `.gsp` file will use the headers and footers defined for your site.

The images that you include into your dpSlate markdown document will be stored in the `\site` directory.  Thus, when you edit your dpSlate markdown, the system will automatically manage the resulting dpEngine `.gsp` files on your dpEngine portal. 

As mentioned earlier, when you use dpEngine, there is no need to install dpSlate, it is part of your dpEngine environment. 

### Editing with dpEngine  

There are two ways to edit the Markdown for a dpSlate document hosted in dpEngine; you can either edit it locally using Git or you can edit it inside Bitbucket using a web browser.

When you edit the document locally, you will need to find the document markdown source in the \dpslate\source folder tree in your local Git repository.  After you are done with the edit, you will commit and push the document to your dpEngine stage branch.  Your Bitbucket server will automatically build the HTML instance of the document and it will be accessible in the staging environment for your portal.  You can use any of hundreds of different markdown editors to edit your dpSlate source documents.

The second method is to view the document using your browser in the staging environment.  If you are an authorized _Author_ or _Editor_ for the document, you will see the following buttons on the document:

* _Edit_ - allows you to change the document.  When you press the `edit` button, a Markdown editor will open in your browser with the corresponding dpSlate document loaded.  You simply change your markdown file and when you save it, your document will be converted and your browser will display the recently edited document.
* _Images_ - allows you to manage the images in the dpslate image folder for use within your markdown document.  You can upload or delete images.
* _Publish_ - allows you to publish your new document to your production environment.  The _Publish_ button is only available to those with the _Editor_ role.


# How dpSlate Works

When used in _Stand Alone Mode_, dpSlate generates HTML documents from _dp Flavored Markdown (dpFM)_, a particular dialect of Markdown.  When used in _dpEngine Mode_, dpSlate generates GSP documents from the dpFM Markdown in a particular format that dpEngine wants. dpSlate software is written in Ruby and takes advantage of some popular Ruby software including Middleman, RedCarpet, and Rouge.  The dpSlate software reads a .md (markdown) source-file and will output a .html file along with the accompanying Javascript and CSS files.

To get a consistent look and feel to your web documentation, you will want your  authors to use the dpFM tags in a particular to we get a common and consistent look and feel.

# Structure of a dpSlate Document

As you look at this document, you will notice that there are a couple of feature.  First, to the left is the Table of Contents area.  Next, in the center is the Body of the document, and to the Right (in the dark area) are code examples.  Each of these elements have the following characteristics:

## Left Hand Panel

The panel to the left contains meta-data about your document.  It contains three things, the _Title Page_, the _Search Box_, and the _Table of Contents_.

* _Title Page_ - At the very top, is the title of the document.  If you've enabled the Title Page function, then an _about_ link will be created and when clicked it will open up a title page and provide more information about the document.
* _Search Box_ - If search is enabled, a Search Box will appear above the Table of Contents.  The Search Box is used to search the document looking for phrases of interest.  The phrases are then highlighted in the Table of Contents.
* _The Table of Contents_ - The Table of Contents are automatically built if the feature has been turned on.  By default, on the H1 is normally displayed.  If a user selects a H1 item, the TOC will expand to display the H2 items underneath it.  If the user selects a H2 item, the TOC will expand to display the H3 items underneath it.  Directives are used to control the table of contents.

## Center Panel

The center panel contains the body of the document is found in the center panel and contains the main textual description of the API.  It uses a number of different elements and features to communicate what the API actually does and these include:

* Headers - these are titles of document section of which the H1 and H2 will automatically appear in the TOC
* Paragraphs - these are simple paragraphs of text
* Bold Text
* Italicized Text
* Inline Code Text
* Tables
* Bullet Lists
* Number Lists
* Hints - These are Green Highlighted Text
* Warnings - These are Red Highlighted Text
* Notes - These are Blue Highlighted Text
* Links - HTML hyperlinks to external documents

## Right Hand Panel

The key feature of dpSlate documents is when it is used for technical information.  When the right hand panel in turned on, code samples can be viewed alongside of the API call that they illustrate.  Further sample code can be held simultaneously in several different programming languages (important for SOAP and REST API's).  Because programmers tend to only work in a single language at a time, the dpSlate format accommodates this by having the programming language as a tab on the far right panel.  Thus, the developer is able to choose a programming language and then use the documentation in that language without being distracted by any other language.

Sample code is anchored to either the H1 or H2 heading that they are inserted under; that is, they are placed under the Heading and will move up or down with the main text body. Code samples have the following elements that are used to control their placement:

* Language - there is a tab for each language that is supported and specified in the header.  
* Code Annotations - these are highlighted areas that are not code but used to point out a code section.
* Shared Code Samples - it is possible to make code that appears in all of the tabs.

-> The default behavior is to place code samples into a dedicated right-hand panel.  However, you can also turn off the right-hand panel and the code samples will appear inline with the text in the main panel of the document.
 
  
# Document Directives

> Directives in the Document

```yaml
---
title: "Authoring Documents dpSlate"

version: "V4.1" 

copyright: "Copyright &copy; 2013-2015 Perigee Capital, LLC., Portions Copyright 2008-2013 by Concur Technologies, Inc. All Rights Reserved."

publisher: "DeveloperProgram.com"

publisherAddress: "Perigee Capital LLC., 2300 Greenhill Drive, Suite 400, Round Rock, TX 78664, USA"

comments: "dpSlate is Licensed under the Apache License, Version 2.0 (the License); you may not use this file except in compliance with the License. You may obtain a copy of the License on the site http://www.apache.org at /licenses/LICENSE-2.0.  Unless required by applicable law or agreed to in writing, the dpSlate software distributed under the License is distributed on an AS IS BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.  The Perigee Capital, DevelopProgram.com, DP.com, dpSlate, and the dp.com Logo are trademarks of Perigee Capital, LLC."

titlePage: ON

tableOfContents: ON

tocAccordion: 1

rightPanel: ON

leftPanel: ON

documentSearch: ON

languageTabs:
  - shell: Sample
  - python: Python
  - ruby: Ruby
  
tocSelectors: "h1,h2,h3"
  
---
```

A dpFM source document is a document with a `.md` extension.  These source files are used by dpSlate to generate each of HTML or `gsp` documents that are presented on your portal.  Each dpSlate dpFM source document is a plain text document that starts with a YAML header that contains directives used to control how the document will be formatted.  The YAML header starts and ends with a line that has three dashes, `---`, that start in the first column of the line.

The YAML header contains directives that control how the document will look and appear when it is converted to HTML.  The directives consist of a YAML variable name, the directive, followed by a `:`.  There are four types of YAML variables:

* _Boolean_ - booleans variables are used to turn things on or off using various keywords to represent true or false.  YAML is flexible and the values for true and false are anything that kinda looks like a true or false.  For example true can be represented by `T, TRUE, Y, Yes, or ON` independent of case while the values for false are similar and can be represented by `F, FALSE, N, NO, or OFF` regardless of case.

* _String_ - a string is either a string of text or quoted text.  Text can be quoted either by a double, `"`, or single, `'`, quotation mark.  Boolean keywords that are not in quotes might be interpreted as a boolean directive.

* _List_ -  a list is a collection of items.  The items in the list are strings that are also know as a “hash” or a “dictionary”.  Directives that are lists consist of the directive followed by a number of lines that are indented and start with a dash, `-`, followed by a space. 

* _Integer_ - a numerical value.


The valid dpSlate YAML document directives include:

## Document Panels

A dpSlate document is made up of up to three panels which are turned on or off with the following directives:

* `leftPanel:` is a boolean directive that is used to turn on the left hand panel.  When turned on, the left hand panel will contain the title page, the document search box, the table of contents, and the ToC footer if each of them are turned on.  If the leftPanel is turned off, then the items that should be included in the leftPanel are placed at the top of the center panel.

-> When the Left Hand Panel is turned off, the Right Hand Panel will also be turned off at the same time and the rightPanel directive will be ignored.
 

* `rightPanel:` is a boolean directive that is used to turn on the right hand panel.  When turned on, the right hand panel contains tabs for each programming language that has sample code associated with it.  When the right hand panel is turned off, the code samples are inserted in-line in the center panel.

The Center Panel is always on and cannot be turned on or off.

## Title Page

There are a number of variables that are used for display in the title page of the document.  The Title Page is displayed at the very top of the document is the text "About this Document" which is a link.  When the link is selected, the Title Page will open up and display information about the document from the variables in the header including:

* `titlePage:` is a boolean that when set to true will turn on the Title Page feature. 
* `title:` text string that contains the name of the document.  It is used for both in the Title Page and the &lt;title&gt; tag in the header of the resulting HTML page.
* `version:` a text string used to display the current version of the document in both the Title Page and the TOC Footer (if both are turned on).
* `copyright:` a text string that contains the copyright statement for the document.  Copyright statements should contain the word "Copyright", followed by the copyright symbol of &copy;, followed by the years that the work was first created and the year that it was last modified, and finished off with the phrase "All Rights Reserved."
* `publisher:` a text string that contains the name of the document publisher.
* `publisherAddress:` a text string that contains the address of the publisher.
* `comments:`  a free text string that allows the author to put in information about the document that will help the reader understand the context.

In addition to these values that are set for the Title Page, the date that the document was "built" is displayed at the bottom of the "Title Page" as the "Published Date".

## Language Tabs

The _languageTab_ directive is used to create the programming language tabs that make up the right hand panel of a dpSlate document.  The _languageTab_ directive is a list and thus the _languageTab_ statement is followed by one or more lines containing a statement that contains two blank spaces, a dash, the name of the language for use in encoding the document, an option ":", followed by an optional display name for the language.

The name of the language must be recognized by the system such that the display engine will automatically perform syntax highlighting on the code.  The engine supports lots of different languages but the most common values used are:

* c++:C++
* c#:C#
* css:CSS
* html:HTML
* json:JSON
* java:Java
* javascript:JavaScript
* markdown:dpFM
* objective-c:Objective-C
* perl:Perl
* php: PHP
* puppet:Puppet
* python:Python
* ruby:Ruby
* shell
* xml:XML
* yaml:YAML

-> Only list the languages that you want to have as tabs in your document.  Each time you list a language as a _languageTab_, dpSlate will automatically create the language tab regardless if that language is used in the document.
 

## The Left Hand Panel

When turned on, the far left panel of a dpSlate document contains the title page, the document search box, and the Table of Contents.  The title page is generated from the directives already discussed, the ToC is automatically generated from the Headers found in your dpFM source document but it is controlled by the values you set for directives in the headers of your documents.

## ToC Directives

There are a number of directives for controlling how the Table of Contents is presented.  These are:

* `documentSearch:` a boolean used to turn the document search feature on and off.

-> Document Search is dpSlate's way of providing a full text index for readers.  When you turn on document search in your document, a search box will appear above the  Table of Contents. When the reader types in text into the search box, the Table of Contents will be removed and text in the document that matches the search term will be highlighted with a yellow background.  A _next_ and _prev_ button will be provided to allow the reader to jump to the next and previous hit on the search term.  Search is turned off when the leftPanel is set to `OFF`.
 

* `tocSelectors:` this string is a comma list of the document elements that will be selected for inclusion into the table of contents.  If the statement is missing, then the default value is "h1, h2, h3" which means that Headers 1, 2, and 3 will be included into the Table of Contents.  If you were to choose "h2, h3, h4, h5" then the first level headers would be ignored and only the second, third, fourth, and fifth levels will be selected for inclusion into the Table of Contents.
* `tocAccordion:` this is an integer value that is used to controlling the hiding (collapsing) of items in the table of contents.  The value is set to how many heading levels should open by default (_i.e._, not be collpased).  For example, number 6 will show everything in the Table of Contents since there are only 6 heading levels while the number 0 will hide all of the Table of Content entries until it is time for them to open.  The entries in the Table of Contents that are initially hidden will open when you scroll into those headings and will then close again as you scroll out of them.

-> When the leftPanel is turned off, the `tocAccordion` has no effect.  This is because the Table of Contents will be moved to be above the main body of the document and the accordion nature of the Table of Contents would interfere with the scrolling through the document.

## Default Directives

The YAML directives can be set at a site wide level for all of your documents. Thus, you can avoid typing in the same text for each of the directives for each document.  This feature also allows you to set your site defaults for directives and then change them for all documents quickly.  You do this by modifying the file at `\site\_defaults.yml`.  This file contains all of the directives that you will see in your document and you can set them globally for your site.  If you later define a directive in a specific document, the document value will overide the default value that you set.

Throughout your folder structure 

# dpSlate Flavored Markdown

While the YAML directives control the meta-data of the document, the actual content of your document is done using Markdown, in particular dpSlate Flavored Markdown or dpFM.  This is a version of standard markdown that has been extended to encompass the needs of technical documentation.  dpFM has been designed to allow you to control all of the content needs of a dpSlate document using Markdown alone.  Below are the markdown elements that make up dpFM.

## Headers

Headers are created by using one or more # characters starting in the first line of text within the dpFM document. The sample to the right shows dpFM that will result in a level 1, level 2, and level 3 headers.  Only the level 1 and level 2 headers will appear in the Table of Contents.  When you create sample code, it will anchor to a header.

On the right are a list of headers in markdown and below is how they will appear in the document:
######

> Headings

```markdown
# H1 Header
## H2 Header
### H3 Header
#### H4 Header
#### H5 Header
#### H6 Header

```
Below are some sample headers.

### H3 Header
#### H4 Header
#### H5 Header
#### H6 Header

-> Remember that only the headers that you specify in the YAML directives at the top of your document using the _tocSelector_ directive will appear in the _Table of Contents_.

## Creating a Paragraphs

For normal text, just type your paragraph on a single line.

    This is some paragraph text. Exciting, no?

Make sure the lines above below your paragraph are empty.

## Creating Formatted Text

> Formatting Text in dpFM

```markdown
    This text is **bold**, this is *italic*, and this is an

    `
    Inline code block in the main section.
    `
    
    You can also use underscores to create __bold__ or _italic_.
    
    Finally, you can combine ***bold and italic***.
```

    This text is **bold**, this is *italic*, and this is an

    `Inline code block in the main section.`
    
    You can also use underscores to create __bold__ or _italic_.
    
    Finally, you can combine ***bold and italic***.

=> You can use those formatting rules in code annotations, tables, paragraphs, lists, wherever.


## Strikethrough

```markdown

Strikethrough allows you to show text that is ~~no longer relevant by using strikethrough~~


```

You can format text with a strikethrough by enclosing the text in double tildes, `~~`.  The example to the right becomes:

Strikethrough allows you to show text that is ~~no longer relevant by using strikethrough~~


## Links

> The Three Ways to Create dpFM Links

```markdown
Here's an inline link to [Google](http://www.google.com/).
Here's a reference-style link to [Google][1].
Here's a very readable link to [Yahoo!][yahoo].

  [1]: http://www.google.com/
  [yahoo]: http://www.yahoo.com/
```

There are three ways to write links in dpFM. Each is easier to read than the last.  The code to the right will generate the following:

Here's an inline link to [Google](http://www.google.com/).
Here's a reference-style link to [Google][1].
Here's a very readable link to [Yahoo!][yahoo].

  [1]: http://www.google.com/
  [yahoo]: http://www.yahoo.com/
  
The link definitions can appear anywhere in the document -- before or after the place where you use them. The link definition names [1] and [yahoo] can be any unique string, and are case-insensitive; [yahoo] is the same as [YAHOO].


## Inserting an Image

> dpFM for Inserting an Image Stored Locally

```markdown
![DP Logo](/static/images/logo.png).
```

![DP Logo](/static/images/logo.png).

The Markdown to the right shows how an image can be inserted, in this case, it is the DP Logo that is right above this.  The text inside the square brackets, `[DP Logo]` will become the alt text for the image in the HTML `alt=` parameter.

=> Images essentially look just like a link except that they start with a '!' .

-> Notice that this image is coming from the local image folder.  We recommend that you place your images inside the image folder within your source directory.

## Horizontal Rules

Sometimes you just need a Horizontal Rule (line) to convey something.  dpFM does this with either three or more consecutive Hyphens `-`, Asterisks `*`, or Underscores `_`.


```markdown
Three or more...

---

Hyphens

***

Asterisks

___

Underscores
```
Three or more...

---

Hyphens

***

Asterisks

___

Underscores

## Tables

> dpFM for Creating a Table

```markdown
Table Header 1 | Table Header 2 | Table Header 3
-------------- | -------------: | :------------:
Row 1 col 1 | Row 1 col 2 | Row 1 col 3
Row 2 col 1 | Row 2 col 2 | Row 2 col 3
```

Slate uses PHP Markdown Extra style tables.  The example to the right will create the table below.


Table Header 1 | Table Header 2 | Table Header 3
-------------- | -------------: | :------------:
Row 1 col 1 | Row 1 col 2 | Row 1 col 3
Row 2 col 1 | Row 2 col 2 | Row 2 col 3

Notice the colons in the line underneath the header line.  These are used align that columns of the table. A no colon or only a colon to the left will cause the column to align to the left.  A colon to the right will cause the column to align right.  And a colon to the left and the right will cause the column to center.

-> Note that the pipes do not need to line up with each other on each line. 

-> There must be at least three dashes in each segment of the separator between the header and the body of the table. 

=> If you don't like that syntax, feel free to use normal html \<table\>`s directly in your markdown. 


## Numbered Lists

> dpFM for Numbered Lists

```markdown
1. This
2. Is
  3. Nested
  6. Number
  1. List
3. An
8. Ordered
9. List
```

Numbered lists are created using the dpFM markdown code to the right.  You can create nested lists, but the bullets are indented by two spaces.  The sample code to the right will create the list below:

1. This
2. Is
  3. Nested
  6. Number
  1. List
3. An
8. Ordered
9. List

-> Notice that the order of the numbers do not make a difference.  It is just that a number is used that makes an ordered list.  

-> Note that by indenting by two characters, you are creating an indented list and the numbering restarts and when you go back, the numbering resumes.

## Bulleted Lists

> dpFM for created bullet lists

```markdown
- This
+ Is
  * nested
  - bullet
* A
* Bullet
* List
```

Numbered lists are created using the dpFM markdown code to the right.  you can create nested lists, but the bullets are indented by two spaces.  The sample code
to the right will create the list below:

- This
+ Is
* A
  * nested
  - bullet
* Bullet
* List


-> Notice that bullet lists can be created using a -, a +, or an \*.  

-> Note that by indenting by two characters, you are creating an indented list. 

## Footnotes

```markdown

...defining the footnote.[^somesamplefootnote]

 [^somesamplefootnote]: Here is the text of the footnote itself.

```

Footnotes are created using the markdown for footnotes and then defining the footnote.[^somesamplefootnote]  When printing the document, the footnotes will appear at the end of the document and will be ordered sequentially starting with the cardinal number 1. When the document is displayed, footnotes will be superscripted and will be a link that generates a popup[^somesamplefootnote][^secondSamplefootnote].  If you insert a footnote but do not define the footnote, then it will simply appear as text in the document such as [^undefinedFootnote].

[^somesamplefootnote]: Here is the text of the footnote itself.  Footnotes can be a large body of text.  They will appear at the end of the document with a horizontal rule above them.  Footnotes can contain _markdown_ which will be processed properly.

[^secondSamplefootnote]: Here is the text of a second footnote.

-> footnotes only works in the web pages and not on the printed page.  If you would like to include a list of all of the footnotes at the end of the document, you can do this by using the include markdown tag with the special variable for the footnotes, _i.e._, `{{$footnotes}}.`

## Abbreviations

```markdown
  
*[XYZ]: Xray Yankee Zulu  

```

dpSlate markdown includes support for the PHP Markdown for abbreviations.  The examples to the right show two cases of abbreviations which are also included below.  The markdown must begin at a new line, if it does not, it will be recognized as text.

Because these abbreviations have been defined in the document, every occurance of HTML and W3C in the document will appeared as underlined with dashes.  When you hover over the abbreviation, a `?` will appear and eventually a _tool tip_ will appear with the defintion of the abbreviation.

Abbreviations can be composed of lower and upper case letters and numbers.

-> abbreviation only works in the web pages and not on the printed page.  If you would like to include a sorted list of all abbreviations in your document you can do this by using the include markdown tag with the special variable for the abbreviations, _i.e._, `{{$abbreviations}}`.

## Definitions

```markdown

=[Markdown]: a language used with plain text to indicate formating options.  Markdown is often used to process documents into HTML.
 
```

Definitions are like abbreviations but unlike an abbreviation, they will not be used to create a popover in the HTML document.  However, they can be output as a sorted collection using the the include markdown tag with the special variable for definitions, _i.e._, `{{$definitions}}`.  The example to the right shows the markdown tag for a definition.  The definition is made up of two areas, the name of the term and the rest of the paragraph which defines the term.

-> In addition to having markdown include tags to output abbreviations, `{{$abbreviations}}`, and definitions, `{{$definitions}}`, you can also output a the combined and sorted abbreviations and definitions (_e.g._, terms used in the document) then use the markdown include tag `{{$terms}}`

## Alerts

> Sample for creating Notes and Warnings

```markdown

=> This is a success message.

-> This is an info or note message.

~> This is a warning message.

!> This is a danger message.

```

Technical documents often have _alerts_ which are warning and notes that are intended for the reader.  Although standard markdown does not support this concept, dpSlate has been extended to support _alerts_.  You can add warnings and notes with just a little HTML embedded in your markdown document.  To the right, are three different examples of highlights using html.  Below you will see how each of the three examples will manifest themselves in the final document.


=> This is a success message.

-> This is an info or note message.

~> This is a warning message.

!> This is a danger message.


~> In previous versions of dpSlate, alerts were called _asides_ and they were done with HTML tags.  It is highly recommended that your use of asides be ported to the new markdown methods as you can now use markdown in your alerts.  Eventually, HTML tags will be deprecated and turned off to provide better security against cross site scripting.

## Includes

```markdown

 {{source/dpSlateHelp/_goodmen.md}}

 {{error.md}}

```

Sometimes you might want to break a markdown file into multiple parts such that you can reuse the parts in different documents. Although standard markdown does not support the concept of _includes_, dpSlate markdown has been extended to provide this support.  Anywhere within the markdown, you can add the contents of another file by simply using markdown include using two open curly brackets, followed by the path and filespec, and closed with two close curly brackets.  The include markdown statement must be at the start of a new line and of the form `{{filepath/filename.ext}}`  If the file is not found an error message is inserted in place of the include.  Below are two examples of includes.  In the markdown source, the statements to the right have been inserted.  

Below is an example, the first include is for the file, called `_goodmen.md`.  This file exsists and contains the markdown text of `Now is the _time_ for all good men...`.  In this case the markdown tag is replaced with the markdown in the referenced file.

{{source/dpSlateHelp/_goodmen.md}}

This is followed by the second example, the file, `error.md` which does not exsist.  When this occurs, the markdown tag is left intact.

{{error.md}}

The include tag can also be used to include either the contents of your page directives (e.g., settings) or for special variables.  
-> The include directive for markdown __must__ start on a new line or it will be ignored.

~> It is highly recommended that your included markdown files have a file name that begins with a `_` (underscore).  The dpSlate static file generator does not generate build files for files with filenames that begin with a `_` and thus, if you name your file this way, the fragment files that you are including will not be generated into their own, stand-alone page.

!> The new markdown include feature is the recommended method for doing includes.  Future versions of dpSlate will eliminate other include methods.

### Including Special Variables

To include the contents of special variables you use the include of the form`{{ $variable }}` where the `$variable` denotes a collection of HTML content that was generated when processing the document.  The special variables are either: 

* `{{$footnotes}}` - when a markdown include tag has this variable, it will be substituted with the HTML list of all footnotes in order.  This can be used to place the footnotes at the end of the document for printing.
* `{{$abbreviations}}` - when a markdown include tag has this variable, it will be substituted with the HTML text for an alphbetically ordered list of all abbreviations that were included in the document.  This can be used to place a list of abbreviations/acronyms in the document.
* `{{$definitions}}` when a markdown include tag has this variable, it will be substituted with the HTML text for an alphbetically ordered list of all definitions that were included in the document.  This can be used to place a list of definitions used in the document.
* `{{$terms}}` - when a markdown include tag has this variable, it will be substituted with the HTML text for an alphbetically ordered list of both the abbreviations and definitions that were included in the document.  This can be used to place a list of terms (_i.e._, definitions, abbreviations, and acronyms) in the document.

-> If there are no footnotes or abbreviations, then the null string will be substituted for the tag.  If you misspell the special variable name, then the original tag will remain.

### Including Settings Variables

To include the contents of a Settings Variable you use the include of the form`{{ =variable }}` where the `=variable` denotes a variable that contains the contents of one of the YAML page directives or settings.  In addition to the predefined page directives or settings that are used to control the formating of the page, you can also define any Settings Variable that you later wish to use in the document.

For example, lets say that in your YAML settings you add a line called `myDocumentVersion: "Version 4.5"`.  If you then insert the markdown of `{{ =myDocumentVersion }}` into your document, that markdown tag will be replaced with the contents of the settings variable, in this example, "Version 4.5".

~> If your Settings Variable is not defined, then the tag will remain.

## HTML in Markdown

You can also use raw HTML in your Markdown, and it'll mostly work pretty well.  But there really is no reason for this as most markdown that you want can be created using dpFM.

<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>

!> Just because you can, doesn't mean that you should.  One of the features of Markdown is that you don't have to worry about the formatting details of HTML.  Also, it provides a separation of content and format which you loose when you start placing HTML into your Markdown.


## Code Blocks

> Sample dpFM to Denote Sample Code

```markdown
    ```python
    // this is some python code
    ```
    ```ruby
    # this is some ruby code
    ```
```

Code samples are an important way of communicating how to use an API.  dpSlate does an excellent job of handling code samples in multiple languages simultaneously through the use of the tabbed sample code panel on the right hand side.


### Language Tabs

You denote a code samples by using three left-single-quote marks followed by the name of the language.  The name of the language is used to place the code sample into the proper tab. Each code samples will appear in the dark area to the right of the main text. Code samples need to appear right under the Level 1 or Level 2 headers in your markdown file to allow them to be anchored properly.

The "language tabs" are the tabs that appear in the upper right of dpSlate Documents. Users browsing the docs use them to select their programming language of choice.

In the sample dpFM code to the right, the Ruby code will appear in the Ruby tab, while the Python code will appear in the Python tab. Because the dpSlate engine understands the syntax of most computer programming languages, the sample code will have its language syntax highlighted automatically in a way that would make sense to the developer.

But just because a language is used as sample code within a dpSlate document it does not mean that the tab will appear.  You tell the system which Language tabs you want to display by editing the `language-tabs` list at the top of your dpFM source document.

=> Sometimes it is useful to share code between multiple tabs, you can do this by placing tagging the sample code using a language that is not used as a tab name.  For example if you tag sample code as `all` and `all` is not listed in the `language-tabs` then that sample code will appear in all of the tabs. 

## Annotations

> Code Sample Annotations

```markdown
> This is a Code Annotation!
```
It is sometimes useful to highlight or annotate a part of the sample code.  This is done with code annotations.  By placing a > as the first character in your dpFM line of text, you will create a code annotation that will appear in the area to the right, next to the code samples.

~> Make sure that you have a blank line after your Code Annotation.  If you do not, the annotation will continue until there is a blank line.
 

### Using Markdown in Annotations

>The following markdown code:

```markdown

> Table Header 1 | Table Header 2 | Table Header 3
> -------------- | -------------: | :------------:
> Row 1 col 1 | Row 1 col 2 | Row 1 col 3
> Row 2 col 1 | Row 2 col 2 | Row 2 col 3 

> ![DP Logo](/static/images/logo.png).

```

When you use the chevron `>` symbol, it takes the entire line and places it into the pannel to the right. Since it does not have a language, it will appear on all of the tabs to the right.  Additionally, because it is not "code" it is not treated as pre-formatted text.  As a result of these factors, the annotation feature can be very useful for placing Markdown or even HTML into the right hand panel.

> will result in the table in the right hand panel:

> Table Header 1 | Table Header 2 | Table Header 3
> -------------- | -------------: | :------------:
> Row 1 col 1 | Row 1 col 2 | Row 1 col 3
> Row 2 col 1 | Row 2 col 2 | Row 2 col 3 

> ![DP Logo](/static/images/logo.png).

For example, I can use the `>` to place a table into the right hand panel and just beneath it I placee an image.

# Using Stand Alone Mode

dpSlate can be installed on any Windows, Mac, or Linux system.  After it is installed, you can use your local copy of dpSlate in conjuntion with the markdown editor of your choice to test and preview your documents. 

## Previewing your Docs

> Command to Start Your Preview Server

```shell
bundle exec middleman server

```

>Output:

```
  == The Middleman is loading
  == The Middleman is standing watch at http://0.0.0.0:4567
  == Inspect your site configuration at http://0.0.0.0:4567/__middleman/
```
Open a terminal window and `cd` to your document directory.  Next type the command to the left and you will start the server.

using the server command to the left, you can view your documents in any web browser.  When you change the source document and refresh your browser window, you will see the changes that you made to your document.  

## Building HTML from Markdown

> Command to create your HTML Files

```shell
rake build
```
> Output:

```shell
cd dpSlate
bundle exec middleman build --clean
      create  build/images/logo.png
      create  build/images/Untitled.png
      create  build/fonts/icomoon.svg
      create  build/fonts/icomoon.woff
      create  build/fonts/icomoon.ttf
      create  build/fonts/icomoon.eot
      create  build/javascripts/lang_selector.js
      create  build/javascripts/all.js
      create  build/javascripts/jquery_ui.js
      create  build/javascripts/jquery.tocify.js
      create  build/stylesheets/variables.css
      create  build/stylesheets/icon-font.css
      create  build/stylesheets/normalize.css
      create  build/stylesheets/syntax.css
      create  build/stylesheets/screen.css
      create  build/stylesheets/print.css
      create  build/index.html
cd -
```

The `rake build` command tells Middleman to build your website to the `build` directory of your project in a way that is Github compatible.  You then need to share those static HTML files with the DevNet team for publishing.  You can do this via Box.net or Dropbox.

# Partials

!> Partials were deprecated in this version of dpSlate.  The same functionality is provided with markdown includes and including of settings variables. It is not recommended that you continue to use this feature as it is not as fullproof as the newer methods.  The old partial method of using erb files will continue to work but will no longer be supported.

# Release Notes

## dpSlate V4.1

dpSlate v4.1 adds new features that allows improved integration into dpEngine, this was the major goal of v4.1.  To achieve this goal, we made it such that dpSlate is:

* based upon the Bootstrap CSS framework from Twitter
* builds directly into the /site directory which is where dpEngine holds its content
* enabled the building of .gsp pages instead of .html pages when dpSlate is running on a dpEngine server.
* enable the ability to create a default `defaults.yml` file in the `/source` directory which will allow you to set your document directives globally for the site.  Thus, you will no longer need to bother with YAML directives which do not change from page to page; you just set it in the new defaults.yml.  As part of this we changed the name of the directives to make them more consistent. 

To enable this to work, we needed to change the way that dpSlate works and as such there will be some conversion that you will need to make some changes to migrate your documents to dpSlate V4.1.

### The build directory has moved.  
 
 Previously, the `build` directory was located in your git repository.  The new location of the build directory is not in your git repository but will be parallel to your git root directory and will be called `/site`

### The `\images` directory has moved.  

> dpSlate V4.0

```

[/images/myimage.png]

```

> dpSlate V4.1

```

[/static/images/myimage.png]

```

Previously, your images were located in a root `/images` directory.  To ensure that your dpSlate images do not conflict with other images being used on dpSlate, images are now located in the file `/static/images`.  Thus, you will need to add the `/dpSlateStatic` to the front of your image references.  For example, if you have an imag

### Changes to YAML Directives

In V4.0, some of the YAML directives were in _camel case_ format while others were not.  We've decided to make these consistent by placing them all in _camel case_ format.  Below are the old directives and new:

| V4.0  | New V4.1 | Description |
|---------- | --------- | :------------|
| title     | _same_     | the title of your document |
| copyright | _same_ | the copyright statement for your document |
| publisher | _same_ | your company name |
| publisher_address | publisherAddress | the main address for your company |
| commments | _same_ | any additional information that you want to put on the title page |
| titlePage | _same_ | Boolean to turn titlePage ON or OFF |
| tableOfContents | _same_ | Boolean to turn table of contents ON or OFF |
| tocAccordian | tocAccordion | Has been changed from a Boolean to an Integer.  It is used turn the expanding ToC feature ON or OFF.  The new integer value is used to control how many levels are open by default.  Thus, the old ON value can be achieved with a 6 and the old OFF value can be achieved with a 1. |
| rightPanel | _same_ | Boolean to turn the right hand panel ON or OFF, when OFF code samples are moved in-line |
| leftPanel | _same_ | Boolean to turn the left hand panel off, when turned off Title Page and ToC are moved to the top |
| documentSearch | _same_ | Boolean to turn the document search feature ON or OFF |
| language_tabs | languageTabs | Array to add the language name, and display name for each language tab |
| toc_selectors | tocSelectors | comma list of HTML headings that will be used in the Table of Contents |
| toc_footers | _deprecated_ | Deprecated.  You should use _comments_ instead | 

### Default YAML Directives

Make sure that you take advantage of the new default YAML directive capability by setting your default values in the file at `/dpSlate/source/_defaults.yml`.

## dpSlate V4.2

### New dpFM

dpSlate v4.2 includes many new markdown features that allow you to create richer technical documentation.  These new markdown features are documented in this document but below is a summary of the features:

* _Includes_ - There is a new markdown tag that allows you to include another markdown file using the syntax `{{path\file.ext}}`.  

* _Footnotes_ - You can now add footnotes to your markdown using the PHP Flavored Markdown syntax.  This allows you to define the reference point for the footnote and then the footnote separately. The footnotes are inserted in numerical order using superscripts which have links.  If the user clicks the link, a popup will open that contains the footnote. There is also a special include tag to place the list footnotes anywhere that you want in the document. 

* _Abbreviations_ You can now create/add abbreviations and acronym defintions to your document using the PHP Flavored Markdown syntax.  Any and all occurances of the abbreviation will be a link that when clicked will open a popover with the defintion.  There is also a special include tag to allow you to place an alphabetical list of all of the abbreviations defined in your document whereever you want.

* _Alerts_ - _Asides_ have been renamed _alerts_ and have been added as Markdown rather thatn using HTML.  There are now four different levels or types of alerts; information, note, warning, alert.  In the future you should replace all of your HTML _asides_ with the new markdown _alerts_.

* _Glyph Fonts_ - Because dpSlate now includes Bootstrap, the old slate Glyph Font has been removed from the source and references to glyph icons have been converted to the Bootstrap Glyph Font.

# Footnotes

```markdown
{{$footnotes}}
```

Below are all of the footnotes used in the markdown.  This was output using the include markdown in the example.

{{$footnotes}}


# Abbreviations

```markdown
{{$abbreviations}}
```
Below are all of the abbreviations in the markdown.  This was output using the include markdown in the example.

{{$abbreviations}}


# Definitions
```markdown
{{$definitions}}
```

Below are all of the definitions in the markdown.  This was output using the include markdown in the example.

{{$definitions}}

# Terms Used In This Document

```markdown
{{$terms}}
```

Below are all of the definitions and abbreviations in a sorted, combined list in the markdown.  This was output using the include markdown in the example.

{{$terms}}


*[dpFM]: dp Flavored Markdown

*[HTML]: Hyper Text Markup Language

*[W3C]: World Wide Web Consortium

*[YAML]: Yet Another Markup Language


=[Markdown]: Markdown is a lighter language than HTML for formating text into documents.  Markdown is typically used to output HTML.

=[dpEngine]: dpEngine is the business eco-system automation SaaS from dp.com.  It is typically used to create developer and partner eco-systems.
