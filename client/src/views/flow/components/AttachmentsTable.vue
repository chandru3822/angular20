<template>
  <small v-if="!drillDownAttachments.length" small class="pl-3">No attachments available</small>

  <v-container v-else dense :key="renderTicker">
    <v-row v-for="item in drillDownAttachments"  class="text-left attachment"  :class="{'primary-row': item.main}" :key="item.processStepId">
      <v-col cols="5" class="text-left pa-1">
        <v-btn
            icon
            text
            :href="item.presignedUrl" class="type">
          <v-icon large color="grey">
            {{ getIconForFile(item) }}
          </v-icon>
        </v-btn>
        <a v-if="!item.edit" :href="item.presignedUrl"
           class="type link text-left text-decoration-none">
          {{ item.editableName }}
        </a>
        <v-text-field
            v-else
            hide-details
            label="Filename"
            class="my-2 text-field"
            v-model="item.editableName"
        ></v-text-field>
      </v-col>
      <v-col small class="text-center px-1 attachment-info">{{ item.uploadedBy ? `${item.uploadedBy}, ` : ''}}{{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}</v-col>
      <v-col class="text-right pa-0">
        <v-btn v-if="!item.edit" dense small text class="px-0" @click="[item.edit = true, renderTicker++]">
          <v-icon>edit</v-icon>
        </v-btn>
        <v-btn v-if="item.edit" dense text small class="px-0" @click="[item.edit = false, renderTicker++]">
          cancel
        </v-btn>
        <v-btn  v-if="item.edit" dense small text class="px-0" @click="saveFilename(item)">
          <v-icon>save</v-icon>
        </v-btn>
        <v-dialog
            v-model="item.deleteConfirm"
            width="400"
        class="albatross-body-1">
          <template #activator="{ on }">
            <v-btn small text v-on="on" class="px-0" v-if="!item.edit">
              <v-icon>delete</v-icon>
            </v-btn>
          </template>
          <v-card>
            <v-card-text class="pt-4">
              Are you sure you want to delete {{item.filename}}?
            </v-card-text>
            <v-card-actions>
              <v-btn
                  class="elevation-0 text-capitalize"
                  @click="item.deleteConfirm = false">
                No
              </v-btn>
              <v-spacer></v-spacer>
              <v-btn
                  color="primaryCustom"
                  dark
                  class="elevation-0 text-capitalize"
                  @click="[item.archived = true, deleteAttachment(item.id)]">
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {getFileIcon, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {deleteAttachment} from "@/services/attachmentService";

export default {
  name: "AttachmentsTable",
  props: {
    attachments: Array,
    displayType: Object,
    showNonPrimaryDocs: Boolean
  },
  data () {
    return { renderTicker: 0 }
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
    deleteAttachment: async function (id) {
      await deleteAttachment(id)
    },
  }
}
</script>

<style scoped>
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
  color: #5E636D;

}

.primary-row{
  background-color: #ebf5ff !important;
}

</style>
