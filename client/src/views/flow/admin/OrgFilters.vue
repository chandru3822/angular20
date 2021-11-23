<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Org Filters</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newOrgFilter = {}]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Org Filter</h3>
          <div class="mb-3">
            <v-select attach v-model="newOrgFilter.orgLevelId"
                      :items="levels"
                      label="Level"
                      item-value="id"
            >
              <template slot="selection" slot-scope="data">
                {{ data.item.level }} - {{ data.item.levelName }}
              </template>
              <template slot="item" slot-scope="data">
                {{ data.item.level }} - {{ data.item.levelName }}
              </template>
            </v-select>
            <v-text-field text v-model="newOrgFilter.rank" type="number"
                          label="Rank" />
            <label>Show Type:</label>
            <input type="checkbox" class="ml-3" v-model="newOrgFilter.showType">
          </div>
          <v-btn :disabled="!newOrgFilter.orgLevelId || !newOrgFilter.rank"
                 color="primaryCustom" class="white--text mr-2"
                 @click="saveOrgFilter(newOrgFilter, true)">
            Save
          </v-btn>
          <v-btn @click="[addNew = !addNew, newOrgFilter = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="orgFilters"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': orgFilters.indexOf(item) % 2}">
              <h3>Edit Org Filter</h3>
              <div class="mb-3">
                <v-select attach v-model="item.orgLevelId"
                          :items="levels"
                          label="Level"
                          item-value="id"
                >
                  <template slot="selection" slot-scope="data">
                    {{ data.item.level }} - {{ data.item.levelName }}
                  </template>
                  <template slot="item" slot-scope="data">
                    {{ data.item.level }} - {{ data.item.levelName }}
                  </template>
                </v-select>
                <v-text-field text v-model="item.rank" type="number"
                              label="Rank" />
                <input type="checkbox" v-model="item.showType">
              </div>
              <v-btn :disabled="!item.orgLevelId || !item.rank"
                     color="primaryCustom" class="white--text mr-2"
                     @click="saveOrgFilter(item, false)">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': orgFilters.indexOf(item) % 2}">
              <td class="text-left">{{ item.levelName }}</td>
              <td class="text-left">{{ item.rank }}</td>
              <td class="text-left">
                <input type="checkbox" v-model="item.showType" disabled readonly>
              </td>
              <td>
                <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                  <template #activator="{ on }">
                    <v-btn small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                        class="headline grey lighten-2"
                        primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      <div class="error-text">
                        WARNING: This action can cause issues with many other screens.
                      </div>
                      Are you sure you want to delete this org filter: {{ item.levelName }}?
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
                          @click="deleteOrgFilter(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getOrgFilters, getOrgLevels} from '@/services/orgService'
  import { handleHidingGlobalLoader, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'OrgFilters',

    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        levels: [],
        orgFilters: [],
        newOrgFilter: {},
        selectedOrgFilterId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Org Level', value: 'levelName', show: true },
          { text: 'Rank', value: 'rank', width: 80, show: true },
          { text: 'Show Type', value: 'showType', width: 80, show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: []
      }
    },
    async created () {
      this.getOrgFilters()
      this.getOrgLevels()
    },
    methods: {
      async getOrgFilters () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getOrgFilters()
          this.orgFilters = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Filters')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOrgFilter(of, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/org/filters`, of)
          if(isNew){
            this.orgFilters.push(data)
            this.addNew = false
            this.newOrgFilter = {}
            this.snackbar = getSnackbar('SUCCESS', 'Org Filter Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.expanded = []
            this.snackbar = getSnackbar('SUCCESS', 'Org Filter Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Org Filter' : 'Error Updating Org Filter')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgLevels() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getOrgLevels()
          this.levels = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Org Levels')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteOrgFilter(filter) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/org/filters/${filter.id}`)
          this.orgFilters = this.orgFilters.filter(ol => {
            return ol.id !== filter.id
          })
          this.snackbar = getSnackbar('SUCCESS', 'Org Filter Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Org Filter')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
