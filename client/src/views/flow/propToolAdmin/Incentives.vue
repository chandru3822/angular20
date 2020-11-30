<template>
  <v-container id="incentives-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Incentives</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newIncentive = {}, incentiveEntities = []]" color="primaryCustom">
              <v-icon>add</v-icon>
              Add New
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-select v-model="newIncentive.incentiveCategoryId"
                    :items="incentiveCategories"
                    no-data-text="No Categories Available"
                    label="Incentive Category"
                    item-text="incentiveCategory"
                    item-value="id"
                    @input="getIncentiveEntities(newIncentive.incentiveCategoryId)"
          ></v-select>
          <v-select v-model="newIncentive.incentiveEntityId"
                    :items="incentiveEntities"
                    no-data-text="No Entities Available"
                    label="Entity"
                    item-text="name"
                    item-value="id"
          ></v-select>
          <v-select v-model="newIncentive.incentiveTypeId"
                    :items="incentiveTypes"
                    no-data-text="No Types Available"
                    label="Incentive Type"
                    item-text="incentiveType"
                    item-value="id"
          ></v-select>
          <v-text-field v-if="newIncentive.incentiveTypeId == 1" type="number" v-model="newIncentive.amount"
                        append-icon="mdi-percent"
                        label="Amount">
          </v-text-field>
          <v-text-field v-show="newIncentive.incentiveTypeId == 2" type="number" v-model="newIncentive.amount"
                        prepend-icon="mdi-currency-usd"
                        label="Amount">
          </v-text-field>
          <v-radio-group v-model="newIncentive.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newIncentive.incentiveCategoryId || !newIncentive.incentiveEntityId || !newIncentive.incentiveTypeId
                            || !newIncentive.amount || newIncentive.active == null" @click="saveIncentive(newIncentive)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterIncentives()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            item-key="uuid"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug incentives-table"
        >
          <template #no-data>
            No available incentives
          </template>

          <template #no-results>
            No available incentives
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-select v-model="item.incentiveCategoryId"
                        :items="incentiveCategories"
                        no-data-text="No Categories Available"
                        label="Incentive Category"
                        item-text="incentiveCategory"
                        item-value="id"
                        readonly
                        disabled
              ></v-select>
              <v-select v-model="item.incentiveEntityId"
                        :items="incentiveEntities"
                        no-data-text="No Entities Available"
                        label="Entity"
                        item-text="name"
                        item-value="id"
              ></v-select>
              <v-select v-model="item.incentiveTypeId"
                        :items="incentiveTypes"
                        no-data-text="No Types Available"
                        label="Incentive Type"
                        item-text="incentiveType"
                        item-value="id"
              ></v-select>
              <v-text-field v-if="item.incentiveTypeId == 1" type="number" v-model="item.amount"
                            append-icon="mdi-percent"
                            label="Amount">
              </v-text-field>
              <v-text-field v-show="item.incentiveTypeId == 2" type="number" v-model="item.amount"
                            prepend-icon="mdi-currency-usd"
                            label="Amount">
              </v-text-field>
              <v-radio-group v-model="item.active" column>
                <v-radio label="Active" :value="true"></v-radio>
                <v-radio label="Inactive" :value="false"></v-radio>
              </v-radio-group>
              <v-btn :disabled="!item.incentiveCategoryId || !item.incentiveEntityId || !item.incentiveTypeId
                            || !item.amount || item.active == null" @click="saveIncentive(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.incentiveCategory}}</td>
              <td class="text-left">{{item.incentiveEntityName}}</td>
              <td class="text-left">{{item.incentiveType}}</td>
              <td class="text-left">{{item.incentiveType == 'Per Watt' ? '$' + item.amount : item.amount + '%'}}</td>
              <td class="text-left">{{item.active ? 'Active' : 'Inactive'}}</td>
              <td>
                <div style="display: flex;">
                  <v-btn small text @click="[expanded = [item], selectedIndex = index, getIncentiveEntities(item.incentiveCategoryId)]" v-if="!expanded.includes(item)">
                    <v-icon v-if="item.immutable">expand_more</v-icon>
                    <v-icon v-else>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="[expanded = [], selectedIndex = index, incentiveEntities = []]"
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
                        Are you sure you want to delete this incentive?
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
                            @click="[item.archived = true, deleteIncentive(item.id)]">
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

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import { v4 as uuidv4 } from 'uuid'

  import orderBy from "lodash.orderby";

  export default {
    name: 'Incentives',

    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        incentives: [],
        incentiveCategories: [],
        incentiveTypes: [],
        incentiveEntities: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newIncentive: {},
        addNew: false,
        headers: [
          {text: 'Category', value: 'incentiveCategory', show: true},
          {text: 'Entity', value: 'incentiveEntityName', show: true},
          {text: 'Type', value: 'incentiveType', show: true},
          {text: 'Amount', value: 'amount', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getIncentives()
      this.getIncentiveCategories()
      this.getIncentiveTypes()
    },
    methods: {
      async getIncentives() {
        try {
          const {data} = await getRequest(`/propTool/incentive`)
          this.incentives = data
          // populate uuid field
          this.incentives.forEach(i => {
            i.uuid = uuidv4()
          })

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Incentives')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getIncentiveCategories() {
        try {
          const {data} = await getRequest(`/propTool/incentive/categories`)
          this.incentiveCategories = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Incentive Categories')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getIncentiveTypes() {
        try {
          const {data} = await getRequest(`/propTool/incentive/types`)
          this.incentiveTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Incentive Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getIncentiveEntities(categoryId) {
        try {
          const {data} = await getRequest(`/propTool/incentive/entities/${categoryId}`)
          this.incentiveEntities = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Entities')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteIncentive(id, type) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/incentive/type/${type}/${id}/`)
          this.snackbar = getSnackbar('SUCCESS', 'Incentive Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Incentive')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterIncentives() {
        return this.incentives.filter(u => {
          return !u.archived
        })
      },
      async saveIncentive(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/incentive`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.incentives.push(data)
          } else {
            item.incentiveEntityName = data.incentiveEntityName
            item.incentiveType = data.incentiveType
          }

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Incentive Saved' : 'Incentive Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

          // reset the new fields
          this.addNew = false
          this.newIncentive = {}
          this.expanded = []

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Incentive' : 'Error Adding Incentive')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #incentives-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #incentives-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .incentives-table {
    margin-top: 2px;
  }

</style>

