<template>
  <div>
    <v-dialog persistent  v-model="showCoversheetModal"
              content-class="coversheet-modal-content">
      <AttachmentCoversheetModal :existing-attachment="selectedFile"
                                 :show-modal="showCoversheetModal"
                                 :close-callback="closeCoversheet"
                                 :projectId="projectId"
                                 :projectProcessStepId="projectProcessStepId"
                                 :userId="userId"
                                 :contactId="contactId"
                                 :orgId="orgId"
                                 :objectTypeId="objectTypeId"
                                 :projectProcessStepEventId="projectProcessStepEventId">
      </AttachmentCoversheetModal>
    </v-dialog>
    <small v-if="!drillDownAttachments.length" small class="pl-3 no-attach">No attachments available</small>
    <v-container v-else dense :key="renderTicker" id="attachment-table" class="pa-0">
      <v-row v-for="(item, index) in filteredDrillDownAttachments" class="text-left attachment hover-effect"
             :key="item.processStepId" @click="selectFile(item)" >

        <v-col  cols="9" md="10" class="text-left pt-0 height-one-hunned">
          <div class="file-column">
            <div @mouseover="buttonHovered = true" @mouseleave="buttonHovered = false">
              <v-checkbox v-if="compare" @change="selectFileToCompare($event, item)"
                          v-model="item.compare"
                          :disabled="!item.compare && countSelected >= maxSelectable">
              </v-checkbox>
            </div>
            <v-icon size="25" color="grey" @click="selectFile(item)">
              {{ getIconForFile(item) }}
            </v-icon>
            <div class="file-name-container">
              <div class="file-name-div">
                <div @click="selectFile(item)" class="text-left no-text-decoration file-name">
                  {{ item.displayName }}
                </div>
              </div>
              <div class="text-left uploaded-by">
                {{ item.uploadedBy ? `${item.uploadedBy}, ` : '' }}
                {{ item.dateCreated | formatDate('timestamp', 'M/D/YY') }}
              </div>
            </div>
          </div>
        </v-col>
        <!--        <v-col cols="3" class="text-right px-1 attachment-info">-->
        <!--          {{ item.uploadedBy ? `${item.uploadedBy}, ` : '' }}{{-->
        <!--            item.dateCreated | formatDate('timestamp', 'M/D/YY')-->
        <!--          }}-->
        <!--        </v-col>-->
        <v-col cols="3" md="2" class="text-right pa-0 height-one-hunned">
          <AlbatrossButton
              icon
              v-if="!allowUpload && !loadLinked && displayType.linkable && !item.linkedToSelected"
              :disabled="performingLink"
              variant="text"
              color="neurtal"
              @click="linkAttachment(item, true)"
              @mouseover="buttonHovered = true"
              @mouseleave="buttonHovered = false"
              class="px-0 button-position"
          >
            <v-icon size="25">link</v-icon>
          </AlbatrossButton>
          <AlbatrossButton
              icon
              v-if="!allowUpload && loadLinked"
              :disabled="performingLink"
              variant="text"
              color="primary"
              @click="linkAttachment(item, false)"
              @mouseover="buttonHovered = true"
              @mouseleave="buttonHovered = false"
              class="px-0 button-position"
          >
            <v-icon size="25">mdi-link-off</v-icon>
          </AlbatrossButton>
          <AlbatrossButton
              icon
              v-if="allowUpload"
              variant="text"
              color="primary"
              @click.native.stop="startDelete(item)"
              @mouseover="buttonHovered = true"
              @mouseleave="buttonHovered = false"
              class="px-0 button-position"
              prepend-icon="delete"
          >
            <v-icon size="25">delete</v-icon>
          </AlbatrossButton>
          <AlbatrossButton
              icon
              variant="text"
              color="primary"
              class="button-position"
              @click.native.stop
              :href="item.presignedUrl"
              @mouseover="buttonHovered = true"
              @mouseleave="buttonHovered = false"
              prepend-icon="mdi-tray-arrow-down"
          >
            <v-icon size="25" >mdi-tray-arrow-down</v-icon>
          </AlbatrossButton>
        </v-col>
      </v-row>
    </v-container>
    <ConfirmationDialog
        :open-dialog="attachmentDeleteConfirm"
        :retain-focus="false"
        @confirm="deleteTheAttachment"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete <b>{{ attachmentToDeleteName }}</b>?
    </ConfirmationDialog>
  </div>
</template>

<script setup>
import {
  getFileIcon,

  postRequestWithRequestParams
} from "@/helpers/helpers";

import {deleteAttachment} from "@/services/attachmentService";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import { useProjectStore } from '@/stores/ProjectStorePinia.js'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
// const rootInstance = getCurrentInstance().appContext.app;

const props = defineProps({
  attachments: Array,
  search: String,
  displayType: Object,
  showNonPrimaryDocs: Boolean,
  loadLinked: Boolean,
  allowUpload: Boolean,
  compare: Boolean,
  projectId: Number,
  userId: Number,
  contactId: Number,
  orgId: Number,
  objectTypeId: Number,
  projectProcessStepId: Number,
  projectProcessStepEventId: Number,
  compareCallback: Function,
  deleteCallback: Function,
  countSelected: Number,
  cancelResetKey: Number,
  allowEdit: {
    type: Boolean,
    default: true,
  },
})
const { attachments, search, displayType, showNonPrimaryDocs, loadLinked, allowUpload,
  compare, projectId, userId, contactId, orgId, objectTypeId, projectProcessStepId,
  projectProcessStepEventId, countSelected,
  cancelResetKey, allowEdit } = toRefs(props)

watch(cancelResetKey, () => {
  //this is called when the parent element clicks "cancel comparison"
  attachments.value.forEach(a => {
    a.compare = false
  })
})

const renderTicker = ref(0)
const showCoversheetModal = ref(false)
const selectedFile = ref({})
const attachmentDeleteConfirm = ref(false)
const attachmentToDelete = ref({})
const linkAttachmentPath = ref(null)
const maxSelectable = ref(3)
const performingLink = ref(false)
const buttonHovered = ref(false)


const drillDownAttachments = computed(() => {
  if (displayType.value === null) {
    return []
  } else {
    return attachments.value.filter(a => {
      return !a.archived && a.attachmentTypeId === displayType.value.attachmentTypeId && a.linked === loadLinked.value
          && ((search.value != null && search.value !== '') ? a.displayName.toLowerCase().includes(search.value.toLowerCase()) : true)
    })
  }
})
const attachmentToDeleteName = computed(() => {
  return attachmentToDelete.value ? attachmentToDelete.value.filename : ""
})

const filteredDrillDownAttachments = computed(() => {
  return drillDownAttachments.value?.filter(a => !a.archived)
})


const selectFile =  (attachment) => {
  if(!buttonHovered.value) {
    selectedFile.value = attachment
    showCoversheetModal.value = true
  }
}
const closeCoversheet = () => {
  showCoversheetModal.value = false
}
const getIconForFile = (item) => {
  return getFileIcon(item)
}
const deleteTheAttachment = async () => {
  const id = attachmentToDelete.value.id
  try {
    await deleteAttachment(id)
    if(props.deleteCallback) {
      props.deleteCallback(id)
    }
    //this value tells the right pane to update when a file is deleted
    projectStore.incrementReloadKey()

    //only emit a change event if something was linked, only the actively showing linked section will update
    vueInstance.$emit('attachmentDeleted', id)

    snackbar('SUCCESS', 'Document Deleted')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Document')

    appStore.loading = false
  } finally {
    closeDeleteDialog()
  }
}
const linkAttachment = async(attachment, doLink) => {
  try {
    performingLink.value = true
    if (projectProcessStepEventId.value) {
      linkAttachmentPath.value = `/projectProcessStep/${projectProcessStepId.value}/event/${projectProcessStepEventId.value}/linkAttachment/${attachment.id}`
    } else if (projectProcessStepId.value) {
      linkAttachmentPath.value = `/projectProcessStep/${projectProcessStepId.value}/linkAttachment/${attachment.id}`
    } else if (projectId.value) {
      linkAttachmentPath.value = `/project/${projectId.value}/linkAttachment/${attachment.id}`
    } else if (objectTypeId.value === 2) {
      //contact
      linkAttachmentPath.value = `/contact/${contactId.value}/linkAttachment/${attachment.id}`
    } else if (objectTypeId.value === 5) {
      //org
      linkAttachmentPath.value = `/org/${orgId.value}/linkAttachment/${attachment.id}`
    } else if (objectTypeId.value === 3) {
      //user
      linkAttachmentPath.value = `/user/${userId.value}/linkAttachment/${attachment.id}`
    }

    const {data} = await postRequestWithRequestParams(`${linkAttachmentPath.value}`, null, {doLink})
    if (!doLink) {
      attachment.archived = true
      attachment.linked = false
      attachment.linkedToSelected = false
      //this value tells the right pane to update after a file is unlinked from the center pane
      //definitely better ways to handle this but fully refreshing is what we are doing for now
      projectStore.incrementReloadKey()
    } else {
      attachment.linkedToSelected = true
      //only emit a change event if something was linked, only the actively showing linked section will update
      vueInstance.$emit('newAttachmentLinked', attachment)
    }

    performingLink.value = false
    snackbar('SUCCESS', 'Document Linked')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Linking Document')

    appStore.loading = false
  }
}
const startDelete = (item) => {
  attachmentToDelete.value = item
  attachmentDeleteConfirm.value = true
}
const closeDeleteDialog = () => {
  attachmentDeleteConfirm.value = false
  attachmentToDelete.value = null
}
const selectFileToCompare = (e, item) => {
  props.compareCallback(item)
}
</script>

<style lang="scss">
#attachment-table .type {
  font-size: 14px;
}
</style>

<style lang="scss" scoped>
.attachment {
  display: flex;
  justify-content: space-between;
  height: 44px;
}

.text-left {
  display: flex;
  justify-content: flex-start;
  align-items: center;
}

.text-right {
  display: flex;
  justify-content: flex-end;
}

.attachment-info {
  font-size: 14px;
  color: var(--v-grey-darken2);

}

.no-attach {
  color: var(--v-primaryText-base);
}

.file-column {
  display: flex;
  max-width: 100%;
  max-height: 100%;
  align-items: center;
}

.file-name-container {
  display: flex;
  flex-direction: column;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-name-div {
  font-size: 14px;
  padding-left: 3px;
}

.file-name {
  display: block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.uploaded-by {
  font-size: 11px;
  padding-left: 3px;
  color: var(--v-grey-base);
}

.hover-effect:hover{
  background-color: #F5F5F5;
  cursor: pointer;
}

.button-position{
  position:relative;
  top:4px;
}
</style>
