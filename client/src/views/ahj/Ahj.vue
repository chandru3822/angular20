<template>
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-layout align-center row fill-height mb-1 style="width: 100%">
        <v-flex xs6 text-xs-left fill-height>
          <v-tabs
            v-model="tabs"
            color="rgba(0,0,0,0)"
            slider-color="#337ab7"
          >
            <v-tab :key="1">AHJ</v-tab>
            <v-tab :key="2" class="text-capitalize">Utility</v-tab>
          </v-tabs>
        </v-flex>
        <v-flex xs6 text-xs-right fill-height>
          <v-btn
            color="primaryButton"
            class="app-button white--text"
            @click="addItem"
          >Add New</v-btn>
        </v-flex>
      </v-layout>

      <v-divider></v-divider>

      <v-layout column fill-height>
        <v-flex xs12>
          <v-tabs-items v-model="tabs">

            <v-tab-item :key="1">
              <v-dialog v-model="ahjDialog" max-width="500px">
                <v-card>
                  <v-card-title>
                    <span class="headline">{{ ahjFormTitle }}</span>
                  </v-card-title>

                  <v-card-text>
                    <v-container grid-list-md>
                      <v-layout column nowrap>
                        <v-flex xs12 sm6 md4>
                          <v-text-field v-model="editedItem.name" label="Name" required></v-text-field>
                        </v-flex>
                        <v-flex xs12 sm6 md4>
                          <v-select
                            label="Metro Area"
                            :items="ahjOptions"
                            v-model="editedItem.metroAreaId"
                            required
                          ></v-select>
                        </v-flex>
                      </v-layout>
                    </v-container>
                  </v-card-text>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                    <v-btn color="primaryButton" raised @click="saveAhj" style="color: #fff !important"
                           :disabled="!editedItem.metroAreaId || !editedItem.name">
                      {{ ahjBtnTxt }}
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

              <v-dialog v-model="deleteAhjDialog" max-width="500px">
                <v-card>
                  <v-card-title>
                    <span class="headline">Confirm</span>
                  </v-card-title>

                  <v-card-text>
                    <v-container grid-list-md>
                      <v-layout column nowrap>
                        <v-flex xs12 sm6 md4>
                          Are you sure you want to delete the AHJ for {{ ahjToDelete }}?
                        </v-flex>
                      </v-layout>
                    </v-container>
                  </v-card-text>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                    <v-btn color="brRed" style="color: #fff !important" raised @click="confirmDeleteAhj">Yes</v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

              <v-layout my-5 fill-height>
                <v-card style="width: 100% !important">
                  <v-card-title>
                    <v-spacer></v-spacer>
                    <v-text-field
                      v-model="ahjSearch"
                      append-icon="search"
                      label="Search"
                      single-line
                      hide-details
                    ></v-text-field>
                  </v-card-title>
                  <v-data-table
                    :headers="visibleHeaders"
                    :items="filteredAhjs"
                    :search="ahjSearch"
                    :options="pagination"
                    :items-per-page="-1"
                    fixed-header
                    dense
                    hide-default-footer
                    class="elevation-1"
                    style="width: 100%"
                  >
<!-- TODO: Implement individual column filtering once the Vuetify v2.0.0 documentation improves -->
<!--                    <template #header="{ headers }">-->
<!--                      <thead>-->
<!--                        <tr-->
<!--                          v-for="header in headers"-->
<!--                          :key="header.text"-->
<!--                        >-->
<!--                          <th-->
<!--                            :class="['column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']"-->
<!--                            @click="changeSort(header.value)"-->
<!--                          >-->
<!--                            {{ header.text }}-->
<!--                            <v-icon small>arrow_upward</v-icon>-->
<!--                          </th>-->
<!--                        </tr>-->
<!--                        <tr-->
<!--                          v-for="header in headers"-->
<!--                          :key="header.text"-->
<!--                          style="padding-top: 10px"-->
<!--                        >-->
<!--                          <td>-->
<!--                            <v-text-field-->
<!--                              v-if="ahjFilters[header.value].type === FILTER_TYPE.TEXT"-->
<!--                              v-model="ahjFilters[header.value].value"-->
<!--                              filled-->
<!--                            />-->
<!--                            <v-select-->
<!--                              v-else-if="ahjFilters[header.value].type === FILTER_TYPE.SELECT"-->
<!--                              :items="ahjSearchFilters[header.value]"-->
<!--                              v-model="ahjFilters[header.value].value"-->
<!--                              filled-->
<!--                            ></v-select>-->
<!--                          </td>-->
<!--                        </tr>-->
<!--                      </thead>-->
<!--                    </template>-->

                    <template #body="{ items }" class="table-body">
                      <tr
                        v-for="(ahj, index) in items"
                        :key="ahj.id"
                        :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
                      >
                        <td>{{ ahj.name ? ahj.name : '' }}</td>
                        <td>{{ ahj.metroArea ? ahj.metroArea : '' }}</td>
                        <td>{{ ahj.state ? ahj.state : '' }}</td>
                        <td>
                          <router-link :to="'ahj/' + ahj.id + '/permit'" class="mr-3 ahj-link">Permit</router-link>
                          <router-link :to="'ahj/' + ahj.id + '/inspection'" class="mr-3 ahj-link">Inspection</router-link>
                          <router-link :to="'ahj/' + ahj.id + '/design'" class="mr-3 ahj-link">Design</router-link>
                          <v-icon small class="mr-3 ahj-link-icon" @click="editAhj(ahj)">edit</v-icon>
                          <v-icon small class="ahj-link-icon" @click="deleteAhj(ahj)">delete</v-icon>
                        </td>
                      </tr>
                    </template>
                  </v-data-table>
                </v-card>
              </v-layout>
            </v-tab-item>

            <v-tab-item :key="2">
              <v-dialog v-model="ahjUtilityDialog" max-width="500px">
                <v-card>
                  <v-card-title>
                    <span class="headline">{{ ahjUtilityFormTitle }}</span>
                  </v-card-title>

                  <v-card-text>
                    <v-container grid-list-md>
                      <v-layout column nowrap>
                        <v-flex xs12 sm6 md4>
                          <v-text-field v-model="editedItem.name" label="Name" filled></v-text-field>
                        </v-flex>
                        <v-flex xs12 sm6 md4>
                          <v-text-field v-model="editedItem.metroArea" label="Metro Area" filled></v-text-field>
                        </v-flex>
                        <v-flex xs12 sm6 md4>
                          <v-text-field v-model="editedItem.state" label="State" filled></v-text-field>
                        </v-flex>
                      </v-layout>
                    </v-container>
                  </v-card-text>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                    <v-btn color="primaryButton" style="color: #fff !important" raised @click="saveAhjUtility"
                           :disabled="!editedItem.name || !editedItem.metroArea || !editedItem.state">
                      {{ ahjUtilityBtnTxt }}
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

              <v-layout my-5 fill-height>
                <v-card style="width: 100% !important">
                  <v-card-title>
                    <v-spacer></v-spacer>
                    <v-text-field
                      v-model="ahjUtilitySearch"
                      append-icon="search"
                      label="Search"
                      single-line
                      hide-details
                    ></v-text-field>
                  </v-card-title>
                  <v-data-table
                    :headers="visibleHeaders"
                    :items="filteredAhjUtilities"
                    :search="ahjUtilitySearch"
                    :options="pagination"
                    :items-per-page="-1"
                    fixed-header
                    dense
                    hide-default-footer
                    class="elevation-1"
                    style="width: 100%"
                  >
<!-- TODO: Implement individual column filtering once the Vuetify v2.0.0 documentation improves -->
<!--                    <template #header="{ headers }">-->
<!--                      <tr>-->
<!--                        <th-->
<!--                          v-for="header in headers"-->
<!--                          :key="header.text"-->
<!--                          :class="['column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']"-->
<!--                          @click="changeSort(header.value)"-->
<!--                        >-->
<!--                          {{ header.text }}-->
<!--                          <v-icon small>arrow_upward</v-icon>-->
<!--                        </th>-->
<!--                        <th></th>-->
<!--                      </tr>-->
<!--                      <tr>-->
<!--                        <th-->
<!--                          v-for="header in headers"-->
<!--                          :key="header.text"-->
<!--                        >-->
<!--                          <v-text-field style="margin-top: 10px"-->
<!--                            v-model="ahjUtilityFilters[header.value].value" box-->
<!--                          />-->
<!--                        </th>-->
<!--                        <th></th>-->
<!--                      </tr>-->
<!--                    </template>-->

                      <template #body="{ items }" class="table-body">
                        <tr
                          v-for="(ahjUtility, index) in items"
                          :key="ahjUtility.id"
                          :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
                        >
                          <td>{{ ahjUtility.name ? ahjUtility.name : '' }}</td>
                          <td>{{ ahjUtility.metroArea ? ahjUtility.metroArea : '' }}</td>
                          <td>{{ ahjUtility.state ? ahjUtility.state : '' }}</td>
                          <td>
                            <router-link :to="'ahj/utility/' + ahjUtility.id + '/details'" class="mr-3 ahj-link">Details</router-link>
                            <v-icon small class="mr-3 ahj-link-icon" @click="editAhjUtility(ahjUtility)">edit</v-icon>
                          </td>
                        </tr>
                      </template>
                    </v-data-table>
                  </v-card>
                </v-layout>
              </v-tab-item>
            </v-tabs-items>
          </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import { mapState } from 'vuex'
  import { AppMutations } from '@/stores/AppStore'

  const FILTER_TYPE = {
    TEXT: 'text',
    SELECT: 'select'
  }

  const FILTER_DEFAULTS = {
    name: {value: [], type: FILTER_TYPE.TEXT, model: 'name'},
    metroArea: {value: [], type: FILTER_TYPE.TEXT, model: 'metroArea'},
    state: {value: [], type: FILTER_TYPE.SELECT, model: 'state'}
  }

  export default {
    name: 'ahjs',
    data: () => ({
      FILTER_TYPE,
      ahjDialog: false,
      ahjUtilityDialog: false,
      deleteAhjDialog: false,
      tabs: null,
      headers: [
        { text: 'Name', value: 'name', show: true },
        { text: 'Metro Area', value: 'metroArea', show: true },
        { text: 'State', value: 'state', show: true },
        { text: null, value: null, sortable: false, show: true }
      ],
      ahjSearch: '',
      ahjUtilitySearch: '',
      ahjs: [],
      ahjUtilities: [],
      ahjEditedIndex: -1,
      ahjUtilityEditedIndex: -1,
      editedItem: {
        name: '',
        metroArea: '',
        metroAreaId: '',
        state: '',
        stateAbrv: ''
      },
      defaultItem: {
        name: '',
        metroArea: '',
        metroAreaId: '',
        state: '',
        stateAbrv: ''
      },
      ahjToDelete: '',
      ahjFilters: [],
      ahjUtilityFilters: [],
      ahjSearchFilters: {
        name: [],
        metroArea: [],
        state: []
      },
      ahjUtilitySearchFilters: {
        name: [],
        metroArea: [],
        state: []
      },
      pagination: {},
      ahjOptions: []
    }),
    computed: {
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      filteredAhjs () {
        return this.ahjs && this.ahjs.filter(ahj => {

          return Object.keys(this.ahjFilters).every(filterName => {
            const filter = this.ahjFilters[filterName]

            if (filter.value.length < 1) {
              return true
            }

            if (!ahj[filterName]) {
              return false
            }

            return ahj[filterName].toLowerCase().includes(filter.value.toLowerCase())
          })
        })
      },
      filteredAhjUtilities () {
        return this.ahjUtilities && this.ahjUtilities.filter(utility => {

          return Object.keys(this.ahjUtilityFilters).every(filterName => {
            const filter = this.ahjUtilityFilters[filterName]

            if (filter.value.length < 1) {
              return true
            }

            if (!utility[filterName]) {
              return false
            }

            return utility[filterName].toLowerCase().includes(filter.value.toLowerCase())
          })
        })
      },
      ahjFormTitle () {
        return this.ahjEditedIndex === -1 ? 'Create AHJ' : 'Update AHJ'
      },
      ahjBtnTxt () {
        return this.ahjEditedIndex === -1 ? 'Add' : 'Update'
      },
      ahjUtilityFormTitle () {
        return this.ahjUtilityEditedIndex === -1 ? 'Create Utility' : 'Update Utility'
      },
      ahjUtilityBtnTxt () {
        return this.ahjUtilityEditedIndex === -1 ? 'Add' : 'Update'
      },
      ...mapState({
        loading: state => state.app.loading
      })
    },
    watch: {
      ahjDialog (val) {
        val || this.close()
      },
      ahjUtilityDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchAhjs () {
        const {data} = await getRequest('/api/v1/company/blueraven/ahj')
        this.ahjs = cloneDeep(data)
      },
      async fetchAhjUtilities () {
        const {data} = await getRequest('/api/v1/company/blueraven/ahjUtility/list/all')
        this.ahjUtilities = cloneDeep(data)
      },
      initFilters () {
        this.ahjFilters = cloneDeep(FILTER_DEFAULTS)
        this.ahjUtilityFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        if (this.tabs === 0) {
          this.ahjDialog = true
        } else {
          this.ahjUtilityDialog = true
        }
      },
      editAhj (item) {
        this.ahjEditedIndex = this.ahjs.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.ahjDialog = true
      },
      editAhjUtility (item) {
        this.ahjUtilityEditedIndex = this.ahjUtilities.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.ahjUtilityDialog = true
      },
      deleteAhj (item) {
        this.ahjDeleteIndex = this.ahjs.indexOf(item)
        this.ahjToDelete = item.name
        this.deleteAhjDialog = true
      },
      close () {
        if (this.ahjDialog) {
          this.ahjDialog = false
        } else if (this.ahjUtilityDialog) {
          this.ahjUtilityDialog = false
        } else {
          this.deleteAhjDialog = false
        }
        setTimeout(() => {
          this.editedItem = Object.assign({}, this.defaultItem)
          if (this.ahjEditedIndex !== -1) {
            this.ahjEditedIndex = -1
          } else if (this.ahjUtilityEditedIndex !== -1) {
            this.ahjUtilityEditedIndex = -1
          } else {
            this.ahjDeleteIndex = -1
            this.ahjToDelete = ''
          }
        }, 300)
      },
      saveAhj () {
        // this.editedItem.currentUser = this.$store.state.user.details.id
        switch (this.editedItem.metroAreaId) {
          case 4:
            this.editedItem.metroArea = 'Colorado Springs'
            this.editedItem.state = 'Colorado'
            this.editedItem.stateAbrv = 'CO'
            break;
          case 8:
            this.editedItem.metroArea = 'Denver'
            this.editedItem.state = 'Colorado'
            this.editedItem.stateAbrv = 'CO'
            break;
          default:
            this.editedItem.metroArea = 'Not Specified'
            this.editedItem.state = 'Not Specified'
            this.editedItem.stateAbrv = 'Not Specified'
        }

        if (this.ahjEditedIndex > -1) {
          Object.assign(this.ahjs[this.ahjEditedIndex], this.editedItem)
        } else {
          this.ahjs.push(this.editedItem)
        }
        this.close()
        this.initFilters()
        this.fetchAhjs()
        this.fetchAhjSearchFilters()
      },
      saveAhjUtility () {
        if (this.ahjUtilityEditedIndex > -1) {
          Object.assign(this.ahjUtilities[this.ahjUtilityEditedIndex], this.editedItem)
        } else {
          this.ahjUtilities.push(this.editedItem)
        }

        this.close()
        this.initFilters()
        this.ahjUtilities = this.fetchAhjUtilities()
        this.fetchAhjUtilitySearchFilters()
      },
      confirmDeleteAhj () {
        this.ahjs.splice(this.ahjDeleteIndex, 1)

        this.close()
        this.initFilters()
        this.fetchAhjs()
        this.fetchAhjSearchFilters()
      },
      fetchAhjSearchFilters () {
        let ahjNames = []
        this.ahjs.forEach(ahj => {
          ahjNames.push(ahj.name)
        })
        this.ahjSearchFilters.name = ahjNames

        let ahjMetroAreas = []
        this.ahjs.forEach(ahj => {
          ahjMetroAreas.push(ahj.metroArea)
        })
        this.ahjSearchFilters.metroArea = ahjMetroAreas

        let ahjStates = ['']
        this.ahjs.forEach(ahj => {
          ahjStates.push(ahj.state)
        })
        this.ahjSearchFilters.state = ahjStates
      },
      fetchAhjUtilitySearchFilters () {
        let ahjUtilityNames = []
        this.ahjUtilities.forEach(utility => {
          ahjUtilityNames.push(utility.name)
        })
        this.ahjUtilitySearchFilters.name = ahjUtilityNames

        let ahjUtilityMetroAreas = []
        this.ahjUtilities.forEach(utility => {
          ahjUtilityMetroAreas.push(utility.metroArea)
        })
        this.ahjUtilitySearchFilters.metroArea = ahjUtilityMetroAreas

        let ahjUtilityStates = []
        this.ahjUtilities.forEach(utility => {
          ahjUtilityStates.push(utility.state)
        })
        this.ahjUtilitySearchFilters.state = ahjUtilityStates
      },
      changeSort (column) {
        if (this.pagination.sortBy === column) {
          this.pagination.descending = !this.pagination.descending
        } else {
          this.pagination.sortBy = column
          this.pagination.descending = false
        }
      }
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.initFilters()

      Promise.all([
        this.fetchAhjs(),
        this.fetchAhjUtilities()
      ]).then(() => this.$store.commit(AppMutations.SET_LOADING, false))

      if (this.ahjs.length > 0) {
        this.fetchAhjSearchFilters()

        this.ahjs.forEach(ahj => {
          this.ahjOptions.push({ text: ahj.metroArea + " (" + ahj.stateAbrv + ")", value: ahj.metroAreaId })
        })
        this.ahjOptions.sort((a, b) => {
          let textA = a.text.toUpperCase()
          let textB = b.text.toUpperCase()
          return (textA < textB) ? -1 : (textA > textB) ? 1 : 0
        })
      }

      if (this.ahjUtilities.length > 0) {
        this.fetchAhjUtilitySearchFilters()
      }
    }
  }
</script>

<style lang="scss" scoped>
  .ahj-link {
    color: var(--v-brBlue-base);
    text-decoration: none;
    &:hover {
      text-decoration: underline;
      color: var(--v-primaryText-base);
    }
  }
  .ahj-link-icon {
    color: var(--v-brBlue-base) !important;
    &:hover {
      color: var(--v-primaryText-base) !important;
    }
  }
</style>