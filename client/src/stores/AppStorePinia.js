import { defineStore } from 'pinia'
import theme from '@/helpers/defaultTheme.js'

const defaultState = {
  loading: false,
  selectedProcessStepName: null,
  availableUpdate: false,
  redirectUrl: null,
  spinnerUrl: null,
  announcements: [],
  theme: theme.LIGHT,
  snack: {
    show: false
  }
}

export const useAppStore = defineStore('app', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {

  },
  actions: {
    showSnack(snack) {
      this.snack = {...snack, show: true}
    }
  }
})