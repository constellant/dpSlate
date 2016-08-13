/*
Copyright 2008-2013 Concur Technologies, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.
*/
!function(t){"use strict";function e(e){if(e&&""!==e){$(".lang-selector a").removeClass("active"),$(".lang-selector a[data-language-name='"+e+"']").addClass("active");for(var i=0;i<l.length;i++)$(".highlight."+l[i]).hide();$(".highlight."+e).show(),t.toc.calculateHeights(),$(window.location.hash).get(0)&&$(window.location.hash).get(0).scrollIntoView(!0)}}function i(t){return"string"!=typeof t?{}:(t=t.trim().replace(/^(\?|#|&)/,""),t?t.split("&").reduce(function(t,e){var i=e.replace(/\+/g," ").split("="),n=i[0],s=i[1];return n=decodeURIComponent(n),s=void 0===s?null:decodeURIComponent(s),t.hasOwnProperty(n)?Array.isArray(t[n])?t[n].push(s):t[n]=[t[n],s]:t[n]=s,t},{}):{})}function n(t){return t?Object.keys(t).sort().map(function(e){var i=t[e];return Array.isArray(i)?i.sort().map(function(t){return encodeURIComponent(e)+"="+encodeURIComponent(t)}).join("&"):encodeURIComponent(e)+"="+encodeURIComponent(i)}).join("&"):""}function s(){if(location.search.length>=1){var t=i(location.search).language;if(t)return t;if(-1!=jQuery.inArray(location.search.substr(1),l))return location.search.substr(1)}return!1}function a(t){var e=i(location.search);return e.language?(e.language=t,n(e)):t}function o(t){if(history){var e=window.location.hash;e&&(e=e.replace(/^#+/,"")),history.pushState({},"","?"+a(t)+"#"+e),localStorage.setItem("language",t)}}function r(t){var i=localStorage.getItem("language");l=t;var n=s();n?(e(n),localStorage.setItem("language",n)):e(null!==i&&-1!=jQuery.inArray(i,l)?i:l[0])}var l=[];t.setupLanguages=r,t.activateLanguage=e,$(function(){$(".lang-selector a").on("click",function(){var t=$(this).data("language-name");return o(t),e(t),!1}),window.onpopstate=function(){e(s())}})}(window);