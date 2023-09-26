import { defineStore } from 'pinia'

const defaultState = {
  storedReport: {},
  storedColumns: [],
  storedFilters: [],
  storedUnsavedChanges: false
}

export default defineStore('report', {
  state: () => {
    if (localStorage.getItem('report')) {
      return JSON.parse(localStorage.getItem('report'))
    } else {
      return defaultState
    }
  },
  getters: {
    report() {
      return this.storedReport
    },
    columns() {
      return this.storedColumns
    },
    filters() {
      return this.storedFilters
    },
    hasUnsavedChanges() {
      return this.storedUnsavedChanges
    }
  },
  actions: {
    setReport(newReport) {
      this.storedReport = newReport
    }
  }
})