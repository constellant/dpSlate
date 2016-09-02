---

title: "dpSlate YAML Default Tests"

version: "dpSlate V4.1"

copyright: "Loaded from the local file"

publisher: "Publisher is overridden"

publisherAddress:  "Publisher Address is overriddent"

comments: "Comments are overwritten"

languageTabs:
  - shell: Overide Shell
  - python: Overide Python
  - ruby: Overide Ruby

---

# Introduction 

This is a test of the new YAML default tests.  dpSlate from V4.1 and on uses YAML to define variables that are used to configure dpSlate.  The system has defaults which are hard coded, next the system will apply the site level defaults found in `/dpslate/source/defaults.yml`.  The system will then look for `defaults.yml` files all the way down the directory tree applying those defaults.  Finally, the values that are found in the document are applied.

# Success Criteria

This test is successful if the markdown generates the proper HTML and the resulting dpSlate document exhibits the behavior defined in the default YAML file in `/source/defaults.yml`  The test is successful if:

1.  The page displays the Title Page and Table of Contents
2.  The values in the Title Page and the Language tabs come from the document and not the defaul (see below).

## Default Values

```yml

title: ""

version: "" 

copyright: "Copyright &copy; 2013-2016 by Perigee Capital, LLC., Portions Copyright 2008-2013 by Concur Technologies, Inc. All Rights Reserved."

publisher: "DeveloperProgram.com"

publisherAddress: "Perigee Capital LLC., 2300 Greenhill Drive, Suite 400, Round Rock, TX 78664, USA"

comments: "dpSlate is Licensed under the Apache License, Version 2.0 (the License); you may not use this file except in compliance with the License. You may obtain a copy of the License on the site http://www.apache.org at /licenses/LICENSE-2.0.  Unless required by applicable law or agreed to in writing, the dpSlate software distributed under the License is distributed on an AS IS BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.  The Perigee Capital, DevelopProgram.com, DP.com, dpSlate, and the dp.com Logo are trademarks of Perigee Capital, LLC."

titlePage: true

tableOfContents: true

tocAccordion: true

rightPanel: true

leftPanel: true

documentSearch: true

languageTabs:
  - shell: Sample
  - python: Python
  - ruby: Ruby
  
tocSelectors: "h1,h2,h3"  

```
The page will use the values of the YAML directives to the right as default as these are set in the file `/source/_defaults.yml`.

## Page Overides

```yml

title: "dpSlate YAML Default Tests"

version: "dpSlate V4.1"

copyright: "Loaded from the local file"

publisher: "Publisher is overridden"

publisherAddress:  "Publisher Address is overriddent"

comments: "Comments are overwritten"

languageTabs:
  - shell: Overide Shell
  - python: Overide Python
  - ruby: Overide Ruby
  
```

The YAML directives to the right show the values that have been set within the page.  All of these values will override the default values shown previously.
