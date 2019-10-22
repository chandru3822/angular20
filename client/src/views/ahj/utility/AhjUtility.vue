<template>
  <v-row no-gutters style="width: 100% !important">
    <v-col cols="12">
      <v-row class="mb-1 px-3" align="center">
        <v-col class="pa-0 text-left" cols="6">
          <v-tabs
            v-model="tabs"
            background-color="rgba(0,0,0,0)"
            slider-color="primaryCustom"
          >
            <v-tab to="/ahj" class="ma-0">AHJ</v-tab>
            <v-tab to="/ahjUtility" class="text-capitalize">Utility</v-tab>
          </v-tabs>
        </v-col>
        <v-col class="pa-0 text-right" cols="6">
          <v-btn
            color="primaryButton"
            class="ma-0 app-button white--text"
            @click="addItem"
          >Add New</v-btn>
        </v-col>
      </v-row>

      <v-divider></v-divider>

      <v-row no-gutters class="my-5">
        <v-col cols="12">
          <v-card>
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
                    <td :class="{ 'strike': ahjUtility.archived}">
                      {{ ahjUtility.name ? ahjUtility.name : '' }}
                    </td>
                    <td>{{ ahjUtility.metroArea ? ahjUtility.metroArea : '' }}</td>
                    <td>{{ ahjUtility.state ? ahjUtility.state : '' }}</td>
                    <td>
                      <router-link :to="'ahjUtility/' + ahjUtility.id + '/details'" class="mr-3 ahj-link">Details</router-link>
                      <v-icon small class="mr-3 ahj-link-icon" @click="editAhjUtility(ahjUtility)">
                        edit
                      </v-icon>
                    </td>
                  </tr>
                </template>
              </v-data-table>

            <v-dialog v-model="ahjUtilityDialog" max-width="500px">
              <v-card>
                <v-card-title>
                  <span class="headline">{{ ahjUtilityFormTitle }}</span>
                </v-card-title>

                <v-card-text>
                  <v-text-field
                    label="Name"
                    v-model="editedItem.name"
                    required
                    filled
                  ></v-text-field>
                  <v-select
                    label="Metro Area"
                    :items="metroAreas"
                    v-model="editedItem.metroAreaId"
                    required
                    filled
                  ></v-select>
                  <v-checkbox
                    v-if="!addMode"
                    label="Archived"
                    v-model="editedItem.archived"
                  ></v-checkbox>
                </v-card-text>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                  <v-btn color="primaryButton" class="white--text" raised @click="saveAhjUtility"
                         :disabled="!editedItem.name || !editedItem.metroAreaId">
                    {{ ahjUtilityBtnTxt }}
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-card>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { getRequest, putRequest, postRequest } from '@/helpers/helpers'
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
      ahjUtilities: [],
      ahjUtilitySearch: '',
      editedItem: {
        utilityName: '',
        metroAreaId: '',
        archived: ''
      },
      ahjUtilityDialog: false,
      addMode: false,
      ahjUtilityFilters: [],
      ahjUtilitySearchFilters: {
        name: [],
        metroArea: [],
        state: []
      },
      pagination: {},
      metroAreas: []
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
        return this.addMode ? 'Create Utility' : 'Update Utility'
      },
      ahjUtilityBtnTxt () {
        return this.addMode ? 'Add' : 'Update'
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
        const {data} = await getRequest('/ahjUtility/list/all', 'blueraven')
        this.ahjUtilities = cloneDeep(data)
      },
      async getActiveMetroAreas () {
        const {data} = await getRequest('/metro/getActive', 'blueraven')
        data.forEach(item => {
          let option = {
            text: item.metroArea + ' (' + item.area + ')',
            value: item.id
          }
          this.metroAreas.push(option)
        })
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
        if (this.addMode) {
          await postRequest('/ahjUtility', this.editedItem, 'blueraven')
        } else {
          await putRequest('/ahjUtility/simpleUpdate', this.editedItem, 'blueraven')
        }

        this.close()
        this.initFilters()
        this.fetchAhjUtilities()
        this.fetchAhjUtilitySearchFilters()
        this.editedItem = {}
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
  .strike {
    text-decoration: line-through;
  }
</style>
