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
                <v-btn text color="primary" @click="loadProjectAttachmentTypes()" v-on="on">
                  <v-icon>mdi-tray-arrow-up</v-icon>
                </v-btn>
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
            <v-btn v-if="!isMobile"
                   text
                   color="primary"
                   @click="setSplitColumnValue()">
              <v-icon v-if="!$store.state.project.manualColumnSplit">mdi-format-columns</v-icon>
              <v-icon v-else>mdi-format-align-justify</v-icon>
            </v-btn>
            <div class="align-self-center">
              <v-btn
                v-if="userCanEdit"
                color="primary"
                :icon="isMobile"
                :disabled="isFieldsLoading || fieldsSaving"
                @click="updateFieldGroups()">
                <v-icon v-if="isMobile">save</v-icon>
                <span v-else>Save Fields</span>
              </v-btn>
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
                    <v-col :cols="$store.state.project.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
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
                    <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
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

<script>

import {
  handleHidingGlobalLoader,
  getRequest,
  postRequestWithRequestParams,
  logError,
  getSnackbar,
  getRequestWithParams, getAttachmentSourceId
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import {ProjectMutations} from '@/stores/ProjectStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import {Actions} from '@/store'
import constants from '@/helpers/constants'
import ConfirmationDialog from '../../../components/ConfirmationDialog.vue'
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

export default {
  name: 'ProjectDetails',
  components: {
    ConfirmationDialog,
    SpinnerInline,
    CustomValueInput,
    AttachmentsFolderList,
    AttachmentCoversheetModal
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      customFieldGroups: [],
      menuOpen: false,
      fieldsSaving: false,
      isFieldsLoading: false,
      dirtyCfvs: [],
      attachmentTypes: [],
      attachmentMenuOpen: false,
      acceptedFileTypes: constants.STANDARD_IMAGES_DOCS_AUDIO,
      tempFile: {},
      fileToUpload: null,
      showCoversheetModal: false,
      snackbar: {},
      unsavedFieldsModal: false,
      toPath: null,
      query: {},
      // windowWidth: window.innerWidth,
      // splitColumnMinWidth: 1700
    }
  },
  created() {
    window.document.title = `${this.project.projectName} - Project Details`
    this.getFieldGroups()
  },
  mounted() {
    // window.addEventListener('resize', () => {
    //   this.windowWidth = window.innerWidth
    // })
  },
  props: {
    project: Object,
    projectTab: Object
  },
  watch: {
    projectTab: function () {
      this.getFieldGroups()
    },
  },
  computed: {
    ...mapStores(useUserStore, useAppStore),
    userCanEdit() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
    },
    companyId() {
      return this.userStore.details.companyId
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    },
  },
  beforeRouteUpdate(to, from, next){
    if(this.dirtyCfvs.length === 0){
      next()
    } else {
      this.toPath = to.path
      this.query = to.query
      this.unsavedFieldsModal = true
    }
  },
  beforeRouteLeave(to, from, next){
    if(this.dirtyCfvs.length === 0){
      next()
    } else {
      this.toPath = to.path
      this.query = to.query
      this.unsavedFieldsModal = true
    }
  },
  methods: {
    async loadProjectAttachmentTypes() {
      const {data} = await getRequestWithParams(`/attachmentType/objectType/project`, {
        params: {
          linkable: false,
          allowUpload: true,
          focused: false
        }
      })
      this.attachmentTypes = data
    },
    setSplitColumnValue() {
      //flip the flag
      this.$store.commit(ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT)
    },
    getCustomFieldValuesToDisplay(values, columnNum) {
      if (this.$store.state.project.manualColumnSplit) {
        return values.filter(function (element, index, values) {
          return (index % 2 === (columnNum === 1 ? 0 : 1));
        });
      } else {
        return values
      }
    },

    getDirtyFieldsCount() {
      return this.dirtyCfvs?.length || 0
    },
    getFieldGroups: async function () {
      //two custom tabs have id = -1 and id = -2
      if(this.projectTab?.id != null && this.projectTab?.id > 0) {
        this.isFieldsLoading = true
        this.customFieldGroups = []
        try {
          const {data} = await getRequest(`/customFieldValues/project/${this.projectId}/tab/${this.projectTab.id}`, null, [])
          this.customFieldGroups = data
        } catch (e) {
          logError(e)
        } finally {
          this.isFieldsLoading = false
        }
      }
    },
    updateFieldGroups: async function () {
      if (this.$refs.projectForm.validate()) {
        this.fieldsSaving = true
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await postRequestWithRequestParams(`/customFieldValues/project/${this.projectId}`, this.dirtyCfvs, {
            tabId: this.projectTab.id
          })
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.snackbar = getSnackbar('SUCCESS', 'Fields Saved')
          this.appStore.showSnack(this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Project Fields')
          this.appStore.showSnack(this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } finally {
          this.fieldsSaving = false
        }
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.appStore.showSnack(this.snackbar)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(field) || !this.userCanEdit
    },
    selectFile: function (typeId) {
      document.getElementById(`menuFileInput${typeId}`)?.click();
    },
    async doUpload(files, type) {
      if (files?.length > 0) {
        if (type.hasFieldsAssigned) {
          let file = files[0]
          this.setTempFile(file, type)
        } else {
          await this.uploadDocument(files, type)
        }
      }
    },
    setTempFile: function (file, type) {
      this.tempFile = {}
      this.fileToUpload = null
      //we dont upload new files until after they fill in custom fields, need to pass file to next screen
      this.fileToUpload = file
      this.tempFile.attachmentTypeId = type.attachmentTypeId
      this.tempFile.attachmentType = type.attachmentType
      let displayName = this.fileToUpload.name.substr(0, this.fileToUpload.name.lastIndexOf('.'))
      this.tempFile.displayName = displayName
      this.showCoversheetModal = true
    },
    uploadDocument: async function (files, type) {
      //this should only get called if the attachment type doesn't have any native fields
      try {
        //reset error message when trying to upload new file
        this.error = {}
        if (files?.length > 0) {
          const { sourceId, secondaryId } = getAttachmentSourceId(this.projectId, this.projectProcessStepId, this.projectProcessStepEventId,
            this.userId, this.contactId, this.orgId)

          this.$store.commit(AppMutations.SET_LOADING, true)

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
              const uploaded = await this.$store.dispatch(Actions.FILE_UPLOAD_MULTI, filesToUpload)
              this.attachments = [...this.attachments, ...uploaded]
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              let file = files[0]
              if(file?.size > 0) {
                // console.log('doing this')
                await this.$store.dispatch(Actions.FILE_UPLOAD, {
                  file: file,
                  attachmentTypeId: type.attachmentTypeId,
                  displayName: file?.name?.substr(0, file?.name?.lastIndexOf('.')),
                  objectTypeId: 1,
                  sourceId,
                  secondaryId,
                  callback: this.fileUploaded
                })
              }
            }
          }
        }
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.appStore.showSnack(this.snackbar)
      }
    },
    fileUploaded(attachment, error) {
      if (error) {
        this.snackbar = getSnackbar('ERROR', error.message)
        this.appStore.showSnack(this.snackbar)
      } else {
          //this value tells the right pane to update when a file is uploaded
          this.$store.commit(ProjectMutations.INCREMENT_RELOAD_KEY)
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    closeCoversheet(attachmentTypeId) {
      this.showCoversheetModal = false
      //if you cancel the coversheet the file-input files prop is not getting reset. do manually here
      //could not get it to reset using the vue $ref stuff. but this way with getElementById does work
      document.getElementById(`menuFileInput${attachmentTypeId}`).value = null
    },
    goToPath(path, query) {
      //reset these values so the next screen works if also a pps
      this.unsavedFieldsModal = false
      this.dirtyCfvs = []
      this.$router.push({path, query})
    },
  }
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

  & > .v-btn__content {
    color: white !important;
  }
}
</style>
