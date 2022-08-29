<template>
  <v-card class="px-6 pt-4 square-card" :width="width">
    <v-form ref="uploadDocumentForm" class="one-hunned">
      <v-card-title
        color="blackText"
        class="albatross-header-3 text-capitalize pa-0"
        primary-title>
        Select Folder
        <v-spacer></v-spacer>
        <v-btn
            text color="primary"
          class="elevation-0 text-capitalize"
          @click="$emit('cancel')"
        >
          Close
        </v-btn>
      </v-card-title>
      <v-card-text class="pt-4 px-0 pb-0 documents-list-container">
        <div class="documents-list-inner">
          <v-row class="d-flex justify-start">
            <input type="file"
                   multiple
                   :accept="acceptedFileTypes"
                   @change="uploadDocument($event.target.files, clickedTypeId)"
                   ref="hiddenFileInput" style="display: none">
            <div
              @click="[clickedTypeId = type.attachmentTypeId, $refs.hiddenFileInput.click()]"
              :class="{'file-hover': dragTypeId === type.attachmentTypeId}"
              class="type text-center file-icon"
              @dragenter="dragTypeId=type.attachmentTypeId"
              @dragleave="dragTypeId=null"
              @dragend="dragTypeId=null"
              @drop.prevent="addDragDocument($event, type.attachmentTypeId)"
              @dragover.prevent="dragTypeId=type.attachmentTypeId"
              v-for="type in attachmentTypes"
            >
              <div>
                <v-icon x-large color="yellow accent-4" @dragleave.prevent>folder</v-icon>
                <div @dragleave.prevent>{{ type.attachmentType }}</div>
              </div>
            </div>
          </v-row>
        </div>
      </v-card-text>
    </v-form>
  </v-card>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader, logError,
  putRequest
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {Actions} from "@/store";
import {ProjectMutations} from '@/stores/ProjectStore'
import constants from "@/helpers/constants";

export default {
  name: "UploadDocumentModal",
  props: {
    show: Boolean,
    attachmentTypes: Array,
    ppsId: Number,
    ppsEventId: Number,
    width: Number,
    showSuccessSnackbar: Boolean
  },
  components: {},
  data() {
    return {
      dragTypeId: null,
      clickedTypeId: null,
      maxFiles: constants.MAX_FILE_UPLOADS,
      acceptedFileTypes: constants.STANDARD_IMAGES_AND_DOCS,
    }
  },
  created() {
  },
  computed: {},
  methods: {
    addDragDocument: async function (e, attachmentTypeId) {
      let files = e.dataTransfer.files
      await this.uploadDocument(files, attachmentTypeId)
    },
    uploadDocument: async function (files, attachmentTypeId) {
      if (files?.length > this.maxFiles) {
        this.snackbar = getSnackbar('ERROR', `Cannot upload more than ${this.maxFiles} files at one time. Please try again and select fewer files.`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else if (files?.length > 0) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          //reset error message when trying to upload new file
          this.error = {}
          // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
          for (let i = 0; i < files.length; ++i) {
            let file = files[i];
            if (file && file.size > 0) {
              await this.$store.dispatch(null != this.ppsId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD :
                null != this.ppsEventId ? Actions.PROJECT_PROCESS_STEP_EVENT_FILE_UPLOAD : Actions.OBJECT_TYPE_FILE_UPLOAD, {
                file,
                attachmentTypeId: attachmentTypeId ?? this.displayType?.attachmentTypeId,
                projectProcessStepId: this.ppsId,
                projectProcessStepEventId: this.ppsEventId,
                callback: this.uploadCallback
              })
            }
          }
          // this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async uploadCallback(newAttachment, error) {
      if (error) {
        this.error = error
        this.snackbar = getSnackbar('ERROR', error.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else {
        //show snackbar if told to
        if(this.showSuccessSnackbar) {
          this.snackbar = getSnackbar('SUCCESS', 'Document Uploaded')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        //i dont remember why we do this
        this.$store.commit(ProjectMutations.INCREMENT_RELOAD_KEY)
        this.$emit('cancel')
      }
      this.$store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
</script>

<style scoped>
.documents-list-container {
  width: 100%;
  display: flex;
  justify-content: center;
}

/*.documents-list-inner {*/
/*  width: 750px;*/
/*}*/

.upload-actions {
  justify-content: end;
}

.file-hover {
  background: #F6F7F8;
}

.file-icon {
  width: 167px;
  padding: 16px;
  margin: 0 12px 24px 12px;

}

.file-icon:hover {
  background: #F6F7F8;
}
</style>
