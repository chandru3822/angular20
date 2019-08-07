import Vue from 'vue'
import Vuex from 'vuex'
import { UserStore } from '@/stores/UserStore'
import { AppStore } from '@/stores/AppStore'
import { MAX_FILE_SIZE } from '@/helpers/helpers'
import { postRequest } from "./helpers/helpers";

Vue.use(Vuex)

export const Mutations = {
  INIT: 'storeInt'
}

export const Actions = {
  FILE_UPLOAD: 'fileUpload'
}

const store = new Vuex.Store({
  plugins: [
    store => {
      store.commit(Mutations.INIT)
      store.subscribe((mutation, state) => {
        localStorage.setItem('store', JSON.stringify(state))
      })
    }
  ],
  modules: {
    user: UserStore,
    app: AppStore
  },
  mutations: {
    [Mutations.INIT] (state) {
      if (localStorage.getItem('store')) {
        const hydratedState = JSON.parse(localStorage.getItem('store'))
        this.replaceState(Object.assign(state, hydratedState))
      }
    }
  },
  actions: {
    [Actions.FILE_UPLOAD]: (context, { file, attachmentSourceTypeId, sourceId, callback }) => {
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > MAX_FILE_SIZE) {
          const error = { error: true, errorMsg: 'File size cannot exceed 10MB' }
          callback(error)
        } else {
          let formData = new FormData()
          formData.append('file', file)
          formData.append('attachmentSourceTypeId', attachmentSourceTypeId)
          formData.append('sourceId', sourceId)

          const resp = await postRequest('/api/v1/flow/document/upload', formData)

          const {status} = resp
          if (status === 200) {
            callback(resp.data)
          }
        }
      })
      reader.readAsArrayBuffer(file)
    }
  }
})

export default store
