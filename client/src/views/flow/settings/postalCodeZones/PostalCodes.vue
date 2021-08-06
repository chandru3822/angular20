<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Round Robins</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newZone = {}]" v-if="userCanAdd">
              {{'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Round Robin Name"
                tabindex=1
                v-model="newZone.zoneName"
            ></v-text-field>
            <v-text-field
                label="Distribution Time Frame (Days)"
                tabindex=1
                v-model="newZone.distributionTimeFrameDays"
            ></v-text-field>
            <v-btn :disabled="!newZone.zoneName || !newZone.distributionTimeFrameDays" @click="addPostalCodeZone">Save</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search users and zones"
                single-line
                hide-details
                @input="debounceSearch"
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterPostalCodeZones()"
              :fixed-header="true"
              :items-per-page="-1"
              disable-sort
              :loading="dataLoading"
              hide-default-footer
              class="elevation-1 round-robin-table"
            >

              <template #header.zoneName="{ header }">
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
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left clickable" @click="goToPostalCodeZone(item.id)">{{item.zoneName}}</td>
                  <td class="text-left clickable" @click="goToPostalCodeZone(item.id)">{{item.distributionTimeFrameDays}}</td>
                  <td class="text-left clickable" @click="goToPostalCodeZone(item.id)">{{item.schedulableFutureDays}}</td>
                  <td class="text-right">
                    <v-btn small text @click="goToPostalCodeZone(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-if="userCanDelete"
                      v-model="item.deleteConfirm"
                      width="500">
                      <template v-slot:activator="{ on }">
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
                          Are you sure you want to delete this round robin: <strong>{{ item.zoneName }}</strong>?
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
                            @click="[item.archived = true, deletePostalCodeZone(item.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
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
  import debounce from 'lodash.debounce'
  import cloneDeep from 'lodash.clonedeep'
  import {  getRequestWithParams, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'PostalCodes',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        addNew: false,
        search: null,
        newZone: {},
        nameSearch: '',
        dataLoading: true,
        selectedZoneId: null,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        postalCodeZones: [],
        masterPostalCodeZones: [],
        headers: [
          {text: 'Round Robin Name', value: 'zoneName', show: true},
          {text: 'Distribution Time Frame (Days)', value: 'distributionTimeFrameDays', show: true},
          {text: 'Schedulable Future Days', value: 'schedulableFutureDays', show: true},
          {text: '', value: 'icons', show: true},
        ]
      }
    },
    computed: {
    },
    methods: {
      debounceSearch: debounce( function () {
        //don't allow search to be null - causes issues
        // this.search = this.search || ''
        this.getPostalCodeZones()
      }, 500),
      filterPostalCodeZones () {
        return this.postalCodeZones.filter(pcz => { return !pcz.archived})
      },
      goToPostalCodeZone(zoneId) {
        this.$router.push({path: `/settings/postalCode/${zoneId}/scheduleTo`})
      },
      async getPostalCodeZones () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/postalCode/zones`, { params: { searchQuery: this.search}})
          this.postalCodeZones = data
          this.masterPostalCodeZones = cloneDeep(data)
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePostalCodeZone (zoneId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/postalCode/zone/${zoneId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Zone Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addPostalCodeZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/postalCode/zone`, this.newZone)
          this.$router.push({path: `/settings/postalCode/${data.id}/scheduleTo`})
          this.snackbar = getSnackbar('SUCCESS', 'Zone Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterResults() {
        this.postalCodeZones = this.masterPostalCodeZones.filter(pcz => {
          return pcz?.zoneName?.toLowerCase().includes(this.nameSearch.toLowerCase())
        })
      }
    },
    async created () {
      this.getPostalCodeZones()
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

