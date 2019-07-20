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
    <div class="checklist-item-edit-ctrls px-3"
         v-show="addMode || editMode">
      <v-textarea required label="Description" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="checklistItem.description">
      </v-textarea>
      <div class="checklist-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" color="brRed"
               @click="deleteItem" class="white--text">
          Delete
        </v-btn>
        <v-btn @click="saveItem" color="primaryButton" class="white--text"
               :disabled="checklistItem.description === ''">
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </div>
    <draggable v-model="checklistItems"
               group="checklistGroup" @start="drag=true" @end="drag=false">
      <v-list v-for="item in checklistItems"
              :key="item.id">
        <v-list-item v-show="checklistItems.length > 0"
                     class="grab" :title="item.description">
          <v-list-item-action>
            <v-icon small class="mr-3" @click="editItem(item)">edit</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title v-text="item.description"
                               style="font-size: 0.95em !important">
            </v-list-item-title>
          </v-list-item-content>
          <v-list-item-action>
            <v-icon>drag_handle</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </draggable>
    <div class="empty-list"
         v-show="checklistItems.length < 1">
      This checklist doesn't have any items
    </div>
  </v-card>
</template>

<script>
  import { deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import draggable from 'vuedraggable'

  export default {
    name: "AhjChecklist",
    components: {
      draggable
    },
    props: {
      title: {
        type: String,
        default: null
      },
      typeId: {
        type: Number,
        default: null
      },
      permitId: {
        type: Number,
        default: null
      },
      checklistItems: {
        type: Array,
        default: null
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
        editMode: false
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      addItem() {
        this.editMode = false
        this.checklistItem.description = ''
        this.addMode = true
      },
      editItem(item) {
        this.addMode = false
        this.checklistItem = Object.assign({}, item)
        this.editMode = true
      },
      async deleteItem() {
        await deleteRequest(`/api/v1/company/blueraven/ahj/${this.permitId}/permit/${this.checklistItem.id}`)
        this.editMode = false
      },
      async saveItem() {
        if (this.addMode) {
          await postRequest(`/api/v1/company/blueraven/ahj/${this.permitId}/permit`, this.checklistItem)
          this.addMode = false
        } else {
          await putRequest(`/api/v1/company/blueraven/ahj/${this.permitId}/permit`, this.checklistItem)
          this.editMode = false
        }
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