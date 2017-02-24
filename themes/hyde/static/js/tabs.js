// main navigation
$(document).ready(function(){
 var segments = window.location.pathname.split('/');
 for (var i = 0; i < segments.length; i++) {
   if (segments[i].trim().length > 0) {
     $('#' + segments[i]).addClass('active');
     break;
   }
 }
});

// tabs in bench suites
$(document).ready(function(){
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

$(document).keypress(function(e) {
  if (e.charCode == 36) {
      $('tr.row.mssql').removeClass('mssql').addClass('_mssql');
      $('tr.row.oracle12c').removeClass('oracle12c').addClass('_oracle12c');
  } else if (e.charCode == 104) {
      $('tr.row._mssql').removeClass('mssql').addClass('mssql');
      $('tr.row._oracle12c').removeClass('oracle12c').addClass('oracle12c');
  }
});