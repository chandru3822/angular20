<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-note-template">
  <v-card class="mb-3 pb-1">
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold">
        Note Templates
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px" v-if="userCanEdit">
        <v-icon v-show="!addMode && !editMode"
                @click="addNoteTemplate" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <form class="note-template-edit-ctrls pa-4"
          ref="noteTemplateForm" v-show="addMode || editMode">
      <v-text-field label="Title" filled
                    v-model="noteTemplate.title"
      ></v-text-field>
      <v-textarea required label="Note" auto-grow filled
                  v-model="noteTemplate.note">
      </v-textarea>
      <div class="note-template-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" color="brRed" small
               @click="deleteNoteTemplate" class="white--text py-1 px-2">
          Delete
        </v-btn>
        <v-btn @click="saveNoteTemplate" color="primaryButton" class="white--text py-1 px-2"
               :disabled="noteTemplate.note === ''" small>
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </form>
    <v-card v-show="noteTemplatesCopy.length > 0" class="ma-4"
            v-for="(noteTemplate, index) in noteTemplatesCopy"
            :key="noteTemplate.id">
      <v-card-title class="primaryCustom white--text font-weight-bold title-with-icon">
        {{ noteTemplate.title }}
        <v-icon class="white--text" title="Copy text to clipboard"
                @click="copyText(index)">file_copy</v-icon>
      </v-card-title>
      <v-card-text class="mt-4 note-text">
        <v-icon small v-if="userCanEdit" @click="editNoteTemplate(noteTemplate)">edit</v-icon>
        <span :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
          {{ noteTemplate.note }}
        </span>
      </v-card-text>
    </v-card>
    <div class="empty-list" v-show="noteTemplatesCopy.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      No note templates found
    </div>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import Snackbar from '@/components/Snackbar'
  import { AppMutations } from '@/stores/AppStore'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: "AhjNoteTemplates",
    components: {
      Snackbar
    },
    props: {
      inspectionId: {
        type: Number
      },
      userCanEdit: {
        type: Boolean
      },
      ahjId: {
        type: Number
      },
      noteTemplates: {
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
        snackbar: {},
        noteTemplate: {
          id: null,
          title: null,
          note: null
        },
        addMode: false,
        editMode: false,
        noteTemplatesCopy: this.noteTemplates
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      addNoteTemplate() {
        this.editMode = false
        this.addMode = true
        this.noteTemplate.title = ''
        this.noteTemplate.note = ''
      },
      editNoteTemplate(noteTemplate) {
        this.addMode = false
        this.editMode = true
        this.noteTemplate = Object.assign({}, noteTemplate)
      },
      async saveNoteTemplate() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (this.addMode) {
          try {
            const {data} = await postRequest(`/ahj/${this.ahjId}/inspection/${this.inspectionId}/noteTemplates`, this.noteTemplate, 'blueraven')
            this.noteTemplatesCopy.push(cloneDeep(data))
            this.snackbar = getSnackbar('SUCCESS', 'Note template added')
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding note template')
          }
          this.addMode = false
        } else {
          try {
            const {data} = await putRequest(`/ahj/${this.ahjId}/inspection/${this.inspectionId}/noteTemplates/${this.noteTemplate.id}`, this.noteTemplate, 'blueraven')
            let updatedNoteTemplateIndex = this.noteTemplatesCopy.findIndex(i => i.id === data.id)
            this.noteTemplatesCopy[updatedNoteTemplateIndex].title = data.title
            this.noteTemplatesCopy[updatedNoteTemplateIndex].note = data.note
            this.snackbar = getSnackbar('SUCCESS', 'Note template updated')
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating note template')
          }
          this.editMode = false
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async deleteNoteTemplate() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await putRequest(`/ahj/${this.ahjId}/inspection/${this.inspectionId}/noteTemplates/${this.noteTemplate.id}/archive`, null, 'blueraven')
          let deletedNoteTemplateIndex = this.noteTemplatesCopy.findIndex(i => i.id === this.noteTemplate.id)
          this.noteTemplatesCopy.splice(deletedNoteTemplateIndex, 1)
          this.snackbar = getSnackbar('SUCCESS', 'Note template deleted')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting note template')
        }
        this.editMode = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      copyText(index) {
        let notes = document.getElementsByClassName('note-text')
        let text = notes[index].lastChild // Grab the node of the element
        let selection = window.getSelection() // Get the Selection object
        let range = document.createRange() // Create a new range
        range.selectNodeContents(text) // Select the content of the node from line 1
        selection.removeAllRanges() // Delete any old ranges
        selection.addRange(range) // Add the range to selection
        document.execCommand('copy') // Execute the command
        selection.removeAllRanges() // Delete any old ranges
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link,
  .note-template {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .cancel-link:hover {
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
  .note-template-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  .title-with-icon {
    font-size: 0.85em !important;
    display: flex;
    justify-content: space-between;
    .v-icon {
      cursor: pointer;
    }
  }
  .note-text {
    color: var(--v-primaryText-base) !important;
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    .v-icon {
      margin: 5px 7px 0 0 !important;
      max-width: 30px;
      height: 30px;
      padding: 5px;
      border: 1px solid var(--v-primary-base) !important;
      border-radius: 3px;
      display: flex;
      justify-content: center;
      cursor: pointer;
      &:hover {
        background-color: #ddd;
      }
    }
    span {
      width: 100%;
    }
  }
  .empty-list {
    padding: 20px;
    font-size: 0.85em;
  }
</style>
