<template>
  <v-container id="ps-container" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Process Step Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="rowShadeCustom">
            <v-text-field v-if="addNew"
                          v-model="newType.processStepStatusType"
                          placeholder="Enter a type"
                          label="Status Type">
            </v-text-field>
            <v-autocomplete single-line
                            :items="rootStatusTypes"
                            v-model="newType.processStepStatusTypeId"
                            item-value="id"
                            label="Select a Category"
                            item-text="processStepStatusType"
                            attach></v-autocomplete>
            <v-btn :disabled="!newType.processStepStatusTypeId || !newType.processStepStatusType" @click="addNewType">Save</v-btn>
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
              :items="filterProcessStepStatuses()"
              :fixed-header="true"
              :expanded.sync="expanded"
              single-expand
              :search="search"
              :footer-props="footerProps"
              :options.sync="options"
              class="elevation-1"
            >
              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
                  <h3 class="mb-3">Edit Status Type</h3>
                  <v-text-field v-model="item.processStepStatusType"
                                label="Status Type"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                  ></v-text-field>
                  <v-autocomplete
                    :items="filteredRootStatuses(item)"
                    v-model="item.processStepStatusTypeId"
                    item-value="id"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit || item.processStepStatusTypeId === 3"
                    label="Select a Category"
                    item-text="processStepStatusType"
                    attach></v-autocomplete>

                  <v-btn color="primary" dark class="white--text mr-4"
                         :disabled="!item.processStepStatusType || !item.processStepStatusTypeId"
                         @click="saveType(item, false)">Save</v-btn>
                </td>
              </template>
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.processStepStatusType}}
                  </td>
                  <td class="text-left">
                    {{item.rootProcessStepStatusType}}
                  </td>
                  <td class="text-right">
                    <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                    <confirm-delete-dialog
                        v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                        label="this status type: "
                        :item-to-delete="item.processStepStatusType"
                        @confirm-delete="[item.archived = true, deleteType(item)]"
                    ></confirm-delete-dialog>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'

  import orderBy from 'lodash.orderby'
  import {getStatusTypes, getCompanyStatusTypes} from '@/services/processStepStatusTypeService'
  import {handleHidingGlobalLoader, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

  export default {
    name: 'Statuses',
    components: {ConfirmDeleteDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        search: '',
        statusTypes: [],
        expanded: [],
        rootStatusTypes: [],
        headers: [
          {text: 'Process Step Status', value: 'processStepStatusType', show: true},
          {text: 'Category', value: 'rootProcessStepStatusType', show: true},
          {text: '', value: 'icons', show: true, sortable: false},
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        addNew: false,
        newType: {},
        selectedStatusTypeId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      }
    },
    computed: {
    },
    methods: {
      filteredRootStatuses() {
        return this.rootStatusTypes.filter(rst => rst.id !== 3)
      },
      async getCompanyStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getCompanyStatusTypes()
          this.statusTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getStatusTypes()
          this.rootStatusTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType (type) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/processStep/status/${type.id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewType () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newType.companyId = this.companyId
          const {data, status} = await postRequest(`/processStep/status`, this.newType)

          // add it to the records already on the screen
          this.statusTypes.push(data)
          this.statusTypes = orderBy(this.statusTypes, [s => s.processStepStatusType.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newType = {}
          this.snackbar = getSnackbar('SUCCESS', 'Status Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType (s) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/processStep/status`, s)
          this.selectedStatusTypeId = null
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Status Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProcessStepStatuses () {
        return this.statusTypes.filter(s => { return !s.archived})
      },
    },
    async created () {
      this.getCompanyStatusTypes()
      this.getStatusTypes()
    }
  }
</script>

<style lang="scss">
  #ps-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
</style>

<style scoped lang="scss">
  #ps-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
</style>
