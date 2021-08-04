<template>
  <v-container id="utilities-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Utilities</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newUtility = { utilityStates: [] }]" color="primaryCustom">
              <v-icon v-if="!addNew">add</v-icon>
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newUtility.utilityCompany"
                        label="Utility Name">
          </v-text-field>
          <v-btn class="mb-1" @click="newUtility.utilityStates.push({})">Add State</v-btn>
          <v-card class="px-4" flat v-for="(us, index) in newUtility.utilityStates" :key="index">
            <v-row>
              <v-select attach v-model="us.companyStateId"
                        class="mr-4"
                        :items="states"
                        no-data-text="No States Available"
                        label="State"
                        item-text="state"
                        item-value="companyStateId"
              ></v-select>
              <v-text-field type="number" v-model="us.costPerKwh" class="mr-4"
                            label="Cost Per KwH">
              </v-text-field>
              <v-text-field type="number" v-model="us.escalator" class="mr-4"
                            label="Escalator">
              </v-text-field>
            </v-row>
          </v-card>
          <v-radio-group v-model="newUtility.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newUtility.utilityCompany || (!newUtility.utilityStates || newUtility.utilityStates.length === 0) || newUtility.active == null" @click="saveUtility(newUtility)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterUtilities()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug utilities-table"
        >
          <template #no-data>
            No available utilities
          </template>

          <template #no-results>
            No available utilities
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.utilityCompany"
                            label="Utility Name">
              </v-text-field>
              <div>
                <v-btn class="mb-1" @click="item.utilityStates.push({ archived: false })">
                  <v-icon>add</v-icon>
                  Add State
                </v-btn>
              </div>
              <v-card class="px-4" flat color="transparent" v-for="(us, index) in filterBy(item.utilityStates, false, 'archived')" :key="index">
                <v-row v-show="us.archived != true">
                  <v-select attach v-model="us.companyStateId"
                            :items="states"
                            class="mr-4"
                            no-data-text="No States Available"
                            label="State"
                            item-text="state"
                            item-value="companyStateId"
                  ></v-select>
                  <v-text-field type="number" v-model="us.costPerKwh" class="mr-4"
                                label="Cost Per KwH">
                  </v-text-field>
                  <v-text-field type="number" v-model="us.escalator" class="mr-4"
                                label="Escalator">
                  </v-text-field>
                  <v-dialog
                      v-model="us.deleteConfirm"
                      width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn text v-on="on">
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
                        Are you sure you want to delete this state?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                            @click="us.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                            color="primaryCustom"
                            text
                            @click="[us.archived = true, us.deleteConfirm = false]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-row>
              </v-card>
              <v-radio-group v-model="item.active" column>
                <v-radio label="Active" :value="true"></v-radio>
                <v-radio label="Inactive" :value="false"></v-radio>
              </v-radio-group>
              <v-btn :disabled="!item.utilityCompany || (!item.utilityStates || item.utilityStates.length === 0)" @click="saveUtility(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.utilityCompany}}</td>
              <td class="text-left">
                <span v-for="(s, index) in item.utilityStates" :key="index">
                  {{s.state}}<span v-if="index + 1 < item.utilityStates.length">,</span>
                </span>
              </td>
              <td class="text-left">{{item.active ? 'Active' : 'Inactive'}}</td>
              <td>
                <div style="display: flex;">
                  <v-btn small text @click="[expanded = [item], selectedIndex = index]"
                         v-if="!expanded.includes(item)">
                    <v-icon v-if="item.immutable">expand_more</v-icon>
                    <v-icon v-else>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="[expanded = [], selectedIndex = index]"
                         v-if="expanded.includes(item)">cancel
                  </v-btn>
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
                        Are you sure you want to delete this utility?
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
                            @click="[item.archived = true, deleteUtility(item.id)]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </div>
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

  import {getCompanyStates} from '@/services/stateService'
  import {getRequest, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby"
  import Vue2Filters from 'vue2-filters'

  export default {
    name: 'Utilities',
    mixins: [Vue2Filters.mixin],

    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        utilities: [],
        states: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newUtility: {
          utilityStates: []
        },
        addNew: false,
        headers: [
          {text: 'Utility', value: 'utility', show: true},
          {text: 'States', value: 'states', show: true},
          {text: 'Status', value: 'status', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getUtilities()
      this.getCompanyStates()
    },
    methods: {
      async getUtilities() {
        try {
          const {data} = await getRequest(`/propTool/utility`)
          this.utilities = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Utilities')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUtility(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/utility/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Utility Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Utility')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterUtilities() {
        return this.utilities.filter(u => {
          return !u.archived
        })
      },
      async getCompanyStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUtility(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/utility`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.utilities.push(data)
          }
          this.utilities = orderBy(this.utilities, [u => u.utilityCompany.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Utility Saved' : 'Utility Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

          // reset the new fields
          this.addNew = false
          this.newUtility = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Utility' : 'Error Adding Utility')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
  #utilities-container .v-data-table__wrapper {
    height: calc(100vh - 200px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #utilities-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .utilities-table {
    margin-top: 2px;
  }

</style>

