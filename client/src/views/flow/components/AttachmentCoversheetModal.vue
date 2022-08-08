<template>
  <v-card class="square-card">
    <v-card-text class="pb-0 pl-0">
      <v-row>
        <v-col cols="4" class="coversheet-left-pane">
          Fill Out Coversheet
          <v-divider></v-divider>
          Document Details
          <v-card class="square-card pa-3">
            <v-text-field
              label="Document Name"
              v-model="fileDetails.editableName"
            ></v-text-field>
            <DatetimePickerInput
              v-model="fileDetails.dateCreated"
              :timezone="timezone"
              :type="'date'"
              readonly
              :format="'MM/DD/YYYY'"
              label="Upload Date"
            />
            <v-text-field
              disabled readonly
              label="Uploaded By"
              v-model="fileDetails.uploadedBy"
            ></v-text-field>
            <v-text-field
              disabled readonly
              label="Document Type"
              v-model="fileDetails.attachmentType"
            ></v-text-field>
            <v-text-field
              disabled readonly
              label="Document Location"
              v-model="fileDetails.originLocation"
            ></v-text-field>
          </v-card>
          Additional Document Details
          <v-col
            class="pt-0"
            v-for="(cfg, index) in customFieldGroups"
            :key="index"
          >
            {{ cfg.groupName }}
            <v-card class="square-card pa-3">
              <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                                :key="idx"
                                :show-field-name="false"
                                :callback="populateDirtyCfvs"
                                :required="cf.required"
                                :readonly="getReadOnly(cf)"
                                :field="cf"></CustomValueInput>
            </v-card>

          </v-col>
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <div class="flex-display">
                <v-btn small text @click="closeModal()">
                  Cancel Upload
                </v-btn>
                <v-btn small :loading="fieldsSaving" color="primary" @click="saveAndUpload()">
                  Save and Upload
                </v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
        </v-col>
        <v-col cols="8">
          <div class="one-hunned text-right">
            <v-btn x-small text @click="closeModal()">
              <v-icon>close</v-icon>
            </v-btn>
          </div>
          {{ fileDetails.filename }}
          <v-divider></v-divider>
          file preview here
        </v-col>
      </v-row>
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
      fieldsSaving: false
    }
  },
  created() {
    this.doPageLoad()
  },
  computed: {},
  methods: {
    async doPageLoad() {
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
      if (!this.existingAttachment.id) {
        //file hasn't been uploaded yet so do that first to get the id
        await this.uploadDocument()
      } else {
        //if file already exists then only save fields
        await this.updateFieldGroups(this.existingAttachment.id)
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
        let tempFileName = newAttachment.filename.substr(0, newAttachment.filename.lastIndexOf('.'))
        newAttachment.editableName = tempFileName !== null && tempFileName !== '' ? tempFileName : newAttachment.filename
        newAttachment.editableNameCopy = newAttachment.editableName
        // this.snackbar = getSnackbar('SUCCESS', 'Document Uploaded')
        // this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        // this.attachments = [...this.attachments, newAttachment]
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

<style scoped>
.coversheet-left-pane {
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  padding-left: 25px;
}
</style>
