<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCodeZone.zoneName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="savePostalCodeZone"
                   color="primary" v-if="$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <v-text-field
              v-model="postalCodeZone.zoneName"
              label="Zone Name"
              hide-details
            ></v-text-field>
            <v-btn text @click="[addPostalCode = !addPostalCode, getAvailablePostalCodes()]"
                   color="primary" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">
              Add
            </v-btn>
            <v-card v-if="addPostalCode">
              <v-autocomplete
                  :items="availablePostalCodes"
                  item-value="id"
                  item-text="postalCode"
                  clearable
                  label="Postal Code"
                  return-object
                  v-model="selectedPostalCode"
                  @input="savePostalCodeToZone"
              ></v-autocomplete>
            </v-card>
            <v-data-table
                :headers="headers"
                :items="postalCodeZone.postalCodes"
                :fixed-header="true"
                :items-per-page="-1"
                hide-default-footer
                class="elevation-1"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.postalCode}}
                  </td>
                </tr>
              </template>
            </v-data-table>

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
    name: 'ZipPostalCodeZone',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        dataLoading: true,
        addPostalCode: false,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        postalCodeZoneId: this.$route.params.id,
        postalCodeZone: {},
        selectedPostalCode: {},
        availablePostalCodes: [],
        headers: [
          {text: 'Postal Code', value: 'postalCode', show: true},
        ]
      }
    },
    computed: {
    },
    methods: {
      async getPostalCodeZone () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/zone/${this.postalCodeZoneId}`)
          this.postalCodeZone = data
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
      async getAvailablePostalCodes () {
        if(this.addPostalCode) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data, status} = await getRequest(`/postalCode/zone/${this.postalCodeZoneId}/availableCodes`)
            this.availablePostalCodes = data
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      // async getRoundRobins () {
      //   this.$store.commit(AppMutations.SET_LOADING, true)
      //   try {
      //     const {data, status} = await getRequest(`/roundRobin`)
      //     this.roundRobins = data
      //     handleHidingGlobalLoader(this, status)
      //   } catch (e) {
      //     console.error('*** ERROR ***', e)
      //     this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
      //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   }
      // },
      async savePostalCodeZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode/zone`, this.postalCodeZone)
          this.snackbar = getSnackbar('SUCCESS', 'Postal Code Zone Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Postal Code Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePostalCodeToZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/postalCode/zone/${this.postalCodeZoneId}/postalCode`, this.selectedPostalCode)
          this.snackbar = getSnackbar('SUCCESS', 'Postal Code Saved to Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Postal Code to Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created () {
      this.getPostalCodeZone()
    }
  }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
</style>

