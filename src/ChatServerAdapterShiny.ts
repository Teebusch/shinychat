import type { ChatEvent, ThisUser, User } from "./types";

const mockShinyObject = {
  setInputValue: (name: string, value: any, options: {}) => {
    console.log(`Mock Shiny: setInputValue called with name=${name}, value=${value}, options=${JSON.stringify(options)}`);
  },
  addCustomMessageHandler: (name: string, handler: (message: any) => void) => {
    console.log(`Mock Shiny: CustomMessageHandler added for Event '${name}'`);
  }
}



export class ChatServerAdapter {
  #Shiny;

  constructor(mockShiny = false) {
    if (mockShiny) {
      this.#Shiny = mockShinyObject;
      return;
    }

    this.#Shiny = window.Shiny;

    if (!this.#Shiny) {
      throw new Error("Shiny JavaScript library is not available.");
    }
  }

  sendMessage(message: string) {
    this.#Shiny.setInputValue('send_chat_message', message, {priority: "event"});
  }

  onChatEvent(callback: (event: ChatEvent) => void) {
    this.#Shiny.addCustomMessageHandler("chat-message", callback);
    this.#Shiny.addCustomMessageHandler("user-added", callback);
    this.#Shiny.addCustomMessageHandler("user-removed", callback);
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
