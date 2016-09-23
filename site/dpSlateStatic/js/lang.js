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
!function(t){"use strict";function e(t){if(t&&""!==t){$(".lang-selector a").removeClass("active"),$(".lang-selector a[data-language-name='"+t+"']").addClass("active");for(var e=0;e<l.length;e++)$(".highlight."+l[e]).hide();$(".highlight."+t).show(),$(window.location.hash).get(0)&&$(window.location.hash).get(0).scrollIntoView(!0)}}function n(t){return"string"!=typeof t?{}:(t=t.trim().replace(/^(\?|#|&)/,""),t?t.split("&").reduce(function(t,e){var n=e.replace(/\+/g," ").split("="),i=n[0],o=n[1];return i=decodeURIComponent(i),o=void 0===o?null:decodeURIComponent(o),t.hasOwnProperty(i)?Array.isArray(t[i])?t[i].push(o):t[i]=[t[i],o]:t[i]=o,t},{}):{})}function i(t){return t?Object.keys(t).sort().map(function(e){var n=t[e];return Array.isArray(n)?n.sort().map(function(t){return encodeURIComponent(e)+"="+encodeURIComponent(t)}).join("&"):encodeURIComponent(e)+"="+encodeURIComponent(n)}).join("&"):""}function o(){if(location.search.length>=1){var t=n(location.search).language;if(t)return t;if(-1!=jQuery.inArray(location.search.substr(1),l))return location.search.substr(1)}return!1}function r(t){var e=n(location.search);return e.language?(e.language=t,i(e)):t}function s(t){if(history){var e=window.location.hash;e&&(e=e.replace(/^#+/,"")),history.pushState({},"","?"+r(t)+"#"+e),localStorage.setItem("language",t)}}function a(t){var n=localStorage.getItem("language");l=t;var i=o();i?(e(i),localStorage.setItem("language",i)):e(null!==n&&-1!=jQuery.inArray(n,l)?n:l[0])}var l=[];t.setupLanguages=a,t.activateLanguage=e,$(function(){$(".lang-selector a").on("click",function(){var t=$(this).data("language-name");return s(t),e(t),!1}),window.onpopstate=function(){e(o())}})}(window);