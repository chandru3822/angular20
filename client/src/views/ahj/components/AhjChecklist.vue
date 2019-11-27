<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-checklist">
  <v-card>
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{title}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px">
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
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" color="brRed" small
               @click="deleteItem" class="white--text py-1 px-2">
          Delete
        </v-btn>
        <v-btn @click="saveItem" color="primaryButton" class="white--text py-1 px-2"
               :disabled="checklistItem.description === ''" small>
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </form>
    <draggable v-model="checklistItemsCopy" group="checklistGroup"
               @start="drag=true" @end="reorderChecklistItems">
      <v-list v-for="item in checklistItemsCopy"
              :key="item.id">
        <v-list-item v-show="checklistItemsCopy.length > 0"
                     class="grab" :title="item.description">
          <v-list-item-action>
            <v-icon small class="mr-3" @click="editItem(item)">edit</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title v-text="item.description">
            </v-list-item-title>
          </v-list-item-content>
          <v-list-item-action>
            <v-icon>drag_handle</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </draggable>
    <div class="empty-list"
         v-show="checklistItemsCopy.length < 1">
      This checklist doesn't have any items
    </div>
  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import draggable from 'vuedraggable'

  export default {
    name: "AhjChecklist",
    components: {
      draggable
    },
    props: {
      title: {
        type: String
      },
      checklistTypeId: {
        type: Number
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
      checklistItems: {
        type: Array
      }
    },
    data () {
      return {
        checklistItem: {
          id: null,
          type: this.type,
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
        this.checklistItem.checklistTypeId = this.checklistTypeId

        if (this.addMode) {
          this.checklistItem.displayOrder = this.checklistItemsCopy.length
          const {data} = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist`, this.checklistItem, 'blueraven')
          this.checklistItemsCopy.push(cloneDeep(data))
          this.addMode = false
        } else {
          const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist/${this.checklistItem.id}`, this.checklistItem, 'blueraven')
          let updatedItemIndex = this.checklistItemsCopy.findIndex(i => i.id === data.id)
          this.checklistItemsCopy[updatedItemIndex].description = data.description
          this.editMode = false
        }
      },
      async deleteItem() {
        await deleteRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/checklist/${this.checklistItem.id}`, 'blueraven')
        let deletedItemIndex = this.checklistItemsCopy.findIndex(i => i.id === this.checklistItem.id)
        this.checklistItemsCopy.splice([deletedItemIndex], 1)
        this.editMode = false
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
  }
</style>
