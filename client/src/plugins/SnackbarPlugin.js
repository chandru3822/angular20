import { getSnackbar } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'

export const SnackbarPlugin = {
  install(Vue, { store }) {
    Vue.prototype.$snackbar = (type, msg, displayAsHtml = false) => {
      const snackbar = getSnackbar(type, msg, displayAsHtml)
      store.commit(AppMutations.SHOW_SNACK, snackbar)
    }
  }
}
