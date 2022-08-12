<template>
  <v-card class="coversheet-container">
    <v-card-text class="pa-0">
      <v-form ref="attachmentFieldsForm">
        <v-row class="coversheet-container ma-0">
          <v-col cols="4" class="coversheet-left-pane pa-6">
            <div class="d-flex align-center">
              <v-btn small text color="primary" class="min-w-25 px-0 mr-6">
                <v-icon>mdi-menu</v-icon>
              </v-btn>
              <div class="albatross-header-1 default-text-color">Document Summary</div>
            </div>
              <v-divider class="mt-1 mb-6"></v-divider>
            <div v-if="saveError" class="error-text">
              {{errorMsg}}
            </div>
            <div class="subtitle-1 mb-4 default-text-color">Document Details</div>
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
              <div @click="goToPath(fileDetails.originPath)" class="clickable">
                <v-text-field
                  disabled readonly
                  label="Document Location"
                  v-model="fileDetails.originLocation"
                  class="albatross-body-2"
                ></v-text-field>
              </div>
            </v-card>
            <div v-if="customFieldGroups.length > 0" class="subtitle-1 mt-6 mb-3 default-text-color">Additional Document Details</div>
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
            <v-toolbar flat dense color="white"
                       class="fixed-toolbar-bottom mt-1 px-0 coversheet-save-bar">
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text color="primary" small @click="closeModal()">
                  {{ isExisting ? 'Cancel' : 'Cancel Upload' }}
                </v-btn>
                <div>
                  <v-btn small :loading="fieldsSaving"
                         class="mt-3"
                         color="primary" @click="saveAndUpload()">
                    {{ isExisting ? 'Save Changes' : 'Save and Upload' }}
                  </v-btn>
                </div>
              </v-toolbar-items>
            </v-toolbar>
          </v-col>
          <v-col cols="8" class="coversheet-right-pane pa-6">
            <div class="d-flex align-center albatross-header-1 default-text-color" >{{ fileDetails.displayName }}
            <div class="one-hunned text-right">
              <v-btn small text color="primary"
                     v-if="isExisting"
                     :href="existingAttachment.presignedUrl">
                <v-icon>mdi-tray-arrow-down</v-icon>
              </v-btn>
              <v-btn x-small text color="primary" @click="closeModal()">
                <v-icon>close</v-icon>
              </v-btn>
            </div>
            </div>
            <v-divider class="mt-1"></v-divider>
            file preview here
          </v-col>
        </v-row>
      </v-form>
    </v-card-text>
  </v-card>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader, logError, postRequest,
  putRequest
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {Actions} from "@/store";
import {ProjectMutations} from '@/stores/ProjectStore'
import constants from "@/helpers/constants"
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from "@/services/customFieldService"
import cloneDeep from 'lodash.clonedeep'

export default {
  name: "AttachmentCoversheetModal",
  props: {
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
  },
  components: {
    DatetimePickerInput,
    CustomValueInput
  },
  watch: {
    showModal: function (visible) {
      //created only gets called the first time the modal opens. this forces it to load every time (the watcher doesn't get call on the first time the modal opens, so no double loading to worry about)
      if (visible) {
        this.doPageLoad()
      }
    }
  },
  data() {
    return {
      fileDetails: {},
      timezone: this.$store.state.user.details.timezone.value,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
      customFieldGroups: [],
      dirtyCfvs: [],
      fieldsSaving: false,
      displayNameChanged: false,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      saveError: false,
      errorMsg: null,
      isExisting: false
    }
  },
  created() {
    this.doPageLoad()
  },
  computed: {},
  methods: {
    goToPath(path) {
      if(null != path) {
        this.$router.push(path)
      }
    },
    async doPageLoad() {
      //reset all the items cuz when the modal re-opens it doesnt reset everything
      this.isExisting = null != this.existingAttachment.id
      this.displayNameChanged = false,
      this.customFieldGroups = []
      this.dirtyCfvs = []
      this.fileDetails = {}
      this.saveError = false
      this.errorMsg = null

      //required so that both new and existing files work since the objects aren't identical
      this.fileDetails = cloneDeep(this.existingAttachment)

      await this.getFieldGroups()
    },
    getFieldGroups: async function () {
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/attachmentType/${this.existingAttachment.attachmentTypeId}`, {
          params: {
            attachmentId: this.existingAttachment.id
          }
        }, null, [])
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isFieldsLoading = false
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field)
    },
    closeModal() {
      this.closeCallback()
    },
    async saveAndUpload() {
      if (this.$refs.attachmentFieldsForm.validate()) {
        if (!this.existingAttachment.id) {
          //file hasn't been uploaded yet so do that first to get the id
          await this.uploadDocument()
        } else {
          //existing file
          if(this.displayNameChanged) {
            await this.saveDisplayName()
          }
          //if file already exists then only save fields
          await this.updateFieldGroups(this.existingAttachment.id)
        }
      } else {
        this.errorMsg = 'Additional fields are required before saving.'
        this.saveError = true
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async saveDisplayName() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.existingAttachment.displayName = this.fileDetails.displayName
        const {data, status} = await putRequest(`/attachment/${this.existingAttachment.id}`, this.existingAttachment)
        this.existingAttachment.presignedUrl = data.presignedUrl
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    uploadDocument: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        //reset error message when trying to upload new file
        this.error = {}
        if (this.file && this.file.size > 0) {
          console.log('file here', this.file)
          await this.$store.dispatch(null != this.projectProcessStepEventId ? Actions.PROJECT_PROCESS_STEP_EVENT_FILE_UPLOAD :
            null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD :
              (this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                Actions.OBJECT_TYPE_FILE_UPLOAD, {
            file: this.file,
            attachmentTypeId: this.existingAttachment.attachmentTypeId,
            displayName: this.fileDetails.displayName,
            projectId: this.projectId,
            projectProcessStepId: this.projectProcessStepId,
            userId: this.userId,
            contactId: this.contactId,
            orgId: this.orgId,
            objectTypeId: this.objectTypeId,
            projectProcessStepEventId: this.projectProcessStepEventId,
            callback: this.uploadCallback
          })
        }
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async uploadCallback(newAttachment, error) {
      if (error) {
        this.error = error
        this.snackbar = getSnackbar('ERROR', error.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else {
        await this.updateFieldGroups(newAttachment.id)
        this.fileUploadedCallback(newAttachment)
        this.closeModal()
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    async updateFieldGroups(attachmentId) {
      if (this.dirtyCfvs?.length > 0) {
        this.fieldsSaving = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          // save dirty custom field values
          const {data} = await postRequest(`/customFieldValues/attachmentType/${this.existingAttachment.attachmentTypeId}/attachment/${attachmentId}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.snackbar = getSnackbar('SUCCESS', 'Fields Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } finally {
          this.fieldsSaving = false
        }
      }
    },
  }
}
</script>

<style lang="scss">
.coversheet-save-bar .v-toolbar__content {
  padding: 0 !important;
}

</style>

<style lang="scss" scoped>
.coversheet-container {
  height: 90vh;
  max-height: 90vh;
}

.min-w-25 {
  min-width: 25px !important;
}

.coversheet-left-pane {
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  height: 90vh;
  max-height: 90vh;
  overflow-y: auto;
}

.coversheet-right-pane {
  height: 90vh;
  max-height: 90vh;
  overflow-y: auto;
}
</style>
