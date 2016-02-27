<%@ page contentType="text/html; charset=UTF-8" %>
<% request.setAttribute("leftNavStart",leftNavStart.toString()); %>
<dp:checkContentAccess />
<!doctype html>
<html lang="en">

<head> 
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
  <meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible" />
  <meta content="width=device-width, initial-scale=1, maximum-scale=1" name="viewport" />
  
  <title><g:render template="/site/includes/dpCommon/title/dynamic" /></title>

        <g:render template="/site/includes/structure/crankset/css/css"  />    
    
        <g:render template="/site/includes/cssIncludes/api-slate/css"  />

        <g:render template="/site/includes/structure/crankset/js/js"  />

<script>
	// $(window).on("hashchange", function () {
	// 	window.scrollTo(window.scrollX, window.scrollY - 41);
	// });
	$(window).scroll(function() {
		var $myTop = $(document).scrollTop();
		if ($myTop > 124) {
			$(".lang-selector, .tocify-wrapper").addClass("stick-top");
		} else {
			$(".lang-selector, .tocify-wrapper").removeClass("stick-top");
		}
	});
	$(window).scroll(function() {
		var $myBottom = $(document).height() - $(window).height() - $(window).scrollTop();
		if ($myBottom < 285) {
			$(".lang-selector, .tocify-wrapper").addClass("stick-bottom");
		} else {
			$(".lang-selector, .tocify-wrapper").removeClass("stick-bottom");
		}
	});
	var myHeaderWidth = $(".header-login").width();
</script>

        <g:render template="/site/includes/google_analytics"  />
        
        
        <style>
 body{
	 font:13px/1.5  'CiscoSansLight',Arial,Helvetica,sans-serif;
 } 
 
 .content h1, .content section h1, .content h2, .content section h2, .content h3, .content section h3, .content h4, .content h5, .content h6, .content section h4, .content section h5, .content section h6, html, body {
font-family:  'CiscoSansLight',Arial,Helvetica,sans-serif
}


.social-floater{display:none;}
 </style>
        
  
   <!-- InstanceBeginEditable name="header_region" -->
  
   <!-- InstanceEndEditable -->
  
</head>  

  <!--[if lt IE 7]> <body class="no-js ie6 oldie index"> <![endif]-->
  <!--[if IE 7]>    <body class="no-js ie7 oldie index"> <![endif]-->
  <!--[if IE 8]>    <body class="no-js ie8 oldie index"> <![endif]-->
  <!--[if gt IE 8 | !(IE)]><!--> <body class="no-js index"> <!--<![endif]-->
  
<!-- Include header and navigation -->
    
     <!--incl refs -->
        
        <!-- Include header and navigation -->
        <div id="majorMenu"> 
            <g:render template="/site/includes/structure/crankset/widgets/top2013"  />  
        </div>    
            
        <div id="stalk">     
            <g:render template="/site/includes/structure/crankset/widgets/navs/topNav/threeLevels/combo/devnet-combo"  />  
        </div>
             
    <div class="main-container container_14">
    	<g:render template="/site/includes/widgets/breadcrumbs"  />
    </div>
  
<div id="dpSlateContent" >
  <script>
  document.write ('<object type="text/html" data="/dpslate/build', window.location.pathname.replace(".gsp", ".html") , '" width="100%" height="1400px" ></object>');
  </script>
</div>
  
<g:render template="/site/includes/structure/crankset/widgets/footer2"  />  
<g:render template="/site/includes/structure/crankset/widgets/botomjs"  /> 
    
</body>
<!-- InstanceEnd --></html>