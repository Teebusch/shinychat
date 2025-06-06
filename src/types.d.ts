export type Message = {
  id: string;
  text: string;
  timestamp: string;
  userId: string;
}

export type MessageList = Message[];

export type User = {
  id: string;
  name: string;
  lastSeen: string;
  isSelf?: boolean;
}

export type UserList = User[];

export type UserStore = {
  users: UserList;
  getUserById: (id: string) => User | undefined;
}

export type RoomStore = {
  messages: MessageList;
}

export type ThisUserStore = {
  id: string;
  name: string;
}