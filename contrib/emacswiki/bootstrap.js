// Public Domain
// initial version by Alex Schroeder <alex@gnu.org>
// with many improvements by Evgkeni Sampelnikof

$(function(){

  // add fancy classes
  $('div.header' ).addClass('container');
  $('div.wrapper').addClass('container');
  $('div.footer' ).addClass('container');
  $('div.footer > .navbar' ).remove();
  $('.message > p' ).addClass('alert');
  $('img.portrait').addClass('img-polaroid');

  $('input:text').addClass('input-medium search-query');
  $('textarea').addClass('span12');
  $('input:submit').addClass('btn');
  $('.download a').addClass('btn btn-success');

  $('.footer .gotobar').remove();
  $('.footer br').first().remove();
  var $gotobar = $('.gotobar')
                   .after($('<div>').attr('class','navbar')
                     .append($('<div>').attr('class','navbar-inner')
                       .append($('<ul>').attr('class', 'nav'))));
  var $id = $('h1 a').first().text();
  var $list = $('.nav')
                .append($('<li>')
                  .append($('<a>').attr('class', 'brand').attr('href', 'http://www.emacswiki.org/')
                    .append('Emacs Wiki')));
  $('.gotobar a').each(function() {
    var $item = $('<li>');
    $(this).appendTo($item);
    $item.appendTo($list);
    if ($(this).text() == $id) {
      $item.addClass('active');
    }
  });
  $gotobar.remove();

  // search without labels, without button, without language field
  $('form.search input[type=submit]').remove();
  $('form.search label').remove();
  $('form.search input#searchlang').remove();
  $('form.search')
	.css({'float': 'right',
	      'margin-top': '10px'});
  $('.navbar').append($('form.search'));

  // add button style to some links
  $('.edit.bar a').addClass('btn');

  // add color to Talk button for a non-existing page
  $('a.btn.comment.edit').addClass('btn-warning');

  // move article link and talk link below title
  var $link = $('a.original').add('a.comment');
  if ($link) {
    $('.header h1').after($('<p>').append($link));
  }

  // toc
    if ($('title').text() == "EmacsWiki: Wikified Emacs Lisp List") {
	$('.content').addClass('ell');
    }

  // tables
  $('table').addClass('table');

  // minor edit checkbox
  $('input[type=checkbox]').addClass('checkbox');
  $('input[type=checkbox]').parent().addClass('checkbox');

  // clean up admin page
  $('li a.clear').parent().remove();
  $('li a.index').parent().remove();

  $('a[href="http://creativecommons.org/licenses/GPL/2.0/"]')
    .parent()
    .css({'margin-right': '120px',
          'opacity': 0.3,
          'padding-top': '1em'});
  $('.footer .bar')
    .after('<hr />');
  var footer_wrapper = $('<div/>')
    .addClass('footer_wrapper');
  var footer = $('.footer.container');
  footer.after(footer_wrapper);
  footer_wrapper.append(footer);
  var logo_image = $('<img />')
    .attr('src', 'http://emacswiki.org/ew_logo.png');
  $('.header .navbar .brand').html(logo_image);
});
