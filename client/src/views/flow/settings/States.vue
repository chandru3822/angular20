<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">States</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanAdd" @click="[addNew = !addNew, selectedState = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add State to Company</h3>
          <div class="mb-3">
            <v-autocomplete
                v-model="selectedState"
                :items="states"
                label="Select a state to use"
                item-text="state"
                item-value="id"
                return-object
                attach
            ></v-autocomplete>
          </div>
          <v-btn :disabled="!selectedState"
                 color="primary" class="white--text mr-2"
                 @click="saveCompanyState(selectedState, true)">
            Save
          </v-btn>
          <v-btn text color="primary" @click="[addNew = !addNew, selectedState = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filterStates"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterStates.indexOf(item) % 2}">
              <h3>Edit State</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.mapLatitude"
                              label="Map Latitude" />
                <v-text-field text v-model="item.mapLongitude"
                              label="Map Longitude" />
                <v-text-field text v-model="item.mapZoom"
                              label="Map Zoom" />
                <label>Active:</label>
                <input class="ml-3" type="checkbox" v-model="item.active">
              </div>
              <v-btn :disabled="!item.mapLatitude || !item.mapLongitude || !item.mapZoom"
                     color="primary" class="white--text mr-2"
                     @click="saveCompanyState(item, false)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': filterStates.indexOf(item) % 2}">
              <td class="text-left">{{ item.state }}</td>
              <td class="text-left">{{ item.abbreviation }}</td>
              <td class="text-left">
                <input type="checkbox" v-model="item.active" disabled readonly>
              </td>
              <td>
                <v-btn small text color="primary" v-if="userCanEdit && !expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" v-if="userCanEdit && expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-btn small text color="primary" v-if="userCanDelete" @click="stateToDelete=item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!stateToDelete" @confirm="deleteCompanyState" @close-dialog="stateToDelete=null">
      Are you sure you want to delete this state: <strong>{{stateToDeleteName}}</strong>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getAvailableStates} from '@/services/stateService'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import orderBy from "lodash.orderby";
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
  import ConfirmationDialog from "@/ConfirmationDialog";

  export default {
    name: 'CompanyStates',
    components: {ConfirmationDialog, ConfirmDeleteDialog},
    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        levels: [],
        companyStates: [],
        selectedState: {},
        states: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
        selectedCompanyStateId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'State', value: 'state', show: true },
          { text: 'Abbreviation', value: 'abbreviation', show: true },
          { text: 'Active', value: 'active', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: [],
        stateToDelete: null
      }
    },
    computed:{
      stateToDeleteName() {
        return this.stateToDelete ? this.stateToDelete.state : ''
      },
      filterStates () {
        return orderBy(this.companyStates.filter(cs => { return !cs.archived}), [cs => cs.state.toLowerCase()])
      },
    },
    async created () {
      this.getCompanyStates()
      this.getStates()
    },
    methods: {
      async saveCompanyState(ol, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            ...ol
          }
          params.stateId = ol.id
          params.id = isNew ? null : params.id
          const {data, status} = await putRequest(`/state/saveCompanyState`, params)
          if(isNew){
            this.companyStates.push(data)
            this.addNew = false
            this.selectedState = {}
            this.snackbar = getSnackbar('SUCCESS', 'State Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'State Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding State' : 'Error Updating State')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyStates() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/state/company`)
          this.companyStates = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Company States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStates() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getAvailableStates()
          this.states = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCompanyState() {
        const companyState = this.stateToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/state/companyState/${companyState.id}`)
          companyState.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'State Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting State')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.stateToDelete = null
      },

    }
  }
</script>
