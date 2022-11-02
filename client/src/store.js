import Vue from 'vue'
import Vuex from 'vuex'
import {UserStore} from '@/stores/UserStore'
import {ProjectStore} from '@/stores/ProjectStore'
import {BrsStore} from '@/stores/BrsStore'
import {AppStore} from '@/stores/AppStore'
import constants from '@/helpers/constants'
import ProposalStore, { ProposalMutations } from '@/views/blueraven/settings/proposalDesigner/store'
import { deleteRequest, getRequestWithParams, postRequest } from './helpers/helpers'

Vue.use(Vuex)

export const Mutations = {
  INIT: 'storeInt'
}

export const Actions = {
  FILE_UPLOAD_MULTI: 'fileUploadMulti',
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
        if (mutation.type === ProposalMutations.REGISTER_EDITOR) return
        const { notifications, proposal, cancelTokens, ...newState } = state //don't store notifications
        localStorage.setItem('store', JSON.stringify(newState))
      })
    }
  ],
  state: {
    cancelTokens: []
  },
  getters: {
    cancelTokens(state) {
      return state.cancelTokens
    },
    uploadUrl: (state) => (objectTypeId, sourceId, secondaryId) => {
      switch(objectTypeId) {
        case 1:  //project
          return `/project/${sourceId}/attachment`
        case 2:  //contact
          return `/contact/${sourceId}/attachment`
        case 3:  //user
          return `/user/${sourceId}/attachment`
        case 4:  //process step
          return `/projectProcessStep/${sourceId}/attachment`
        case 5:  //org
          return `/org/${sourceId}/attachment`
        case 6:  //event
          return `/projectProcessStep/${secondaryId}/event/${sourceId}/attachment`
        default:
          return `/attachment`
      }
    }
  },
  modules: {
    user: UserStore,
    brs: BrsStore,
    app: AppStore,
    project: ProjectStore,
    proposal: ProposalStore
  },
  mutations: {
    ADD_CANCEL_TOKEN(state, token) {
      state.cancelTokens.push(token)
    },
    CLEAR_CANCEL_TOKENS(state) {
      state.cancelTokens = []
    },
    [Mutations.INIT](state) {
      if (localStorage.getItem('store')) {
        const hydratedState = JSON.parse(localStorage.getItem('store'))
        this.replaceState(Object.assign(state, hydratedState))
      }
    }
  },
  actions: {
    CANCEL_PENDING_REQUESTS(context) {

      // Cancel all request where a token exists
      context.state.cancelTokens.forEach((request) => {
        if (request.cancel) {
          request.cancel()
        }
      })

      // Reset the cancelTokens store
      context.commit('CLEAR_CANCEL_TOKENS')
    },
    [Actions.FILE_DELETE]: async (context, {id, callback}) => {
      //todo: need to handle errors in these functions
      const {status} = await deleteRequest(`/attachment/${id}`)
      callback(status)
    },
    [Actions.FILE_UPLOAD_MULTI]: async (context, filesDto) => {
      let uploadUrl;
      const requests = filesDto
        .filter(({file, sizeLimit = constants.MAX_FILE_SIZE}) => {
          return file.size <= sizeLimit
        })
        .map(({file, attachmentTypeId, sourceId, displayName, deleteFirst = true, objectTypeId, secondaryId}) => {
          //@kaleb - sry if this breaks, i didn't test it, just matched it to the new checks to ensure no bad file types get uploaded
            let fileExtension = file.name.substring(file.name.lastIndexOf('.'))
            //only continue with upload if matches whitelisted file types
            if(constants.WHITELISTED_FILE_EXTENSIONS.includes(fileExtension)) {
              const formData = new FormData()
              formData.append('file', file)
              formData.append('attachmentTypeId', attachmentTypeId)
              formData.append('displayName', displayName)

              //sourceId is only used when uploading to /attachments (which means that objectTypeId will be null)
              if (sourceId != null && objectTypeId == null) {
                formData.append('sourceId', sourceId)
                formData.append('deleteFirst', deleteFirst)
              }

              //only do this once. they can only upload multiple files to one location
              if(uploadUrl == null) {
                uploadUrl = context.getters.uploadUrl(objectTypeId, sourceId, secondaryId)
              }

              return formData
            } else {
              return null
            }
        })
        .map(data => postRequest(uploadUrl, data))

      const responses = await Promise.all(requests)
      return responses.map(res => res.data)

    },
    [Actions.FILE_UPLOAD]: (context, {
      file,
      attachmentTypeId,
      sourceId,
      secondaryId, //currently only used when the upload url requires another id (ppse attachents)
      displayName,
      deleteFirst = true,
      objectTypeId,
      sizeLimit,
      callback
    }) => {
      let reader = new FileReader()
      reader.addEventListener('loadend', async function () {
        let maxFileSize = sizeLimit ?? constants.MAX_FILE_SIZE
        if (file.size > maxFileSize) {
          const error = {error: true, errorMsg: `File size cannot exceed ${maxFileSize / 1048576}MB`}
          callback(null, error)
        } else {
          let fileExtension = file.name.substring(file.name.lastIndexOf('.'))
          //only continue with upload if matches whitelisted file types
          if (constants.WHITELISTED_FILE_EXTENSIONS.includes(fileExtension)) {
            let formData = new FormData()
            formData.append('file', file)
            formData.append('attachmentTypeId', attachmentTypeId)
            formData.append('displayName', displayName)

            //sourceId is only used when uploading to /attachments (which means that objectTypeId will be null)
            if (null != sourceId && objectTypeId == null) {
              formData.append('deleteFirst', deleteFirst)
              formData.append('sourceId', sourceId)
            }

            let url = context.getters.uploadUrl(objectTypeId, sourceId, secondaryId)
            const resp = await postRequest(url, formData)

            const {status} = resp
            if (status === 200) {
              callback(resp.data)
            }
          } else {
            callback(null, {message: `Unaccepted File Type`})
          }
        }
      })
      reader.readAsArrayBuffer(file)
    },
    [Actions.FILE_GET_ONE]: async (context, {sourceId, attachmentTypeId, callback}) => {
      const {data, status} = await getRequestWithParams(`/attachment/getOne`, {
        params: {
          attachmentTypeId, sourceId
        }
      })
      callback(data, status)
    },
    [Actions.FILE_GET_LIST]: async (context, {sourceId, attachmentTypeId, callback}) => {
      const {data, status} = await getRequestWithParams(`/attachment`, {
        params: {
          attachmentTypeId, sourceId
        }
      })
      callback(data, status)
    }
  }
})

export default store
