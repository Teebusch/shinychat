import './style.css'
import Alpine from 'alpinejs'
import { formatTime } from './utils'
import type { Room, ThisUser, User, Users } from './types'
import { ChatServerAdapter as ChatServerAdapter } from './ChatServerAdapterShiny'

globalThis.Alpine = Alpine // useful for debugging
globalThis.formatTime = formatTime // make function available globally

Alpine.store('user', {
  id: '111',
  name: 'Alice',
  update(newData: User) {
    this.id = newData.id
    this.name = newData.name
  }
} as ThisUser)


Alpine.store('users', {
  _users: [
    { id: '111', name: 'Alice',   lastSeen: '2023-10-01 12:00', isSelf: true },
    { id: '222', name: 'Bob',     lastSeen: '2023-10-01 12:00' },
    { id: '333', name: 'Charlie', lastSeen: '2023-10-01 12:00' },
    { id: '444', name: 'David',   lastSeen: '2023-10-01 12:00' },
    { id: '555', name: 'Eve',     lastSeen: '2023-10-01 12:00' }
  ],

  get users() {
    return this._users
  },

  getUserById(id) {
    if (!id) return undefined
    return this._users.find(user => user.id === id)
  },

  updateUsers(users) {
    this._users = users
  }
} as Users)


Alpine.store('room', {
  _history: [
    { id: '01', type: 'user-joined', timestamp: '2023-10-01 11:00', userId: '111' },
    { id: '02', type: 'user-joined', timestamp: '2023-10-01 11:01', userId: '222' },
    { id: '11', type: 'message',     timestamp: '2023-10-01 12:00', userId: '111', message: 'Hi!!' },
    { id: '12', type: 'message',     timestamp: '2023-10-01 12:05', userId: '222', message: 'Hi there!' },
    { id: '03', type: 'user-joined', timestamp: '2023-10-01 12:06', userId: '333' },
    { id: '13', type: 'message',     timestamp: '2023-10-01 12:10', userId: '333', message: 'Goodbye!' },
    { id: '14', type: 'message',     timestamp: '2023-10-01 12:15', userId: '111', message: 'Goodbye!' },
    { id: '15', type: 'message',     timestamp: '2023-10-01 12:20', userId: '222', message: 'Goodbye!' },
    { id: '16', type: 'message',     timestamp: '2023-10-01 12:25', userId: '333', message: 'Goodbye!' },
    { id: '17', type: 'message',     timestamp: '2023-10-01 12:30', userId: '111', message: 'Goodbye!' },
    { id: '18', type: 'message',     timestamp: '2023-10-01 12:35', userId: '222', message: 'Goodbye!' },
    { id: '19', type: 'message',     timestamp: '2023-10-01 12:40', userId: '333', message: 'Goodbye!' },
    { id: '04', type: 'user-left',   timestamp: '2023-10-01 12:44', userId: '222' },
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
  }

} as Room)


const chatServer = new ChatServerAdapter(true);

chatServer.onChatEvent(Alpine.store('room').addEvent)
chatServer.onUpdateRoomHistory(Alpine.store('room').updateHistory)
chatServer.onUpdateUserList(Alpine.store('users').updateUsers)
chatServer.onUpdateThisUser(Alpine.store('user').update)

Alpine.start()