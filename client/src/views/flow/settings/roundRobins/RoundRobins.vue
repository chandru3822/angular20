<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Round Robins</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newRoundRobin = {}, getCompanyTimezones()]" v-if="userCanAdd">
              <span v-if="!addNew">{{'Add New'}}</span>
              <span v-else>{{'Cancel'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Round Robin Name"
                tabindex=1
                v-model="newRoundRobin.roundRobinName"
            ></v-text-field>
            <v-text-field
                label="Distribution Time Frame (Days)"
                tabindex=1
                v-model="newRoundRobin.distributionTimeFrameDays"
            ></v-text-field>
            <v-autocomplete v-model="newRoundRobin.companyTimezoneId"
                            :items="companyTimezones"
                            label="Time Zone"
                            style="width: 200px;"
                            item-text="timezone"
                            item-value="id"
                            attach
            ></v-autocomplete>
            <v-btn color="primary" :disabled="!newRoundRobin.roundRobinName || !newRoundRobin.distributionTimeFrameDays || !newRoundRobin.distributionTimeFrameDays" @click="addRoundRobin" class="mb-3">Save</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search users and round robins"
                single-line
                hide-details
                @input="debounceSearch"
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterRoundRobins()"
              :fixed-header="true"
              :items-per-page="-1"
              disable-sort
              :loading="dataLoading"
              @click:row="goToRoundRobin"
              hide-default-footer
              :mobile-breakpoint="770"
              class="elevation-1 round-robin-table table-striped"
            >

              <template #header.roundRobinName="{ header }">
                <th class="pa-2 text-left">
                  {{ header.text }}
                  <v-text-field outlined
                                hide-details
                                class="filter-input"
                                v-model="nameSearch"
                                @input="filterResults()">
                  </v-text-field>
                </th>
              </template>

              <template #item="{ item, index }">
                <tr class="clickable" @click="goToRoundRobin(item)">
                  <td class="text-left">
                    {{ item.roundRobinName }}
                  </td>
                  <td class="text-left">{{item.distributionTimeFrameDays}}</td>
                  <td class="text-left">{{ item.schedulableFutureDays }}</td>

                  <td class="text-right">
                    <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary" @click.stop="goToRoundRobin(item)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="userCanDelete" icon :large="$vuetify.breakpoint.smAndDown" color="primary" @click.stop="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog="showDeleteDialog"
        @confirm="deleteRoundRobin"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this round robin: <strong>{{itemToDeleteName}}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import debounce from 'lodash.debounce'
  import cloneDeep from 'lodash.clonedeep'
  import {  handleHidingGlobalLoader, getRequestWithParams, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'RoundRobins',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        addNew: false,
        search: null,
        newRoundRobin: {},
        nameSearch: '',
        dataLoading: true,
        selectedRoundRobinId: null,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        roundRobins: [],
        masterRoundRobins: [],
        headers: [
          {text: 'Round Robin Name', value: 'roundRobinName', show: true},
          {text: 'Distribution Time Frame (Days)', value: 'distributionTimeFrameDays', show: true},
          {text: 'Schedulable Future Days', value: 'schedulableFutureDays', show: true},
          {text: '', value: 'icons', show: true},
        ],
        companyTimezones: [],
        showDeleteDialog: false,
        itemToDelete: null
      }
    },
    computed: {
      itemToDeleteName() {
        return this.itemToDelete ? this.itemToDelete.roundRobinName : '';
      }
    },
    methods: {
      async getCompanyTimezones() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/timezone`)
          this.companyTimezones = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Timezones')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      debounceSearch: debounce( function () {
        //don't allow search to be null - causes issues
        // this.search = this.search || ''
        this.getRoundRobins()
      }, 500),
      filterRoundRobins () {
        return this.roundRobins.filter(pcz => { return !pcz.archived})
      },
      goToRoundRobin(rr) {
        this.$router.push({path: `/settings/roundRobin/${rr.id}/scheduleTo`})
      },
      async getRoundRobins () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/roundRobin`, { params: { searchQuery: this.search}})
          this.roundRobins = data
          this.masterRoundRobins = cloneDeep(data)
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRoundRobin () {
        this.itemToDelete.archived = true
        const roundRobinId = this.itemToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/roundRobin/${roundRobinId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Round Robin Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Round Robin')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.closeDeleteDialog()
      },
      async addRoundRobin () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/roundRobin`, this.newRoundRobin)
          this.$router.push({path: `/settings/roundRobin/${data.id}/scheduleTo`})
          this.snackbar = getSnackbar('SUCCESS', 'Round Robin Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Round Robin')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterResults() {
        this.roundRobins = this.masterRoundRobins.filter(pcz => {
          return pcz?.roundRobinName?.toLowerCase().includes(this.nameSearch.toLowerCase())
        })
      },
      closeDeleteDialog() {
        this.showDeleteDialog = false;
        this.itemToDelete = null;
      }
    },
    async created () {
      this.getRoundRobins()
    }
  }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
</style>

