/*
 * jQuery Highlight plugin
 *
 * Based on highlight v3 by Johann Burkard
 * http://johannburkard.de/blog/programming/javascript/highlight-javascript-text-higlighting-jquery-plugin.html
 *
 * Code a little bit refactored and cleaned (in my humble opinion).
 * Most important changes:
 *  - has an option to highlight only entire words (wordsOnly - false by default),
 *  - has an option to be case sensitive (caseSensitive - false by default)
 *  - highlight element tag and class names can be specified in options
 *
 * Usage:
 *   // wrap every occurrance of text 'lorem' in content
 *   // with <span class='highlight'> (default options)
 *   $('#content').highlight('lorem');
 *
 *   // search for and highlight more terms at once
 *   // so you can save some time on traversing DOM
 *   $('#content').highlight(['lorem', 'ipsum']);
 *   $('#content').highlight('lorem ipsum');
 *
 *   // search only for entire word 'lorem'
 *   $('#content').highlight('lorem', { wordsOnly: true });
 *
 *   // don't ignore case during search of term 'lorem'
 *   $('#content').highlight('lorem', { caseSensitive: true });
 *
 *   // wrap every occurrance of term 'ipsum' in content
 *   // with <em class='important'>
 *   $('#content').highlight('ipsum', { element: 'em', className: 'important' });
 *
 *   // remove default highlight
 *   $('#content').unhighlight();
 *
 *   // remove custom highlight
 *   $('#content').unhighlight({ element: 'em', className: 'important' });
 *
 *
 * Copyright (c) 2009 Bartek Szopka
 *
 * Licensed under MIT license.
 *
 */
jQuery.extend({highlight:function(e,i,o,t){if(3===e.nodeType){var n=e.data.match(i);if(n){var s=document.createElement(o||"span");s.className=t||"highlight";var r=e.splitText(n.index);r.splitText(n[0].length);var l=r.cloneNode(!0);return s.appendChild(l),r.parentNode.replaceChild(s,r),1}}else if(1===e.nodeType&&e.childNodes&&!/(script|style)/i.test(e.tagName)&&(e.tagName!==o.toUpperCase()||e.className!==t))for(var d=0;d<e.childNodes.length;d++)d+=jQuery.highlight(e.childNodes[d],i,o,t);return 0}}),jQuery.fn.unhighlight=function(e){var i={className:"highlight",element:"span"};return jQuery.extend(i,e),this.find(i.element+"."+i.className).each(function(){var e=this.parentNode;e.replaceChild(this.firstChild,this),e.normalize()}).end()},jQuery.fn.highlight=function(e,i){var o={className:"highlight",element:"span",caseSensitive:!1,wordsOnly:!1};if(jQuery.extend(o,i),e.constructor===String&&(e=[e]),e=jQuery.grep(e,function(e,i){return""!=e}),e=jQuery.map(e,function(e,i){return e.replace(/[-[\]{}()*+?.,\\^$|#\s]/g,"\\$&")}),0==e.length)return this;var t=o.caseSensitive?"":"i",n="("+e.join("|")+")";o.wordsOnly&&(n="\\b"+n+"\\b");var s=new RegExp(n,t);return this.each(function(){jQuery.highlight(this,s,o.element,o.className)})};