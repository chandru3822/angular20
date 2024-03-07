<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">File Uploads</v-toolbar-title>
        </v-toolbar>

        <div>
          <v-autocomplete v-model="selectedAttachmentTypeId"
                          :items="attachmentTypes"
                          label="Attachment Type"
                          item-text="attachmentType"
                          item-value="id"
          />
          <!--          <br/>-->
          <!--          <span>Auto Create Generic Join Record?</span>-->
          <!--          <input type="checkbox" class="ml-2"-->
          <!--                 v-model="addToJoin">-->

          <div v-if="selectedAttachmentTypeId">
            <div class="mb-2">Note: This will upload as soon as you select your file(s)</div>
            <div @drop.prevent='addDragDocument' @dragover.prevent>
              <v-file-input
                  dense
                  multiple
                  ref='fileInput'
                  hide-details
                  :show-size='error.error'
                  outlined
                  label='Upload Files'
                  @change='uploadAttachment'
              />
              <span class='error-text' v-if='error.message'>{{ error.message }}</span>
            </div>
          </div>
          <div v-else>
            Select an attachment type to upload
          </div>
        </div>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest} from '@/helpers/helpers'
import {Actions} from '@/store'
import {getCurrentInstance, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const error = ref({})
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const attachmentTypes = ref([])
const selectedAttachmentTypeId = ref(null)
const addToJoin = ref(true)

onMounted(async () => {
  await getAttachmentTypes()
})

const getAttachmentTypes = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/attachmentType/system`)
    attachmentTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const addDragDocument = async (e) => {
  let files = e.dataTransfer.files
  await uploadAttachment(files)
}
const uploadAttachment = async (files) => {
  if (files?.length > 0) {
    store.commit(AppMutations.SET_LOADING, true)

    try {
      error.value = {}
      let numFiles = files?.length
      let count = 0
      for (const f of files) {
        if (f.size > 0) {
          await store.dispatch(Actions.FILE_UPLOAD, {
            file: f,
            attachmentTypeId: selectedAttachmentTypeId.value,
            sourceId: null,
            displayName: f.name.substr(0, f.name.lastIndexOf('.')),
            deleteFirst: false,
            callback: async (document) => {
              snackbar('SUCCESS', 'Successfully uploaded document')
              count++
              if (count === numFiles) {
                selectedAttachmentTypeId.value = null
                files = []
                store.commit(AppMutations.SET_LOADING, false)
              }
            }
          })
        }
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error uploading document')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
</script>
