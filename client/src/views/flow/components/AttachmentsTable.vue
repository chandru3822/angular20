<template>
  <small v-if="!drillDownAttachments.length" small class="pl-3 no-attach">No attachments available</small>

  <v-container v-else dense :key="renderTicker" id="attachment-table">
    <v-row v-for="item in drillDownAttachments"  class="text-left attachment"  :class="{'primary-row': item.main}" :key="item.processStepId">
      <v-col cols="6" class="text-left pa-1">
        <v-btn
            icon
            text
            :href="item.presignedUrl" class="type">
          <v-icon size="25" color="grey">
            {{ getIconForFile(item) }}
          </v-icon>
        </v-btn>
        <a v-if="!item.edit" :href="item.presignedUrl"
           class="type link text-left text-decoration-none">
          {{ item.editableNameCopy }}
        </a>
        <v-text-field
            v-else
            hide-details
            label="Filename"
            class="my-2 text-field"
            v-model="item.editableName"
        ></v-text-field>
      </v-col>
      <v-col cols="4" class="text-center px-1 attachment-info">{{ item.uploadedBy ? `${item.uploadedBy}, ` : ''}}{{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}</v-col>
      <v-col cols="2" class="text-right pa-0">
        <v-btn v-if="!item.edit" dense small text color="primary" class="px-0" @click="[item.edit = true, renderTicker++]">
          <v-icon>edit</v-icon>
        </v-btn>
        <v-btn v-if="item.edit" dense text color="primary" small class="px-0" @click="[item.edit = false, item.editableName = item.editableNameCopy, renderTicker++]">
          cancel
        </v-btn>
        <v-btn  v-if="item.edit" dense small text color="primary" class="px-0" @click="saveFilename(item)">
          <v-icon>save</v-icon>
        </v-btn>
        <v-btn small text color="primary" @click="startDelete(item)" class="px-0" v-if="!item.edit">
          <v-icon>delete</v-icon>
        </v-btn>
        <ConfirmationDialog
            :open-dialog="attachmentDeleteConfirm"
            @confirm="deleteAttachment"
            @close-dialog="closeDeleteDialog"

        >Are you sure you want to delete {{attachmentToDeleteName}}?</ConfirmationDialog>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {getFileIcon, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {deleteAttachment} from "@/services/attachmentService";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: "AttachmentsTable",
  components: {ConfirmationDialog},
  props: {
    attachments: Array,
    displayType: Object,
    showNonPrimaryDocs: Boolean
  },
  data () {
    return {
      renderTicker: 0,
      attachmentDeleteConfirm: false,
      attachmentToDelete: {}
    }
  },
  computed: {
    drillDownAttachments () {
      if (this.displayType === null) {
        return []
      } else {
        if (this.showNonPrimaryDocs) {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId)
        }
        else {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId && a.main)
        }
      }
    },
    attachmentToDeleteName(){
      return this.attachmentToDelete ? this.attachmentToDelete.filename : ""
    }
  },
  methods: {
    getIconForFile (item) {
      return getFileIcon(item)
    },
    async saveFilename(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let newFileName = item.editableName
        if(item.fileExtension) {
          newFileName += '.' + item.fileExtension
        }
        item.filename = newFileName
        const {data, status} = await putRequest(`/attachment/${item.id}`, item)
        item.editableNameCopy = item.editableName
        item.presignedUrl = data.presignedUrl
        item.edit = false
        this.renderTicker++;
        this.snackbar = getSnackbar('SUCCESS', 'Saved Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    deleteAttachment: async function () {
      const id = this.attachmentToDelete.id
      try {
        await deleteAttachment(id)
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
    startDelete(item){
      this.attachmentToDelete = item
      this.attachmentDeleteConfirm = true
    },
    closeDeleteDialog() {
      this.attachmentDeleteConfirm = false
      this.attachmentToDelete = null
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

.text-left{
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
