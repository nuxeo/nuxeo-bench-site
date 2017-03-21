$(document).ready(function(){

  // latest blog posts on homepage
  $.getJSON('https://www.nuxeo.com/api/blog_en.json', function(result){
    var blogLimit = 3, blogTag = 'Benchmark';
    var blogCount = 0;
    for(var i = 0; blogCount < blogLimit && i < result.length; i++) {
      var field = result[i];
      var categories = [], hasTag = false;
      $.each(field.category, function(name, data) {
        if ('blog-tag' === data.domain) {
          categories.push(name);
          if (blogTag === name) {
            hasTag = true;
          }
        }
      });
      if (hasTag) {
        $('.home .blog-section').append('<a class="flex-ctn blog-post" href="https://www.nuxeo.com/blog/' + field.slug + '" target="_blank"><div>' + categories + '</div><hr><div class="h2-like title">' + field.title + '</div><div>' + new Date(field['wp:post_date']).toLocaleDateString() + ' • ' + field['dc:creator'] + '</div></a>');
        blogCount++;
      }
    }
  });

  // tabs in bench suites
  $('ul.tabs li').click(function(ele) {
    if (!$(this).hasClass('active')) {
      var tabNum = $(this).index();

      $(this).siblings().removeClass('active');
      $(this).addClass('active');

      var div = $(this).parents('.bench').find('.tabs-content');
      div.children().removeClass('active');
      div.children().eq(tabNum).addClass('active');
    }
  });
});
