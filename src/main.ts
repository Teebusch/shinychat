import './style.css'
import Alpine from 'alpinejs'
import { formatTime } from './utils'
import type { RoomStore, ThisUserStore, UserStore } from './types'

declare global {
  // Extend globalThis to include Alpine and formatTime
  var Alpine: typeof import("alpinejs");
  var formatTime: (date: string | Date) => string;
}

globalThis.Alpine = Alpine // useful for debugging
globalThis.formatTime = formatTime // make function available globally

Alpine.store('user', {
  id: '11',
  name: 'Alice'
} as ThisUserStore)


Alpine.store('users', {
  users: [
    { id: '11', name: 'Alice',   lastSeen: '2023-10-01 12:00', isSelf: true },
    { id: '22', name: 'Bob',     lastSeen: '2023-10-01 12:00' },
    { id: '33', name: 'Charlie', lastSeen: '2023-10-01 12:00' },
    { id: '44', name: 'David',   lastSeen: '2023-10-01 12:00' },
    { id: '55', name: 'Eve',     lastSeen: '2023-10-01 12:00' }
  ],

  getUserById(id) {
    if (!id) return undefined
    return this.users.find(user => user.id === id)
  }
} as UserStore)


Alpine.store('room', {
  messages: [
    { id: '1', text: 'Hello, world! How is it going. This is a long message.', timestamp: '2023-10-01 12:00', userId: '11' },
    { id: '2', text: 'How are you?', timestamp: '2023-10-01 12:05', userId: '22' },
    { id: '3', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '33' },
    { id: '4', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '11' },
    { id: '5', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '22' },
    { id: '6', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '33' },
    { id: '7', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '11' },
    { id: '8', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '22' },
    { id: '9', text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: '33' }
  ]
} as RoomStore)

Alpine.start()