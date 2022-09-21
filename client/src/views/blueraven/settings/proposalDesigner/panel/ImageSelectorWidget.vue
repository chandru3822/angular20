<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="text-h5 grey lighten-2">
        Proposal Image Selector
      </v-card-title>

      <div class="previews">
        <div class="preview-image" :class="{'selected' : selected && selected.id === image.id }" v-for="image in images"
             @click="select(image)">
          <img-proxy :uuid="image.uuid" :alt="image.filename" :width="100" />
        </div>
      </div>

      <div class="file-upload">
        <v-container class="file-selector" @drop.prevent="addDragDocument" @dragover.prevent>
          <v-row no-gutters>
            <v-col :cols="8">
              <v-file-input
                dense
                counter
                multiple
                ref="fileInput"
                hide-details
                show-size
                outlined
                label="Upload New Images"
                v-model="uploadFiles"
              >
                <template v-slot:selection="{ index, text }">
                  <v-chip
                    v-if="index < 2"
                    color="deep-purple accent-4"
                    dark
                    label
                    small
                  >
                    {{ text }}
                  </v-chip>

                  <span v-else-if="index === 2"
                        class="text-overline grey--text text--darken-3 mx-2"
                  >
                +{{ uploadFiles.length - 2 }} File(s)
              </span>
                </template>
              </v-file-input>
            </v-col>
            <v-col :cols="4">
              <v-btn text :disabled="!uploadFiles.length" @click="uploadAttachments(uploadFiles)">Upload</v-btn>
            </v-col>
          </v-row>
        </v-container>
      </div>

      <v-card-actions>
        <v-btn
          text
          @click="cancel"
        >
          Cancel
        </v-btn>
        <v-spacer></v-spacer>
        <v-btn
          color="primary"
          @click="ok"
          dark
          :disabled="!selected"
        >
          Ok
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
import { getRequestWithParams, getSnackbar, handleHidingGlobalLoader, logError } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import { Actions } from '@/store'
import ImgProxy from '@/components/ImgProxy'

const PROPOSAL_TEMPLATE_ATTACHMENT_TYPE_ID = 939
const IMAGE_REGEX = /^(jpe?g|png|gif|webp)$/i

export default {
  data() {
    return {
      uploadFiles: [],
      selected: null,
      resolve: null,
      reject: null,
      images: [],
      dialog: false
    }
  },
  components: {ImgProxy},
  methods: {
    async _fetchProposalImages() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const { data, status } = await getRequestWithParams(`/attachment`, {
          params: {
            attachmentTypeId: 939 //PROPOSAL_TEMPLATE
          }
        }, null, [])

        this.images = data?.filter(a => IMAGE_REGEX.test(a.fileExtension))
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        const snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    open() {
      this.dialog = true
      this._fetchProposalImages()
      return new Promise(((resolve, reject) => {
        this.resolve = resolve
        this.reject = reject
      }))
    },
    select(attachment) {
      this.selected = attachment
    },
    ok() {
      this.resolve({ uuid: this.selected.uuid })
      this.dialog = false
      this.selected = null
    },
    cancel() {
      this.selected = null
      this.reject(undefined)
      this.dialog = false
    },
    addDragDocument: async function(e) {
      this.uploadFiles = e.dataTransfer.files
    },
    async uploadAttachments(files) {
      if (files?.length > 0) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          const filesToUpload = files?.map(file => {
            return {
              file,
              attachmentTypeId: PROPOSAL_TEMPLATE_ATTACHMENT_TYPE_ID,
              sourceId: null,
              deleteFirst: false
            }
          })

          const uploaded = await this.$store.dispatch(Actions.FILE_UPLOAD_MULTI, filesToUpload)
          this.images = [...this.images, ...uploaded]
          this.uploadFiles = []
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error uploading document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
}
</script>
<style scoped lang="scss">

.previews {
  padding: 10px;
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  justify-content: space-between;
  align-content: flex-start;
}

.preview-image {
  cursor: pointer;
  max-width: 100px;
  height: auto;

  img {
    width: 100%;
  }

  &.selected {
    outline: 1px solid blue;
  }
}

.file-upload {
  border-top: 1px dashed #ccc;
  border-bottom: 1px dashed #ccc;
}
</style>
