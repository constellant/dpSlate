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
!function(e){"use strict";function t(e){if(e&&""!==e){$(".lang-selector a").removeClass("active"),$(".lang-selector a[data-language-name='"+e+"']").addClass("active");for(var t=0;t<l.length;t++)$(".highlight."+l[t]).hide();$(".highlight."+e).show(),$(window.location.hash).get(0)&&$(window.location.hash).get(0).scrollIntoView(!0)}}function n(e){return"string"!=typeof e?{}:(e=e.trim().replace(/^(\?|#|&)/,""),e?e.split("&").reduce(function(e,t){var n=t.replace(/\+/g," ").split("="),i=n[0],r=n[1];return i=decodeURIComponent(i),r=void 0===r?null:decodeURIComponent(r),e.hasOwnProperty(i)?Array.isArray(e[i])?e[i].push(r):e[i]=[e[i],r]:e[i]=r,e},{}):{})}function i(e){return e?Object.keys(e).sort().map(function(t){var n=e[t];return Array.isArray(n)?n.sort().map(function(e){return encodeURIComponent(t)+"="+encodeURIComponent(e)}).join("&"):encodeURIComponent(t)+"="+encodeURIComponent(n)}).join("&"):""}function r(){if(location.search.length>=1){var e=n(location.search).language;if(e)return e;if(-1!=jQuery.inArray(location.search.substr(1),l))return location.search.substr(1)}return!1}function o(e){var t=n(location.search);return t.language?(t.language=e,i(t)):e}function s(e){if(history){var t=window.location.hash;t&&(t=t.replace(/^#+/,"")),history.pushState({},"","?"+o(e)+"#"+t),localStorage.setItem("language",e)}}function a(e){var n=localStorage.getItem("language");l=e;var i=r();i?(t(i),localStorage.setItem("language",i)):t(null!==n&&-1!=jQuery.inArray(n,l)?n:l[0])}var l=[];e.setupLanguages=a,e.activateLanguage=t,$(function(){$(".lang-selector a").on("click",function(){var e=$(this).data("language-name");return s(e),t(e),!1}),window.onpopstate=function(){t(r())}})}(window);