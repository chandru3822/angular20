import Vue from 'vue'
import Vuex from 'vuex'
import { UserStore } from '@/stores/UserStore'
import { AppStore } from '@/stores/AppStore'
import axios from 'axios'
import { MAX_FILE_SIZE } from '@/helpers/helpers'

const { VUE_APP_BASE_API } = process.env

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
      reader.addEventListener('loadend', async function () {
        if (file.size > MAX_FILE_SIZE) {
          const error = { error: true, errorMsg: 'File size cannot exceed 10MB' }
          callback(error)
        } else {
          const { data } = await axios.post(`${VUE_APP_BASE_API}/requestUploadURL`, {
            name: file.name,
            type: file.type,
            attachmentSourceTypeId
          })
          const { uploadURL, key, type, disposition } = data
          const resp = await axios({
            method: 'put',
            url: uploadURL,
            headers: { 'Content-Type': type, 'Content-Disposition': disposition },
            data: new Blob([reader.result], { type: file.type })
          })
          const { status } = resp
          if (status === 200) {
            axios.post(`${VUE_APP_BASE_API}/setLocalS3Data`, {
              filename: file.name,
              contentType: file.type,
              fileSize: file.size,
              key,
              attachmentSourceTypeId,
              sourceId
            }).then(({ data }) => {
              const { asset } = data
              callback(asset)
            }).catch(() => {
              const reqLocalError = { error: true, errorMsg: 'Error Uploading File: S3' }
              callback(reqLocalError)
            })
          }
        }
      })
      reader.readAsArrayBuffer(file)
    }
  }
})

export default store
