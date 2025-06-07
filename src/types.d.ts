declare global {
  // Extend globalThis to include Alpine and formatTime
  var Alpine: typeof import("alpinejs");
  var formatTime: (date: string | Date) => string;
}

export type ThisUser = {
  id: string;
  name: string;
  update: (newData: User) => void;
}

export type User = {
  id: string;
  name: string;
  lastSeen?: string;
  isSelf?: boolean;
}

export type Users = {
  _users: User[];
  get users(): User[];
  getUserById: (id: string) => User | undefined;
  updateUsers: (users: User[]) => void;
}

export type ChatEvent = {
  id: string;
  type: 'message' | 'user-joined' | 'user-left';
  timestamp: string;
  userId: string;
  message?: string; // Optional, for message events
}

export type Room = {
  _history: ChatEvent[];
  get messages(): ChatEvent[];
  get roomEvents(): ChatEvent[];
  get history(): ChatEvent[];
  addEvent: (event: ChatEvent) => void;
  updateHistory: (history: ChatEvent[]) => void;
}

