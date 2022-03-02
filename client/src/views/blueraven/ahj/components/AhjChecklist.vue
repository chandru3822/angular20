<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-checklist">
  <v-card>
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{title}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px" v-if="userCanEdit">
        <v-icon v-show="!addMode && !editMode"
                @click="addItem" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <form class="checklist-item-edit-ctrls px-3"
          ref="checklistForm" v-show="addMode || editMode">
      <v-textarea required label="Description" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="checklistItem.description">
      </v-textarea>
      <div class="checklist-btns">
        <a @click="hideCtrls" class="cancel-link mr-3">Cancel</a>
        <confirm-delete-dialog
            label="this checklist item"
            :item-to-delete="checklistItem.description"
            @confirm-delete="[deleteItem(), checklistItem.deleteConfirm = false]"
            textbutton>
        </confirm-delete-dialog>
        <v-btn @click="saveItem" color="primaryButton" class="white--text py-1 px-2"
               :disabled="checklistItem.description === ''" small>
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </form>
    <draggable v-model="checklistItemsCopy" group="checklistGroup"
               @start="drag=true" @end="reorderChecklistItems">
      <v-list v-for="(item,idx) in checklistItemsCopy" :key="item.id" class="py-0">
        <v-divider v-if="idx !== 0"></v-divider>
        <v-list-item v-show="checklistItemsCopy.length > 0"
                     class="grab" :title="item.description">
          <v-list-item-action>
            <v-icon small v-if="userCanEdit" class="mr-3" @click="editItem(item)">edit</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <pre class="app-pre-wrapper">
                 {{item.description}}
            </pre>
          </v-list-item-content>
          <v-list-item-action>
            <v-icon v-if="userCanEdit">drag_handle</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </draggable>
    <div class="empty-list" v-show="checklistItemsCopy.length < 1"
         :style="{'font-size': isNested ? '0.95em !important' : '0.85em !important'}">
      This checklist doesn't have any items
    </div>


  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import draggable from 'vuedraggable'

  import { AppMutations } from '@/stores/AppStore'
  import { putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

  export default {
    name: "AhjChecklist",
    components: {
      ConfirmDeleteDialog,
      draggable,
    },
    props: {
      title: {
        type: String
      },
      checklistTypeId: {
        type: Number
      },
      isNested: {
        type: Boolean,
        default: true
      },
      itemId: {
        type: Number
      },
      itemType: {
        type: String
      },
      ahjId: {
        type: Number
      },
      userCanEdit: {
        type: Boolean
      },
      checklistItems: {
        type: Array,
        default: () => []
      }
    },
    data () {
      return {
        snackbar: {},
        checklistItem: {
          id: null,
          checklistTypeId: this.checklistTypeId,
          description: null
        },
        addMode: false,
        editMode: false,
        drag: false,
        checklistItemsCopy: this.checklistItems
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      reorderChecklistItems() {
        this.drag = false
        for(let i = 0; i < this.checklistItemsCopy.length; i++) {
          this.checklistItem = this.checklistItemsCopy[i]
          this.checklistItem.displayOrder = i
          this.saveItem()
        }
      },
      addItem() {
        this.editMode = false
        this.addMode = true
        this.checklistItem.description = ''
      },
      editItem(item) {
        this.addMode = false
        this.editMode = true
        this.checklistItem = Object.assign({}, item)
      },
      async saveItem() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.checklistItem.checklistTypeId = this.checklistTypeId

        if (this.addMode) {
          this.checklistItem.displayOrder = this.checklistItemsCopy.length

          try {
            let res = null
            if (this.itemType === 'utility') {
              res = await postRequest(`/ahjUtility/${this.itemId}/checklist`, this.checklistItem, 'blueraven')
            } else {
              res = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist`, this.checklistItem, 'blueraven')
            }
            this.checklistItemsCopy.push(cloneDeep(res.data))
            this.snackbar = getSnackbar('SUCCESS', 'Checklist item added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error adding checklist item')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          this.addMode = false
        } else {
          try {
            let res = null
            if (this.itemType === 'utility') {
              res = await putRequest(`/ahjUtility/${this.itemId}/checklist/${this.checklistItem.id}`, this.checklistItem, 'blueraven')
            } else {
              res = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist/${this.checklistItem.id}`, this.checklistItem, 'blueraven')
            }
            let updatedItemIndex = this.checklistItemsCopy.findIndex(i => i.id === res.data.id)
            this.checklistItemsCopy[updatedItemIndex].description = res.data.description
            this.snackbar = getSnackbar('SUCCESS', 'Checklist item updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating checklist item')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          this.editMode = false
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async deleteItem() {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          if (this.itemType === 'utility') {
            await putRequest(`/ahjUtility/checklist/${this.checklistItem.id}/archive`, null, 'blueraven')
          } else {
            await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist/${this.checklistItem.id}/archive`, null, 'blueraven')
          }
          let deletedItemIndex = this.checklistItemsCopy.findIndex(i => i.id === this.checklistItem.id)
          this.checklistItemsCopy.splice(deletedItemIndex, 1)
          this.snackbar = getSnackbar('SUCCESS', 'Checklist item deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting checklist item')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.editMode = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link,
  .checklist-item {
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
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
  }
  .v-list-item__title {
    font-size: 0.95em !important;
    text-align: left;
    max-width: 525px;
  }
  .checklist-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  .empty-list {
    padding: 20px;
    font-size: 0.95em;
    text-align: left;
  }
  .ahj-checklist-item {
    border-bottom: solid 1px #6B777D;
  }
</style>
