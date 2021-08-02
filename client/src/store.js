import Vue from 'vue'
import Vuex from 'vuex'
import { UserStore } from '@/stores/UserStore'
import { BrsStore } from '@/stores/BrsStore'
import { AppStore } from '@/stores/AppStore'
import constants from '@/helpers/constants'
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
  PROJECT_FILE_UPLOAD: 'projectFileUpload',
  PROJECT_PROCESS_STEP_FILE_UPLOAD: 'projectProcessStepFileUpload',
  OBJECT_TYPE_FILE_UPLOAD: 'objectTypeFileUpload',
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
    brs: BrsStore,
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
    [Actions.FILE_UPLOAD]: (context, { file, attachmentTypeId, sourceId, deleteFirst = true, sizeLimit, callback }) => {
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        let maxFileSize = sizeLimit ?? constants.MAX_FILE_SIZE
        if (file.size > maxFileSize) {
          const error = { error: true, errorMsg: `File size cannot exceed ${maxFileSize / 1048576}MB` }
          callback(null, error)
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
    [Actions.PROJECT_FILE_UPLOAD]: (context, { file, attachmentTypeId, projectId, callback }) => {
      // @TODO: Need to find a way to make this work better with the FILE_UPLOAD action. Too much duped code and I hate it
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > constants.MAX_FILE_SIZE) {
          callback(null, {message: `File size cannot exceed ${constants.MAX_FILE_SIZE / 1048576}MB`})
        } else {
          let formData = new FormData()
          formData.append('file', file)
          formData.append('attachmentTypeId', attachmentTypeId)

          try {
            const resp = await postRequest(`/project/${projectId}/attachment`, formData)

            const {status} = resp
            if (status === 200) {
              callback(resp.data)
            }
          } catch(e) {
            callback(null, e)
          }
        }
      })
      reader.readAsArrayBuffer(file)
    },
    [Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD]: (context, { file, attachmentTypeId, projectProcessStepId, callback }) => {
      // @TODO: Need to find a way to make this work better with the FILE_UPLOAD action. Too much duped code and I hate it
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > constants.MAX_FILE_SIZE) {
          callback(null, {message: `File size cannot exceed ${constants.MAX_FILE_SIZE / 1048576}MB`})
        } else {
          let formData = new FormData()
          formData.append('file', file)
          formData.append('attachmentTypeId', attachmentTypeId)

          try {
            const resp = await postRequest(`/projectProcessStep/${projectProcessStepId}/attachment`, formData)

            const {status} = resp
            if (status === 200) {
              callback(resp.data)
            }
          } catch(e) {
            callback(null, e)
          }
        }
      })
      reader.readAsArrayBuffer(file)
    },
    [Actions.OBJECT_TYPE_FILE_UPLOAD]: (context, { file, attachmentTypeId, userId, contactId, orgId, objectTypeId, callback }) => {
      // @TODO: Need to find a way to make this work better with the FILE_UPLOAD action. Too much duped code and I hate it
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > constants.MAX_FILE_SIZE) {
          callback(null, {message: `File size cannot exceed ${constants.MAX_FILE_SIZE / 1048576}MB`})
        } else {
          let formData = new FormData()
          formData.append('file', file)
          formData.append('attachmentTypeId', attachmentTypeId)

          try {
            let url = ''
            switch (objectTypeId) {
              case 3:
                url = `/user/${userId}/attachment`
                break
              case 2:
                url = `/contact/${contactId}/attachment`
                break
              case 5:
                url = `/org/${orgId}/attachment`
                break
            }

            const resp = await postRequest(url, formData)

            const {status} = resp
            if (status === 200) {
              callback(resp.data)
            }
          } catch(e) {
            callback(null, e)
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
