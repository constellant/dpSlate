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
!function(e){"use strict";function t(e){if(e&&""!==e){$(".lang-selector a").removeClass("active"),$(".lang-selector a[data-language-name='"+e+"']").addClass("active");for(var t=0;t<c.length;t++)$(".highlight."+c[t]).hide();$(".highlight."+e).show(),$(window.location.hash).get(0)&&$(window.location.hash).get(0).scrollIntoView(!0)}}function n(e){return"string"!=typeof e?{}:(e=e.trim().replace(/^(\?|#|&)/,""),e?e.split("&").reduce(function(e,t){var n=t.replace(/\+/g," ").split("="),a=n[0],i=n[1];return a=decodeURIComponent(a),i=void 0===i?null:decodeURIComponent(i),e.hasOwnProperty(a)?Array.isArray(e[a])?e[a].push(i):e[a]=[e[a],i]:e[a]=i,e},{}):{})}function a(e){return e?Object.keys(e).sort().map(function(t){var n=e[t];return Array.isArray(n)?n.sort().map(function(e){return encodeURIComponent(t)+"="+encodeURIComponent(e)}).join("&"):encodeURIComponent(t)+"="+encodeURIComponent(n)}).join("&"):""}function i(){if(location.search.length>=1){var e=n(location.search).language;if(e)return e;if(-1!=jQuery.inArray(location.search.substr(1),c))return location.search.substr(1)}return!1}function r(e){var t=n(location.search);return t.language?(t.language=e,a(t)):e}function o(e){if(history){var t=window.location.hash;t&&(t=t.replace(/^#+/,"")),history.pushState({},"","?"+r(e)+"#"+t),localStorage.setItem("language",e)}}function s(e){var n=localStorage.getItem("language");c=e;var a=i();a?(t(a),localStorage.setItem("language",a)):t(null!==n&&-1!=jQuery.inArray(n,c)?n:c[0])}var c=[];e.setupLanguages=s,e.activateLanguage=t,$(function(){$(".lang-selector a").on("click",function(){var e=$(this).data("language-name");return o(e),t(e),!1}),window.onpopstate=function(){t(i())}})}(window);