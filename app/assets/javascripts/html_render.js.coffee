# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#alert($('.bar').attr('style'))

whole_num = $('#whole-num').html()
html_dir = $('#html_dir').text()

setInterval(=>
  stat = $('#download-btn').attr('disabled')
  if(stat == 'disabled')
    $.post('/html_render/update_progress',{
      whole_num: whole_num
      html_dir: html_dir
    })
, 4000);
