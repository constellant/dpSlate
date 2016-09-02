---

title: "dpSlate One Column Test"

version: "V4.0" 

copyright: "Copyright &copy; 2013-2015 Perigee Capital, LLC., Portions Copyright 2008-2013 by Concur Technologies, Inc. All Rights Reserved."

publisher: "DeveloperProgram.com"

publisherAddress: "Perigee Capital LLC., 2300 Greenhill Drive, Suite 400, Round Rock, TX 78664, USA"

comments: "dpSlate is Licensed under the Apache License, Version 2.0 (the License); you may not use this file except in compliance with the License. You may obtain a copy of the License on the site http://www.apache.org at /licenses/LICENSE-2.0.  Unless required by applicable law or agreed to in writing, the dpSlate software distributed under the License is distributed on an AS IS BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.  The Perigee Capital, DevelopProgram.com, DP.com, dpSlate, and the dp.com Logo are trademarks of Perigee Capital, LLC."

titlePage: ON

tableOfContents: ON

tocAccordion: ON

rightPanel: OFF

leftPanel: OFF

documentSearch: ON

languageTabs:
  - shell: Sample
  - python: Python
  - ruby: Ruby
  
tocSelectors: "h1,h2,h3"
  
toooters:

---

# Introduction 

This document presents a test case for the two-column format in which the right-hand-side Code Panel is turned off and the Code is then displayed inline with the text.

This test is sucessful if:

1.  The page is displayed with one columns.
2.  The Title Page and the Table of Contents appear at the top of the page.
3.  The Title Page is not expanded.
4.  The Table of Contents is expaned.
5.  There is no document search facility.
2.  Below, you see a code that is inline in this main panel.
3.  The code does not scroll within a code window but is displayed within the window in full.

# Inserting Large Code Samples

> Large Python Program

```python
import collections
import itertools
import re
import sys
import warnings
from bs4.dammit import EntitySubstitution
try:
    next
except NameError:
    from bs4._compatibility import next_function as next


DEFAULT_OUTPUT_ENCODING = "utf-8"
PY3K = (sys.version_info[0] > 2)

whitespace_re = re.compile("\s+")

def _alias(attr):
    """Alias one attribute name to another for backward compatibility"""
    def _get_alias(self):
        return getattr(self, attr)

    def _set_alias(self):
        return setattr(self, attr)

    alias = property(_get_alias, _set_alias)
    return alias


class NamespacedAttribute(unicode):

    def __new__(cls, prefix, name, namespace=None):
        if name is None:
            obj = unicode.__new__(cls, prefix)
        else:
            obj = unicode.__new__(cls, prefix + ":" + name)
        obj.prefix = prefix
        obj.name = name
        obj.namespace = namespace
        return obj


class PageElement(object):
    """Contains the navigational information for some part of the page
    (either a tag or a piece of text)"""

    # There are five possible values for the "formatter" argument passed in
    # to methods like encode() and prettify():
    #
    # "html" - All Unicode characters with corresponding HTML entities
    #   are converted to those entities on output.
    # "minimal" - Bare ampersands and angle brackets are converted to
    #   XML entities: &amp; &lt; &gt;
    # None - The null formatter. Unicode characters are never
    #   converted to entities.  This is not recommended, but it's
    #   faster than "minimal".
    # A function - This function will be called on every string that
    #  needs to undergo entity substition
    FORMATTERS = {
        "html" : EntitySubstitution.substitute_html,
        "minimal" : EntitySubstitution.substitute_xml,
        None : None
        }

    def setup(self, parent=None, previous_element=None):
        """Sets up the initial relations between this element and
        other elements."""
        self.parent = parent
        self.previous_element = previous_element
        self.next_element = None
        self.previous_sibling = None
        self.next_sibling = None
        if self.parent is not None and self.parent.contents:
            self.previous_sibling = self.parent.contents[-1]
            self.previous_sibling.next_sibling = self

    nextSibling = _alias("next_sibling")  # BS3
    previousSibling = _alias("previous_sibling")  # BS3

    def replace_with(self, replace_with):
        if replace_with is self:
            return
        if replace_with is self.parent:
            raise ValueError("Cannot replace a Tag with its parent.")
        old_parent = self.parent
        my_index = self.parent.index(self)
        if (hasattr(replace_with, 'parent')
            and replace_with.parent is self.parent):
            # We're replacing this element with one of its siblings.
            if self.parent.index(replace_with) < my_index:
                # Furthermore, it comes before this element. That
                # means that when we extract it, the index of this
                # element will change.
                my_index -= 1
        self.extract()
        old_parent.insert(my_index, replace_with)
        return self
    replaceWith = replace_with  # BS3

    def replace_with_children(self):
        my_parent = self.parent
        my_index = self.parent.index(self)
        self.extract()
        for child in reversed(self.contents[:]):
            my_parent.insert(my_index, child)
        return self
    replaceWithChildren = replace_with_children  # BS3

    def extract(self):
        """Destructively rips this element out of the tree."""
        if self.parent is not None:
            del self.parent.contents[self.parent.index(self)]

        #Find the two elements that would be next to each other if
        #this element (and any children) hadn't been parsed. Connect
        #the two.
        last_child = self._last_descendant()
        next_element = last_child.next_element

        if self.previous_element is not None:
            self.previous_element.next_element = next_element
        if next_element is not None:
            next_element.previous_element = self.previous_element
        self.previous_element = None
        last_child.next_element = None

        self.parent = None
        if self.previous_sibling is not None:
            self.previous_sibling.next_sibling = self.next_sibling
        if self.next_sibling is not None:
            self.next_sibling.previous_sibling = self.previous_sibling
        self.previous_sibling = self.next_sibling = None
        return self

    def _last_descendant(self):
        "Finds the last element beneath this object to be parsed."
        last_child = self
        while hasattr(last_child, 'contents') and last_child.contents:
            last_child = last_child.contents[-1]
        return last_child
    # BS3: Not part of the API!
    _lastRecursiveChild = _last_descendant

    def insert(self, position, new_child):
        if new_child is self:
            raise ValueError("Cannot insert a tag into itself.")
        if (isinstance(new_child, basestring)
            and not isinstance(new_child, NavigableString)):
            new_child = NavigableString(new_child)

        position = min(position, len(self.contents))
        if hasattr(new_child, 'parent') and new_child.parent is not None:
            # We're 'inserting' an element that's already one
            # of this object's children.
            if new_child.parent is self:
                if self.index(new_child) > position:
                    # Furthermore we're moving it further down the
                    # list of this object's children. That means that
                    # when we extract this element, our target index
                    # will jump down one.
                    position -= 1
            new_child.extract()

        new_child.parent = self
        previous_child = None
        if position == 0:
            new_child.previous_sibling = None
            new_child.previous_element = self
        else:
            previous_child = self.contents[position - 1]
            new_child.previous_sibling = previous_child
            new_child.previous_sibling.next_sibling = new_child
            new_child.previous_element = previous_child._last_descendant()
        if new_child.previous_element is not None:
            new_child.previous_element.next_element = new_child

        new_childs_last_element = new_child._last_descendant()

        if position >= len(self.contents):
            new_child.next_sibling = None

            parent = self
            parents_next_sibling = None
            while parents_next_sibling is None and parent is not None:
                parents_next_sibling = parent.next_sibling
                parent = parent.parent
                if parents_next_sibling is not None:
                    # We found the element that comes next in the document.
                    break
            if parents_next_sibling is not None:
                new_childs_last_element.next_element = parents_next_sibling
            else:
                # The last element of this tag is the last element in
                # the document.
                new_childs_last_element.next_element = None
        else:
            next_child = self.contents[position]
            new_child.next_sibling = next_child
            if new_child.next_sibling is not None:
                new_child.next_sibling.previous_sibling = new_child
            new_childs_last_element.next_element = next_child

        if new_childs_last_element.next_element is not None:
            new_childs_last_element.next_element.previous_element = new_childs_last_element
        self.contents.insert(position, new_child)

    def append(self, tag):
        """Appends the given tag to the contents of this tag."""
        self.insert(len(self.contents), tag)

    def insert_before(self, predecessor):
        """Makes the given element the immediate predecessor of this one.

        The two elements will have the same parent, and the given element
        will be immediately before this one.
        """
        if self is predecessor:
            raise ValueError("Can't insert an element before itself.")
        parent = self.parent
        if parent is None:
            raise ValueError(
                "Element has no parent, so 'before' has no meaning.")
        # Extract first so that the index won't be screwed up if they
        # are siblings.
        if isinstance(predecessor, PageElement):
            predecessor.extract()
        index = parent.index(self)
        parent.insert(index, predecessor)

    def insert_after(self, successor):
        """Makes the given element the immediate successor of this one.

        The two elements will have the same parent, and the given element
        will be immediately after this one.
        """
        if self is successor:
            raise ValueError("Can't insert an element after itself.")
        parent = self.parent
        if parent is None:
            raise ValueError(
                "Element has no parent, so 'after' has no meaning.")
        # Extract first so that the index won't be screwed up if they
        # are siblings.
        if isinstance(successor, PageElement):
            successor.extract()
        index = parent.index(self)
        parent.insert(index+1, successor)


```

