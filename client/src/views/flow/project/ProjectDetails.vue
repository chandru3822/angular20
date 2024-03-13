<template>
  <div id="project-details-container" class="py-0">
    <v-dialog persistent v-model="showCoversheetModal"
              content-class="coversheet-modal-content">
      <AttachmentCoversheetModal :existing-attachment="tempFile"
                                 :file="fileToUpload"
                                 :show-modal="showCoversheetModal"
                                 :close-callback="closeCoversheet"
                                 :file-uploaded-callback="fileUploaded"
                                 :projectId="projectId"
                                 :objectTypeId="1"

      >
      </AttachmentCoversheetModal>
    </v-dialog>
    <div class="pa-0 height-one-hunned">
      <div class="project-header">
        <v-toolbar color="transparent" class="elevation-0 process-step-toolbar mx-6">
          <v-toolbar-title class="albatross-header-2">{{ projectTab.tabName }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items v-if="projectTab.id !== -1">
            <v-menu data-app :right="!isMobile" :left="isMobile"
                    offset-y
                    v-model="attachmentMenuOpen"
                    max-height="350"
                    :close-on-content-click="!isMobile">
              <template v-slot:activator="{ on }">
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="loadProjectAttachmentTypes()"
                    :activation-handler="on"
                    prepend-icon="mdi-tray-arrow-up"
                ></AlbatrossButton>
              </template>
              <v-list dense class="pa-3">
                <template v-for="(item, index) in attachmentTypes">
                  <v-list-item
                      :key="index"
                      @click="[menuOpen = false, selectFile(item.attachmentTypeId)]">
                    <v-list-item-content>
                      <v-list-item-title>{{ item.attachmentType }}</v-list-item-title>
                    </v-list-item-content>
                    <input
                        :id="`menuFileInput${item.attachmentTypeId}`"
                        type="file"
                        :multiple="!item.hasFieldsAssigned"
                        :accept="acceptedFileTypes"
                        @change='[doUpload($event.target.files, item), attachmentMenuOpen = false]'
                        style="display: none"
                        @click.stop=""
                        :ref="`menuFileInput${item.attachmentTypeId}`"
                    >
                  </v-list-item>
                </template>
              </v-list>
            </v-menu>
            <AlbatrossButton
                v-if="!isMobile"
                variant="text"
                color="primary"
                @click="setSplitColumnValue()"
                :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
            ></AlbatrossButton>
            <div class="align-self-center">
              <AlbatrossButton
                  v-if="userCanEdit"
                  color="primary"
                  :icon="isMobile"
                  :disabled="isFieldsLoading || fieldsSaving"
                  @click="updateFieldGroups()"
                  prepend-icon="save"
                  :text="!isMobile ? 'Save Fields' : ''"
              ></AlbatrossButton>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </div>
      <div class="project-fields-container px-3" ref="projectFieldsContainer">
        <v-form ref="projectForm">
          <v-col v-if="isFieldsLoading">
            <SpinnerInline :size="20" color="primary"/>
          </v-col>

          <div v-else>
            <div v-if="projectTab.id !== -1">
              <v-col
                  :class="{ 'mt-4': index !== 0 }"
                  class="py-0"
                  v-for="(group, index) in customFieldGroups"
                  :key="index"
              >
                <v-toolbar color="transparent" class="elevation-0 process-step-toolbar">
                  <v-toolbar-title class="albatross-header-4-new">{{ group.groupName }}</v-toolbar-title>
                </v-toolbar>
                <v-card class="px-4 text-left square-card" :class="{'mb-6': index === customFieldGroups.length - 1}">
                  <v-row>
                    <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                      <CustomValueInput
                          v-for="(field, idx) in getCustomFieldValuesToDisplay(group.customFieldValues,1)"
                          :key="idx"
                          :required="field.required"
                          :callback="populateDirtyCfvs"
                          :readonly="getReadOnly(field)"
                          :showFieldName="false"
                          :field="field"
                      />
                    </v-col>
                    <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                      <CustomValueInput
                          v-for="(field, idx) in getCustomFieldValuesToDisplay(group.customFieldValues, 2)"
                          :key="idx"
                          :required="field.required"
                          :callback="populateDirtyCfvs"
                          :readonly="getReadOnly(field)"
                          :showFieldName="false"
                          :field="field"
                      />
                    </v-col>
                  </v-row>
                </v-card>
              </v-col>
            </div>
            <div v-else>
              <v-col class="py-0">
                <AttachmentsFolderList :object-type-id="1"
                                       :project-id="projectId"
                                       is-card
                                       :hide-empty="true"
                                       title="Uploaded Documents"
                                       :allow-upload="true"/>
              </v-col>
              <v-col>
                <AttachmentsFolderList :object-type-id="1"
                                       :project-id="projectId"
                                       is-card
                                       :hide-empty="true"
                                       title="Linked Documents"
                                       :load-linked="true"/>
              </v-col>
            </div>
          </div>
        </v-form>
      </div>
    </div>
    <ConfirmationDialog :open-dialog="unsavedFieldsModal" @confirm="[goToPath(toPath, query)]" @close-dialog="unsavedFieldsModal = false">
      <template v-slot:title>Confirm</template>
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:yes>Continue and Discard Changes</template>
    </ConfirmationDialog>
  </div>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  postRequestWithRequestParams,
  logError,

  getRequestWithParams, getAttachmentSourceId
} from '@/helpers/helpers'

import SpinnerInline from '@/components/SpinnerInline'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
import { useFileStore } from '@/stores/FileStore.js'
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router/composables'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const fileStore = useFileStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const customFieldGroups = ref([])
const menuOpen = ref(false)
const fieldsSaving = ref(false)
const isFieldsLoading = ref(false)
const dirtyCfvs = ref([])
const attachmentTypes = ref([])
const attachmentMenuOpen = ref(false)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_DOCS_AUDIO)
const tempFile = ref({})
const fileToUpload = ref(null)
const showCoversheetModal = ref(false)
const unsavedFieldsModal = ref(false)
const toPath = ref(null)
const query = ref({})
const projectForm = ref(null)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const props = defineProps({
  project: Object,
  projectTab: Object
})
const { project, projectTab } = toRefs(props)

onMounted(() => {
  window.document.title = `${project.value.projectName} - Project Details`
  getFieldGroups()
})

watch(projectTab, async() => {
  getFieldGroups()
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

onBeforeRouteLeave(async (to, from, next) => {
  if(dirtyCfvs.value.length === 0){
    next()
  } else {
    toPath.value = to.path
    query.value = to.query
    unsavedFieldsModal.value = true
  }
})
onBeforeRouteUpdate(async (to, from, next) => {
  if(dirtyCfvs.value.length === 0){
    next()
  } else {
    toPath.value = to.path
    query.value = to.query
    unsavedFieldsModal.value = true
  }
})


const loadProjectAttachmentTypes = async() => {
  const {data} = await getRequestWithParams(`/attachmentType/objectType/project`, {
    params: {
      linkable: false,
      allowUpload: true,
      focused: false
    }
  })
  attachmentTypes.value = data
}
const setSplitColumnValue = () => {
  //flip the flag
  projectStore.manualColumnSplit = !projectStore.manualColumnSplit
}
const getCustomFieldValuesToDisplay = (values, columnNum) => {
  if (projectStore.manualColumnSplit) {
    return values.filter(function (element, index, values) {
      return (index % 2 === (columnNum === 1 ? 0 : 1));
    });
  } else {
    return values
  }
}

const getDirtyFieldsCount = () => {
  return dirtyCfvs.value?.length || 0
}
const getFieldGroups = async () => {
  //two custom tabs have id = -1 and id = -2
  if(projectTab.value?.id != null && projectTab.value?.id > 0) {
    isFieldsLoading.value = true
    customFieldGroups.value = []
    try {
      const {data} = await getRequest(`/customFieldValues/project/${projectId.value}/tab/${projectTab.value.id}`, null, [])
      customFieldGroups.value = data
    } catch (e) {
      logError(e)
    } finally {
      isFieldsLoading.value = false
    }
  }
}
const updateFieldGroups = async () => {
  if (projectForm.value.validate()) {
    fieldsSaving.value = true
    try {
      appStore.loading = true
      const {data, status} = await postRequestWithRequestParams(`/customFieldValues/project/${projectId.value}`, dirtyCfvs.value, {
        tabId: projectTab.value.id
      })
      dirtyCfvs.value = []
      customFieldGroups.value = data
      snackbar('SUCCESS', 'Fields Saved')

      handleHidingGlobalLoader( status)
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error Updating Project Fields')

      appStore.loading = false
    } finally {
      fieldsSaving.value = false
    }
  } else {
    snackbar('ERROR', 'Missing Required Fields')

  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getReadOnly =  (field) => {
  return getCustomFieldReadOnly(field) || !userCanEdit.value
}
const selectFile =  (typeId) => {
  document.getElementById(`menuFileInput${typeId}`)?.click();
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
const setTempFile =  (file, type) => {
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
          // console.log('doing multi')
          const filesToUpload = [...files].map(file => {
            return {
              file,
              displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
              attachmentTypeId: type.attachmentTypeId,
              objectTypeId: 1,
              sourceId,
              secondaryId,
            }
          })
          const uploaded = await fileStore.uploadFileMulti(filesToUpload)
          attachments.value = [...attachments.value, ...uploaded]
          appStore.loading = false
        } else {
          let file = files[0]
          if(file?.size > 0) {
            // console.log('doing this')
            await fileStore.uploadFile({
              file: file,
              attachmentTypeId: type.attachmentTypeId,
              displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
              objectTypeId: 1,
              sourceId,
              secondaryId,
              callback: fileUploaded()
            })
          }
        }
      }
    }
  } catch (e) {
    appStore.loading = false
    logError(e)
    snackbar('ERROR', 'Error Uploading File')

  }
}
const fileUploaded = (attachment, error) => {
  if (error) {
    snackbar('ERROR', error.message)

  } else {
    //this value tells the right pane to update when a file is uploaded
    projectStore.incrementReloadKey()
  }
  appStore.loading = false
}
const closeCoversheet = (attachmentTypeId) => {
  showCoversheetModal.value = false
  //if you cancel the coversheet the file-input files prop is not getting reset. do manually here
  //could not get it to reset using the vue $ref stuff. but this way with getElementById does work
  document.getElementById(`menuFileInput${attachmentTypeId}`).value = null
}
const goToPath = (path, query) => {
  //reset these values so the next screen works if also a pps
  unsavedFieldsModal.value = false
  dirtyCfvs.value = []
  router.push({path, query})
}
</script>

<style lang="scss" scoped>
#project-details-container {
  padding-left: 0 !important;
  padding-right: 0 !important;
  max-height: 100%;
  height: 100%;
  position: relative;
}

.project-header {
}

.project-fields-container {
  overflow: auto;
  height: calc(100vh - 175px);
  padding-bottom: 0px !important;

  @media (min-width: 960px) {
    height: calc(100% - 65px);
  }
}

.project-title {
  font-size: 20px;
}

.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 48px;
  }
}
</style>

<style lang="scss">
.process-step-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.manage-btn {

  margin-left: 12px;

}
</style>
