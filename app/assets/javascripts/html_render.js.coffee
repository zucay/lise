# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#alert($('.bar').attr('style'))

whole_num = $('#whole-num').html()
setInterval(->
  stat = $('#download-btn').attr('disabled')
  alert(stat)
  if(stat == 'disabled')
#    location.relaod()
    $.post('/html_render/update_progress',{
      whole_num: whole_num
      dir_path: 'foo/bar'
    })
, 2000);
