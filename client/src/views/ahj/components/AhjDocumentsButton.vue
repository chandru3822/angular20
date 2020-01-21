<template id="ahj-documents-button">
  <div>
    <v-btn class="mt-3 ml-2 clickable" text icon
           @click="documentsDialog = true">
      <v-icon>insert_drive_file</v-icon>
    </v-btn>

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
          <v-btn @click="documentsDialog = !documentsDialog">Close</v-btn>
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
</style>
