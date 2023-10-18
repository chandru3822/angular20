<template>
  <v-container class="custom-field-group-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          Error Deleting Project Status
        </v-card-title>

        <v-card-text>
          You cannot delete a project status that is currently in use.
          <v-list>
            <v-list-item-content v-if="fieldsInUse.statusInUseByProjects">
              Status is in use by various Projects
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByActions">
              Status is in use by various Process Step Actions
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByProcessStepRequirements">
              Status is in use by various Process Step Requirements
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByEventRequirements">
              Status is in use by various Process Step Event Requirements
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primary"
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
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Project Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="primary lighten-9">
          <h3>Add Project Status</h3>
          <v-text-field label="Project Status" v-model="newType.projectStatusType">
          </v-text-field>
          <v-autocomplete single-line
                    :items="rootStatusTypes"
                    v-model="newType.projectStatusTypeId"
                    item-value="id"
                    label="Select a Category"
                    item-text="projectStatusType"
                    attach></v-autocomplete>
          <v-btn color="primary" :disabled="!newType.projectStatusTypeId || !newType.projectStatusType" @click="saveNewType(newType)">Save</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterProjectStatuses()"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          :loading="companyStatusesLoading"
          :sort-by="['displayOrder']"
          :sort-desc="[false]"
          class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text color="primary" icon small class="handle" v-if="userCanEdit">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">
                {{item.projectStatusType}}
              </td>
              <td class="text-left">
                {{item.rootProjectStatusType}}
              </td>
              <td class="text-left">
                <input v-if="item.isDefault" type="checkbox" v-model="item.isDefault" disabled readonly>
              </td>
              <td class="text-left">
                <v-icon v-if="item.iconTag != null">{{item.iconTag}}</v-icon>
              </td>
              <td class="text-right">
                <v-tooltip left>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn icon color="primary" @click="copyToClipBoard(item.id)" v-bind="attrs"
                           v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                  </template>
                  <span>Project Status ID: {{item.id}}</span>
                  <div class="text-center">(click to copy)</div>
                </v-tooltip>
                <v-btn small text color="primary" :to="`/settings/projectStatus/${item.id}/components`">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" @click.stop="[itemToDelete=item, showDeleteDialog=true]">
                  <v-icon >delete</v-icon>
                </v-btn>
              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteType"
                                 @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this status type: <strong>{{toDeleteStatusType}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>


<script>
  import { Actions } from '@/store'
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
  import cloneDeep from 'lodash.clonedeep'
  import Sortable from 'sortablejs'

  import orderBy from 'lodash.orderby'
  import {getCompanyProjectStatusTypes, getProjectStatusTypes} from '@/services/projectStatusTypeService'
  import { handleHidingGlobalLoader, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

  export default {
    name: 'ProjectStatuses',
    mixins: [Vue2Filters.mixin],
    components: {
      ConfirmationDialog,
      draggable,
    },
    data () {
      return {
        snackbar: {},
        constants,
        statusTypes: [],
        rootStatusTypes: [],
        companyStatusesLoading: true,
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true },
          {text: 'Project Stage', value: 'projectStatusType', show: true},
          {text: 'Status', value: 'rootProjectStatusType', show: true},
          {text: 'Initial', value: 'initial', show: true},
          {text: 'Icon', value: 'icon', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addNew: false,
        newType: {},
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
        onEnd({ newIndex, oldIndex }) {
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
      toDeleteStatusType(){
        return this.itemToDelete ? this.itemToDelete.projectStatusType : ''
      }
    },
    methods: {
      async saveOrderChanges (types) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/projectStatus/companyStatuses`, types)
          this.snackbar = getSnackbar('SUCCESS', 'Status Types Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Status Type Changes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyStatusTypes () {
        this.companyStatusesLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getCompanyProjectStatusTypes()
          this.statusTypes = data
          this.companyStatusesLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveNewType(type) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/projectStatus/company`, type)

          // add it to the records already on the screen
          this.statusTypes.push(data)
          this.statusTypes = orderBy(this.statusTypes, [s => s.projectStatusType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}

          this.snackbar = getSnackbar('SUCCESS', 'Project Status Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Project Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProjectStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getProjectStatusTypes()
          this.rootStatusTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType () {
        const item = this.itemToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/projectStatus/companyStatus/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
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
      filterProjectStatuses () {
        return this.statusTypes.filter(s => { return !s.archived})
      },
      copyToClipBoard(textValue){
        navigator.clipboard.writeText(textValue);
        this.snackbar = getSnackbar('SUCCESS', 'Copied text to clipboard')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      },
      closeDeleteDialog() {
        this.showDeleteDialog = false
        this.itemToDelete = null
      }
    },
    async created () {
      this.getCompanyStatusTypes()
      this.getProjectStatusTypes()
    }
  }
</script>

<style scoped lang="scss">
  .status-icon {
    margin-top: 15px;
    max-width: 50px;
    height: auto;
  }

  .status-icon-grid {
    margin-top: 5px;
    max-width: 40px;
    height: auto;
  }
</style>
