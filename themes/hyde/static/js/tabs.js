$(document).ready(function(){
  var blog_bg = [
    'blue',
    'green',
    'aqua'
  ];

  var $blog_section = $('.home .blog-section');

  // latest blog posts on homepage
  $.getJSON('https://www.nuxeo.com/api/blog_en.json', function (result) {
    var blogLimit = 3;
    var categoryFilter = [
      'product and development',
      'product & development'
    ];
    var imagePrefix = '/assets/imgs/';
    var blogCount = 0;

    for (var i = 0; blogCount < blogLimit && i < result.length; i++) {
      var post = result[i];
      var categories = post && post.category && post.category['blog-tag'] || [];
      // console.log('post', post);
      // console.log('categories', categories.join(', '));

      var hasCategory = categories.reduce(function (hasCategory, category) {
        category = category.toLowerCase();
        if (!hasCategory) {
          categoryFilter.forEach(function (filter) {
            if (category === filter) {
              hasCategory = true;
            }
          })
        }
        return hasCategory;
      }, false);

      if (hasCategory) {
        // Remove prefix if necessary
        var featured_image = post.featured_image.indexOf(imagePrefix) === 0 ? post.featured_image.substring(imagePrefix.length) : post.featured_image;

        $blog_section.append('<div class="small-12 medium-4 columns blog-post"><a href="https://www.nuxeo.com/blog/' + post.slug + '" target="_blank"><div class="is-bg-' + blog_bg[blogCount] + ' full-height"><img src="https://res.cloudinary.com/nuxeo/image/upload/h_275,w_550,c_fill,g_faces:auto,f_auto,dpr_auto,q_auto/' + featured_image + '" width="100%"><div class="padded0"><h3>' + post.title + '</h3><p>' + post.excerpt + '</p></div></div></a></div>');

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

$(document).foundation();
