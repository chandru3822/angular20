<template>
  <v-container id="inverters-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Inverter</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newInverter = { inverterStates: [] }" color="primaryCustom">
              <v-icon v-if="!addNew">add</v-icon>
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newInverter.inverterName"
                        label="Name">
          </v-text-field>
          <v-select v-model="newInverter.brand"
                    :items="brands"
                    no-data-text="No Brands Available"
                    label="Brand"
                    item-text="brand"
                    item-value="brand"
          ></v-select>
          <v-select v-model="newInverter.inverterType"
                    :items="inverterTypes"
                    no-data-text="No Types Available"
                    label="Type"
                    item-text="inverterType"
                    item-value="inverterType"
          ></v-select>

          <v-btn class="mb-1" @click="newInverter.inverterStates.push({})">Add State</v-btn>
          <v-card class="px-4" flat v-for="(us, index) in newInverter.inverterStates" :key="index">
            <v-row>
              <v-select v-model="us.companyStateId"
                        class="mr-4"
                        :items="inverterStates"
                        no-data-text="No States Available"
                        label="State"
                        item-text="state"
                        item-value="companyStateId"
              ></v-select>
              <v-text-field type="number" v-model="us.adderAmount" class="mr-4"
                            label="Adder Amount">
              </v-text-field>
            </v-row>
          </v-card>

          <v-radio-group v-model="newInverter.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newInverter.inverterName || !newInverter.brand || !newInverter.inverterType  || (!newInverter.inverterStates || newInverter.inverterStates.length === 0) || newInverter.active == null" @click="saveInverter(newInverter)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterInverters()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 fix-column-width-bug inverters-table"
        >
          <template #no-data>
            No available inverters
          </template>

          <template #no-results>
            No available inverters
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.inverterName"
                            label="Name">
              </v-text-field>

              <v-select v-model="item.brand"
                        :items="brands"
                        no-data-text="No Brands Available"
                        label="Brand"
                        item-text="brand"
                        item-value="brand"
              ></v-select>
              <v-select v-model="item.inverterType"
                        :items="inverterTypes"
                        no-data-text="No Types Available"
                        label="Type"
                        item-text="inverterType"
                        item-value="inverterType"
              ></v-select>

              <v-btn class="mb-1" @click="item.inverterStates.push({})">Add State</v-btn>
              <v-card class="px-4" flat v-for="(us, index) in item.inverterStates" :key="index">
                <v-row v-show="us.archived != true">
                  <v-select v-model="us.companyStateId"
                            class="mr-4"
                            :items="inverterStates"
                            no-data-text="No States Available"
                            label="State"
                            item-text="state"
                            item-value="companyStateId"
                  ></v-select>
                  <v-text-field type="number" v-model="us.adderAmount" class="mr-4"
                                label="Adder Amount">
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
              <v-btn :disabled="!item.inverterName || !item.brand || !item.inverterType || (!item.inverterStates || item.inverterStates.length === 0)" @click="saveInverter(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.inverterName}}</td>
              <td class="text-left">{{item.brand}}</td>
              <td class="text-left">{{item.inverterType}}</td>
              <td class="text-left">
                <span v-for="(s, index) in item.inverterStates" :key="index">
                  {{s.state}}<span v-if="index + 1 < item.inverterStates.length">,</span>
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
                        Are you sure you want to delete this inverter?
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
                            @click="[item.archived = true, deleteInverter(item.id)]">
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getCompanyStates} from '@/services/stateService'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby";

  export default {
    name: 'Inverters',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        inverters: [],
        brands: ['Enphase', 'SolarEdge'],
        inverterTypes: ['Microinverters', 'Inverter w/ Power Optimizers'],
        inverterStates: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newInverter: {inverterStates: []},
        addNew: false,
        headers: [
          {text: 'Inverter', value: 'inverterName', show: true},
          {text: 'Brand', value: 'brand', show: true},
          {text: 'Type', value: 'inverterType', show: true},
          {text: 'States', value: 'states', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getInverters()
      this.getCompanyStates()
    },
    methods: {
      async getInverters() {
        try {
          const {data} = await getRequest(`/propTool/inverter`)
          this.inverters = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Inverters')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteInverter(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/inverter/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Inverter Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Inverter')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterInverters() {
        return this.inverters.filter(u => {
          return !u.archived
        })
      },
      async getCompanyStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyStates()
          this.inverterStates = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveInverter(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/inverter`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.inverters.push(data)
          }
          this.inverters = orderBy(this.inverters, [p => p.inverterName.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Inverter Saved' : 'Inverter Added')

          // reset the new fields
          this.addNew = false
          this.newInverter = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Inverter' : 'Error Adding Inverter')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #inverters-container .v-data-table__wrapper {
    height: calc(100vh - 200px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #inverters-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .inverters-table {
    margin-top: 2px;
  }

</style>

