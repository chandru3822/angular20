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
              v-model="file.fileName"
            ></v-text-field>
            <DatetimePickerInput
              v-model="file.dateCreated"
              :timezone="timezone"
              :type="'date'"
              readonly
              :format="'MM/DD/YYYY'"
              label="Upload Date"
            />
            <v-text-field
              disabled readonly
              label="Uploaded By"
              v-model="file.createdBy"
            ></v-text-field>
            <v-text-field
              disabled readonly
              label="Document Type"
              v-model="file.fileType"
            ></v-text-field>
            <v-text-field
              disabled readonly
              label="Document Location"
              v-model="file.location"
            ></v-text-field>
          </v-card>
          Additional Document Details
          <v-col
            class="pt-0"
            v-for="(cfg, index) in customFieldGroups"
            :key="index"
          >
            {{cfg.groupName}}
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
                  Save and Upload</v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
        </v-col>
        <v-col cols="8">
          {{ file.fileName }}
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

export default {
  name: "AttachmentCoversheetModal",
  props: {
    attachmentTypeId: Number,
    existingAttachmentId: Number,
    closeCallback: Function,
    showModal: Boolean
  },
  components: {
    DatetimePickerInput,
    CustomValueInput
  },
  watch: {
    showModal: async function (visible) {
      //created only gets called the first time the modal opens. this forces it to load every time (the watcher doesn't get call on the first time the modal opens, so no double loading to worry about)
      if(visible) {
        await this.getFieldGroups()
      }
    }
  },
  data() {
    return {
      file: {},
      timezone: this.$store.state.user.details.timezone.value,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
      customFieldGroups: [],
      attachmentId: null,
      dirtyCfvs: [],
      fieldsSaving: false
    }
  },
  async created() {

    //todo: temp, take this out
    this.file = {
      id: 4167016,
      fileName: 'Final Design 4242',
      dateCreated: '2022-06-14 17:46:35.153513',
      createdBy: ' Brendan Filmore',
      fileType: 'Final Design',
      location: 'Design and Financing 384596'
    }
    await this.getFieldGroups()
  },
  computed: {},
  methods: {
    getFieldGroups: async function () {
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/attachmentType/${this.attachmentTypeId}`, { params: {
            attachmentId: this.existingAttachmentId
          }}, null, [])
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isFieldsLoading = false
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if(!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field)
    },
    closeModal() {
      this.closeCallback()
    },
    saveAndUpload() {
      //todo: get this id back from the upload later
      this.attachmentId = this.existingAttachmentId || 4167016
      console.log('we will save here', this.attachmentTypeId)
      if(this.dirtyCfvs?.length > 0) {
        console.log('dirty cfvs: ', this.dirtyCfvs)
        this.updateFieldGroups()
      }
    },
    async updateFieldGroups() {
      this.fieldsSaving = true
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // save dirty custom field values
        const {data} = await postRequest(`/customFieldValues/attachmentType/${this.attachmentTypeId}/attachment/${this.attachmentId}`, this.dirtyCfvs)
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
