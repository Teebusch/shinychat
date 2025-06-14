declare global {
  // Extend globalThis to include Alpine and formatTime
  var Alpine: typeof import("alpinejs");
  var formatTime: (date: string | Date) => string;
}

export type User = {
  id: string | undefined;
  name: string | undefined;
  // Optional properties to track user state
  lastSeen?: string;
}

export type Users = {
  users: User[];
  getUserById: (id: string) => User | undefined;
}

export type ChatEvent = {
  id: string;
  type: 'message' | 'user-joined' | 'user-left';
  timestamp: string;
  userId: string;
  message?: string; // Optional, for message events
}

export type Room = {
  history: ChatEvent[];
  addEvent: (event: ChatEvent) => void;
  sendMessage: (message: string) => void;
}

