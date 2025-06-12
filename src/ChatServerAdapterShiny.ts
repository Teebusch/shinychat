import type { ChatEvent, User } from "./types";

declare global {
  var Shiny: any;  // TODO: import Shiny Type Definitions
}

const mockShinyObject = {
  handlers: [] as {name: string, handler: (message: any) => void}[],

  setInputValue: function(name: string, value: any, options: {}) {
    console.log(`Mock Shiny: setInputValue called with name=${name}, value=${value}, options=${JSON.stringify(options)}`);
  },

  addCustomMessageHandler: function(name: string, handler: (message: any) => void) {
    this.handlers.push({ name: name, handler: handler });
    console.log(`Mock Shiny: CustomMessageHandler added for Event '${name}'`);
  }
}


export class ChatServerAdapter {
  #Shiny;

  constructor(mockShiny = false) {
    this.#Shiny = window.Shiny;
    
    if (!this.#Shiny) {
      if (mockShiny) {
        console.warn("Shiny JavaScript library is not available. Using mock Shiny object.");
        this.#Shiny = mockShinyObject;
      } else {
        throw new Error("Shiny JavaScript library is not available.");
      }
    }
  }

  sendMessage(message: string) {
    this.#Shiny.setInputValue('send_chat_message', message, {priority: "event"});
  }

  onChatEvent(callback: (event: ChatEvent) => void) {
    this.#Shiny.addCustomMessageHandler("chat-message", callback);
    this.#Shiny.addCustomMessageHandler("user-joined", callback);
    this.#Shiny.addCustomMessageHandler("user-left", callback);
  }
  
  onUpdateRoomHistory(callback: (history: ChatEvent[]) => void) {
    this.#Shiny.addCustomMessageHandler("update-room-history", callback);
  }
  
  onUpdateUserList(callback: (users: User[]) => void) {
    this.#Shiny.addCustomMessageHandler("update-user-list", callback);
  }

  onUpdateThisUser(callback: (newData: User) => void) {
    this.#Shiny.addCustomMessageHandler("update-this-user", callback);
  }
}
