<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-documents">
  <v-card class="mb-4">
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold"
                       :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <label class="button" @click="$refs.fileInput.value = ''">
        <v-icon class="white--text" style="cursor: pointer">add</v-icon>
        <input type="file" style="display: none" ref="fileInput" @input="saveDocument($event.target.files)">
      </label>
    </v-toolbar>
    <v-list v-show="documents.length > 0"
            v-for="document in documents"
            :key="document.id">
      <v-list-item :title="document.filename">
        <v-list-item-content>
          <v-list-item-title>
            <a :href="document.presignedUrl" download class="list-document">{{document.filename}}</a>
          </v-list-item-title>
        </v-list-item-content>
        <v-list-item-action>
          <v-icon small class="mr-3" @click="deleteDocument(document.id)">delete</v-icon>
        </v-list-item-action>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="documents.length < 1">
      No documents uploaded
    </div>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-card>
</template>

<script>
  import { deleteRequest, getSnackbar } from '@/helpers/helpers'
  import { Actions } from '@/store'
  import { AppMutations } from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'

  export default {
    name: "AhjDocuments",
    props: {
      title: {
        type: String,
        default: null
      },
      documentTypeId: {
        type: Number,
        default: null
      },
      sourceId: {
        type: Number,
        default: null
      },
      ahjId: {
        type: Number,
        default: null
      },
      documents: {
        type: Array,
        default: null
      }
    },
    components: {
      Snackbar
    },
    data () {
      return {
        documentsCopy: this.documents,
        snackbar: {}
      }
    },
    methods: {
      async saveDocument() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: this.$refs.fileInput.files[0],
            attachmentSourceTypeId: this.documentTypeId,
            sourceId: this.sourceId,
            callback: async (document) => {
              this.documentsCopy.push(document)
              this.snackbar = getSnackbar('SUCCESS', 'Successfully Uploaded Document')
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading Document')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteDocument(documentId) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await deleteRequest(`/document/${documentId}`)
          let deletedDocumentIndex = this.documentsCopy.findIndex(i => i.id === documentId)
          this.documentsCopy.splice([deletedDocumentIndex], 1)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Document')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Document')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style scoped lang="scss">
  .flex-row-center {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
  }
  .list-document {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .list-document:hover {
    text-decoration: underline;
  }
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-text-field,
  .v-input ::v-deep label {
    font-size: 0.95em !important;
  }
  .v-list__item__title {
    font-size: 0.8em !important;
  }
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
  }
  .empty-list {
    padding: 20px;
    font-size: 0.85em;
  }
</style>
