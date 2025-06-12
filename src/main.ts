import './style.css'
import Alpine from 'alpinejs'
import { formatTime } from './utils'
import type { Room, ThisUser, User, Users } from './types'
import { ChatServerAdapter as ChatServerAdapter } from './ChatServerAdapterShiny'

globalThis.Alpine = Alpine // useful for debugging
globalThis.formatTime = formatTime // make function available globally

const chatServer = new ChatServerAdapter(true);

Alpine.store('user', {
  id: undefined,
  name: undefined,
  update(newData: User) {
    this.id = newData.id
    this.name = newData.name
  }
} as ThisUser)


Alpine.store('users', {
  _users: [
    // { id: '111', name: 'Alice', lastSeen: '2023-10-01 12:00' },
  ],

  get users() {
    return this._users
  },

  getUserById(id) {
    if (!id) return undefined
    return this._users.find(user => user.id === id)
  },

  updateUsers(users) {
    this._users = [...users]
  }
} as Users)


Alpine.store('room', {
  _history: [
    // { id: '01', type: 'user-joined', timestamp: '2023-10-01 11:00', userId: '111' },
    // { id: '02', type: 'message',     timestamp: '2023-10-01 12:40', userId: '111', message: 'Hello!' },
    // { id: '03', type: 'message',     timestamp: '2023-10-01 12:40', userId: '222', message: 'Goodbye!' },
    // { id: '04', type: 'user-left',   timestamp: '2023-10-01 12:44', userId: '222' },
  ],

  get messages() {
    return this._history.filter(event => event.type === 'message')
  },

  get roomEvents() {
    return this._history.filter(event => event.type !== 'message')
  },

  get history() {
    return this._history
  },

  addEvent(event) {
    this._history.push(event)
  },

  updateHistory(history) {
    this._history = history
  },


  sendMessage(message: string) {
    chatServer.sendMessage(message)
  }

} as Room)


chatServer.onChatEvent((event) => {
  console.log('event received:', event);
  (Alpine.store('room') as Room).addEvent(event);
})

chatServer.onUpdateRoomHistory((history) => {
  console.log('updating room history:', history);
  (Alpine.store('room') as Room).updateHistory(history);
})

chatServer.onUpdateUserList((users) => {
  console.log('updating user list:', users);
  (Alpine.store('users') as Users).updateUsers(users);
})

chatServer.onUpdateThisUser((newData) => {
  console.log('setting user info:', newData);
  (Alpine.store('user') as ThisUser).update(newData);
})

Alpine.start()