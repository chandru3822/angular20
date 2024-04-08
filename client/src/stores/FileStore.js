import { defineStore } from 'pinia'
import { deleteRequest, getRequestWithParams, postRequest } from '@/helpers/helpers.js'
import constants from '@/helpers/constants.js'
import { Actions } from '@/store.js'

//@TODO: There are a few things here dealing with tokens. That's how it was in vuex, so keeping
// it here during the move to pinia. Might separate it out some day....

//@TODO: Also the file uploading itself doesn't any storage at all. Could just make it a regular
// javascript service

const defaultState = {
  cancelTokens: []
}

export const useFileStore = defineStore('file', {
  persist: true,
  state: () => ({...defaultState}),
  getters: {

  },
  actions: {
    cancelPendingRequests() {
      // Cancel all request where a token exists
      this.cancelTokens.forEach((request) => {
        if (request.cancel) {
          request.cancel()
        }
      })

      // Reset the cancelTokens store
      this.cancelTokens = []
    },
    getUploadUrl(objectTypeId, sourceId, secondaryId) {
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
    },
    async deleteFile({id, callback}) {
      //todo: need to handle errors in these functions
      const {status} = await deleteRequest(`/attachment/${id}`)
      callback(status)
    },
    async getOne({sourceId, attachmentTypeId, callback}) {
      const {data, status} = await getRequestWithParams(`/attachment/getOne`, {
        params: {
          attachmentTypeId, sourceId
        }
      })
      callback(data, status)
    },
    async uploadFile({
      file,
      attachmentTypeId,
      sourceId,
      secondaryId, //currently only used when the upload url requires another id (ppse attachents)
      displayName,
      deleteFirst = true,
      objectTypeId,
      sizeLimit,
      callback
    }) {
      let reader = new FileReader()
      let url = this.getUploadUrl(objectTypeId, sourceId, secondaryId)
      reader.addEventListener('loadend', async function () {
        let maxFileSize = sizeLimit ?? constants.MAX_FILE_SIZE
        if (file.size > maxFileSize) {
          const error = {error: true, errorMsg: `File size cannot exceed ${maxFileSize / 1048576}MB`}
          callback(null, error)
        } else {
          let fileExtension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase()
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
    async uploadFileMulti(filesDto) {
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
            uploadUrl = this.getUploadUrl(objectTypeId, sourceId, secondaryId)
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
  }
})