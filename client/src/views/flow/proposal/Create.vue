<template>
  <v-container>
    <v-row no-gutters>
      <!-- FIRST COLUMN -->
      <v-col cols="12" md="3" class="pr-sm-0 pr-md-1 mb-3">
        <!-- CUSTOMER DETAILS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Customer Details
          </v-card-title>
          <v-card-text class="mt-4">

            <div class="flex-display">
              <v-text-field v-model="prop.projectId" label="Project ID"></v-text-field>
              <v-btn color="#ddd" small style="margin-top: 11px" @click="validateProjectId()">Validate</v-btn>
            </div>

            <div>
              <v-text-field v-model="prop.customerName" label="Customer Name"></v-text-field>
              <v-text-field v-model="prop.address" label="Address"></v-text-field>
              <v-text-field v-model="prop.city" label="City"></v-text-field>
              <v-select v-model="prop.stateId"
                        class="mr-4"
                        :items="states"
                        no-data-text="No States Available"
                        label="State"
                        item-text="state"
                        item-value="id"
              ></v-select>
              <v-text-field v-model="prop.zipCode" label="Zip Code"></v-text-field>
              <v-text-field v-model="prop.phone" label="Phone"></v-text-field>
              <v-text-field v-model="prop.email" label="Email"></v-text-field>
              <v-select v-model="prop.utilityCompanyId"
                        class="mr-4"
                        :items="utilityCompanies"
                        no-data-text="No Utility Companies Available"
                        label="Utility Company"
                        item-text="utilityCompany"
                        item-value="id"
              ></v-select>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- SECOND COLUMN -->
      <v-col cols="12" md="3" class="px-sm-0 px-md-1 mb-3">
        <!-- FINANCING -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Financing
          </v-card-title>
          <v-card-text class="mt-4">
            <div>
              <v-select v-model="prop.productId"
                        class="mr-4"
                        :items="products"
                        no-data-text="No Products Available"
                        label="Product"
                        item-text="productName"
                        item-value="id"
              ></v-select>
              <v-text-field type="number" v-model="prop.loanTerm" label="Loan Terms in Years"></v-text-field>
              <v-text-field type="number" v-model="prop.interestRate" label="Interest Rate"></v-text-field>
              <v-text-field type="number" v-model="prop.downPayment" label="Optional Down Payment"></v-text-field>
              <v-select v-model="prop.promotion"
                        :items="promotions"
                        label="Promotion"
              ></v-select>
            </div>

          </v-card-text>
        </v-card>

        <!-- ENERGY EFFICIENCY -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Energy Efficiency
          </v-card-title>
          <v-card-text class="mt-4">
            <div>
              <v-text-field type="number" v-model="prop.numberOfEcobees" label="Number of Ecobees"></v-text-field>
              <v-text-field type="number" v-model="prop.numberOfLeds" label="Number of LEDs"></v-text-field>
              <v-select v-model="prop.monitor"
                        :items="monitors"
                        label="Monitor"
                        item-text="text"
                        item-value="value"
              ></v-select>
            </div>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- THIRD COLUMN -->
      <v-col cols="12" md="3" class="px-sm-0 px-md-1 mb-3">
        <!-- SYSTEM DETAILS -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            System Details
          </v-card-title>
          <v-card-text class="mt-4">
            <div class="">

              <div class="flex-display">
                <v-text-field type="number" v-model="prop.auroraDesignId" label="Aurora Design ID"></v-text-field>
                <v-btn color="#ddd" small style="margin-top: 11px" @click="validateAuroraDesignId()">Validate</v-btn>
              </div>

              <v-text-field type="number" v-model="prop.yearOutput" label="Year 1 kwh Output"></v-text-field>
              <v-text-field type="number" v-model="prop.numberOfPanels" label="Number of Panels"></v-text-field>
              <v-select v-model="prop.panelId"
                        :items="panels"
                        label="Panel"
                        item-text="panelName"
                        item-value="id"
              ></v-select>
              <v-select v-model="prop.inverterId"
                        :items="inverters"
                        label="Inverter"
                        item-text="inverterName"
                        item-value="id"
              ></v-select>
            </div>
          </v-card-text>
        </v-card>

        <!-- ADDERS -->
        <v-card>
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Adders
          </v-card-title>
          <v-card-text class="mt-4">
            <div id="addersDiv">
              <v-card flat v-for="(us, index) in prop.adders" :key="index">
                <div class="flex-display">
                  <v-select v-model="us.id"
                            :items="adders"
                            no-data-text="No Adders Available"
                            label="Adder"
                            item-text="adderName"
                            item-value="id"
                  ></v-select>
                  <v-btn @click="deleteAdder(index)" text v-on="on"><v-icon>delete</v-icon></v-btn>
                </div>
              </v-card>
            </div>

            <v-btn class="mb-1" @click="prop.adders.push({})">Add</v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- FOURTH COLUMN -->
      <v-col cols="12" md="3" class="pl-sm-0 pl-md-1 mb-3">
        <!-- COMPLETE -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Complete
          </v-card-title>
          <v-card-text class="mt-4">
            <div>
              <v-text-field v-model="prop.proposalCreatedBy" label="Proposal Created By"></v-text-field>
              <v-text-field v-model="prop.qaCompletedBy" label="QA Completed By"></v-text-field>
              <v-text-field v-model="prop.notes" label="Notes"></v-text-field>
            </div>

            <div class="centered">
              <v-btn v-if="!isModify" color="primaryCustom" dark @click="generateProposal(prop)">Generate Proposal</v-btn>
              <v-btn v-else color="primaryCustom" dark @click="generateProposal(prop)">Update Proposal</v-btn>
            </div>
          </v-card-text>
        </v-card>


        <!-- OUTPUT SUMMARY -->
        <v-card class="mb-3">
          <v-card-title class="primaryCustom white--text font-weight-bold">
            Output Summary
          </v-card-title>
          <v-card-text  class="mt-4 pb-1">
            <div>
              <v-text-field readonly type="number" v-model="prop.proposalNumber" label="Proposal Number"></v-text-field>
              <v-text-field readonly type="number" v-model="prop.totalSystemPrice" label="Total System Price"></v-text-field>
              <v-text-field readonly type="number" v-model="prop.offsetVal" label="Offset"></v-text-field>
              <v-text-field readonly type="number" v-model="prop.productionFactor" label="Production Factor"></v-text-field>
            </div>

            <div class="centered">
              <v-btn color="primaryCustom" dark @click="alert('getDetails')">See Details</v-btn>
            </div>

          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'
  import {getStates} from '@/services/stateService'

  export default {
    name: 'Create',
    components: {
      Snackbar
    },
    data() {
      return {
        proposalIdIn: parseInt(this.$route.params.proposalId),
        snackbar: {},
        prop: {
          projectId: null,
          customerName: null,
          address: null,
          city: null,
          stateId: null,
          zipCode: null,
          phone: null,
          email: null,
          utilityCompany: null,
          loanTerm: null,
          interestRate: null,
          downPayment: null,
          promotion: null,
          numberOfEcobees: null,
          numberOfLeds: null,
          monitor: null,
          auroraDesignId: null,
          yearOutput: null,
          numberOfPanels: null,
          panel: null,
          inverter: null,
          adders: [],
          addersChanged: false,
          proposalCreatedBy: null,
          qaCompletedBy: null,
          notes: null,
          proposalNumber: null,
          totalSystemPrice: null,
          offsetVal: null,
          productionFactor: null
        },
        states: [],
        utilityCompanies: [],
        panels: [],
        inverters: [],
        products: [],
        promotions: ['BluePower', 'BluePower+', 'BluePower+ Prepaid'],
        monitors: [{ value: true, text: "Yes" }, { value: false, text: "No" }],
        adders: [],
        originalAdders: [],
        IS_MOBILE,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        isModify: false,
        headers: [
          { text: null, value: 'icons', show: true, sortable: false }
        ],
        expanded: []
      }
    },
    async created () {
      debugger
      this.getStates()
      this.getUtilityCompanies()
      this.getProducts()
      this.getPanels()
      this.getInverters()
      this.getAdders()

      if (!isNaN(this.proposalIdIn)) {
        this.getProposal();
      }
    },
    methods: {
      async getStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUtilityCompanies() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/propTool/utility`)
          this.utilityCompanies = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Utility Companies')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProducts() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/propTool/product`)
          this.products = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Products')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
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
      async getAdders() {
        try {
          const {data} = await getRequest(`/propTool/adder`)
          this.adders = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Adders')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async generateProposal(prop) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {

          debugger
          prop.addersChanged = false;
          if (this.isModify) {
            if (this.originalAdders.length == prop.adders.length) {
              debugger
              for (var i = 0; i < prop.adders.length; ++i) {
                if (prop.adders[i].id !== this.originalAdders[i].id) {
                  console.log('2');
                  prop.addersChanged = true;
                }
              }
            }
            else {
              prop.addersChanged = true;
            }
          }

          const {data} = await putRequest(`/propTool/proposal`, prop)
          this.snackbar = getSnackbar('SUCCESS', prop.id ? 'Proposal Saved' : 'Proposal Added')

          this.$router.push({name: 'modify', params: {proposalId: data.id}})

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', prop.id ? 'Error Updating Proposal' : 'Error Adding Proposal')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getProposal() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/propTool/proposal/${this.$route.params.proposalId}`)
          this.prop = data;
          this.originalAdders = JSON.parse(JSON.stringify(data.adders));
          this.isModify = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Proposal')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async validateAuroraDesignId() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          // TODO: Update with Aurora validation
          const {data} = await getRequest(`/project/${this.prop.projectId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Aurora Design ID Valid')

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Invalid Aurora Design ID')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async validateProjectId() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/project/${this.prop.projectId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Project ID Valid')

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Invalid Project ID')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAdder(index) {
        debugger;
        this.prop.adders.splice(index, 1);
        debugger;
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

