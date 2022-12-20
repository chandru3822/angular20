<template>
  <v-container id="utility-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
          :headers="headers"
          :items="filteredUtilities"
          :loading="dataLoading"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          fixed-header
          hide-default-footer
          class="elevation-1 utility-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text @click="addItem" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">
                <v-icon>add</v-icon>
                <span v-if="!constants.IS_MOBILE">Add New</span>
              </v-btn>
            </div>
          </template>

          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="utilityFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="utilityFilters[header.value].type === 'text'"
                                v-model="utilityFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                type="search"
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="utilityFilters[header.value].type === 'select'"
                            :items="states"
                            v-model="utilityFilters[header.value].value"
                            :placeholder="'Select a ' + header.text.toLowerCase()"
                            clearable
                            filled
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
                <v-icon color="primary" small class="mr-3 feat-db-link-icon" @click.stop="editUtility(item)" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')">
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

        <v-dialog v-model="utilityDialog" max-width="500px">
          <v-card>
            <v-card-title>
              <span class="text-h5">{{ utilityFormTitle }}</span>
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
              <v-btn color="primary" class="white--text" raised @click="saveUtility"
                     :disabled="!editedItem.name || !editedItem.metroAreaId || !editedItem.companyStateId">
                {{ utilityBtnTxt }}
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
  import {FILTER_DEFAULTS, FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";

  export default {
    name: 'utilities',

    data: () => ({
      snackbar: {},
      constants,
      dataLoading: true,
      tabs: FEAT_DB_TABS,
      headers: [
        { text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 350, show: true },
        { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 350, show: true },
        { text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 250, show: true },
        { text: null, value: 'icons', sortable: false, show: true, width: 100 }
      ],
      utilities: [],
      states: [],
      editedItem: {
        utilityName: '',
        metroAreaId: '',
        archived: ''
      },
      utilityDialog: false,
      addMode: false,
      utilityFilters: [],
      metroAreas: []
    }),
    computed: {
      filteredUtilities () {
        return this.utilities && this.utilities.filter(utility => {
          return Object.keys(this.utilityFilters).every(filterName => {
            const filter = this.utilityFilters[filterName]

            if (filter.value?.length < 1) {
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
      utilityFormTitle () {
        return this.addMode ? 'Create Utility' : 'Update Utility'
      },
      utilityBtnTxt () {
        return this.addMode ? 'Add' : 'Update'
      }
    },
    watch: {
      utilityDialog (val) {
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
      async fetchUtilities () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/featDb/utility/list/all', 'blueraven')
          this.utilities = cloneDeep(data)
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
        this.utilityFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        this.getActiveMetroAreas()
        this.addMode = true
        this.utilityDialog = true
      },
      editUtility (item) {
        this.editedItem = Object.assign({}, item)
        this.getActiveMetroAreas()
        this.addMode = false
        this.utilityDialog = true
      },
      close () {
        this.utilityDialog = false
        this.editedItem = {}
      },
      async saveUtility () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (this.addMode) {
          try {
            const {status} = await postRequest('/featDb/utility', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'Utility created')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error creating utility')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          try {
            const {status} = await putRequest('/featDb/utility/simpleUpdate', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'Utility updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating utility')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

        this.close()
        this.initFilters()
        await this.fetchUtilities()
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
      this.fetchUtilities().then(() => this.$store.commit(AppMutations.SET_LOADING, false))
    }
  }
</script>

<style lang="scss" scoped>
  #utility-container {
    overflow: auto;
    padding-top: 0;
  }

  .feat-db-link {
    color: var(--v-brBlue-base);
    text-decoration: none;

    &:hover {
      text-decoration: underline;
      color: var(--v-primary-base);
    }
  }

  .strike {
    text-decoration: line-through;
  }

  .utility-table {
    margin-top: 2px;
  }

  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 240px);

    .table-filter {
      font-weight: normal;
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
