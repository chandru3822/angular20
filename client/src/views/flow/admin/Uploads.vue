<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">File Uploads</v-toolbar-title>
        </v-toolbar>

        <div>
          <v-autocomplete v-model="selectedAttachmentTypeId"
                          :items="attachmentTypes"
                          label="Attachment Type"
                          item-text="attachmentType"
                          item-value="id"
          />
          <!--          <br/>-->
          <!--          <span>Auto Create Generic Join Record?</span>-->
          <!--          <input type="checkbox" class="ml-2"-->
          <!--                 v-model="addToJoin">-->

          <div v-if="selectedAttachmentTypeId">
            <div class="mb-2">Note: This will upload as soon as you select your file(s)</div>
            <div @drop.prevent='addDragDocument' @dragover.prevent>
              <v-file-input
                dense
                multiple
                ref='fileInput'
                hide-details
                :show-size='error.error'
                outlined
                label='Upload Files'
                @change='uploadAttachment'
              />
              <span class='error-text' v-if='error.message'>{{ error.message }}</span>
            </div>
          </div>
          <div v-else>
            Select an attachment type to upload
          </div>
        </div>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {Actions} from "@/store";

export default {
  name: 'Uploads',

  data() {
    return {
      snackbar: {},
      constants,
      error: {},
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      attachmentTypes: [],
      selectedAttachmentTypeId: null,
      addToJoin: true
    }
  },
  async created() {
    await this.getAttachmentTypes()
  },
  methods: {
    async getAttachmentTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/attachmentType/system`)
        this.attachmentTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    addDragDocument: async function (e) {
      let files = e.dataTransfer.files
      await this.uploadDocument(files, this.attachmentTypeId)
    },
    async uploadAttachment(files) {
      if (files?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          this.error = {}
          let numFiles = files?.length
          let count = 0
          for (const f of files) {
            if (f.size > 0) {
              await this.$store.dispatch(Actions.FILE_UPLOAD, {
                file: f,
                attachmentTypeId: this.selectedAttachmentTypeId,
                sourceId: null,
                deleteFirst: false,
                callback: async (document) => {
                  this.snackbar = getSnackbar('SUCCESS', 'Successfully uploaded document')
                  this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                  count++
                  if (count === numFiles) {
                    this.selectedAttachmentTypeId = null
                    files = []
                    this.$store.commit(AppMutations.SET_LOADING, false)
                  }
                }
              })
            }
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error uploading document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
  }
}
</script>
