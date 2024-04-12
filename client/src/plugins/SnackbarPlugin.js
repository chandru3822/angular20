import { getSnackbar } from '@/helpers/helpers'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()

export const SnackbarPlugin = {
  install(Vue) {
    Vue.prototype.$snackbar = (type, msg, displayAsHtml = false) => {
      const snackbar = getSnackbar(type, msg, displayAsHtml)
      appStore.showSnackDeprecated(snackbar)
    }
  }
}
