<template>
  <v-container id="products-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Products</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newProduct = {}]" color="primaryCustom">
              <v-icon>add</v-icon>
              Add New
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4 mt-1" v-if="addNew">
          <v-text-field v-model="newProduct.productName"
                        label="Product Name">
          </v-text-field>
          <v-select v-model="newProduct.financierId"
                    :items="financiers"
                    no-data-text="No Financiers Available"
                    label="Financier"
                    item-text="name"
                    item-value="id"
          ></v-select>
          <v-text-field type="number" v-model="newProduct.termLength"
                        label="Loan Term in Years">
          </v-text-field>
          <v-text-field type="number" v-model="newProduct.interestRate"
                        label="Interest Rate">
          </v-text-field>
          <v-text-field type="number" v-model="newProduct.dealerFee"
                        label="Dealer Fee">
          </v-text-field>
          <v-radio-group v-model="newProduct.active" column>
            <v-radio label="Active" :value="true"></v-radio>
            <v-radio label="Inactive" :value="false"></v-radio>
          </v-radio-group>
          <v-btn :disabled="!newProduct.productName || newProduct.active == null" @click="saveProduct(newProduct)">Save</v-btn>
        </v-card>
        <v-divider v-if="addNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterProducts()"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug products-table"
        >
          <template #no-data>
            No available products
          </template>

          <template #no-results>
            No available products
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-text-field v-model="item.productName"
                            label="Product">
              </v-text-field>
              <v-select v-model="item.financierId"
                        :items="financiers"
                        no-data-text="No Financiers Available"
                        label="Financier"
                        item-text="name"
                        item-value="id"
              ></v-select>
              <v-text-field type="number" v-model="item.termLength"
                            label="Loan Term in Years">
              </v-text-field>
              <v-text-field type="number" v-model="item.interestRate"
                            label="Interest Rate">
              </v-text-field>
              <v-text-field type="number" v-model="item.dealerFee"
                            label="Dealer Fee">
              </v-text-field>
              <v-radio-group v-model="item.active" column>
                <v-radio label="Active" :value="true"></v-radio>
                <v-radio label="Inactive" :value="false"></v-radio>
              </v-radio-group>
              <v-btn :disabled="!item.productName" @click="saveProduct(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.productName}}</td>
              <td class="text-left">{{item.financier}}</td>
              <td class="text-left">{{item.termLength}}</td>
              <td class="text-left">{{item.interestRate}}%</td>
              <td class="text-left">{{item.dealerFee}}</td>
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
                        Are you sure you want to delete this product?
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
                            @click="[item.archived = true, deleteProduct(item.id)]">
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
  import orderBy from "lodash.orderby";

  export default {
    name: 'Products',

    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        products: [],
        financiers: [],
        expanded: [],
        dataLoading: true,
        selectedIndex: null,
        newProduct: {},
        addNew: false,
        headers: [
          {text: 'Product', value: 'product', show: true},
          {text: 'Financier', value: 'financier', show: true},
          {text: 'Loan Term', value: 'termLength', show: true},
          {text: 'Interest Rate', value: 'interestRate', show: true},
          {text: 'Dealer Fee', value: 'dealerFee', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created() {
      this.getProducts()
      this.getFinanciers()
    },
    methods: {
      async getFinanciers() {
        try {
          const {data} = await getRequest(`/propTool/financier`)
          this.financiers = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Financiers')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProducts() {
        try {
          const {data} = await getRequest(`/propTool/product`)
          this.products = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Products')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteProduct(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/propTool/product/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Product Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Product')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProducts() {
        return this.products.filter(u => {
          return !u.archived
        })
      },
      async saveProduct(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/propTool/product`, item)
          // add it to the records already on the screen
          if(!item.id) {
            this.products.push(data)
          }
          this.products = orderBy(this.products, [f => f.productName.toLowerCase()])

          this.snackbar = getSnackbar('SUCCESS', item.id ? 'Product Saved' : 'Product Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

          // reset the new fields
          this.addNew = false
          this.newProduct = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', item.id ? 'Error Updating Product' : 'Error Adding Product')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #products-container .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #products-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .products-table {
    margin-top: 2px;
  }

</style>

