<template>
  <v-row>
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          <v-btn text to="/ahj" color="primaryCustom">
            AHJ
          </v-btn>
          <v-btn text to="/ahjUtility" color="primaryCustom">
            Utility
          </v-btn>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addItem" color="primaryCustom" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">
            <v-icon>add</v-icon>
            <span v-if="!constants.IS_MOBILE">Add New</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>

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
              <v-text-field v-if="ahjUtilityFilters[header.value]"
                            v-model="ahjUtilityFilters[header.value].value"
                            :placeholder="'Enter a ' + header.text.toLowerCase()"
                            clearable
                            filled
                            dense
                            class="pt-2 table-filter"
              ></v-text-field>
            </th>
          </tr>
        </template>

        <template #item="{ item, index }" class="table-body">
          <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
            <td class="text-left" :class="{'strike': item.archived}">{{ item.name ? item.name : '' }}</td>
            <td class="text-left">{{ item.metroArea ? item.metroArea : '' }}</td>
            <td class="text-left">{{ item.state ? item.state : '' }}</td>
            <td class="text-left">
              <router-link :to="'ahjUtility/' + item.id + '/details'" class="mr-3 ahj-link">Details</router-link>
              <v-icon small class="mr-3 ahj-link-icon" @click="editAhjUtility(item)" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')">
                edit
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
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { AppMutations } from '@/stores/AppStore'

  const FILTER_DEFAULTS = {
    name: {value: '', type: 'text', model: 'name'},
    metroArea: {value: '', type: 'text', model: 'metroArea'},
    state: {value: '', type: 'select', model: 'state'}
  }

  export default {
    name: 'ahjUtilities',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      constants,
      dataLoading: true,
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
        { text: null, value: null, sortable: false, show: true, width: 120 }
      ],
      ahjUtilities: [],
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

            if (filter.value !== null) {
              return utility[filterName].toLowerCase().includes(filter.value.toLowerCase())
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
      async fetchAhjUtilities () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest('/ahjUtility/list/all', 'blueraven')
          this.ahjUtilities = cloneDeep(data)
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getActiveMetroAreas () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest('/metro/getActive', 'blueraven')
          data.forEach(item => {
            let option = {
              text: item.metroArea,
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
            await postRequest('/ahjUtility', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ utility created')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error creating AHJ utility')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          try {
            await putRequest('/ahjUtility/simpleUpdate', this.editedItem, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'AHJ utility updated')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error updating AHJ utility')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

        this.close()
        this.initFilters()
        await this.fetchAhjUtilities()
        this.editedItem = {}
      }
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.initFilters()
      this.fetchAhjUtilities().then(() => this.$store.commit(AppMutations.SET_LOADING, false))
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
  .ahj-utility-table {
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
