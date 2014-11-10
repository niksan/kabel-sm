//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require html5
//= require jquery.cycle.all.min
//= require slides.min.jquery
//= require_tree .

$(function(){
  $('#slides').slides({
    preload: true,
    preloadImage: 'img/loading.gif',
    play: 5000,
    pause: 2500,
    hoverPause: true});});

$(document).ready(function(){					
    $("#back-top").hide();
    $(function () {
        $(window).scroll(function () {
            if ($(this).scrollTop() > 200) {
                $('#back-top').fadeIn();
            } else {
                $('#back-top').fadeOut();}});
        $('#back-top a').click(function () {
            $('body,html').animate({
                scrollTop: 0}, 800);
            return false;});});				
  $("#slideshowCont").css("overflow", "hidden");
  $("#last").css("display", "block");
  $("#next").css("display", "block");
  $('#slideShow ul').cycle({ fx: 'scrollLeft',pause:1, next: '#next', prev: '#last', timeout:0});}
);
