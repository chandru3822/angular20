<template>
  <v-container id="ahj-utility-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
<!--        <v-toolbar color="white" class="elevation-1">-->
<!--          <v-toolbar-title class="app-title">-->
<!--            <v-btn v-for="tab in tabs" text :to="tab.path" color="primary">-->
<!--              {{tab.label}}-->
<!--            </v-btn>-->
<!--          </v-toolbar-title>-->
<!--          <v-spacer></v-spacer>-->
<!--          <v-toolbar-items>-->
<!--            <v-btn text @click="addItem" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">-->
<!--              <v-icon>add</v-icon>-->
<!--              <span v-if="!constants.IS_MOBILE">Add New</span>-->
<!--            </v-btn>-->
<!--          </v-toolbar-items>-->
<!--        </v-toolbar>-->

        <v-data-table
          :headers="headers"
          :items="filteredAhjUtilities"
          :loading="dataLoading"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          fixed-header
          hide-default-footer
          class="elevation-1 ahj-utility-table"
        >
          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="ahjUtilityFilters[header.value]" class="pt-2 ml-0 table-filter">
                  <v-text-field v-if="ahjUtilityFilters[header.value].type === 'text'" class="pt-2 table-filter"
                                v-model="ahjUtilityFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                type="search"
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="ahjUtilityFilters[header.value].type === 'select'"
                            :items="states"
                            v-model="ahjUtilityFilters[header.value].value"
                            :placeholder="'Select a ' + header.text.toLowerCase()"
                            clearable
                            filled
                            class="mt-2"
                            type="search"
                            item-text="state"
                            dense
                            hide-details
                                  attach
                  ></v-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]" @click="goToRoute(item.id)" class="clickable">
              <td class="text-left" :class="{'strike': item.archived}">{{ item.name ? item.name : '' }}</td>
              <td class="text-left">{{ item.metroArea ? item.metroArea : '' }}</td>
              <td class="text-left">{{ item.state ? item.state : '' }}</td>
              <td class="text-right">
                <v-icon color="primary" class="mr-3 ahj-link-icon" @click.stop="editAhjUtility(item)" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')">
                  edit
                </v-icon>
              </td>
            </tr>
          </template>

          <template #no-data>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>

          <template #no-results>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>
        </v-data-table>

        <v-dialog v-model="ahjUtilityDialog" max-width="500px">
          <v-card>
            <v-card-title>
              <span class="text-h5">{{ ahjUtilityFormTitle }}</span>
            </v-card-title>

            <v-card-text>
              <v-text-field
                label="Name"
                v-model="editedItem.name"
                required
                type="search"
                filled
              ></v-text-field>
              <v-autocomplete
                label="Metro Area"
                :items="metroAreas"
                v-model="editedItem.metroAreaId"
                required
                filled
                attach
              ></v-autocomplete>
              <v-autocomplete label="State"
                              :items="states"
                              v-model="editedItem.companyStateId"
                              item-text="state"
                              item-value="id"
                              type="search"
                              autocomplete="off"
                              required
                              filled
                              attach
              ></v-autocomplete>
              <v-checkbox
                v-if="!addMode"
                label="Archived"
                v-model="editedItem.archived"
              ></v-checkbox>
            </v-card-text>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="primary" text @click="close">Cancel</v-btn>
              <v-btn color="primary" class="white--text" raised @click="saveAhjUtility"
                     :disabled="!editedItem.name || !editedItem.metroAreaId || !editedItem.companyStateId">
                {{ ahjUtilityBtnTxt }}
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { AppMutations } from '@/stores/AppStore'
  import {getActiveStates} from '@/services/stateService'
  import {FILTER_DEFAULTS, AHJ_TABS} from "@/views/blueraven/ahj/AhjConstants";

  export default {
    name: 'ahjUtilities',

    data: () => ({
      snackbar: {},
      constants,
      dataLoading: true,
      tabs: AHJ_TABS,
      headers: [
        { text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 350, show: true },
        { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 350, show: true },
        { text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 250, show: true },
        { text: null, value: null, sortable: false, show: true, width: 100 }
      ],
      ahjUtilities: [],
      states: [],
      editedItem: {
        utilityName: '',
        metroAreaId: '',
        archived: ''
      },
      ahjUtilityDialog: false,
      addMode: false,
      ahjUtilityFilters: [],
      metroAreas: []
    }),
    computed: {
      filteredAhjUtilities () {
        return this.ahjUtilities && this.ahjUtilities.filter(utility => {
          return Object.keys(this.ahjUtilityFilters).every(filterName => {
            const filter = this.ahjUtilityFilters[filterName]

            if (filter.value && filter.value.length < 1) {
              return true
            }

            if (!utility[filterName]) {
              return false
            }

            if (filter.value !== null && filter.value !== undefined) {
              return utility[filterName].toLowerCase().includes(filter.value.toLowerCase())
            } else if (filter.value === undefined) {
              filter.value = []
            } else {
              filter.value = ''
            }
          })
        })
      },
      ahjUtilityFormTitle () {
        return this.addMode ? 'Create Utility' : 'Update Utility'
      },
      ahjUtilityBtnTxt () {
        return this.addMode ? 'Add' : 'Update'
      }
    },
    watch: {
      ahjUtilityDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getActiveStates()
          this.states = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async fetchAhjUtilities () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/ahjUtility/list/all', 'blueraven')
          this.ahjUtilities = cloneDeep(data)
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getActiveMetroAreas () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/metro/getActive', 'blueraven')
          data.forEach(item => {
            let option = {
              text: item.metroArea,
              value: item.id
            }
            this.metroAreas.push(option)
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      initFilters () {
        this.ahjUtilityFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        this.getActiveMetroAreas()
        this.addMode = true
        this.ahjUtilityDialog = true
      },
      editAhjUtility (item) {
        this.editedItem = Object.assign({}, item)
        this.getActiveMetroAreas()
        this.addMode = false
        this.ahjUtilityDialog = true
      },
      close () {
        this.ahjUtilityDialog = false
        this.editedItem = {}
      },
      async saveAhjUtility () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (this.addMode) {
          try {
            const {status} = await postRequest('/ahjUtility', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ utility created')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error creating AHJ utility')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          try {
            const {status} = await putRequest('/ahjUtility/simpleUpdate', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ utility updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating AHJ utility')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

        this.close()
        this.initFilters()
        await this.fetchAhjUtilities()
        this.editedItem = {}
      },
      goToRoute(id) {
        this.$router.push('utility/' + id + '/details')
      },
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.initFilters()
      this.fetchStates()
      this.fetchAhjUtilities().then(() => this.$store.commit(AppMutations.SET_LOADING, false))
    }
  }
</script>

<style lang="scss" scoped>
  #ahj-utility-container {
    overflow: auto;
    padding-top: 0;
  }

  .ahj-link {
    color: var(--v-brBlue-base);
    text-decoration: none;

    &:hover {
      text-decoration: underline;
      color: var(--v-primary-base);
    }
  }

  //.ahj-link-icon {
  //  color: var(--v-brBlue-base) !important;
  //
  //  &:hover {
  //    color: var(--v-primaryText-base) !important;
  //  }
  //}

  .strike {
    text-decoration: line-through;
  }

  .ahj-utility-table {
    margin-top: 2px;
  }

  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 200px);

    .table-filter {
      font-weight: normal;
      font-size: 0.875rem;
      margin-left: 15px;
      margin-bottom: 10px;

      .v-text-field,
      .v-select {
        font-size: 0.875rem;
        margin-left: 15px;
      }
    }
  }

  @media (min-width: 769px) {
    .v-data-table ::v-deep .v-data-table__wrapper {
      max-height: calc(100vh - 162px);
    }
  }
</style>
