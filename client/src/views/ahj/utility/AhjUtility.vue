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
            <v-tab to="/ahj">AHJ</v-tab>
            <v-tab to="/ahjUtility" class="text-capitalize">Utility</v-tab>
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
<!--                            v-models="ahjUtilityFilters[header.value].value" box-->
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
                        <router-link :to="'ahjUtility/' + ahjUtility.id + '/details'" class="mr-3 ahj-link">Details</router-link>
                        <v-icon small class="mr-3 ahj-link-icon" @click="editAhjUtility(ahjUtility)">edit</v-icon>
                      </td>
                    </tr>
                  </template>
                </v-data-table>
              </v-card>
            </v-layout>
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
    name: 'ahjUtilities',
    data: () => ({
      FILTER_TYPE,
      ahjUtilityDialog: false,
      deleteAhjUtilityDialog: false,
      tabs: [
        {
          label: 'AHJ',
          path: '/ahj',
          display: true
        },
        {
          label: 'Utility',
          path: '/ahjUtility',
          display: true
        }
      ],
      headers: [
        { text: 'Name', value: 'name', show: true },
        { text: 'Metro Area', value: 'metroArea', show: true },
        { text: 'State', value: 'state', show: true },
        { text: null, value: null, sortable: false, show: true }
      ],
      ahjUtilitySearch: '',
      ahjUtilities: [],
      ahjUtilityEditedIndex: -1,
      editedItem: {
        name: '',
        metroAreaId: ''
      },
      defaultItem: {
        name: '',
        metroAreaId: ''
      },
      ahjUtilityFilters: [],
      ahjUtilitySearchFilters: {
        name: [],
        metroArea: [],
        state: []
      },
      ahjUtilityToDelete: {},
      pagination: {}
    }),
    computed: {
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
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
      ahjUtilityDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchAhjUtilities () {
        const {data} = await getRequest('/api/v1/company/blueraven/ahjUtility/list/all')
        this.ahjUtilities = cloneDeep(data)
      },
      initFilters () {
        this.ahjUtilityFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        this.ahjUtilityDialog = true
      },
      editAhjUtility (item) {
        this.ahjUtilityEditedIndex = this.ahjUtilities.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.ahjUtilityDialog = true
      },
      deleteItem (item) {
        //call ahjUtilities delete endpoint
        this.deleteAhjUtilityDialog = true
      },
      close () {
        this.ahjUtilityDialog = false
        this.deleteAhjUtilityDialog = false
      },
      saveAhjUtility () {
        if (this.ahjUtilityEditedIndex > -1) {
          Object.assign(this.ahjUtilities[this.ahjUtilityEditedIndex], this.editedItem)
        } else {
          this.ahjUtilities.push(this.editedItem)
        }

        this.close()
        this.initFilters()
        this.fetchAhjUtilities()
        this.fetchAhjUtilitySearchFilters()
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
      this.currentUser = this.$store.state.user.details.id
      this.initFilters()

      Promise.all([
        this.fetchAhjUtilities()
      ]).then(() => this.$store.commit(AppMutations.SET_LOADING, false))

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