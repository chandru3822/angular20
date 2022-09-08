<template>
  <div>
    <v-dialog persistent :width="1000" v-model="showCoversheetModal"
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
    <v-container v-else dense :key="renderTicker" id="attachment-table">
      <v-row v-for="item in filterBy(drillDownAttachments, false, 'archived')" class="text-left attachment" :key="item.processStepId">
        <v-col cols="6" class="text-left pa-1">
          <v-checkbox v-if="compare" @change="selectFileToCompare($event, item)"
                      v-model="item.compare"
                      :disabled="!item.compare && countSelected >= maxSelectable">
          </v-checkbox>
          <v-btn icon text @click="selectFile(item)" class="type">
            <v-icon size="25" color="grey">
              {{ getIconForFile(item) }}
            </v-icon>
          </v-btn>
          <a @click="selectFile(item)" class="text-left no-text-decoration">
            {{ item.displayName }}
          </a>
        </v-col>
        <v-col cols="4" class="text-center px-1 attachment-info">
          {{ item.uploadedBy ? `${item.uploadedBy}, ` : '' }}{{ item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY') }}
        </v-col>
        <v-col cols="2" class="text-right pa-0">
          <v-btn small v-if="!allowUpload && !loadLinked && displayType.linkable && !item.linkedToSelected"
                 :disabled="performingLink"
                 text color="primary" @click="linkAttachment(item, true)" class="px-0">
            <v-icon>link</v-icon>
          </v-btn>
          <v-btn small v-if="!allowUpload && loadLinked"
                 :disabled="performingLink"
                 text color="primary" @click="linkAttachment(item, false)" class="px-0">
            <v-icon>mdi-link-off</v-icon>
          </v-btn>
          <v-btn small v-if="allowUpload" text color="primary" @click="startDelete(item)" class="px-0">
            <v-icon>delete</v-icon>
          </v-btn>
          <v-btn small text color="primary" :href="item.presignedUrl">
            <v-icon>mdi-tray-arrow-down</v-icon>
          </v-btn>
          <ConfirmationDialog
            :open-dialog="attachmentDeleteConfirm"
            @confirm="deleteAttachment"
            @close-dialog="closeDeleteDialog"

          >Are you sure you want to delete {{ attachmentToDeleteName }}?
          </ConfirmationDialog>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import {
  getFileIcon,
  getRequestWithParams,
  postRequest,
  getSnackbar,
  handleHidingGlobalLoader,
  putRequest,
  postRequestWithRequestParams
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {deleteAttachment} from "@/services/attachmentService";
import ConfirmationDialog from "@/ConfirmationDialog";
import AttachmentCoversheetModal from '@/views/flow/components/AttachmentCoversheetModal'
import Vue2Filters from 'vue2-filters'
import {ProjectMutations} from "@/stores/ProjectStore"

export default {
  name: "AttachmentsTable",
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    AttachmentCoversheetModal
  },
  props: {
    attachments: Array,
    search: String,
    displayType: Object,
    //loadLinked = the component for the linked sections. if true should only be able to unlink the attachments from here
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
    countSelected: Number

  },
  data() {
    return {
      renderTicker: 0,
      showCoversheetModal: false,
      selectedFile: {},
      attachmentDeleteConfirm: false,
      attachmentToDelete: {},
      linkAttachmentPath: null,
      maxSelectable: 3,
      performingLink: false,
    }
  },
  computed: {
    drillDownAttachments() {
      if (this.displayType === null) {
        return []
      } else {
        return this.attachments.filter(a => {
          return !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId && a.linked === this.loadLinked
            && ((this.search != null && this.search !== '') ? a.filename.toLowerCase().includes(this.search.toLowerCase()) : true)
        })
      }
    },
    attachmentToDeleteName() {
      return this.attachmentToDelete ? this.attachmentToDelete.filename : ""
    }
  },
  methods: {
    selectFile: function (attachment) {
      this.selectedFile = attachment
      this.showCoversheetModal = true
    },
    closeCoversheet() {
      this.showCoversheetModal = false
    },
    getIconForFile(item) {
      return getFileIcon(item)
    },
    deleteAttachment: async function () {
      const id = this.attachmentToDelete.id
      try {
        await deleteAttachment(id)
        this.deleteCallback(id)
        //this value tells the right pane to update when a file is deleted
        this.$store.commit(ProjectMutations.INCREMENT_RELOAD_KEY)
        this.snackbar = getSnackbar('SUCCESS', 'Document Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Document')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()

    },
    async linkAttachment(attachment, doLink) {
      try {
      this.performingLink = true
      if(this.projectProcessStepEventId) {
        this.linkAttachmentPath = `/projectProcessStep/${this.projectProcessStepId}/event/${this.projectProcessStepEventId}/linkAttachment/${attachment.id}`
      } else if(this.projectProcessStepId) {
        this.linkAttachmentPath = `/projectProcessStep/${this.projectProcessStepId}/linkAttachment/${attachment.id}`
      } else if(this.projectId) {
        this.linkAttachmentPath = `/project/${this.projectId}/linkAttachment/${attachment.id}`
      } else if (this.objectTypeId === 2) {
        //contact
        this.linkAttachmentPath = `/contact/${this.contactId}/linkAttachment/${attachment.id}`
      } else if (this.objectTypeId === 5) {
        //org
        this.linkAttachmentPath = `/org/${this.orgId}/linkAttachment/${attachment.id}`
      } else if (this.objectTypeId === 3) {
        //user
        this.linkAttachmentPath = `/user/${this.userId}/linkAttachment/${attachment.id}`
      }

      const {data} = await postRequestWithRequestParams(`${this.linkAttachmentPath}`, null, { doLink})
      if(!doLink) {
        attachment.archived = true
        //this value tells the right pane to update after a file is unlinked from the center pane
        //definitely better ways to handle this but fully refreshing is what we are doing for now
        this.$store.commit(ProjectMutations.INCREMENT_RELOAD_KEY)
      } else {
        attachment.linkedToSelected = true
      }
      this.performingLink = false
      this.snackbar = getSnackbar('SUCCESS', 'Document Linked')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Linking Document')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    startDelete(item) {
      this.attachmentToDelete = item
      this.attachmentDeleteConfirm = true
    },
    closeDeleteDialog() {
      this.attachmentDeleteConfirm = false
      this.attachmentToDelete = null
    },
    selectFileToCompare(e, item) {
      this.compareCallback(item)
    }
  }
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
</style>
