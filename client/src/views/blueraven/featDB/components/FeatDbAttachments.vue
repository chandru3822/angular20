<template>
  <div>
    <v-expansion-panels accordion multiple flat class=".rounded-0">
      <div v-if="!attachmentTypes.length">No attachments available</div>
      <v-expansion-panel v-for="type in attachmentTypes" :key="type.attachmentTypeId">
        <v-expansion-panel-header class="expansion-panel-header">
          <template v-slot:default="{ open }">
            <v-row no-gutters class="align-center" :class="{'bold' : open}">
              {{ `${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})` }}
              <v-spacer></v-spacer>
              <div class="expansion-panel-header-open" v-if="open"
                   key="0">
                <input
                    :id="`fileInput${type.attachmentTypeId}`"
                    type="file"
                    multiple
                    :accept="acceptedFileTypes"
                    @change='uploadDocument($event.target.files, type.attachmentTypeId)'
                    style="display: none"
                    @click.stop=""
                    ref='fileInput'
                >
                <a-btn
                    @click.native.stop="selectFile(type.attachmentTypeId)"
                    @dragenter="dragTypeId=type.attachmentTypeId"
                    @dragleave="dragTypeId=null"
                    @dragend="dragTypeId=null"
                    v-if="userCanEdit"
                    :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
                    @drop.prevent="addDragDocument($event, type.attachmentTypeId)"
                    @dragover.prevent="dragTypeId=type.attachmentTypeId"
                    :elevation="0"
                    variant="text"
                    color="primary"
                    class="expansion-panel-btn upload-button"
                    text="Upload"
                ></a-btn>
              </div>
              <span
                  v-else
                  key="1"
              ></span>
            </v-row>
          </template>
        </v-expansion-panel-header>
        <v-expansion-panel-content>
          <AttachmentsTable
              :display-type="type"
              :attachments="attachments"
              :show-non-primary-docs="true"
              :allow-edit="false"
              :allow-upload="userCanEdit"
              :delete-callback="deleteCallback"
          ></AttachmentsTable>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script setup>
import {

} from "@/helpers/helpers";

import AttachmentsTable from "@/views/flow/components/AttachmentsTable.vue";
import constants from "@/helpers/constants";
import { getCurrentInstance, computed, ref, toRefs, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useFileStore } from '@/stores/FileStore.js'


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const fileStore = useFileStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const dragTypeId = ref(null)
const error = ref({})
const maxFiles = ref(1)
const renderTicker = ref(0)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_AND_DOCS)
const headers = ref([
  {text: null, value: 'fileIcon', show: true},
  {text: null, value: 'filename', show: true},
  {text: null, value: 'icons', show: true},
])
const showNonPrimaryDocs = ref(false)

const props = defineProps({
  attachmentTypes: Array,
  attachments: Array,
  sourceId: Number,
  userCanEdit: Boolean,
  objectTypeId: Number,
  userId: Number,
  contactId: Number,
  orgId: Number,
})

const { attachmentTypes, sourceId, userCanEdit, objectTypeId, userId, contactId, orgId } = toRefs(props)

const getTypeCount = (typeId) => {
  try {
    return props.attachments.filter(a => a.attachmentTypeId === typeId && !a.archived)?.length || 0
  } catch {
    return 0
  }
}
const getNonPrimaryCount = (typeId) => {
  try {
    return props.attachments?.filter(a => a.attachmentTypeId === typeId && !a.archived && !a.main).length || 0
  } catch {
    return 0
  }
}
const addDragDocument = async (e, attachmentTypeId) => {
  let files = e.dataTransfer.files
  await uploadDocument(files, attachmentTypeId)
}
const selectFile = function (typeId) {
  document.getElementById(`fileInput${typeId}`)?.click();
}
const uploadDocument = async (files, attachmentTypeId) => {
  if (files?.length > maxFiles.value) {
    snackbar('ERROR', `Cannot upload more than ${maxFiles.value} files at one time. Please try again and select fewer files.`)
  } else if (files?.length > 0) {
    appStore.loading = true

    try {
      let file = files[0]
      await fileStore.uploadFile({
        file: file,
        attachmentTypeId: attachmentTypeId,
        sourceId: sourceId.value,
        displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
        deleteFirst: false,
        callback: async (document) => {
          props.attachments.push(document)
          snackbar('SUCCESS', 'Successfully uploaded document')
        }
      })
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error uploading document')
    }
    appStore.loading = false
  }
}
const uploadCallback = async(newAttachment, error) => {
  if (error) {
    error.value = error
    snackbar('ERROR', error.message)
  } else {
    let tempFileName = newAttachment.filename.substr(0, newAttachment.filename.lastIndexOf('.'))
    newAttachment.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : newAttachment.filename
    //adding this "copy" so that if they edit a name then click cancel we dont update the ui with their change
    newAttachment.editableNameCopy = newAttachment.editableName
    snackbar('SUCCESS', 'Document Uploaded')
    props.attachments = [...props.attachments, newAttachment]
  }
  appStore.loading = false
}

const deleteCallback = (id) => {
  props.attachments = props.attachments.filter(a => a.id !== id)
}
</script>

<style lang="scss" scoped>
.expansion-panel-header {
  font-size: 14px;
  color: var(--v-primaryText-base);
}

.bold {
  font-weight: bold;
}

.expansion-panel-header-open {
  display: flex;
  align-items: center;
}

.expansion-panel-btn {
  font-size: 12px;
  font-weight: bold;
  text-transform: capitalize;
  margin: 0;
}

.file-hover {
  background: #EEF0F4 !important;
}
</style>
