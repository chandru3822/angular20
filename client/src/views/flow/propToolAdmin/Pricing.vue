<template>
  <v-container id="pricings-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Pricing</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newPricing = {}]" color="primaryCustom">
              <v-icon v-if="!addNew">add</v-icon>
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-select v-model="newPricing.companyStateId"
                    :items="states"
                    no-data-text="No States Available"
                    label="State"
                    item-text="state"
                    item-value="companyStateId"
                    @input="[getUtilityStates(newPricing.companyStateId), newPricing.utilityStateId = null]"
          ></v-select>
          <v-select v-model="newPricing.utilityStateId"
                    :items="utilityStates"
                    no-data-text="No Utilities Available"
                    label="Utility"
                    item-text="utilityCompany"
                    item-value="id"
          ></v-select>
          <v-select v-model="newPricing.productId"
                    :items="products"
                    no-data-text="No Products Available"
                    label="Product"
                    item-text="productName"
                    item-value="id"
          ></v-select>
          <v-text-field type="number" v-model="newPricing.targetProductionFactor"
                        label="Target Production Factor">
          </v-text-field>
          <v-text-field type="number" v-model="newPricing.fundingCap"
                        label="Funding Cap">
          </v-text-field>
          <v-radio-group v-model="newPricing.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newPricing.utilityStateId || !newPricing.productId || !newPricing.targetProductionFactor || !newPricing.fundingCap || newPricing.active == null" @click="savePricing(newPricing)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterPricings()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug pricings-table"
        >
          <template #no-data>
            No available pricings
          </template>

          <template #no-results>
            No available pricings
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-select v-model="item.companyStateId"
                        :items="states"
                        no-data-text="No States Available"
                        label="State"
                        item-text="state"
                        item-value="companyStateId"
                        @input="[getUtilityStates(item.companyStateId), item.utilityStateId = null]"
              ></v-select>
              <v-select v-model="item.utilityStateId"
                        :items="utilityStates"
                        no-data-text="No Utilities Available"
                        label="Utility"
                        item-text="utilityCompany"
                        item-value="id"
              ></v-select>
              <v-select v-model="item.productId"
                        :items="products"
                        no-data-text="No Products Available"
                        label="Product"
                        item-text="productName"
                        item-value="id"
              ></v-select>
              <v-text-field type="number" v-model="item.targetProductionFactor"
                            label="Target Production Factor">
              </v-text-field>
              <v-text-field type="number" v-model="item.fundingCap"
                            label="Funding Cap">
              </v-text-field>
              <v-radio-group v-model="item.active" column>
                <v-radio label="Active" :value="true"></v-radio>
                <v-radio label="Inactive" :value="false"></v-radio>
              </v-radio-group>
              <v-btn :disabled="!item.utilityStateId || !item.productId || !item.targetProductionFactor || !item.fundingCap || item.active == null" @click="savePricing(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.state}}</td>
              <td class="text-left">{{item.utilityCompany}}</td>
              <td class="text-left">{{item.productName}}</td>
              <td class="text-left">{{item.targetProductionFactor}}</td>
              <td class="text-left">{{item.fundingCap}}</td>
              <td class="text-left">{{item.active ? 'Active' : 'Inactive'}}</td>
              <td>
                <div style="display: flex;">
                  <v-btn small text @click="[expanded = [item], selectedIndex = index, getUtilityStates(item.companyStateId)]"
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
                        Are you sure you want to delete this pricing?
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
                            @click="[item.archived = true, deletePricing(item.id)]">
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
    name: 'Pricings',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        pricings: [],
        states: [],
        utilityStates: [],
        products: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newPricing: {},
        addNew: false,
        headers: [
          {text: 'State', value: 'state', show: true},
          {text: 'Utility', value: 'utilityCompany', show: true},
          {text: 'Product', value: 'productName', show: true},
          {text: 'Target Production Factor', value: 'targetProductionFactor', show: true},
          {text: 'Funding Cap', value: 'fundingCap', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getPricings()
      this.getProducts()
      this.getStates()
    },
    methods: {
      async getProducts() {
        try {
          const {data} = await getRequest(`/propTool/product`)
          this.products = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Products')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPricings() {
        try {
          const {data} = await getRequest(`/propTool/productUtilityState`)
          this.pricings = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Pricings')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePricing(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/productUtilityState/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Pricing Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Pricing')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPricings() {
        return this.pricings.filter(u => {
          return !u.archived
        })
      },
      async getStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUtilityStates (companyStateId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/propTool/utility/state/${companyStateId}`)
          this.utilityStates = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePricing(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/productUtilityState`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.pricings.push(data)
          }

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Pricing Saved' : 'Pricing Added')

          // reset the new fields
          this.addNew = false
          this.newPricing = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Pricing' : 'Error Adding Pricing')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #pricings-container .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #pricings-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .pricings-table {
    margin-top: 2px;
  }

</style>

