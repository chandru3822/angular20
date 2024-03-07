<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCode.postalCode}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="savePostalCode"
                   :disabled="!postalCode.placeName || !postalCode.stateId"
                   color="primary" v-if="userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <v-text-field
              v-model="postalCode.placeName"
              label="Place Name"
              :rules="requiredRules"
              hide-details
            ></v-text-field>
            <v-autocomplete
              :items="zones"
              item-value="id"
              item-text="zoneName"
              clearable
              hide-details
              class="mt-5"
              label="Postal Code Zone"
              v-model="postalCode.postalCodeZoneId"
            ></v-autocomplete>
            <v-autocomplete
              :items="states"
              item-value="id"
              item-text="state"
              clearable
              :rules="requiredRules"
              hide-details
              class="mt-5"
              label="State"
              v-model="postalCode.stateId"
            ></v-autocomplete>
            <v-autocomplete
                :items="roundRobins"
                item-value="id"
                item-text="roundRobinName"
                clearable
                hide-details
                class="mt-5"
                label="Round Robin"
                v-model="postalCode.roundRobinId"
            ></v-autocomplete>
            <v-autocomplete
              :items="callGroups"
              item-value="id"
              item-text="callGroupName"
              clearable
              class="mt-5"
              label="Call Group"
              v-model="postalCode.callGroupId"
            ></v-autocomplete>
            <v-checkbox label="Disqualified"
                        class="default-text-color"
                        v-model="postalCode.disqualified"/>
            <v-checkbox label="Self-Gen Only"
                        class="default-text-color"
                        v-model="postalCode.selfGen"/>
            <v-checkbox label="Inside Sales"
                        class="default-text-color"
                        v-model="postalCode.insideSales"/>
            <v-checkbox label="Sales Partners"
                        class="default-text-color"
                        v-model="postalCode.salesPartners"/>
            <v-textarea class="body-medium" hide-details
                        auto-grow
                        rows="4"
                        label="Notes"
                        outlined v-model="postalCode.notes"/>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import {getStates} from '@/services/stateService'
  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import constants from "@/helpers/constants";
  import { mapStores } from 'pinia'
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'

  export default {
    name: 'ZipPostalCode',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        dataLoading: true,
        postalCodeId: this.$route.params.id,
        postalCode: {},
        zones: [],
        states: [],
        roundRobins: [],
        callGroups: [],
        requiredRules: constants.BASIC_REQUIRED_RULE,
      }
    },
    computed: {
      ...mapStores(useUserStore, useAppStore),
      userCanEdit() {
        return this.userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')
      },
      companyId() {
        return this.userStore.details.companyId
      },
      userId() {
        return this.userStore.details.id
      },
    },
    async created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.dataLoading = true
      Promise.all([
        this.getPostalCode(),
        this.getRoundRobins(),
        this.getZones(),
        this.getStates(),
        this.getCallGroups()
      ]).then(() => {
        this.$store.commit(AppMutations.SET_LOADING, false);
        this.dataLoading = false;
      })
    },
    methods: {
      async getPostalCode () {
        try {
          const {data, status} = await getRequest(`/postalCode/${this.postalCodeId}`)
          this.postalCode = data
          this.dataLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.appStore.showSnack(this.snackbar)
        }
      },
      async getStates () {
        try {
          const {data, status} = await getStates()
          this.states = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.appStore.showSnack(this.snackbar)
        }
      },
      async getRoundRobins () {
        try {
          const {data, status} = await getRequest(`/roundRobin`)
          this.roundRobins = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.appStore.showSnack(this.snackbar)
        }
      },
      async getZones () {
        try {
          const {data, status} = await getRequest(`/postalCode/zones`)
          this.zones = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.appStore.showSnack(this.snackbar)
        }
      },
      async getCallGroups () {
        try {
          const {data, status} = await getRequest(`/callGroup`, 'blueraven')
          this.callGroups = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.appStore.showSnack(this.snackbar)
        }
      },
      async savePostalCode () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode`, this.postalCode)
          this.snackbar = getSnackbar('SUCCESS', 'Postal Code Saved')
          this.appStore.showSnack(this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Postal Code')
          this.appStore.showSnack(this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
</style>

