import './style.css'
import Alpine from 'alpinejs'
import { formatTime } from './utils'
import type { Room, User, Users } from './types'
import { ChatServerAdapter as ChatServerAdapter } from './ChatServerAdapterShiny'

globalThis.Alpine = Alpine // useful for debugging
globalThis.formatTime = formatTime // make function available globally

const chatServer = new ChatServerAdapter(true);

Alpine.store('thisUser', {
  id: undefined,
  name: undefined,
} as User)


Alpine.store('users', {
  users: [],

  getUserById(id) {
    if (!id) return undefined
    return this.users.find(user => user.id === id)
  }

} as Users)


Alpine.store('room', {
  history: [],

  addEvent(event) {
    this.history.push(event)
  },

  sendMessage(message: string) {
    chatServer.sendMessage(message)
  }

} as Room)


chatServer.onUpdateThisUser((newData) => {
  console.log("Updating thisUser store with new data:", newData);
  (Alpine.store('thisUser') as User).id = newData.id;
  (Alpine.store('thisUser') as User).name = newData.name;
})

chatServer.onUpdateRoomHistory((history) => {
  (Alpine.store('room') as Room).history = history;
})

chatServer.onUpdateUserList((users) => {
  (Alpine.store('users') as Users).users = users;
})

chatServer.onChatEvent((event) => {
  (Alpine.store('room') as Room).addEvent(event);
})



Alpine.start()