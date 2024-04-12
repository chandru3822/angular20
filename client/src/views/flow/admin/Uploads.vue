<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">File Uploads</v-toolbar-title>
        </v-toolbar>

        <div>
          <a-autocomplete v-model="selectedAttachmentTypeId"
                          :items="attachmentTypes"
                          label="Attachment Type"
                          item-title="attachmentType"
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
import {handleHidingGlobalLoader, getRequest} from '@/helpers/helpers'
import {getCurrentInstance, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useFileStore } from '@/stores/FileStore.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const fileStore = useFileStore()
const router = useRouter()
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
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/attachmentType/system`)
    attachmentTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const addDragDocument = async (e) => {
  let files = e.dataTransfer.files
  await uploadAttachment(files)
}
const uploadAttachment = async (files) => {
  if (files?.length > 0) {
    appStore.loading = true

    try {
      error.value = {}
      let numFiles = files?.length
      let count = 0
      for (const f of files) {
        if (f.size > 0) {
          await fileStore.uploadFile({
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
                appStore.loading = false
              }
            }
          })
        }
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error uploading document')
      appStore.loading = false
    }
  }
}
</script>
