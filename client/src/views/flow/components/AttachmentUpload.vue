<template>
  <div @drop.prevent='addDragDocument' @dragover.prevent>
    <v-file-input
      dense
      multiple
      ref='fileInput'
      hide-details
      :show-size='error.error'
      outlined
      label='Upload Files'
      @change='uploadDocument'
    />
    <span class='error-text' v-if='error.message'>{{ error.message }}</span>
  </div>
</template>

<script>
import { Actions } from '@/store'
import { AppMutations } from '@/stores/AppStore'
import { getSnackbar, logError } from '@/helpers/helpers'
import constants from "@/helpers/constants"

// @TODO: need to generisize this so it can be used for any object type (project, process step, contact, user, org)

export default {
  name: 'AttachmentUpload',
  data() {
    return {
      error: {},
      maxFiles: constants.MAX_FILE_UPLOADS,
      companyId: this.$store.state.user.details.companyId
    }
  },
  props: {
    projectId: Number,
    projectProcessStepId: Number,
    attachmentTypeId: Number,
    objectTypeId: Number,
    userId: Number,
    contactId: Number,
    orgId: Number,
    callback: Function
  },
  created() {
  },
  computed: {},
  methods: {
    addDragDocument: async function(e) {
      let files = e.dataTransfer.files
      console.log('files here', files)
      await this.uploadDocument(files, this.attachmentTypeId)
    },
    uploadDocument: async function(files) {
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
            let file = files[i]
            if (file && file.size > 0) {
              await this.$store.dispatch((this.projectId) ? Actions.PROJECT_FILE_UPLOAD :
                null != this.projectProcessStepId ? Actions.PROJECT_PROCESS_STEP_FILE_UPLOAD : Actions.OBJECT_TYPE_FILE_UPLOAD, {
                file,
                attachmentTypeId: this.attachmentTypeId,
                projectId: this.projectId,
                projectProcessStepId: this.projectProcessStepId,
                userId: this.userId,
                contactId: this.contactId,
                orgId: this.orgId,
                objectTypeId: this.objectTypeId,
                callback: async (newAttachment, error) => {
                  this.$refs?.fileInput?.reset()
                  this.callback(newAttachment, error)
                }
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
    }
  }
}
</script>

<style scoped lang='scss'>
.v-btn:before {
  display: none;
}

.type {
  font-size: 12px;
}

.link {
  color: inherit;
  text-decoration: none;
}

.attachment-table {
  border-top: solid 2px #E0E0E0;
  border-bottom: solid 2px #E0E0E0;
}

.primary-row {
  background-color: #ebf5ff !important;
}

.file-hover {
  background: #F6F7F8;
}
</style>
