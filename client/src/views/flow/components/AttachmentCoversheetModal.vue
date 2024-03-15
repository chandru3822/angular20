<template>
  <v-card class="coversheet-container">
    <v-card-text class="pa-0">
      <v-form ref="attachmentFieldsForm">
        <v-row class="coversheet-container ma-0">
          <v-col cols="12" md="4" class="coversheet-left-pane  pt-3 px-4 pb-2"  v-if="!isMobile || tab===0">
            <v-toolbar flat dense class="app-toolbar coversheet-title">
              <v-toolbar-title class="title-large">Document Summary</v-toolbar-title>
              <v-spacer/>
              <v-toolbar-items v-if="isMobile">
                <a-btn
                    size="x-small"
                    variant="text"
                    color="primary"
                    @click="closeModal()"
                    prepend-icon="close"
                ></a-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div v-if="saveError" class="error-text mt-3">
              {{errorMsg}}
            </div>
            <div class="subtitle-1 mb-4 mt-4 default-text-color">Upload Details</div>
            <v-card class="square-card pa-3">
              <v-text-field
                  label="Document Name"
                  :rules="requiredRules"
                  @change="displayNameChanged = true"
                  v-model="fileDetails.displayName"
                  class="albatross-body-2"
              ></v-text-field>
              <DatetimePickerInput
                  v-model="fileDetails.dateCreated"
                  :timezone="timezone"
                  :type="'date'"
                  readonly
                  hidePrependIcon
                  :format="'MM/DD/YYYY'"
                  label="Upload Date"
                  custom-class="albatross-body-2"
              />
              <v-text-field
                  disabled readonly
                  label="Uploaded By"
                  v-model="fileDetails.uploadedBy"
                  class="albatross-body-2"
              ></v-text-field>
              <v-text-field
                  disabled readonly
                  label="Document Type"
                  v-model="fileDetails.attachmentType"
                  class="albatross-body-2"
              ></v-text-field>
              <div class="location-container">
                <label class="location-label">Document Location</label>
                <a class="location-link" @click="goToPath(fileDetails.originPath)">{{fileDetails.originLocation}}</a>
              </div>
              <!--              <div @click="goToPath(fileDetails.originPath)" class=" mb-3 relative"-->
              <!--                  :class="{'clickable': fileDetails.originPath}">-->
              <!--                <div class="force_clickable-overlay"></div>-->
              <!--                <v-text-field-->
              <!--                  disabled readonly-->
              <!--                  label="Document Location"-->
              <!--                  v-model="fileDetails.originLocation"-->
              <!--                  class="albatross-body-2"-->
              <!--                  hide-details-->
              <!--                ></v-text-field>-->
              <!--              </div>-->
            </v-card>
            <div v-if="customFieldGroups.length > 0" class="subtitle-1 mt-6 mb-3 default-text-color">Document Information</div>
            <v-col
                class="pa-0"
                v-for="(cfg, index) in customFieldGroups"
                :key="index"
            >
              <div class="albatross-body-1 default-text-color mb-2">{{ cfg.groupName }}</div>
              <v-card class="square-card pa-3 mb-6">
                <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                                  :key="idx"
                                  :show-field-name="false"
                                  :callback="populateDirtyCfvs"
                                  :required="cf.required"
                                  :readonly="getReadOnly(cf)"
                                  custom-class="albatross-body-2"
                                  :field="cf"></CustomValueInput>
              </v-card>

            </v-col>
            <div class="fixed-toolbar-bottom bottom-toolbar-container">
              <v-toolbar flat dense color="white"
                         class=" mt-1 px-0 coversheet-save-bar">
                <v-spacer></v-spacer>
                <v-toolbar-items>
                  <ConfirmationDialog :open-dialog="confirmClose" @confirm="closeModal()" @close-dialog="confirmClose = null">
                    <template v-slot:title>Cancel</template>
                    Are you sure you want to cancel this upload?
                    <template v-slot:yes>Yes</template>
                    <template v-slot:no>No</template>
                  </ConfirmationDialog>
                  <a-btn
                      variant="text"
                      v-if="isExisting"
                      color="primary"
                      size="small"
                      @click="closeModal()"
                      text="Cancel"
                  ></a-btn>
                  <a-btn
                      variant="text"
                      v-else
                      color="primary"
                      size="small"
                      @click="confirmClose = true"
                      text="Cancel"
                  ></a-btn>
                  <div>
                    <a-btn
                        size="small"
                        :loading="fieldsSaving"
                        :disabled="customFieldsLoading"
                        class="mt-3"
                        color="primary"
                        @click="saveAndUpload()"
                        :text="isExisting ? 'Save Changes' : 'Save and Upload'"
                    ></a-btn>
                  </div>
                </v-toolbar-items>
              </v-toolbar>
            </div>
          </v-col>
          <v-col cols="12" md="8" class="coversheet-right-pane pt-3 px-4 pb-2" ref="rightPaneViewer"  v-if="!isMobile || tab === 1">
            <v-toolbar flat dense class="app-toolbar coversheet-title">
              <v-toolbar-title class="title-large">{{ fileDetails.displayName }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="isExisting"
                    :href="existingAttachment.presignedUrl"
                    prepend-icon="mdi-tray-arrow-down"
                ></a-btn>
                <a-btn
                    size="x-small"
                    variant="text"
                    color="primary"
                    @click="closeModal()"
                    prepend-icon="close"
                ></a-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="mt-3 preview-main-container">
              <div v-if="isImage" class="one-hunned height-one-hunned">
                <div class="preview-image-container">
                  <v-img name="coversheetPreview"
                         class="preview-image"
                         :width="imageWidth+'px'"
                         :src="fileSrcUrl"></v-img>

                </div>
                <v-toolbar v-if="!isMobile" dense class="page-selection-bar" flat color="transparent">
                  <a-btn
                      variant="text"
                      @click="zoomImage(false)"
                      color="unset"
                      prepend-icon="mdi-magnify-minus-outline"
                  ></a-btn>
                  <v-spacer></v-spacer>

                  <a-btn
                      variant="text"
                      @click="zoomImage(true)"
                      color="unset"
                      prepend-icon="mdi-magnify-plus-outline"
                  ></a-btn>
                </v-toolbar>
              </div>
              <div v-else-if="isPdf" class="one-hunned height-one-hunned overflow-auto">
                <div v-if="pdfIsLoading" class="text-center">
                  <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
                </div>
                <vue-pdf-embed
                    ref="pdfRef"
                    :source="fileSrcUrl"
                    :page="pdfPage"
                    :width="pdfWidth"
                    @rendered="handleDocumentRender"
                />
              </div>
              <div v-else class="height-one-hunned one-hunned">
                <v-card class="square-card no-preview-container" >
                  <div class="text-center">
                    <v-icon :size="200" color="white">mdi-image-frame</v-icon>

                    <div class="mt-5">No Preview Available</div>
                  </div>
                </v-card>
              </div>
            </div>
            <div v-if="isPdf && !pdfIsLoading">
              <v-toolbar dense class="page-selection-bar" flat color="transparent">
                <a-btn
                    variant="text"
                    @click="zoomPdf(false)"
                    color="unset"
                    prepend-icon="mdi-magnify-minus-outline"
                ></a-btn>
                <v-spacer></v-spacer>
                <a-btn
                    variant="text"
                    :disabled="pdfPage <= 1"
                    @click="pdfPage--"
                    class="mr-3"
                    color="unset"
                    prepend-icon="mdi-chevron-left"
                ></a-btn>

                Page {{ pdfPage }} / {{ pdfPageCount }}

                <a-btn
                    variant="text"
                    @click="pdfPage++"
                    :disabled="pdfPage >= pdfPageCount"
                    class="ml-3"
                    color="unset"
                    prepend-icon="mdi-chevron-right"
                ></a-btn>

                <v-spacer></v-spacer>
                <a-btn
                    variant="text"
                    @click="zoomPdf(true)"
                    color="unset"
                    prepend-icon="mdi-magnify-plus-outline"
                ></a-btn>
              </v-toolbar>
            </div>
          </v-col>
          <!--          <v-col cols="12" class="pa-0 d-md-none">-->
          <!--            <v-tabs fixed-tabs v-model="tab">-->
          <!--              <v-tab @click="tab=0">Summary</v-tab>-->
          <!--              <v-tab @click="tab=1">Preview</v-tab>-->
          <!--            </v-tabs>-->
          <!--          </v-col>-->
        </v-row>
      </v-form>
    </v-card-text>
  </v-card>
</template>

<script setup>
import {
  getRequestWithParams,

  getAttachmentSourceId,
  logError, postRequest,
  putRequest
} from "@/helpers/helpers";

import constants from "@/helpers/constants"
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from "@/services/customFieldService"
import cloneDeep from 'lodash.clonedeep'
import VuePdfEmbed from 'vue-pdf-embed/dist/vue2-pdf-embed'
import SpinnerInline from '@/components/SpinnerInline'
import ConfirmationDialog from "@/components/ConfirmationDialog"
import { useFileStore } from '@/stores/FileStore.js'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const fileStore = useFileStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const props = defineProps({
  existingAttachment: Object,
  closeCallback: Function,
  fileUploadedCallback: Function,
  showModal: Boolean,
  file: File,
  projectId: Number,
  projectProcessStepId: Number,
  userId: Number,
  contactId: Number,
  orgId: Number,
  objectTypeId: Number,
  projectProcessStepEventId: Number,
})
const { existingAttachment, showModal,
  file, projectId, projectProcessStepId, userId, contactId, orgId,
  objectTypeId, projectProcessStepEventId } = toRefs(props)

watch(showModal, (visible) => {
  //created only gets called the first time the modal opens. this forces it to load every time (the watcher doesn't get call on the first time the modal opens, so no double loading to worry about)
  if (visible) {
    doPageLoad()
  }
})

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const isFieldsLoading = ref(true)
const fileDetails = ref({})
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_DOCS_AUDIO)
const imageFileExtensions = ref(constants.IMAGE_FILE_EXTENSIONS)
const customFieldGroups = ref([])
const dirtyCfvs = ref([])
const fieldsSaving = ref(false)
const displayNameChanged = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const saveError = ref(false)
const errorMsg = ref(null)
const isExisting = ref(false)
const customFieldsLoading = ref(false)
const isImage = ref(false)
const imageWidth = ref(null)
const isPdf = ref(false)
const pdfPage = ref(1)
const pdfWidth = ref(null)
const pdfPageCount = ref(1)
const pdfIsLoading = ref(true)
const fileSrcUrl = ref(null)
const confirmClose = ref(false)
const tab = ref(isMobile.value ? 1 : 0)
const rightPaneViewer = ref(null)
const pdfRef = ref(null)
const attachmentFieldsForm = ref(null)

onMounted(() => {
  doPageLoad()
  if(isMobile.value){
    tab.value = 1
  }
})

const timezone = computed(() => {
  return userStore.timezone.value
})


const zoomImage = (zoomIn) => {
  imageWidth.value = null === imageWidth.value ? rightPaneViewer.value?.clientWidth : imageWidth.value
  if(zoomIn) {
    imageWidth.value *= 1.2
  } else {
    imageWidth.value /= 1.2
  }
}
const zoomPdf = (zoomIn) => {
  pdfIsLoading.value = true
  pdfWidth.value = null === pdfWidth.value ? rightPaneViewer.value?.clientWidth : pdfWidth.value
  if(zoomIn) {
    pdfWidth.value *= 1.2
  } else {
    pdfWidth.value /= 1.2
  }
}
const handleDocumentRender = () => {
  pdfIsLoading.value = false
  pdfPageCount.value = pdfRef.value.pageCount
}
const goToPath = (path) => {
  if(null != path) {
    if(path === router.currentRoute.path) {
      closeModal()
    } else {
      router.push(path)
    }
  }
}
const doPageLoad = async() => {
  //reset all the items cuz when the modal re-opens it doesnt reset everything
  isExisting.value = null != existingAttachment.value.id
  displayNameChanged.value = false
  customFieldGroups.value = []
  dirtyCfvs.value = []
  fileDetails.value = {}
  saveError.value = false
  errorMsg.value = null
  fileSrcUrl.value = null
  isPdf.value = false
  isImage.value = false
  confirmClose.value = false
  pdfPage.value = 1
  pdfPageCount.value = 1

  //handle urls/extensions for new files prior to upload and also existing files with presigned urls
  let fileExtension = file.value && file.value.name ? file.value?.name?.substr(file.value?.name?.lastIndexOf('.') + 1) : existingAttachment.value.fileExtension
  isPdf.value = fileExtension === 'pdf'
  isImage.value = imageFileExtensions.value.includes(fileExtension.toLowerCase())
  fileSrcUrl.value = file.value && file.value.name ? URL.createObjectURL(file.value) : existingAttachment.value.presignedUrl

  //required so that both new and existing files work since the objects aren't identical
  fileDetails.value = cloneDeep(existingAttachment.value)

  await getFieldGroups()
}
const getFieldGroups = async() => {
  customFieldsLoading.value = true
  try {
    const {data} = await getRequestWithParams(`/customFieldValues/attachmentType/${existingAttachment.value.attachmentTypeId}`, {
      params: {
        attachmentId: existingAttachment.value.id
      }
    }, null, [])
    customFieldGroups.value = data
    customFieldsLoading.value = false
  } catch (e) {
    logError(e)
  } finally {
    isFieldsLoading.value = false
  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getReadOnly = (field) => {
  return getCustomFieldReadOnly(field)
}
const closeModal = () => {
  props.closeCallback(existingAttachment.value.attachmentTypeId)
}
const saveAndUpload = async() => {
  if (attachmentFieldsForm.value.validate()) {
    if (!existingAttachment.value.id) {
      //file hasn't been uploaded yet so do that first to get the id
      await uploadDocument()
    } else {
      //existing file
      if(displayNameChanged.value) {
        await saveDisplayName()
      }
      //if file already exists then only save fields
      await updateFieldGroups(existingAttachment.value.id)
    }
  } else {
    errorMsg.value = 'Additional fields are required before saving.'
    saveError.value = true
    snackbar('ERROR', 'Missing Required Fields')

  }
}
const saveDisplayName = async() => {
  appStore.loading = true
  try {
    existingAttachment.value.displayName = fileDetails.value.displayName
    const {data, status} = await putRequest(`/attachment/${existingAttachment.value.id}`, existingAttachment.value)
    existingAttachment.value.presignedUrl = data.presignedUrl
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Changes')

    appStore.loading = false
  }
}
const uploadDocument = async() => {
  try {
    appStore.loading = true
    //reset error message when trying to upload new file
    error.value = {}
    if (file.value && file.value.size > 0) {
      const {sourceId, secondaryId} = getAttachmentSourceId(projectId.value, projectProcessStepId.value, projectProcessStepEventId.value,
          userId.value, contactId.value, orgId.value)

      if(sourceId != null) {
        await fileStore.uploadFile({
          file: file.value,
          attachmentTypeId: existingAttachment.value.attachmentTypeId,
          displayName: fileDetails.value.displayName,
          objectTypeId: objectTypeId.value,
          sourceId,
          secondaryId,
          callback: uploadCallback.value
        })
      }
    }
    // appStore.loading = false
  } catch (e) {
    appStore.loading = false
    logError(e)
    snackbar('ERROR', 'Error Uploading File')

  }
}
const uploadCallback = async(newAttachment, error) => {
  if (error) {
    error.value = error
    snackbar('ERROR', error.message)

  } else {
    await updateFieldGroups(newAttachment.id)
    props.fileUploadedCallback(newAttachment)
    closeModal()
  }
  appStore.loading = false
}
const updateFieldGroups = async(attachmentId) => {
  if (dirtyCfvs.value?.length > 0) {
    fieldsSaving.value = true
    appStore.loading = true
    try {
      // save dirty custom field values
      const {data} = await postRequest(`/customFieldValues/attachmentType/${existingAttachment.value.attachmentTypeId}/attachment/${attachmentId}`, dirtyCfvs.value)
      dirtyCfvs.value = []
      customFieldGroups.value = data
      snackbar('SUCCESS', 'Fields Saved')

      appStore.loading = false
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error Saving Custom Fields')

      appStore.loading = false
    } finally {
      fieldsSaving.value = false
    }
  }
}
</script>

<style lang="scss">
.coversheet-save-bar .v-toolbar__content {
  padding: 0 !important;
}

.coversheet-title .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}
</style>

<style lang="scss" scoped>
.coversheet-container {
  height: 90vh;
  max-height: 90vh;
  @media (min-width: 960px) {
    height: 75vh;
    align-content: flex-start;
  }

}


.min-w-25 {
  min-width: 25px !important;
}

.coversheet-left-pane {
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  height: 100%;
  //max-height: 90vh;
  overflow-y: auto;
  padding-bottom: 0 !important;
}

.coversheet-right-pane {
  height: 100%;
  //max-height: 90vh;
  overflow-y: auto;
}

.coversheet-pane-height-with-tabs {
  height: calc(100% - 50px);
}

.bottom-toolbar-container {
  margin: 0 -10px;
  background-color: white;
  padding-bottom: 15px;
}
.preview-main-container {
  height: calc(100% - 122px);
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.preview-image-container {
  overflow: auto;
  height: 100%;
}

.preview-image {
  overflow: auto;
  max-width: unset !important;
}

//.page-selection-bar {
//  position: absolute;
//  bottom: 0;
//  width: 100%;
//}

.no-preview-container {
  background-color: var(--v-grey-lighten2);
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.force_clickable-overlay {
  height: 50px;
  width: 100%;
  position: absolute;
  z-index: 10;
}

.location-container {
  position: relative;
  display: flex;
  flex-direction: column;
  height: 60px;
}

.location-label {
  font-family: Lato, sans-serif;
  font-weight: normal;
  height: 20px;
  left: 0;
  top: 0;
  right: auto;
  position: absolute;
  transform: translateX(-15px) scale(0.75);
  font-size: 0.875rem;
  line-height: 20px;
  letter-spacing: normal;
  color: rgba(0, 0, 0, 0.38);
}

.location-link {
  font-family: Lato, sans-serif;
  font-weight: normal;
  font-size: 0.875rem;
  height: 20px;
  left: 0;
  top: 20px;
  right: auto;
  position: absolute;
  line-height: 20px;
  letter-spacing: normal;
  text-decoration: underline;
}
</style>
