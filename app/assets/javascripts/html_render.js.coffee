# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
alert($('.bar').attr('style'))

setInterval(->
#  stat = $('#download-btn').attr('disabled')
#  if(stat == 'disabled')
#    location.relaod()
  $.post('/html_render/update_progress',{
    whole_num: 4,
    dir_path: 'foo/bar'
  })
, 2000);
