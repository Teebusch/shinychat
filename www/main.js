// Handle sending new chat message
$(document).keyup(function(event) {
  if ($('#new-message-text').is(":focus") && (event.key == "Enter") && (event.shiftKey == false)) {
    let content = $('#new-message-text').val();
    $('#new-message-text').val('');
    Shiny.setInputValue('send_chat_message', content, {priority: "event"});
  }
});


// Handle closing / refreshing page
window.onbeforeunload = function() {
  Shiny.setInputValue('user_logout', globalThis.thisUserInfo, {priority: "event"});
}


// Handlers for messages from server
Shiny.addCustomMessageHandler("set-this-user-info", setThisUserInfo);
Shiny.addCustomMessageHandler("update-room-history", updateRoomHistory);
Shiny.addCustomMessageHandler("chat-message", addChatMessage);
Shiny.addCustomMessageHandler("user-added", addRoomEventMessage);
Shiny.addCustomMessageHandler("user-removed", addRoomEventMessage);
Shiny.addCustomMessageHandler("update-user-list", updateUserList);



function setThisUserInfo(userInfo) {
  globalThis.thisUserInfo = userInfo;
}



function updateRoomHistory(history) {
  let messages = document.getElementById('messages');

  let renderedHistory = history.map((event) => {
    if (event.event_type == "chat-message") {
      let chatMessage = renderChatMessage(event);
      return(chatMessage)
    }
    if (event.event_type == "user-added" || event.event_type == "user-removed") {
      let roomEvent = renderRoomEvent(event);
      return(roomEvent)
    }
  })

  messages.replaceChildren(...renderedHistory);
  renderedHistory.at(-1).scrollIntoView()
}



function renderChatMessage(message) {

  let message_is_from_self = globalThis.thisUserInfo.user_uid == message.author_uid;

  // message
  let chatMessage = document.createElement('div');
  chatMessage.classList.add('chat-message');
  chatMessage.classList.toggle('from-self', message_is_from_self);

  // avatar
  let avatar = document.createElement('div');
  avatar.classList.add('avatar');
  let avatarImage = document.createElement('img');
  avatarImage.setAttribute("src", `avatar/${ message.author_name }`);
  avatar.appendChild(avatarImage);

  // speech bubble
  let bubble = document.createElement('div');
  bubble.classList.add('chat-bubble');

  // author name
  let authorName = document.createElement('div');
  authorName.classList.add('chat-bubble__author');
  authorName.innerText = message_is_from_self ? "You" : message.author_name;

  // content
  let content = document.createElement('div');
  content.classList.add('chat-bubble__content');
  let messageText = message.content.trim().replace('\n', "\n\n")
  content.innerText = messageText;

  // time sent
  let time = document.createElement('div');
  time.classList.add('chat-bubble__time_sent');
  let timeSent = formatTime(message.time_sent);
  time.innerHTML = timeSent;

  bubble.appendChild(authorName);
  bubble.appendChild(content);
  bubble.appendChild(time);

  chatMessage.appendChild(avatar);
  chatMessage.appendChild(bubble);

  return(chatMessage);
}



function renderRoomEvent(message) {
  let actions = {
  	'user-removed': "left the chat",
    'user-added': "joined the chat"
  };

  let action = actions[message.event_type];

  let user_is_self = globalThis.thisUserInfo.user_uid == message.user_uid;
  let username = user_is_self ? "You" : message.username;

  let messageHTML = `<span class='username'>${ username }</span> ${ action }`;

  let roomEventMessage = document.createElement('div');
  roomEventMessage.classList.add('room-event-message');
  roomEventMessage.innerHTML = messageHTML;

  return(roomEventMessage);
}



function addChatMessage(message) {
  let chatMessage = renderChatMessage(message);
  chatMessage.classList.add('fade-in');
  document.getElementById('messages').appendChild(chatMessage);
  chatMessage.scrollIntoView();
}



function addRoomEventMessage(message) {
  let roomEventMessage = renderRoomEvent(message);
  roomEventMessage.classList.add('fade-in');
  document.getElementById('messages').appendChild(roomEventMessage);
  roomEventMessage.scrollIntoView();
}



function updateUserList(users) {

  let list = document.createElement('ul');

  users.forEach((user) => {
    let user_is_self = globalThis.thisUserInfo.user_uid == user.uid;

    item = document.createElement('li');
    item.classList.toggle('is-self', user_is_self);

    let avatar = document.createElement('div');
    avatar.classList.add('avatar');
    let avatarImage = document.createElement('img');
    avatarImage.setAttribute("src", `avatar/${ user.name}`);
    avatar.appendChild(avatarImage);

    let name = document.createElement('div');
    name.classList.add('info__name');
    name.innerText = user.name;

    let details = document.createElement('div');
    details.classList.add('info__details');

    details.innerText = user_is_self ? 'You' : `Last seen ${ formatTime(user.last_seen) }`;

    let info = document.createElement('div');
    info.classList.add('info');
    info.appendChild(name);
    info.appendChild(details);

    item.appendChild(avatar);
    item.appendChild(info);
    list.appendChild(item);
  })

  let el = document.getElementById('user-list');
  el.replaceChildren(list);

  document.querySelector('.n-active').innerText = `(${ users.length })`;
}



// Helpers

formatTime = function(timestamp) {
  let date = new Date(timestamp);
  return(date.toLocaleTimeString());
}
