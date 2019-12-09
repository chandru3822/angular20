import Vue from 'vue'
import Vuex from 'vuex'
import { UserStore } from '@/stores/UserStore'
import { AppStore } from '@/stores/AppStore'
import { MAX_FILE_SIZE } from '@/helpers/helpers'
import {postRequest, deleteRequest, getRequest, getRequestWithParams} from "./helpers/helpers";
import {AppMutations} from "./stores/AppStore";

Vue.use(Vuex)

export const Mutations = {
  INIT: 'storeInt',
}

export const Actions = {
  FILE_UPLOAD: 'fileUpload',
  FILE_DELETE: 'fileDelete',
  FILE_GET_ONE: 'fileGetOne',
  FILE_GET_LIST: 'fileGetList',
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
    [Actions.FILE_DELETE]: async (context, { id, callback }) => {
      //todo: need to handle errors in these functions
      const {status} = await deleteRequest(`/attachment/${id}`)
      callback(status)
    },
    [Actions.FILE_UPLOAD]: (context, { file, attachmentTypeId, sourceId, deleteFirst, callback }) => {
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > MAX_FILE_SIZE) {
          const error = { error: true, errorMsg: 'File size cannot exceed 10MB' }
          callback(error)
        } else {
          let formData = new FormData()
          formData.append('file', file)
          formData.append('attachmentTypeId', attachmentTypeId)
          formData.append('sourceId', sourceId)
          formData.append('deleteFirst', deleteFirst)

          const resp = await postRequest('/attachment', formData)

          const {status} = resp
          if (status === 200) {
            callback(resp.data)
          }
        }
      })
      reader.readAsArrayBuffer(file)
    },
    [Actions.FILE_GET_ONE]: async (context, { sourceId, attachmentTypeId, callback }) => {
      const {data, status} = await getRequestWithParams(`/attachment/getOne`, { params: {
        attachmentTypeId, sourceId
      }})
      callback(data, status)
    },
    [Actions.FILE_GET_LIST]: async (context, { sourceId, attachmentTypeId, callback }) => {
      const {data, status} = await getRequestWithParams(`/attachment`, { params: {
          attachmentTypeId, sourceId
        }})
      callback(data, status)
    },
  }
})

export default store
