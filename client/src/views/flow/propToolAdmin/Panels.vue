<template>
  <v-container id="panels-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Panel</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newPanel = {panelStates: [] }]" color="primaryCustom">
              <v-icon v-if="!addNew">add</v-icon>
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newPanel.panelName"
                        label="Panel Name">
          </v-text-field>
          <v-text-field type="number" v-model="newPanel.wattage"
                        label="Wattage">
          </v-text-field>
          <v-text-field v-model="newPanel.panelType"
                        label="Type">
          </v-text-field>
          <v-text-field v-model="newPanel.panelColor"
                        label="Color">
          </v-text-field>

          <v-btn class="mb-1" @click="newPanel.panelStates.push({})">Add State</v-btn>
          <v-card class="px-4" flat v-for="(us, index) in newPanel.panelStates" :key="index">
            <v-row>
              <v-select v-model="us.companyStateId"
                        class="mr-4"
                        :items="panelStates"
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

          <v-radio-group v-model="newPanel.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newPanel.panelName || !newPanel.wattage || !newPanel.panelType || !newPanel.panelColor || (!newPanel.panelStates || newPanel.panelStates.length === 0) || newPanel.active == null" @click="savePanel(newPanel)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterPanels()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 fix-column-width-bug panels-table"
        >
          <template #no-data>
            No available panels
          </template>

          <template #no-results>
            No available panels
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.panelName"
                            label="Name">
              </v-text-field>
              <v-text-field type="number" v-model="item.wattage"
                            label="Wattage">
              </v-text-field>
              <v-text-field v-model="item.panelType"
                            label="Type">
              </v-text-field>
              <v-text-field v-model="item.panelColor"
                            label="Color">
              </v-text-field>

              <v-btn class="mb-1" @click="item.panelStates.push({})">Add State</v-btn>
              <v-card class="px-4" flat v-for="(us, index) in item.panelStates" :key="index">
                <v-row v-show="us.archived != true">
                  <v-select v-model="us.companyStateId"
                            class="mr-4"
                            :items="panelStates"
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
              <v-btn @click="savePanel(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.panelName}}</td>
              <td class="text-left">{{item.wattage}}</td>
              <td class="text-left">{{item.panelType}}</td>

              <td class="text-left">
                <span v-for="(s, index) in item.panelStates" :key="index">
                  {{s.state}}<span v-if="index + 1 < item.panelStates.length">,</span>
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
                        Are you sure you want to delete this panel?
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
                            @click="[item.archived = true, deletePanel(item.id)]">
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
    name: 'Panels',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        panels: [],
        panelStates: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newPanel: {
          panelStates: []
        },
        addNew: false,
        headers: [
          {text: 'Name', value: 'panelName', show: true},
          {text: 'Wattage', value: 'wattage', show: true},
          {text: 'Type', value: 'panelType', show: true},
          {text: 'States', value: 'states', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getPanels()
      this.getCompanyStates()
    },
    methods: {
      async getPanels() {
        try {
          const {data} = await getRequest(`/propTool/panel`)
          this.panels = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Panels')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePanel(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/panel/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Panel Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Panel')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPanels() {
        return this.panels.filter(u => {
          return !u.archived
        })
      },
      async getCompanyStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyStates()
          this.panelStates = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePanel(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/panel`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.panels.push(data)
          }
          this.panels = orderBy(this.panels, [p => p.panelName.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Panel Saved' : 'Panel Added')

          // reset the new fields
          this.addNew = false
          this.newPanel = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Panel' : 'Error Adding Panel')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #panels-container .v-data-table__wrapper {
    height: calc(100vh - 200px);
    min-height: 400px;
  }
</style>

<style lang="scss" scoped>
  #panels-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .panels-table {
    margin-top: 2px;
  }

</style>

