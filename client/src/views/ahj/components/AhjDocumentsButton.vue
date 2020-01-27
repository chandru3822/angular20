<template id="ahj-documents-button">
  <div>
    <div id="documents-btn" :title="title" @click="documentsDialog = true"
         :class="[{'mt-4': !small}, {'ml-2': !small}, 'clickable']">
      <v-icon v-if="!small">insert_drive_file</v-icon>
      <v-icon v-if="small" small style="margin-top: -10px">insert_drive_file</v-icon>
    </div>

    <v-dialog v-model="documentsDialog" max-width="600px">
      <v-card class="pt-4 pb-2">
        <v-card-text class="px-4 pb-0">
          <AhjDocument :title="title"
                       :documentTypeId="documentTypeId"
                       :sourceId="sourceId"
                       :ahjId="ahjId"
                       :documents="documents"
          ></AhjDocument>
        </v-card-text>
        <v-card-actions class="flex-display justify-end px-4 pt-0">
          <v-btn @click="documentsDialog = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
  import AhjDocument from './AhjDocuments'

  export default {
    name: "AhjDocumentsButton",
    components: {
      AhjDocument
    },
    props: {
      title: {
        type: String
      },
      documentTypeId: {
        type: Number
      },
      sourceId: {
        type: Number
      },
      ahjId: {
        type: Number
      },
      documents: {
        type: Array,
        default: () => []
      },
      small: {
        type: Boolean,
        default: false
      }
    },
    data () {
      return {
        documentsDialog: false,
        documentsCopy: this.documents
      }
    }
  }
</script>

<style scoped lang="scss">
  #documents-btn {
    height: 16px !important;
  }
</style>
