<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Project Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="rowShadeCustom">
          <h3>Add Project Status</h3>
          <v-text-field label="Project Status" v-model="newType.projectStatusType">
          </v-text-field>
          <v-select single-line
                    :items="rootStatusTypes"
                    v-model="newType.projectStatusTypeId"
                    item-value="id"
                    label="Select a Category"
                    item-text="projectStatusType"></v-select>
          <v-btn :disabled="!newType.projectStatusTypeId || !newType.projectStatusType" @click="saveType(newType, true)">Save</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterProjectStatuses()"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-text-field v-if="selectedStatusTypeId === item.id" v-model="item.projectStatusType">
                </v-text-field>
                <div v-else>{{item.projectStatusType}}</div>
              </td>
              <td class="text-left">
                <v-select v-if="selectedStatusTypeId === item.id"
                          single-line
                          :items="rootStatusTypes"
                          v-model="item.projectStatusTypeId"
                          item-value="id"
                          label="Select a Category"
                          item-text="projectStatusType"></v-select>
                <div v-else>{{item.rootProjectStatusType}}</div>
              </td>
              <td class="text-right">
                <v-icon v-if="selectedStatusTypeId === item.id && userCanEdit" @click="saveType(item, false)">save</v-icon>
                <v-icon v-else-if="userCanEdit" @click="selectedStatusTypeId = item.id">edit</v-icon>
                <v-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                          v-model="item.deleteConfirm" width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this status type: <strong>{{ item.projectStatusType }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="[item.archived = true, deleteType(item)]">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'

  import orderBy from 'lodash.orderby'
  import {getCompanyProjectStatusTypes, getProjectStatusTypes} from '@/services/projectStatusTypeService'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ProjectStatuses',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        constants,
        statusTypes: [],
        rootStatusTypes: [],
        headers: [
          {text: 'Project Status', value: 'projectStatusType', show: true},
          {text: 'Category', value: 'rootProjectStatusType', show: true},
          {text: '', value: 'icons', show: true},
        ],
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
      async getCompanyStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyProjectStatusTypes()
          this.statusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProjectStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getProjectStatusTypes()
          this.rootStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteType (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/project/companyStatus/${item.id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Status Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveType (type, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/project/companyStatus`, type)

          if(isNew) {
            // add it to the records already on the screen
            this.statusTypes.push(data)
            this.statusTypes = orderBy(this.statusTypes, [s => s.projectStatusType.toLowerCase()])

            // reset the new process fields
            this.addNew = false
            this.newType = {}
          }
          this.snackbar = getSnackbar('SUCCESS', 'Project Status Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Project Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProjectStatuses () {
        return this.statusTypes.filter(s => { return !s.archived})
      },
    },
    async created () {
      this.getCompanyStatusTypes()
      this.getProjectStatusTypes()
    }
  }
</script>

<style scoped lang="scss">

</style>
