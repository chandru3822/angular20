<template>
  <v-container class="custom-field-group-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          Error Event Status
        </v-card-title>

        <v-card-text>
          You cannot delete an Event Status that is currently in use.  Please remove from the following locations before deleting.
          <v-list v-for="(item, index) in fieldsInUse.events" :key="item.eventName">
            <v-list-item-content>
              Event
              <div v-if="item.eventName">{{ item.eventName }}</div>
            </v-list-item-content>
          </v-list>

          <v-list v-for="(item, index) in fieldsInUse.processStepEventActions" :key="index">
            <v-list-item-content>
              Process Step Event Action
              <div v-if="item.eventName">Event: {{ item.eventName }}</div>
              <div><span v-if="item.processStepName"> Process Step: {{ item.processStepName }}</span></div>
              <div><span v-if="item.actionName"> Action: {{ item.actionName }}</span></div>
            </v-list-item-content>
          </v-list>

          <v-list v-for="(item, index) in fieldsInUse.processStepEventRequirements" :key="index">
            <v-list-item-content>
              Process Step Event Requirement
              <div v-if="item.eventName">Event: {{ item.eventName }}</div>
              <div><span v-if="item.processStepName"> Process Step: {{ item.processStepName }}</span></div>
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primaryCustom"
            text
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newType = {}]"
                   v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="primary lighten-9">
          <h3>Add Event Status</h3>
          <v-text-field label="Event Status" v-model="newType.eventStatusType">
          </v-text-field>
          <v-autocomplete single-line
                          :items="rootStatusTypes"
                          v-model="newType.eventStatusTypeId"
                          item-value="id"
                          label="Select a Category"
                          item-text="eventStatusType"></v-autocomplete>
          <v-btn color="primary" :disabled="!newType.eventStatusTypeId || !newType.eventStatusType" @click="saveType(newType, true)">
            Save
          </v-btn>
        </v-card>
        <v-card class="square-card">
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-data-table
            :headers="headers"
            :items="filterEventStatuses()"
            :fixed-header="true"
            :expanded.sync="expanded"
            single-expand
            :search="search"
            :items-per-page="-1"
            hide-default-footer
            :sort-by="['displayOrder']"
            :sort-desc="[false]"
            class="elevation-1"
          >
            <template #expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4 text-left"
                  :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
                <h3 class="mb-3">Edit Status Type</h3>
                <v-text-field v-model="item.eventStatusType"
                              label="Status Type"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                ></v-text-field>
                <v-autocomplete
                  :items="rootStatusTypes"
                  v-model="item.eventStatusTypeId"
                  item-value="id"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Select a Category"
                  item-text="eventStatusType"></v-autocomplete>
                <v-btn color="primary" dark class="white--text"
                       :disabled="!item.eventStatusType || !item.eventStatusTypeId"
                       @click="saveType(item, false)">Save
                </v-btn>
              </td>
            </template>
            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td style="width: 50px">
                  <v-btn text icon small class="handle" v-if="userCanEdit">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">
                  {{ item.eventStatusType }}
                </td>
                <td class="text-left">
                  {{ item.rootEventStatusType }}
                </td>
                <td class="text-right">
                  <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                  <v-btn small text color="primary" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                         @click="[itemToDelete=item, showDeleteDialog=true]"
                  >
                    <v-icon>delete</v-icon>
                  </v-btn>
                </td>

              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteType"
                                 @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this status type: <strong>{{itemToDeleteEventStatusType}}</strong>?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>delete</template>
    </ConfirmationDialog>
  </v-container>
</template>


<script>
import {Actions} from '@/store'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'

import orderBy from 'lodash.orderby'
import {getCompanyEventStatusTypes, getEventStatusTypes} from '@/services/eventStatusTypeService'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "../../../ConfirmationDialog";

export default {
  name: 'EventStatuses',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ConfirmDeleteDialog,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      constants,
      search: '',
      statusTypes: [],
      expanded: [],
      rootStatusTypes: [],
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      savingTypeLogo: false,
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true},
        {text: 'Event Status', value: 'eventStatusType', show: true},
        {text: 'Status', value: 'rootEventStatusType', show: true},
        {text: '', value: 'icons', show: true},
      ],
      addNew: false,
      newType: {},
      selectedStatusTypeId: null,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      fieldsInUse: [],
      deleteError: false,
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  mounted() {
    let table = document.querySelector('tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({newIndex, oldIndex}) {
        const rowSelected = _self.statusTypes.splice(oldIndex, 1)[0]
        _self.statusTypes.splice(newIndex, 0, rowSelected)
        let statusTypesClone = cloneDeep(_self.statusTypes)
        statusTypesClone.forEach((g, idx) => {
          g.displayOrder = idx
        })
        _self.saveOrderChanges(statusTypesClone)
      }
    })
  },
  computed: {
    itemToDeleteEventStatusType() {
      return this.itemToDelete ? this.itemToDelete.eventStatusType : ''
    }
  },
  methods: {
    async saveOrderChanges(types) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/event/companyStatuses`, types)
        this.snackbar = getSnackbar('SUCCESS', 'Status Types Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Status Type Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile(item, files, attachmentTypeId, sourceId, sizeLimit) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          sizeLimit,
          attachmentTypeId,
          sourceId,
          callback: async (img, error) => {
            if (error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              item.icon = img

              this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachment(item) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_DELETE, {
          id: item.icon.id,
          callback: async (status) => {
            item.icon = {}
            // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
            this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyEventStatusTypes()
        this.statusTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getEventStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getEventStatusTypes()
        this.rootStatusTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteType() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/event/companyStatus/${item.id}`)
        this.fieldsInUse = [];
        this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.itemToDelete.archived = true
      } catch (e) {
        if (e.status === 400) {
          this.deleteError = true;
          this.fieldsInUse = e.data;
          this.snackbar = getSnackbar("ERROR", "Error Deleting Status");
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        else {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
      this.closeDeleteDialog()
    },
    async saveType(type, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/event/companyStatus`, type)

        if (isNew) {
          // add it to the records already on the screen
          this.statusTypes.push(data)
          this.statusTypes = orderBy(this.statusTypes, [s => s.eventStatusType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}
        } else {
          type.eventStatusTypeId = data.eventStatusTypeId
          type.eventStatusType = data.eventStatusType
          type.rootEventStatusType = data.rootEventStatusType
        }
        this.expanded = []
        this.selectedStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Event Status Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Event Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterEventStatuses() {
      return this.statusTypes.filter(s => {
        return !s.archived
      })
    },
    closeDeleteDialog() {
      this.showDeleteDialog = false
      this.itemToDelete = null
    }
  },
  async created() {
    this.getCompanyStatusTypes()
    this.getEventStatusTypes()
  }
}
</script>

<style scoped lang="scss">

</style>
