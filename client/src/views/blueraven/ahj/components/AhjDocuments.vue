<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-documents">
  <v-card class="mb-4">
    <v-toolbar class="primary">
      <v-toolbar-title class="white--text font-weight-bold"
                       :title="title">
        {{ title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <label class="button" @click="$refs.fileInput.value = ''" v-if="userCanEdit">
        <v-icon class="white--text" style="cursor: pointer">add</v-icon>
        <input type="file" style="display: none" ref="fileInput" @input="saveDocument($event.target.files)">
      </label>
    </v-toolbar>
    <v-list v-show="documents.length > 0"
            v-for="document in documents"
            :key="document.id">
      <v-list-item :title="document.filename">
        <v-list-item-content>
          <v-list-item-title :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
            <a :href="document.presignedUrl" download class="list-document">{{document.filename}}</a>
          </v-list-item-title>
        </v-list-item-content>
        <v-list-item-action>
          <v-icon small color="primary" v-if="userCanEdit" class="mr-3" @click="deleteDocument(document.id)">delete</v-icon>
        </v-list-item-action>
      </v-list-item>
    </v-list>
    <div class="empty-list" v-show="documents.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      No documents uploaded
    </div>

  </v-card>
</template>

<script>
  import { deleteRequest, getSnackbar } from '@/helpers/helpers'
  import { Actions } from '@/store'
  import { AppMutations } from '@/stores/AppStore'


  export default {
    name: "AhjDocuments",
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
      userCanEdit: {
        type: Boolean
      },
      ahjId: {
        type: Number
      },
      documents: {
        type: Array,
        default: () => []
      },
      isNested: {
        type: Boolean,
        default: false
      }
    },

    data () {
      return {
        snackbar: {}
      }
    },
    methods: {
      async saveDocument() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: this.$refs.fileInput.files[0],
            attachmentTypeId: this.documentTypeId,
            sourceId: this.sourceId,
            deleteFirst: false,
            callback: async (document) => {
              this.documents.push(document)
              this.snackbar = getSnackbar('SUCCESS', 'Successfully uploaded document')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error uploading document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async deleteDocument(documentId) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await deleteRequest(`/attachment/${documentId}`)
          let deletedDocumentIndex = this.documents.findIndex(i => i.id === documentId)
          this.documents.splice([deletedDocumentIndex], 1)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully deleted document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting document')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    font-size: 1em !important;
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
    text-align: left;
  }
</style>
