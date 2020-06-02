<template>
  <v-row>
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          <v-btn text to="/ahj" color="primary">
            AHJ
          </v-btn>
          <v-btn text to="/ahjUtility" color="primary">
            Utility
          </v-btn>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addItem" color="primary">
            <v-icon>add</v-icon>
            <span v-if="!constants.IS_MOBILE">Add New</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>

      <v-data-table
        :headers="headers"
        :items="filteredAhjs"
        :options="pagination"
        :items-per-page="-1"
        :mobile-breakpoint="0"
        fixed-header
        dense
        hide-default-footer
        class="elevation-1 ahj-table"
      >
        <template #header="{ props: { headers } }">
          <tr>
            <th v-for="header in headers" :key="header.text" @click="changeSort(header.value)"
                :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
                :class="['column sortable', pagination.descending ? 'desc' : 'asc', header.value === pagination.sortBy ? 'active' : '']"
            >
              <div v-if="ahjFilters[header.value]" class="pt-2 table-filter">
                <v-text-field v-if="ahjFilters[header.value].type === 'text'"
                              v-model="ahjFilters[header.value].value"
                              :placeholder="'Enter a ' + header.text.toLowerCase()"
                              clearable
                              filled
                              dense
                ></v-text-field>
                <v-select v-else-if="ahjFilters[header.value].type === 'select'"
                          :items="states"
                          v-model="ahjFilters[header.value].value"
                          :placeholder="'Select a ' + header.text.toLowerCase()"
                          clearable
                          filled
                          dense
                ></v-select>
              </div>
            </th>
          </tr>
        </template>

        <template #item="{ item, index }" class="table-body">
          <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
            <td class="text-left">{{ item.name ? item.name : '' }}</td>
            <td class="text-left">{{ item.metroArea ? item.metroArea : '' }}</td>
            <td class="text-left">{{ item.state ? item.state : '' }}</td>
            <td class="text-left">
              <router-link v-if="constants.IS_MOBILE" :to="'ahj/' + item.id + '/permit'" class="mr-3 ahj-link">Details</router-link>
              <span v-else>
                <router-link :to="'ahj/' + item.id + '/permit'" class="mr-3 ahj-link">Permit</router-link>
                <router-link :to="'ahj/' + item.id + '/inspection'" class="mr-3 ahj-link">Inspection</router-link>
                <router-link :to="'ahj/' + item.id + '/design'" class="mr-3 ahj-link">Design</router-link>
              </span>
              <v-icon small class="mr-3 ahj-link-icon" @click="editAhj(item)">
                edit
              </v-icon>
              <v-icon small class="ahj-link-icon" @click="deleteItem(item)">
                delete
              </v-icon>
            </td>
          </tr>
        </template>

        <template #no-data>
          <div class="mt-2 mb-4">No records found</div>
        </template>

        <template #no-results>
          <div class="mt-2 mb-4">No records found</div>
        </template>
      </v-data-table>

      <v-dialog v-model="ahjDialog" max-width="500px">
        <v-card>
          <v-card-title>
            <span class="headline">{{ ahjFormTitle }}</span>
          </v-card-title>

          <v-card-text>
            <v-text-field label="Name"
                          v-model="editedItem.name"
                          required
                          filled
            ></v-text-field>
            <v-select label="Metro Area"
                      :items="metroAreas"
                      v-model="editedItem.metroAreaId"
                      required
                      filled
            ></v-select>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
            <v-btn color="primaryButton" raised @click="saveAhj" class="white--text"
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
            Are you sure you want to delete the AHJ for {{ ahjToDelete.name }}?
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
            <v-btn color="brRed" class="white--text" raised
                   @click="deleteAhj(ahjToDelete.id)">Yes</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { AppMutations } from '@/stores/AppStore'

  const FILTER_DEFAULTS = {
    name: {value: '', type: 'text', model: 'name'},
    metroArea: {value: '', type: 'text', model: 'metroArea'},
    state: {value: [], type: 'select', model: 'state'}
  }

  export default {
    name: 'ahjs',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      constants,
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
        { text: null, value: null, sortable: false, show: true, width: constants.IS_MOBILE ? 135 : 300 }
      ],
      ahjs: [],
      editedItem: {
        name: '',
        metroAreaId: ''
      },
      ahjDialog: false,
      ahjDeleteDialog: false,
      addMode: false,
      ahjFilters: [],
      states: [],
      ahjToDelete: {},
      pagination: {},
      metroAreas: []
    }),
    computed: {
      filteredAhjs () {
        return this.ahjs && this.ahjs.filter(ahj => {
          return Object.keys(this.ahjFilters).every(filterName => {
            const filter = this.ahjFilters[filterName]

            if (filter.value && filter.value.length < 1) {
              return true
            }

            if (!ahj[filterName]) {
              return false
            }

            if (filter.value !== null && filter.value !== undefined) {
              return ahj[filterName].toLowerCase().includes(filter.value.toLowerCase())
            } else if (filter.value === undefined) {
              filter.value = []
            } else {
              filter.value = ''
            }
          })
        })
      },
      ahjFormTitle () {
        return this.addMode ? 'Create AHJ' : 'Update AHJ'
      },
      ahjBtnTxt () {
        return this.addMode ? 'Add' : 'Update'
      }
    },
    watch: {
      ahjDialog (val) {
        val || this.close()
      }
    },
    methods: {
      async fetchAhjs () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest('/ahj', 'blueraven')
          this.ahjs = cloneDeep(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getActiveMetroAreas () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest('/metro/getActive', 'blueraven')
          data.forEach(item => {
            let option = {
              text: item.metroArea + ' (' + item.area + ')',
              value: item.id
            }
            this.metroAreas.push(option)
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      initFilters () {
        this.ahjFilters = cloneDeep(FILTER_DEFAULTS)
      },
      addItem () {
        this.getActiveMetroAreas()
        this.addMode = true
        this.ahjDialog = true
      },
      editAhj (item) {
        this.editedItem = Object.assign({}, item)
        this.getActiveMetroAreas()
        this.addMode = false
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
        this.editedItem = {}
      },
      async saveAhj () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (!this.editedItem.id) {
          try {
            await postRequest('/ahj', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ created')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error creating AHJ')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          try {
            await putRequest(`/ahj/${this.editedItem.id}`, this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ updated')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating AHJ')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

        this.close()
        this.initFilters()
        await this.fetchAhjs().then(() => this.fetchStates())
        this.editedItem = {}
      },
      async deleteAhj (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/ahj/${id}`, 'blueraven')
          this.close()
          this.initFilters()
          await this.fetchAhjs().then(() => this.fetchStates())
          this.ahjToDelete = {}
          this.snackbar = getSnackbar('SUCCESS', 'AHJ deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting AHJ')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
      fetchStates () {
        this.states = ['']
        this.ahjs.forEach(ahj => {
          if (ahj.state && this.states.indexOf(ahj.state) === -1) {
            this.states.push(ahj.state)
          }
        })
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
      this.fetchAhjs().then(() => {
        if (this.ahjs.length > 0) {
          this.fetchStates()
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      })
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
  .ahj-table {
    margin-top: 2px;
  }
  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 160px);
  }
  .table-filter {
    font-weight: normal;
    margin-bottom: -15px;
    .v-text-field,
    .v-select {
      font-size: 1.2em;
    }
  }
</style>
