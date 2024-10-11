import { defineStore } from 'pinia'

const defaultState = {
  pps: null,
  linkLabel: null,
  ppsEvent: null,
  selectedTab: 1,
  notesActivityView: 1,
  forceReloadKey: 0,
  manualColumnSplit: false,
  leftSideSplit: false,
  rightSideSplit: false,
  activePpsDropdown: true,
  activeEventDropdown: true,
  projectDetailsDropdown: false,
  projectChildrenDropdown: false,
  projectParentDropdown: false
}

export const useProjectStore = defineStore('project', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {

  },
  actions: {
    resetProjectState() {
      this.pps = {}
      this.ppsEvent = {}
    },
    resetPpsEventState() {
      this.ppsEvent = {}
    },
    incrementReloadKey() {
      this.forceReloadKey++
    }
  }
})