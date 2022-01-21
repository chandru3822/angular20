<template>
  <small v-if="!drillDownAttachments.length" small >No attachments available</small>

  <v-simple-table v-else dense :key="renderTicker">
    <tbody>
    <tr v-for="item in drillDownAttachments"  class="text-left"  :class="{'primary-row': item.main}" :key="item.processStepId">
      <td class="text-left">
        <v-btn
            width="100%"
            icon
            text
            :href="item.presignedUrl" class="type">
          <v-icon large color="grey">
            {{ getIconForFile(item) }}
          </v-icon>
        </v-btn>
      </td>
      <td class="type text-left">
        <a v-if="!item.edit" :href="item.presignedUrl"
           class="type link text-center">
          {{ item.editableName }}
        </a>
        <v-text-field
            v-else
            hide-details
            label="Filename"
            class="my-2"
            v-model="item.editableName"
        ></v-text-field>
      </td>
      <td>{{ item.uploadedBy ? `${item.uploadedBy}, ` : ''}}{{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}</td>
      <td class="text-right">
        <v-btn small text v-if="!item.edit" @click="[item.edit = true, renderTicker++]">
          <v-icon>edit</v-icon>
        </v-btn>
        <v-btn small text v-if="item.edit" @click="saveFilename(item)">
          <v-icon>save</v-icon>
        </v-btn>
        <v-btn small text v-if="item.edit" @click="[item.edit = false, renderTicker++]">
          cancel
        </v-btn>
        <v-dialog
            v-model="item.deleteConfirm"
            width="500">
          <template #activator="{ on }">
            <v-btn small text v-on="on">
              <v-icon>delete</v-icon>
            </v-btn>
          </template>
          <v-card>
            <v-card-title
                class="text-h5 grey lighten-2"
                primary-title>
              Confirm
            </v-card-title>

            <v-card-text class="pt-4">
              Are you sure you want to delete <strong>{{item.filename}}</strong>?
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn
                  @click="item.deleteConfirm = false">
                No
              </v-btn>
              <v-btn
                  color="primaryCustom"
                  text
                  @click="[item.archived = true, deleteAttachment(item.id)]">
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </td>
    </tr>
    </tbody>
  </v-simple-table>
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

</style>
