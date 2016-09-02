---

title: "dpSlate Markdown Fidelity Test"

titlePage: ON

tableOfContents: ON

tocAccordion: OFF 

rightPanel: OFF

leftPanel: ON

languageTabs:
  - md: Markdown
  
tocSelectors: "h1,h2"

---

# Introduction 

This is a Markdown Fidelity test.  It is used to test various Markdown facilities to determine if they are working.

# Success Criteria

This test is successful if the markdown generates the proper HTML.  The test is successful if:

- The content below is rendered properly.
- The document has two Panes, with a Table of Contents to the left but with Markdown Samples inline
- The document has a collapsable Title Page at the Top
- The title page has a copyright, publisher, and publisherAddress which comes from the `default.yml`
- The document does NOT have a search box (search boxes go away in single column documents)
- The document has a Table of contents under the Title Page
- Only Headers h1 and h2 are shown in the Table of contents

# Test Cases

Below are the test cases for the document.

## Headers

On the right are a list of headers in markdown and below is how they will appear in the document:
######

> Headings - Only H1 and H2 are shown in the TOC

```markdown

### H3 Header
#### H4 Header
#### H5 Header
#### H6 Header

```

### H3 Header
#### H4 Header
#### H5 Header
#### H6 Header


## Text Attributes

> Formatting Text in GFM

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


## Strikethrough

```markdown

Strikethrough allows you to show text that is ~~no longer relevant by using strikethrough~~


```

You can format text with a strikethrough by enclosing the text in double tildes, `~~`.  The example to the right becomes:

Strikethrough allows you to show text that is ~~no longer relevant by using strikethrough~~


## Markdown Links

> The Three Ways to Create GFM Links

```markdown
Here's an inline link to [Google](http://www.google.com/).
Here's a reference-style link to [Google][1].
Here's a very readable link to [Yahoo!][yahoo].

  [1]: http://www.google.com/
  [yahoo]: http://www.yahoo.com/
```

There are three ways to write links in GFM. Each is easier to read than the last.  The code to the right will generate the following:

Here's an inline link to [Google](http://www.google.com/).
Here's a reference-style link to [Google][1].
Here's a very readable link to [Yahoo!][yahoo].

  [1]: http://www.google.com/
  [yahoo]: http://www.yahoo.com/
  
The link definitions can appear anywhere in the document -- before or after the place where you use them. The link definition names [1] and [yahoo] can be any unique string, and are case-insensitive; [yahoo] is the same as [YAHOO].

## HTML Standard Links

> Using HTML Links in GRM

```html
<a href="http://www.developerprogram.com" title="DP.com">DeveloperProgram.com Web Site</a>
```

You can also use standard HTML hyperlink syntax.  The HTML example to the right produces the text below:

<a href="http://www.developerprogram.com" title="DP.com">DeveloperProgram.com Web Site</a>


## Images

> GFM for Inserting an Image Stored Locally

```markdown
![DP Logo](/dpSlateStatic/images/logo.png).
```

![DP Logo](/dpSlateStatic/images/logo.png).

The Markdown to the right shows how an image can be inserted, in this case, it is the DP Logo that is right above this.  The text inside the square brackets, `[DP Logo]` will become the alt text for the image in the HTML `alt=` parameter.


## Inserting Horizontal Rules

Sometimes you just need a Horizontal Rule (line) to convey something.  GFM does this with either three or more consecutive Hyphens `-`, Asterisks `*`, or Underscores `_`.


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

## HTML in Markdown

```markdown
<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>
```
You can also use raw HTML in your Markdown, and it'll mostly work pretty well.

<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>


## Creating a Table

> GFM for Creating a Table

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

## Creating Numbered Lists

> GFM for Numbered Lists

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

Numbered lists are created using the GFM markdown code to the right.  You can create nested lists, but the bullets are indented by two spaces.  The sample code to the right will create the list below:

1. This
2. Is
  3. Nested
  6. Number
  1. List
3. An
8. Ordered
9. List

## Creating Bulleted Lists

> GFM for created bullet lists

```markdown
- This
+ Is
  * nested
  - bullet
* A
* Bullet
* List
```

Numbered lists are created using the GFM markdown code to the right.  you can create nested lists, but the bullets are indented by two spaces.  The sample code
to the right will create the list below:

- This
+ Is
* A
  * nested
  - bullet
* Bullet
* List

## Creating Special Notes and Warnings

> Sample for creating Notes and Warnings

```markdown

<aside class="notice"> This is a sample note. </aside>
    
<aside class="warning"> This is a sample warning.</aside>

<aside class="success"> This is a sample hint.</aside>

```

You can add warnings and notes with just a little HTML embedded in your markdown document.  To the right, are three different examples of highlights using html.  Below you will see how each of the three examples will manifest themselves in the final document.

<aside class="notice"> This is a sample note. </aside>
    
<aside class="warning"> This is a sample warning.</aside>

<aside class="success"> This is a sample hint.</aside>

Use the `class="notice"` for blue notes, `class="warning"` for red warnings, and `class="success"` for green notes.

## Sample Code

> Sample GFM to Denote Sample Code

```markdown
    ```python
    // this is some python code
    ```
    ```ruby
    # this is some ruby code
    ```
```

## Creating Code Sample Annotations

> Code Sample Annotations

```markdown
> This is a Code Annotation!
```
It is sometimes useful to highlight or annotate a part of the sample code.  This is done with code annotations.  By placing a > as the first character in your GFM line of text, you will create a code annotation that will appear in the area to the right, next to the code samples.

<aside class="warning"> Make sure that you have a blank line after your Code Annotation.  If you do not, the annotation will continue until there is a blank line.
</aside>
