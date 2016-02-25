$(document).ready(function($) {
  username = $("body").attr("username")
  function chatInit(sess_id) {
    url = "sessions/"+sess_id+"messages/"
    //console.log(sess_id)
    var fire = new Firebase('https://pair-pro.firebaseio.com/sessions/'+sess_id);

    // fire.child("/messages").on('value', function(snapshot){
    //   data = snapshot.val()
    //   //console.log(data)
    //   snapshot.forEach(function(child){
    //     //console.log(child.val())
    //     d = child.val()
    //     $("#messagesContainer").append('<p><b>'+d.username+'</b>: '+d.text+'</p>')
    //   })
    //   //console.log(data)
    // });


    fire.child("/messages").on('child_added', function(child, prev){
        console.log(child.val())
        d = child.val()
        $("#messagesContainer").append('<p><b>'+d.username+'</b>: '+d.text+'</p>')
    });

    $("#sendChatBtn").click(function() {
      text = $("#messageInput").val()
      if (text.trim()) {
        var fire = new Firebase('https://pair-pro.firebaseio.com/sessions/'+sess_id+'/messages');
        fire.push({username: username, text: text})
        $("#messageInput").val("")
      }
    });
  }


  sess_id = $("#chatDiv").attr("session-id");
  if (sess_id) {
    chatInit(sess_id);
  }

});