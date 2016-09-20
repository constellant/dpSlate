(function () {
  'use strict';

  var content, searchResults;
  var matchOpts = { element: 'span', className: 'match' };

  var index = new lunr.Index();

  index.ref('id');
  index.field('title', { boost: 10 });
  index.field('body');
  index.pipeline.add(lunr.trimmer, lunr.stopWordFilter);

  $(populate);
  $(bind);

  function populate() {
    $('h1, h2').each(function() {
      var title = $(this);
      var body = title.nextUntil('h1, h2');
      index.add({
        id: title.prop('id'),
        title: title.text(),
        body: body.text()
      });
    });
  }

  function bind() {
    content = $('.content');
    searchResults = $('.search-results');

    $('#input-search').on('keyup', search);
  }

  function search(event) {
    unmatch();
    searchResults.removeClass('invisible');
    $(".toc-title").addClass('invisible'); 
    $(".toc").addClass('invisible');  //hide the Table of Contents when searching

    // ESC clears the field
    if (event.keyCode === 27) this.value = '';

    if (this.value) {
      var results = index.search(this.value).filter(function(r) {
        return r.score > 0.0001;
      });

      if (results.length) {
        searchResults.empty();
        match.call(this);
        searchResults.html('<li style="color:green"></li>');
        var matches = $('.match');
        $('.search-results li').text( matches.length.toLocaleString('en') + ' Results Found and Highlighted');
        $('.search-results li').append('<span id="searchPrev"> &lt;&lt;prev </span><span id="searchNext"> next&gt;&gt; </span>');
        // keep track of next and previous. Start at one because on SEARCH the forst one was already highlightes
        var matchIndex = 0;
        // look out for user click on NEXT
        $('#searchNext').on('click', function() {
          //Re-set match index to create a wrap effect if the amount if next clicks exceeds the amount of matches found
          if (matchIndex >= matches.length){
            matchIndex = 0;
          }
          var currentMatch = $('.match');
          currentMatch.removeClass('search-highlight');
          var nextMatch = $('.match').eq(matchIndex);
          matchIndex += 1;
          nextMatch.addClass('search-highlight');
          // scroll to the top of the next found instance -n to allow easy viewing
          $(window).scrollTop(nextMatch.offset().top-30);
        });
        // look out for user click on PREVIOUS
        $('#searchPrev').on('click', function() {
          //Re-set match index to create a wrap effect if the amount if next clicks exceeds the amount of matches found
          if (matchIndex < 0){
            matchIndex = matches.length-1;
          }
          var currentMatch = $('.match');
          currentMatch.removeClass('search-highlight');
          var previousMatch = $('.match').eq(matchIndex-2);
          matchIndex -= 1;
          previousMatch.addClass('search-highlight');
          // scroll to the top of the next found instance -n to allow easy viewing
          $(window).scrollTop(previousMatch.offset().top-30);
        });
      } else {
        searchResults.html('<li style="color:red"></li>');
        $('.search-results li').text('No Results Found for "' + this.value + '"');
      }
    } else {
      unmatch();
      searchResults.addClass('invisible');
      $(".toc-title").removeClass('invisible'); 
      $(".toc").removeClass('invisible');  //restore the toc
    }
  }

  function match() {
    if (this.value) content.highlight(this.value, matchOpts);
  }

  function unmatch() {
    content.unhighlight(matchOpts);
  }
})();
