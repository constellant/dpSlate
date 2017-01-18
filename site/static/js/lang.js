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
!function(e){"use strict";function t(e){if(e&&""!==e){$(".lang-selector a").removeClass("active"),$(".lang-selector a[data-language-name='"+e+"']").addClass("active");for(var t=0;t<d.length;t++)$(".highlight."+d[t]).hide();$(".highlight."+e).show(),$(window.location.hash).get(0)&&$(window.location.hash).get(0).scrollIntoView(!0)}}function o(e){return"string"!=typeof e?{}:(e=e.trim().replace(/^(\?|#|&)/,""),e?e.split("&").reduce(function(e,t){var o=t.replace(/\+/g," ").split("="),i=o[0],n=o[1];return i=decodeURIComponent(i),n=void 0===n?null:decodeURIComponent(n),e.hasOwnProperty(i)?Array.isArray(e[i])?e[i].push(n):e[i]=[e[i],n]:e[i]=n,e},{}):{})}function i(e){return e?Object.keys(e).sort().map(function(t){var o=e[t];return Array.isArray(o)?o.sort().map(function(e){return encodeURIComponent(t)+"="+encodeURIComponent(e)}).join("&"):encodeURIComponent(t)+"="+encodeURIComponent(o)}).join("&"):""}function n(){if(location.search.length>=1){var e=o(location.search).language;if(e)return e;if(-1!=jQuery.inArray(location.search.substr(1),d))return location.search.substr(1)}return!1}function r(e){var t=o(location.search);return t.language?(t.language=e,i(t)):e}function s(e){if(history){var t=window.location.hash;t&&(t=t.replace(/^#+/,"")),history.pushState({},"","?"+r(e)+"#"+t),localStorage.setItem("language",e)}}function l(e){var o=localStorage.getItem("language");d=e;var i=n();i?(t(i),localStorage.setItem("language",i)):t(null!==o&&-1!=jQuery.inArray(o,d)?o:d[0])}var d=[];e.setupLanguages=l,e.activateLanguage=t,$(function(){$(".lang-selector a").on("click",function(){var e=$(this).data("language-name");return s(e),t(e),!1}),window.onpopstate=function(){t(n())}})}(window);