$(document).ready(function($) {
  username = $("body").attr("username")
  function chatInit(sess_id) {
    url = "sessions/"+sess_id+"messages/"
    //console.log(sess_id)
    var fire = new Firebase('https://pair-pro.firebaseio.com/sessions/'+sess_id);


    fire.child("/messages").on('child_added', function(child, prev){
        console.log(child.val())
        d = child.val()
        $("#messagesContainer").append('<p class="animated bounceIn"><b>'+d.username+'</b>: '+d.text+''+
          '<i class="material-icons tick-messages">done_all</i></p>')
    });

    $("#sendChatBtn").click(function() {
      sendToFirebase();
    });

    $('#messageInput').keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which);
      if(keycode == '13'){
          sendToFirebase()
      }
    });


    function sendToFirebase(){
      text = $("#messageInput").val();
      if (text.trim()) {
        var fire = new Firebase('https://pair-pro.firebaseio.com/sessions/'+sess_id+'/messages');
        fire.push({username: username, text: text})
        $("#messageInput").val("")
      } else{
        alert("Please type something!!")
      }
    }
  }


  sess_id = $("#chatDiv").attr("session-id");
  if (sess_id) {
    chatInit(sess_id);
  }

});