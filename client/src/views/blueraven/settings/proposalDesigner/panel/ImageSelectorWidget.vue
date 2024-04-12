<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="text-h5 grey lighten-2">
        Proposal Image Selector
      </v-card-title>

      <div class="previews">
        <div
          class="preview-image"
          :class="{ selected: selected && selected.id === image.id }"
          v-for="image in images"
          @click="select(image)"
        >
          <img-proxy :uuid="image.uuid" :alt="image.filename" :width="100" />
        </div>
      </div>

      <div class="file-upload">
        <v-container
          class="file-selector"
          @drop.prevent="addDragDocument"
          @dragover.prevent
        >
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

                  <span
                    v-else-if="index === 2"
                    class="text-overline grey--text text--darken-3 mx-2"
                  >
                    +{{ uploadFiles.length - 2 }} File(s)
                  </span>
                </template>
              </v-file-input>
            </v-col>
            <v-col :cols="4">
              <a-btn
                variant="text"
                :disabled="!uploadFiles.length"
                @click="uploadAttachments(uploadFiles)"
                color="unset"
                text="Upload"
              ></a-btn>
            </v-col>
          </v-row>
        </v-container>
      </div>

      <v-card-actions>
        <a-btn
          variant="text"
          @click="cancel"
          color="unset"
          text="Cancel"
        ></a-btn>
        <v-spacer></v-spacer>
        <a-btn
          color="primary"
          @click="ok"
          :disabled="!selected"
          text="Ok"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script setup>
import {
  getRequestWithParams,
  handleHidingGlobalLoader,
  logError
} from '@/helpers/helpers'
import ImgProxy from '@/components/ImgProxy'
import { getCurrentInstance, ref } from 'vue'
import { useFileStore } from '@/stores/FileStore.js'
import { useAppStore } from '@/stores/AppStore.js'

const fileStore = useFileStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const PROPOSAL_TEMPLATE_ATTACHMENT_TYPE_ID = 939
const IMAGE_REGEX = /^(jpe?g|png|gif|webp)$/i

const uploadFiles = ref([])
const selected = ref(null)
const resolve = ref(null)
const reject = ref(null)
const images = ref([])
const dialog = ref(false)

const _fetchProposalImages = async () => {
  try {
    appStore.loading = true

    const { data, status } = await getRequestWithParams(
      '/attachment',
      {
        params: {
          attachmentTypeId: 939 //PROPOSAL_TEMPLATE
        }
      },
      null,
      []
    )

    images.value = data?.filter((a) => IMAGE_REGEX.test(a.fileExtension))
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error retrieving data')
  } finally {
    appStore.loading = false
  }
}
const open = () => {
  dialog.value = true
  _fetchProposalImages()
  return new Promise((res, rej) => {
    resolve.value = res
    reject.value = rej
  })
}
const select = (attachment) => {
  selected.value = attachment
}
const ok = () => {
  resolve.value({ uuid: selected.value.uuid })
  dialog.value = false
  selected.value = null
}
const cancel = () => {
  selected.value = null
  reject.value(undefined)
  dialog.value = false
}
const addDragDocument = async (e) => {
  uploadFiles.value = e.dataTransfer.files
}
const uploadAttachments = async (files) => {
  if (files?.length > 0) {
    try {
      appStore.loading = true

      const filesToUpload = files?.map((file) => {
        return {
          file,
          attachmentTypeId: PROPOSAL_TEMPLATE_ATTACHMENT_TYPE_ID,
          sourceId: null,
          displayName: file.name.substring(0, file.name.lastIndexOf('.')),
          deleteFirst: false
        }
      })

      const uploaded = await fileStore.uploadFileMulti(filesToUpload)
      images.value = [...images.value, ...uploaded]
      uploadFiles.value = []
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error uploading document')
      appStore.loading = false
    } finally {
      appStore.loading = true
    }
  }
}

defineExpose({
  open
})
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
