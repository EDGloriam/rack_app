$(document).ready(function() {
  $('.btn-try').on('click', function(e) {
    if($("#user_input").val().match(/[1-6]{4}/) == null){
        e.preventDefault();
        $("#user_input").css("border", "2px solid red")
        $("#warning").html("incorrect input")
    }
});
});
