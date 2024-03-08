import router from '@/router.js'
import store, { pinia } from '@/store.js'
import constants from '@/helpers/constants.js'
import axios from 'axios'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useFileStore } from '@/stores/FileStore.js'

const { VITE_ENV, VITE_BASE_API } = import.meta.env
const JWT_EXPIRED = 'invalid token'
const userStore = useUserStore(pinia)
const appStore = useAppStore(pinia)
const fileStore = useFileStore(pinia)

export function responseInterceptor({ response }) {
  if (response) {
    const { message } = response?.data
    const { status } = response
    console.error('*** Request Error ***', response)
    // if the jwt token expired, or 401 unauthorized, or 403 Forbidden
    if (
      (message && message.toLowerCase().indexOf(JWT_EXPIRED) > -1) ||
      status === 401 ||
      status === 403
    ) {
      const msg =
        response.status === 401
          ? 'Session Expired'
          : response.status === 403
          ? 'User Unauthorized'
          : 'Unknown Error'

      if (response?.data?.maintenanceMode && status === 403) {
        //if we dont remove the store item then a logged in user who USED to have permission will still have permission later
        localStorage.removeItem('store')
        router.push({ name: 'siteUnderMaintenance' })
      } else {
        localStorage.removeItem('store')
        userStore.loginError = msg

        //this code handles redirecting them back to the page they were trying to get to after they login
        let rt = {
          name: 'login',
        }
        if (
          !['/', '/home'].includes(router.currentRoute?.path) ||
          appStore.redirectUrl != null
        ) {
          rt.query = {
            redirect: router.currentRoute?.path || appStore.redirectUrl,
          }
        }

        router.push(rt)
      }
    } else if (
      response?.data?.message === constants.NOT_FOUND_404_TEXT &&
      status === 404
    ) {
      router.push({ path: `/dataNotFound` })
    } else if (status >= 500 && status <= 599) {
      //remove the loading spinner that was likely turned on before this error happened
      appStore.loading = false
      //dont do this reroute on local, it is super annoying
      if (VITE_ENV !== 'local') {
        router.push({ path: `/serverError?code=${response.status}` })
      } else {
        //if local we dont reroute, but throw the error so we can see if failed
        // throw { data: response?.data, status }
        return Promise.reject({ data: response?.data, status })
      }
    } else if (![200, 201, 204].includes(status)) {
      //dont take this out, it makes axios await errors work correctly
      // throw { data: response?.data, status }
      return Promise.reject({ data: response?.data, status })
    }
  }
}

export function requestInterceptor(config) {
  if (
    store &&
    store.state &&
    userStore?.jwt &&
    (config.baseURL?.indexOf(VITE_BASE_API) > -1 ||
      config.url.indexOf(VITE_BASE_API) > -1)
  ) {
    config.headers['Authorization'] = `Bearer ${userStore.jwt}`
  }

  // if config.source passed in then use that
  let source = config.source
  //dont cancel if override sent in
  let skipCancel = config.skipCancel

  if (!source) {
    // if no source passed in, Generate cancel token source
    source = axios.CancelToken.source()
    config.cancelToken = source.token
  }

  // Add to vuex to make cancellation available from anywhere
  // todo: investigate using parent/child route detection instead of a param that gets passed in and always skipsCancel even if leaving the route tree
  if (!skipCancel) {
    fileStore.cancelTokens.push(source)
  }
  return config
}
