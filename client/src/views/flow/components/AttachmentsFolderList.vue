<template>
  <div id="attachment-folder-list">
    <v-dialog persistent v-model="showCoversheetModal"
              content-class="coversheet-modal-content">
      <AttachmentCoversheetModal :existing-attachment="tempFile"
                                 :file="fileToUpload"
                                 :show-modal="showCoversheetModal"
                                 :close-callback="closeCoversheet"
                                 :file-uploaded-callback="fileUploaded"
                                 :projectId="projectId"
                                 :projectProcessStepId="projectProcessStepId"
                                 :userId="userId"
                                 :contactId="contactId"
                                 :orgId="orgId"
                                 :objectTypeId="objectTypeId"
                                 :projectProcessStepEventId="projectProcessStepEventId"
      >
      </AttachmentCoversheetModal>
    </v-dialog>
    <v-dialog persistent width="90%" v-model="showCompareModal">
      <AttachmentCompareModal :show-modal="showCompareModal"
                              :attachments="selectedAttachmentsForCompare"
                              :close-callback="closeCompareModal">
      </AttachmentCompareModal>
    </v-dialog>
    <div v-if="loadingDetails" class="one-hunned text-center">
      <SpinnerInline :size="40" color="primary"/>
    </div>
    <div v-else-if="attachmentTypes.length > 0" :class="{'px-3': isCard}">
      <div v-if="activityTab" class="px-5 sticky-compare-bar">
        <a-text-field
            v-model="search"
            prepend-inner-icon="search"
            clearable
            label="Search all project documents"
            single-line
            hide-details
        ></a-text-field>
        <div class="d-flex flex-wrap"
             :class="{'justify-space-between' : $vuetify.breakpoint.smAndUp}">

          <div class="my-2" :class="{'text-no-wrap' : $vuetify.breakpoint.lgAndUp}">
            <a-btn
                class="my-2 mr-3"
                :color="compare ? 'white' : 'primary'"
                :class="{'primary--text': compare, '' : !compare}"
                size="small"
                @click="[cancelResetKey++, selectedAttachmentsForCompare = [], compare = false]"
                v-if="compare"
                text="Cancel Comparison"
            ></a-btn>
            <a-btn
                color="primary"
                class="my-2"
                size="small"
                @click="showCompareModal = true"
                v-if="compare "
                :disabled="selectedAttachmentsForCompare.length === 0"
                text="Confirm Comparison"
            ></a-btn>
            <a-btn
                size="small"
                color="primary"
                class="my-2"
                @click="compare = true"
                v-else-if="!isMobile"
                text="Compare"
            ></a-btn>
          </div>
          <div class="text-no-wrap display-empty-folder-toggle">
            <label class="mr-3 body-medium"
                   :class="{'hide-empty-folder-label' : disableHideEmptyFolderSwitch}">
              Hide Empty Folders
            </label>
            <v-switch
                @change="$emit('toggleEmptyFolders')"
                :disabled="disableHideEmptyFolderSwitch"
                v-model="hideEmptyFolderStatus"
                dense
            ></v-switch>
          </div>
        </div>
      </div>
      <v-toolbar v-if="search.value != null && search.value !== '' && filteredAttachmentTypes.length > 0" dense color="transparent" class="elevation-0 cfg-name-toolbar px-5">
        <v-toolbar-title :class="{'albatross-header-4-new': !smallTitle.value,
                                  'albatross-body-2': smallTitle.value}">
          Search Results
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-chip label outlined color="primary--text" class="sort-chip align-self-center albatross-body-2 flex-shrink-0"
                  @click="sortOldToNew = !sortOldToNew">
            {{ sortOldToNew ? 'Oldest to Newest' : 'Newest to Oldest' }}
          </v-chip>
        </v-toolbar-items>
      </v-toolbar>
      <v-toolbar v-if="title" dense color="transparent" class="elevation-0 process-step-toolbar cfg-name-toolbar">
        <v-toolbar-title :class="{'albatross-header-4-new': !smallTitle.value,
                                  'albatross-body-2': smallTitle.value}">
          {{ title }}
        </v-toolbar-title>
      </v-toolbar>
      <v-card class="text-left square-card" :class="{'elevation-0': !isCard}">
        <div v-if="filteredAttachmentTypes.length === 0" class="body-medium text-center">No documents found.</div>
        <v-expansion-panels v-model="opened" accordion multiple flat class=".rounded-0 condensed" v-if="!attachmentTypesLoading">
          <v-expansion-panel v-for="(type, index) in filteredAttachmentTypes" :key="type.attachmentTypeId">
            <v-expansion-panel-header v-if="getTypeCount(type.attachmentTypeId) > 0 || hideEmptyFolderStatus === false" class="albatross-body-1">
              <template v-slot:default="{ open }">
                <v-row v-if="(allowUpload || forceShowUploadBtn)"
                       class="file-hover d-flex"
                       :class="{'file-hover-active': dragTypeId === type.attachmentTypeId, 'file-hover-inactive': dragTypeId === null || dragTypeId !== type.attachmentTypeId}"
                       @dragenter="(allowUpload || forceShowUploadBtn) ? dragTypeId = type.attachmentTypeId : dragTypeId = null"
                       @dragend="dragTypeId = null"
                       @dragleave="dragTypeId = null"
                       @drop.prevent="addDragDocument($event, type)"
                       @dragover.prevent="(allowUpload || forceShowUploadBtn) ? dragTypeId = type.attachmentTypeId : dragTypeId = null"
                >
                  <v-icon class="child-drag-elements" color="primary">upload</v-icon>
                </v-row>
                <v-row no-gutters class="align-center flex-nowrap" :class="{'bold' : open}">
                  <v-icon class="mr-3" :color="dragTypeId===type.attachmentTypeId ? 'grey lighten-1' : 'grey darken-1'">
                    folder
                  </v-icon>
                  {{ `${type.attachmentType} (${getTypeCount(type.attachmentTypeId)})` }}
                  <v-spacer></v-spacer>

                  <input
                      :id="`fileInput${type.attachmentTypeId}`"
                      type="file"
                      :multiple="!type.hasFieldsAssigned"
                      :accept="acceptedFileTypes"
                      @change='doUpload($event.target.files, type)'
                      style="display: none"
                      :ref="`fileInput${type.attachmentTypeId}`"
                      @click.stop=""
                  >
                  <div class="expansion-panel-header-open" v-if="open"
                       key="0">
                  </div>
                  <span
                      v-else
                      key="1"
                  >
                </span>
                  <a-btn
                      v-if="allowUpload || forceShowUploadBtn"
                      @click.native.stop="selectFile(type.attachmentTypeId)"
                      :icon="isMobile"
                      :elevation="0"
                      variant="text"
                      color="primary"
                      class="text-capitalize"
                      :class="{'mr-4': isMobile}"
                      :disabled="dragTypeId === type.attachmentTypeId"
                      :prepend-icon="isMobile ? 'mdi-tray-arrow-up' : ''"
                      :text="!isMobile ? 'Upload' : ''"
                  ></a-btn>
                </v-row>
              </template>
            </v-expansion-panel-header>
            <v-expansion-panel-content v-if="getTypeCount(type.attachmentTypeId) > 0 || hideEmptyFolderStatus === false">
              <AttachmentsTable
                  :search="search"
                  :display-type="type"
                  :allow-upload="allowUpload || forceShowUploadBtn"
                  :load-linked="loadLinked"
                  :attachments="sortedAttachments"
                  :projectId="projectId"
                  :projectProcessStepId="projectProcessStepId"
                  :userId="userId"
                  :contactId="contactId"
                  :compare="!allowUpload && !loadLinked && compare"
                  :orgId="orgId"
                  :cancel-reset-key="cancelResetKey"
                  :objectTypeId="objectTypeId"
                  :projectProcessStepEventId="projectProcessStepEventId"
                  :compare-callback="toggleAttachmentToCompare"
                  :delete-callback="attachmentDeleted"
                  :count-selected="selectedAttachmentsForCompare.length"
              ></AttachmentsTable>
            </v-expansion-panel-content>
            <v-divider v-if="index !== attachmentTypes.length - 1 && (getTypeCount(type.attachmentTypeId) > 0 || hideEmptyFolderStatus === false)" class="mx-3"></v-divider>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-card>

    </div>
    <div v-else-if="!hideEmpty" class="body-large text-center">Attachments Not Available</div>
  </div>
</template>

<script setup>
import {
  getAttachmentSourceId,
  getRequestWithParams,

  logError
} from '@/helpers/helpers'

import orderBy from 'lodash.orderby'
import AttachmentsTable from "@/views/flow/components/AttachmentsTable";
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import AttachmentCompareModal from '@/views/flow/components/AttachmentCompareModal'
import constants from '@/helpers/constants'
import SpinnerInline from '@/components/SpinnerInline'
import cloneDeep from 'lodash.clonedeep'
import { useProjectStore } from '@/stores/ProjectStore.js'
import { useFileStore } from '@/stores/FileStore.js'

import {getCurrentInstance, toRefs, computed, ref, onMounted, watch, onBeforeUnmount} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import {storeToRefs} from "pinia";
import emitter from '@/services/eventBus.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const fileStore = useFileStore()
const projectStore = useProjectStore()
const { forceReloadKey } = storeToRefs(projectStore)
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify
// const rootInstance = getCurrentInstance().appContext.app;

const props = defineProps({
  allowUpload: Boolean,
  loadLinked: Boolean,
  focused: Boolean,
  hideEmptyFolderStatus: Boolean,
  smallTitle: Boolean,
  title: String,
  activityTab: Boolean, //this tells us whether to show the search and compare buttons
  forceShowUploadBtn: Boolean,
  projectId: Number,
  userId: Number,
  contactId: Number,
  orgId: Number,
  objectTypeId: Number,
  isCard: Boolean,
  hideEmpty: Boolean,
  reloadOnKeyChange: {
    type: Boolean,
    default: false
  }
})
const { allowUpload, loadLinked, focused, hideEmptyFolderStatus, smallTitle, title,
  activityTab, forceShowUploadBtn, projectId, userId, contactId, orgId,
  objectTypeId, isCard, hideEmpty, reloadOnKeyChange } = toRefs(props)



const eventId = ref(null)
const tempFile = ref({})
const fileToUpload = ref(null)
const loadingDetails = ref(false)
const selectedAttachmentsForCompare = ref([])
const cancelResetKey = ref(0)
const attachmentTypes = ref([])
const attachments = ref([])
const dragTypeId = ref(null)
const showCoversheetModal = ref(false)
const coversheetSelectedTypeId = ref(null)
const attachmentTypesLoading = ref(false)
const error = ref({})
const maxFiles = ref(constants.MAX_FILE_UPLOADS)
const renderTicker = ref(0)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_DOCS_AUDIO)
const headers = ref([
  {text: null, value: 'fileIcon', show: true},
  {text: null, value: 'filename', show: true},
  {text: null, value: 'icons', show: true},
])
const search = ref('')
const sortOldToNew = ref(false)
const compare = ref(false)
const showCompareModal = ref(false)
const opened = ref([])
const emptyFolderToggleState = ref(null)
const _filterTimerId = ref(null)
const typePath = ref('')
const attachmentPath = ref('')

const emit = defineEmits(['scrollToTop'])

const processStepId = computed(() => {
  return route.query.processStepId
})
const projectProcessStepId = computed(() => {
  return parseInt(route.params.processStepId) || null
})
const projectProcessStepEventId = computed(() => {
  return parseInt(route.params.ppsEventId) || null
})

const companyId = computed(() => {
  return userStore.details.companyId
})
const sortedAttachments = computed(() => {
  return orderBy(attachments.value, [a => a.dateCreated], search.value != null && search.value !== '' && sortOldToNew.value ? 'asc' : 'desc')
})
const filteredAttachmentTypes = computed(() => {
  //if there's a search value, only show folders with an attachment that matches the search
  return (search.value != null && search.value !== '') ? attachmentTypes.value.filter(type => {
    return attachments.value.filter(a => {
      return a.attachmentTypeId === type.attachmentTypeId && !a.archived && a.linked === loadLinked.value
          && a.displayName.toLowerCase().includes(search.value.toLowerCase())
    })?.length > 0
  }) : attachmentTypes.value
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const disableHideEmptyFolderSwitch = computed(() => {
  return search.value != null && search.value !== ''
})

watch(focused, () => {
  loadAllPageDetails()
})
watch(search, () => {
  emit('scrollToTop')
})

watch(filteredAttachmentTypes, (val) => {
  clearTimeout(_filterTimerId.value)
  _filterTimerId.value = setTimeout(() => {
    opened.value = []
    if(search.value != null && search.value !== '') {
      for(let i = 0; i < val.length; i++){
        opened.value.push(i)
      }
    }
  }, 5)
})

watch([projectProcessStepId, projectProcessStepEventId], () => {
  // whenever pps id ore pps event id changes, this function will run
  loadAllPageDetails()
})
//todo: figure out if this works
// whenever the project store forces a reload - do this - i cant remember why atm
watch(forceReloadKey, () => {
  if (reloadOnKeyChange.value) {
    // reset the selected item
    loadAllPageDetails()
  }
})

onMounted(() => {
  if (loadLinked.value) {
    //this has to be here instead of a normal emits because we want a child attachment table to emit to a different parent folder list
    //if in the linked section and a new record was linked, add it here
    emitter.on('new-attachment-linked', handleAttachmentLinked)
    //if in the linked section and a linked attachment is archived, remove it
    emitter.on('attachment-deleted', handleAttachmentDeleted)
  }

  loadAllPageDetails();
})

onBeforeUnmount(() => {
  emitter.off('new-attachment-linked', handleAttachmentLinked);
  emitter.off('attachment-deleted', handleAttachmentDeleted)
});

const handleAttachmentDeleted = (id) => {
  attachments.value = attachments.value.filter(a => a.id !== id)
}

const handleAttachmentLinked = (data) => {
    let clone = cloneDeep(data)
    clone.linked = true //if you dont clone it here then it updates the root obj in the calling fn which borks stuff
    attachments.value.push(clone)
}

const closeCoversheet = (attachmentTypeId) => {
  showCoversheetModal.value = false
  //if you cancel the coversheet the file-input files prop is not getting reset. do manually here
  //could not get it to reset using the vue $ref stuff. but this way with getElementById does work
  document.getElementById(`fileInput${attachmentTypeId}`).value = null
}
const closeCompareModal = (a) => {
  if (a && null != a.id) {
    //use if compare modal needs to close and the coversheet needs to open
    tempFile.value = a
    showCoversheetModal.value = true
  }
  showCompareModal.value = false
}
const toggleAttachmentToCompare = (attachment) => {
  if (attachment.compare) {
    selectedAttachmentsForCompare.value.push(attachment)
  } else {
    selectedAttachmentsForCompare.value = selectedAttachmentsForCompare.value.filter(a => a.id !== attachment.id)
  }
}
const attachmentDeleted = (id) => {
  attachments.value = attachments.value.filter(a => a.id !== id)
}
const fileUploaded = (attachment, error) => {
  if (error) {
    appStore.showSnack('ERROR', error.message)

  } else {
    attachments.value.push(attachment)
    if (!forceShowUploadBtn.value) {
      //so far, if forceShowUploadBtn, then it is on org, user, contact, etc so it is already where it needs to be and doesn't need to refresh again
      //this value tells the right pane to update when a file is uploaded
      projectStore.incrementReloadKey()
    }
  }
  appStore.loading = false
}
const loadAllPageDetails = async() => {
  //if not objectTypeId(org,contact,user) and should be "all" then use these endpoints to get combined list
  let params = {}
  if ((!objectTypeId.value || objectTypeId.value === 1) && !allowUpload.value && !loadLinked.value) {
    typePath.value = `/combined/project`
    attachmentPath.value = `/project/${projectId.value}/combinedAttachments`
    params.ppsEventId = projectProcessStepEventId.value
    params.ppsId = projectProcessStepId.value
  } else {
    if (projectProcessStepEventId.value) {
      typePath.value = `/eventTypesByPpsEventId/${projectProcessStepEventId.value}`
      attachmentPath.value = `/projectProcessStep/${projectProcessStepId.value}/event/${projectProcessStepEventId.value}/attachments`
    } else if (projectProcessStepId.value) {
      typePath.value = `/processStepTypes/${projectProcessStepId.value}`
      attachmentPath.value = `/projectProcessStep/${projectProcessStepId.value}/attachments`
    } else if (projectId.value) {
      typePath.value = `/objectType/project`
      attachmentPath.value = `/project/${projectId.value}/attachments`
    } else if (objectTypeId.value === 2) {
      //contact
      typePath.value = `/objectType/contact`
      attachmentPath.value = `/contact/${contactId.value}/attachments`
    } else if (objectTypeId.value === 5) {
      //org
      typePath.value = `/objectType/org`
      attachmentPath.value = `/org/${orgId.value}/attachments`
    } else if (objectTypeId.value === 3) {
      //user
      typePath.value = `/objectType/user`
      attachmentPath.value = `/user/${userId.value}/attachments`
    }
  }

  //if focused then override attachment path to get all in project
  // if (focused.value) {
  //   attachmentPath.value = `/project/${projectId.value}/combinedAttachments`
  //   params.ppsEventId = projectProcessStepEventId.value
  //   params.ppsId = projectProcessStepId.value
  // }

  if (typePath.value && attachmentPath.value) {
    loadingDetails.value = true
    let requests = [fetchAttachmentTypes(params), fetchAttachments(params)]
    await Promise.all(requests)
    loadingDetails.value = false
  }
}
const fetchAttachmentTypes = async (typeParams) => {
  emptyFolderToggleState.value = hideEmptyFolderStatus.value
  attachmentTypesLoading.value = true
  const {data} = await getRequestWithParams(`/attachmentType${typePath.value}`, {
    params: {
      ...typeParams,
      linkable: loadLinked.value,
      allowUpload: allowUpload.value,
      focused: focused.value
    }
  })
  attachmentTypes.value = data
  attachmentTypesLoading.value = false
}
const fetchAttachments = async (extraParams) => {
  const {data} = await getRequestWithParams(attachmentPath.value, {
    params: {
      ...extraParams,
      linked: loadLinked.value
    }
  }, null, [])
  data?.forEach(d => {
    let tempFileName = d.filename.substr(0, d.filename.lastIndexOf('.'))
    d.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : d.filename
    //adding this "copy" so that if they edit a name then click cancel we dont update the ui with their change
    d.editableNameCopy = d.editableName
  })

  attachments.value = orderBy(data, [a => a.dateCreated], sortOldToNew.value ? 'asc' : 'desc')
  hideEmptyFolderStatus.value = emptyFolderToggleState.value
}

const getTypeCount = (typeId) => {
  try {
    return attachments.value.filter(a => {
      return a.attachmentTypeId === typeId && !a.archived && a.linked === loadLinked.value
          && ((search.value != null && search.value !== '') ? a.filename.toLowerCase().includes(search.value.toLowerCase()) : true)
    })?.length || 0
  } catch {
    return 0
  }
}
const addDragDocument = async (e, type) => {
  dragTypeId.value = null
  if (allowUpload.value || forceShowUploadBtn.value) {
    let files = e.dataTransfer.files
    await doUpload(files, type)
  }
}
const selectFile = (typeId) => {
  document.getElementById(`fileInput${typeId}`)?.click();
}
const doUpload = async(files, type) => {
  if (files?.length > 0) {
    if (type.hasFieldsAssigned) {
      let file = files[0]
      setTempFile(file, type)
    } else {
      await uploadDocument(files, type)
    }
  }
}
const setTempFile = (file, type) => {
  tempFile.value = {}
  fileToUpload.value = null
  //we dont upload new files until after they fill in custom fields, need to pass file to next screen
  fileToUpload.value = file
  tempFile.value.attachmentTypeId = type.attachmentTypeId
  tempFile.value.attachmentType = type.attachmentType
  let displayName = fileToUpload.value.name.substr(0, fileToUpload.value.name.lastIndexOf('.'))
  tempFile.value.displayName = displayName
  showCoversheetModal.value = true
}
const uploadDocument = async (files, type) => {
  //this should only get called if the attachment type doesn't have any native fields
  try {
    //reset error message when trying to upload new file
    error.value = {}
    if (files?.length > 0) {
      const { sourceId, secondaryId } = getAttachmentSourceId(projectId.value, projectProcessStepId.value, projectProcessStepEventId.value,
          userId.value, contactId.value, orgId.value)

      appStore.loading = true

      //this could probably even be cleaned up a little more. but this is working for my first cleanup attempt
      if (sourceId != null) {
        if(files.length > 1) {
          const filesToUpload = [...files].map(file => {
            return {
              file,
              displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
              attachmentTypeId: type.attachmentTypeId,
              objectTypeId: objectTypeId.value,
              sourceId,
              secondaryId,
            }
          })
          const uploaded = await fileStore.uploadFileMulti(filesToUpload)
          attachments.value = [...attachments.value, ...uploaded]
          if (!forceShowUploadBtn.value) {
            //so far, if forceShowUploadBtn, then it is on org, user, contact, etc so it is already where it needs to be and doesn't need to refresh again
            //this value tells the right pane to update when a file is uploaded
            projectStore.incrementReloadKey()
          }
          appStore.loading = false
        } else {
          let file = files[0]
          if(file?.size > 0) {
            await fileStore.uploadFile({
              file: file,
              attachmentTypeId: type.attachmentTypeId,
              displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
              objectTypeId: objectTypeId.value,
              sourceId,
              secondaryId,
              callback: fileUploaded
            })
          }
        }
      }
    }
  } catch (e) {
    appStore.loading = false
    logError(e)
    appStore.showSnack('ERROR', 'Error Uploading File')

  }

}
</script>

<style lang="scss">

</style>

<style lang="scss" scoped>
.sticky-compare-bar {
  position: sticky;
  top: -2px;
  z-index: 2;
  background: white;
}

.v-expansion-panels.condensed .v-expansion-panel-header {
  padding-top: 6px;
  padding-bottom: 6px;
  min-height: auto;
}

.v-expansion-panels.condensed
.v-expansion-panel--active
.v-expansion-panel-header {
  padding-top: 12px;
  padding-bottom: 12px;
}

.v-expansion-panels.condensed .v-expansion-panel--active:not(:first-child),
.v-expansion-panels.condensed .v-expansion-panel--active + .v-expansion-panel {
  margin-top: 2px;
}


.bold {
  font-weight: bold;
}

.expansion-panel-header-open {
  display: flex;
  align-items: center;
}

.file-hover {
  width: inherit;
  position: absolute;
  height: 100%;
  margin: -24px;
  padding: 24px;

  i {
    width: 100%;
  }
}

.file-hover-inactive {
  hidden: true;

  i {
    display: none;
  }
}

.file-hover-active {
  hidden: false;
  background-color: rgba(#e3eff7, 90%);

  i {
    display: inline-flex;
  }
}

//todo check if still needed??
//.theme--light.v-btn.v-btn--disabled.v-btn--has-bg {
//  background-color: transparent !important;
//}

.child-drag-elements {
  pointer-events: none;
}

.display-empty-folder-toggle {
  display: inline-flex;
  align-items: center;
}

.hide-empty-folder-label {
  color: var(--v-grey-darken1);
}

</style>
