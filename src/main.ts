import './style.css'

import Alpine from 'alpinejs'
import { formatTime } from './utils'

window.Alpine = Alpine // useful for debugging

Alpine.store('thisUser', {
  id: 1,
  name: 'Alice'
})

Alpine.store('users', {

  users: [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
    { id: 3, name: 'Charlie' },
    { id: 4, name: 'David' },
    { id: 5, name: 'Eve' }
  ],

  getUserById(id: number) {
    return this.users.find(user => user.id === id)
  }

})

Alpine.store('room', {
  messages: [
    { id: 1, text: 'Hello, world!', timestamp: '2023-10-01 12:00', userId: 1 },
    { id: 2, text: 'How are you?', timestamp: '2023-10-01 12:05', userId: 2 },
    { id: 3, text: 'Goodbye!', timestamp: '2023-10-01 12:10', userId: 3 }
  ]
})

Alpine.start()