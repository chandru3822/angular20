import { defineStore } from 'pinia'

const defaultState = {
  commissionPositionId: 1 //1 is always the default to start with
}

export const useBrsStore = defineStore('brs', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {

  },
  actions: {

  }
})