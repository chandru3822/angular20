<template>
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-layout align-center row fill-height mb-1 style="width: 100%">
        <v-flex xs6 text-xs-left fill-height>
          <v-tabs
            v-model="tabs"
            color="rgba(0,0,0,0)"
            slider-color="primaryCustom"
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
          <v-dialog v-model="ahjDialog" max-width="500px">
            <v-card>
              <v-card-title>
                <span class="headline">{{ ahjFormTitle }}</span>
              </v-card-title>

              <v-card-text>
                <v-container grid-list-md>
                  <v-layout column nowrap>
                    <v-flex xs12 sm6 md4>
                      <v-text-field
                        v-model="editedItem.name"
                        label="Name"
                        required
                        filled
                      ></v-text-field>
                    </v-flex>
                    <v-flex xs12 sm6 md4>
                      <v-select
                        label="Metro Area"
                        :items="metroAreas"
                        v-model="editedItem.metroAreaId"
                        required
                        filled
                      ></v-select>
                    </v-flex>
                  </v-layout>
                </v-container>
              </v-card-text>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                <v-btn color="primaryButton" raised @click="saveAhj" style="color: #fff !important"
                       :disabled="!editedItem.name || !editedItem.metroAreaId">
                  {{ ahjBtnTxt }}
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>

          <v-dialog v-model="ahjDeleteDialog" max-width="500px">
            <v-card>
              <v-card-title>
                <span class="headline">Confirm</span>
              </v-card-title>

              <v-card-text>
                <v-container grid-list-md>
                  <v-layout column nowrap>
                    <v-flex xs12 sm6 md4>
                      Are you sure you want to delete the AHJ for {{ ahjToDelete.name }}?
                    </v-flex>
                  </v-layout>
                </v-container>
              </v-card-text>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
                <v-btn color="brRed" style="color: #fff !important" raised
                       @click="deleteAhj(ahjToDelete.id)">Yes</v-btn>
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
                      <router-link :to="'ahj/' + ahj.id + '/permit'" class="mr-3 ahj-link">
                        Permit
                      </router-link>
                      <router-link :to="'ahj/' + ahj.id + '/inspection'" class="mr-3 ahj-link">
                        Inspection
                      </router-link>
                      <router-link :to="'ahj/' + ahj.id + '/design'" class="mr-3 ahj-link">
                        Design
                      </router-link>
                      <v-icon small class="mr-3 ahj-link-icon" @click="editAhj(ahj)">
                        edit
                      </v-icon>
                      <v-icon small class="ahj-link-icon" @click="deleteItem(ahj)">
                        delete
                      </v-icon>
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
    name: 'ahjs',
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
      ahjs: [],
      ahjSearch: '',
      editedItem: {
        name: '',
        metroAreaId: ''
      },
      ahjDialog: false,
      ahjDeleteDialog: false,
      ahjFilters: [],
      ahjSearchFilters: {
        name: [],
        metroArea: [],
        state: []
      },
      ahjToDelete: {},
      pagination: {},
      metroAreas: []
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
      ahjFormTitle () {
        return this.editedItem.id === -1 ? 'Create AHJ' : 'Update AHJ'
      },
      ahjBtnTxt () {
        return this.editedItem.id === -1 ? 'Add' : 'Update'
      },
      ...mapState({
        loading: state => state.app.loading
      })
    },
    watch: {
      ahjDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchAhjs () {
        const {data} = await getRequest('/api/v1/company/blueraven/ahj/')
        this.ahjs = cloneDeep(data)
      },
      async getActiveMetroAreas () {
        const {data} = await getRequest('/api/v1/company/blueraven/metro/getActive')
        data.forEach(item => {
          let option = {
            text: item.metroArea + ' (' + item.area + ')',
            value: item.id
          }
          this.metroAreas.push(option)
        })
      },
      initFilters () {
        this.ahjFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        this.getActiveMetroAreas()
        this.ahjDialog = true
      },
      editAhj (item) {
        this.editedItem = Object.assign({}, item)
        this.getActiveMetroAreas()
        this.ahjDialog = true
      },
      deleteItem (item) {
        this.ahjToDelete = {
          id: item.id,
          name: item.name
        }
        this.ahjDeleteDialog = true
      },
      close () {
        this.ahjDialog = false
        this.ahjDeleteDialog = false
      },
      async saveAhj () {
        if (!this.editedItem.id) {
          await postRequest(`/api/v1/company/blueraven/ahj/${this.currentUser}`, this.editedItem)
        } else {
          await putRequest(`/api/v1/company/blueraven/ahj/${this.editedItem.id}/user/${this.currentUser}`, this.editedItem)
        }

        this.close()
        this.initFilters()
        this.fetchAhjs()
        this.fetchAhjSearchFilters()
        this.editedItem = {}
      },
      async deleteAhj (id) {
        await deleteRequest(`/api/v1/company/blueraven/ahj/${id}`)
        this.close()
        this.initFilters()
        this.fetchAhjs()
        this.fetchAhjSearchFilters()
        this.ahjToDelete = {}
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
        this.fetchAhjs()
      ]).then(() => this.$store.commit(AppMutations.SET_LOADING, false))

      if (this.ahjs.length > 0) {
        this.fetchAhjSearchFilters()
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