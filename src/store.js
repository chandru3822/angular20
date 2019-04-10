import Vue from 'vue'
import Vuex from 'vuex'
import { UserStore } from '@/stores/UserStore'
import { AppStore } from '@/stores/AppStore'
import axios from 'axios'
import { MAX_FILE_SIZE } from '@/helpers/helpers'
import UPLOAD_URL from '@/graphql/UploadUrl.gql'
import SET_LOCAL_S3_DATA from '@/graphql/SetLocalS3Data.gql'

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
    [Actions.FILE_UPLOAD]: (context, { apolloClient, file, attachmentSourceTypeId, sourceId, callback }) => {
      let reader = new FileReader()
      reader.addEventListener('loadend', async function (e) {
        if (file.size > MAX_FILE_SIZE) {
          const error = { error: true, errorMsg: 'File size cannot exceed 10MB' }
          callback(error)
        } else {
          // get the upload url from s3
          const { data } = await apolloClient.query({
            query: UPLOAD_URL,
            fetchPolicy: 'no-cache',
            variables: {
              uploadUrlInput: {
                name: file.name,
                type: file.type,
                attachmentSourceTypeId
              }
            },
            debounce: 500
          })
          const { uploadResponse } = data
          const { uploadURL, key, type, disposition } = uploadResponse

          // upload the file to s3
          const resp = await axios({
            method: 'put',
            url: uploadURL,
            headers: { 'Content-Type': type, 'Content-Disposition': disposition },
            data: new Blob([reader.result], { type: file.type })
          })

          // set our local s3 data so we have a record of the file
          const { status } = resp
          if (status === 200) {
            const { data } = await apolloClient.query({
              query: SET_LOCAL_S3_DATA,
              fetchPolicy: 'no-cache',
              variables: {
                localS3Input: {
                  filename: file.name,
                  contentType: file.type,
                  fileSize: file.size,
                  key,
                  attachmentSourceTypeId,
                  sourceId
                }
              },
              debounce: 500
            })

            const { setLocalS3Data } = data
            callback(setLocalS3Data.asset)
          }
        }
      })
      reader.readAsArrayBuffer(file)
    }
  }
})

export default store
