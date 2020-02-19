<template>
  <v-container class="pt-0">
    <v-row class="customer-header elevation-0">
      <v-col cols="6" class="text-left pb-2">
        <div class="customer-title">
          {{customer.fullName}}
          <v-menu
              v-if="customer.customerTypeId === 2 && userCanEdit"
              bottom
              offset-y
              :close-on-content-click="false"
          >
            <template v-slot:activator="{ on }">
              <v-btn v-on="on" dark color="primary" class="white--text"  @click="getAvailableProcesses">
                Convert
              </v-btn>
            </template>
            <v-card class="pa-5">
              Select a process to be used
              <v-select v-model="selectedProcess"
                        :items="availableProcesses"
                        label="Process"
                        placeholder="Select one..."
                        item-text="processName"
                        return-object
                        class="mt-2"
              ></v-select>
              <v-btn text :disabled="!selectedProcess" @click="convertToCustomer">
                Convert
              </v-btn>
            </v-card>
          </v-menu>
        </div>
        <div class="customer-subtitle">
          {{customer.street1}} - {{customer.city}}, {{customer.state}}
        </div>
      </v-col>
      <v-col cols="4" class="customer-owner pb-2">
        <div v-if="!changeOwner || !userCanEdit">
          <div v-if="customer.owner">
            <v-avatar
                :tile="false"
                :size="25"
                color="grey lighten-4"
                class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{customer.owner.fullName}}<br/>
            {{customer.owner.position}}
          </div>
        </div>
        <div v-if="changeOwner && userCanEdit">
          <v-autocomplete v-model="customer.owner"
                    :items="owners"
                    label="Select Owner"
                    item-text="fullName"
                    return-object
                    autocomplete="off"
                    @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" @click="changeOwner = !changeOwner">
          <span v-if="changeOwner">cancel</span>
          <span v-else-if="customer.owner && customer.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
      <v-col cols="2" class="customer-owner pb-2">
        Associated Projects<br/>
        <div v-for="p in customer.projects" :key="p.id">
          <router-link v-if="$store.getters.userHasFeature('PROJECTS')" :to="`/project/${p.id}`">{{p.projectName}}</router-link>
          <span v-else>{{p.projectName}}</span>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6" class="text-left">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Summary</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text @click="saveCustomer">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <v-form ref="address">
              <v-text-field text
                            label="Address"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            @change="addressChanged = true"
                            v-model="customer.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            placeholder=" "
                            @change="addressChanged = true"
                            :readonly="!userCanEdit"
                            v-model="customer.city"></v-text-field>
              <v-select v-model="customer.stateId"
                        :items="states"
                        label="State"
                        @change="addressChanged = true"
                        item-text="state"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Zip"
                            placeholder=" "
                            @change="addressChanged = true"
                            :readonly="!userCanEdit"
                            v-model="customer.postalCode"></v-text-field>
            </v-form>
            <v-text-field text
                          label="Phone"
                          placeholder=" "
                          :readonly="!userCanEdit"
                          v-model="customer.phone"></v-text-field>
            <v-text-field text
                          label="Mobile"
                          :readonly="!userCanEdit"
                          placeholder=" "
                          v-model="customer.mobile"></v-text-field>
            <v-text-field text
                          label="E-Mail"
                          placeholder=" "
                          :readonly="!userCanEdit"
                          v-model="customer.email"></v-text-field>
            <div class="field-label">Created Date</div>
            <datetime
                type="datetime"
                v-model="customer.dateCreated"
                input-class="one-hunned"
                :zone="timezone.value"
                :readonly="!userCanEdit"
                :format="{ year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit' }"
                :phrases="{ok: 'Ok', cancel: 'Close'}"
                :hour-step="1"
                :minute-step="15"
                use12-hour
                disabled
                auto
            ></datetime>
          </v-card>
        </div>
        <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
<!--              <v-btn text @click="saveCustomer">Save</v-btn>-->
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues" :key="idx" :readonly="!userCanEdit" :field="cf"></CustomValueInput>
          </v-card>
        </div>
      </v-col>
      <v-col cols="12" md="6" class="text-left">
        <NotesAndActivity :showNotes="true" :showActivity="false"
                          :notes="notes" :primaryId="parseInt(customerId)"
                          type="Customer"
        ></NotesAndActivity>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import { Datetime } from 'vue-datetime'
import {getStates} from '@/services/stateService'

export default {
  name: 'Customer',
  components: {
    Snackbar,
    CustomValueInput,
    NotesAndActivity,
    Datetime
  },
  data () {
    return {
      snackbar: {},
      states: [],
      customer: {},
      addressChanged: false,
      customFieldGroups: [],
      notes: [],
      owners: [],
      customerId: this.$route.params.id,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CUSTOMERS', 'EDIT'),
      companyId: this.$store.state.user.details.companyId,
      timezone: this.$store.state.user.details.timezone,
      changeOwner: false,
      selectedProcess: null,
      availableProcesses: []
    }
  },
  created () {
    this.getCustomer()
    this.getStates()
    this.getOwners()
    this.getCustomFieldGroups()
    this.getNotes()
  },
  methods: {
    async saveCustomer() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.customer.customFieldGroups = this.customFieldGroups
      this.customer.reloadCoordinates = this.addressChanged
      try {
        const {data} = await postRequest(`/customer`, this.customer)
        this.addressChanged = false
        this.$router.push({name: 'customer', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Customer')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/customer`, { params: {
          primaryId: this.customerId
        }})
        this.customFieldGroups = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomer () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customer/${this.customerId}`)
        this.customer = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Customer')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwners () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customer/owners`)
        this.owners = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Owners')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/note/getCustomerNotes`, { params: {
            primaryId: this.customerId
          }})
        this.notes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Notes')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateOwner() {
      this.changeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/customer/${this.customer.id}/updateOwner`, this.customer.owner)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableProcesses () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/processes`)
        this.availableProcesses = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Processes')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async convertToCustomer() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/customer/${this.customer.id}/convert`, this.selectedProcess)
        this.snackbar = getSnackbar('SUCCESS', 'Successfully Converted')
        this.$router.push({name: 'projectOverview', params: {projectId: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Converting Customer')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
  }
}
</script>

<style lang="scss" scoped>
  .customer-header {
    border-bottom: solid 1px #EAEAF4
  }
  .customer-title {
    font-size: 20px;
  }
  .customer-subtitle {
    font-size: 15px;
  }
  .customer-status {
    font-size: 15px;
    display: flex;
    align-items: flex-end;
    text-align: left;
  }
  .customer-owner {
    font-size: 15px;
    /*display: flex;*/
    /*align-items: flex-end;*/
    text-align: right;
  }
  .change-owner-button {
    text-decoration: underline;
    text-transform: lowercase;
  }
</style>

