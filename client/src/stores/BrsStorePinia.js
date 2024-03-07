import { defineStore } from 'pinia'

const defaultState = {
  commissionPositionId: null
}

export const useBrsStore = defineStore('brs', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {

  },
  actions: {

  }
})