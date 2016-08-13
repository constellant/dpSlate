<!-- place Site specific headers, menu system, breadcrumbs etc below -->

<! -- dpSlate Content will be automatically included -->

<div id="dpSlateContent" >
  <script>

    // include the dpSlate HTML as an iframe
    document.write ('<iframe id="dpSlateDoc" scrolling="yes" frameBorder="0" src="/dpslate/build', window.location.pathname.replace(".gsp", ".html") , '" width="100%" frameBorder="0"></iframe>');

    // after the load of the document, set the height of the iframe equal to the size of the ToC and scroll to any Hash in the URL
    document.getElementById('dpSlateDoc').onload = function resizeDpSlateDoc() {
        document.getElementById('dpSlateDoc').height = document.getElementById('dpSlateDoc').contentDocument.getElementsByClassName('tocify-wrapper')[0].scrollHeight;
        document.getElementById('dpSlateDoc').contentWindow.location.hash = location.hash;
     }
     
     // if there is a click in the document, update the hash in the URL that is displayed 
     document.getElementById('dpSlateDoc').contentWindow.onclick = function updateParentUrlHash () {
         location.hash = document.getElementById('dpSlateDoc').contentWindow.location.hash;
     };
  </script>
</div>

<!-- place footers below and close of document below -->
