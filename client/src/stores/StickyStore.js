// a store to hold input field values that BRS wants to keep saved when navigating to other pages and then back
import { defineStore } from 'pinia'

const defaultState = {
  projectFilter: '' // filter value when on the project search page
}
export const useStickyStore = defineStore('StickyStore', {
  persist: false,
  state: () => ({...defaultState}),
  actions: { logout() {this.$patch(defaultState)}} // data only persists during the session
})
