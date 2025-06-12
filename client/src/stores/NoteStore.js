import { defineStore } from 'pinia';

export const useNoteStore = defineStore('noteStore', {

  // Reactive state
  state: () => ({
    note: '',
    selectedTopics: [],
    addActivity:false
  }),

  //  Getter: true if note is not empty or selectedTopics has items
  getters: {
    hasNote: (state) =>
      !!state.note  || (Array.isArray(state.selectedTopics) && state.selectedTopics.length > 0),  
  },

  //  Actions to update or clear state
  actions: {
    setNote(value) {
      this.note = value;
    },
    setSelectedTopics(value) {
      this.selectedTopics = value;
    },
    clearNote() {
      this.note = '';
      this.selectedTopics = [];
    },
    addActivityNote(value)
    {
      this.addActivity=value;
    }
  },
});
