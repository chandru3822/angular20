<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCode.postalCode}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="savePostalCode"
                   color="primary" v-if="$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')">
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
              hide-details
            ></v-text-field>
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
            <v-checkbox label="Active"
                        class="default-text-color"
                        v-model="postalCode.active"/>
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
  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import constants from "@/helpers/constants";

  export default {
    name: 'ZipPostalCode',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        dataLoading: true,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        postalCodeId: this.$route.params.id,
        postalCode: {},
        roundRobins: [],
        callGroups: [],
      }
    },
    computed: {
    },
    async created () {
      this.getPostalCode()
      this.getRoundRobins()
      this.getCallGroups()
    },
    methods: {
      async getPostalCode () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/${this.postalCodeId}`)
          this.postalCode = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getRoundRobins () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/roundRobin`)
          this.roundRobins = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCallGroups () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/callGroup`, 'blueraven')
          this.callGroups = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePostalCode () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode`, this.postalCode)
          this.snackbar = getSnackbar('SUCCESS', 'Postal Code Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Postal Code')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

