import { defineStore } from 'pinia'

export const useNoteStore = defineStore('noteStore', {
  // Reactive state
  state: () => ({
    note: '',
    selectedTopics: [],
    addActivity: false,
    noteId: ''
  }),

  //  Getter: true if note is not empty or selectedTopics has items
  getters: {
    hasNote: (state) => {
      return (
        !!state.note ||
        (Array.isArray(state.selectedTopics) && state.selectedTopics.length > 0)
      )
    },
    hasNoteID: (state) => {
      return state.noteId
    }
  },

  //  Actions to update or clear state
  actions: {
    setNote(value) {
      this.note = value
    },
    setNoteId(value) {
      this.noteId = value
    },
    setSelectedTopics(value) {
      this.selectedTopics = value
    },
    clearNote() {
      this.note = ''
      this.selectedTopics = []
      this.noteId = ''
    },
    addActivityNote(value) {
      this.addActivity = value
    }
  }
})
