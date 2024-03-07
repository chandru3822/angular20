import { getSnackbar } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()

export const SnackbarPlugin = {
  install(Vue, { store }) {
    Vue.prototype.$snackbar = (type, msg, displayAsHtml = false) => {
      const snackbar = getSnackbar(type, msg, displayAsHtml)
      //@TODO: update both stores until pinia takes over, then remove this
      store.commit(AppMutations.SHOW_SNACK, snackbar)
      appStore.showSnack(snackbar)
    }
  }
}
