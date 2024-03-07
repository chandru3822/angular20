<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{postalCodeZone.zoneName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="savePostalCodeZone"
                   color="primary" v-if="userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <v-text-field class="mt-4"
              v-model="postalCodeZone.zoneName"
              label="Zone Name"
              hide-details
            ></v-text-field>
            <v-autocomplete v-model="postalCodeZone.metroAreaId"
                            :items="metroAreas"
                            class="mt-4"
                            label="Metro Area"
                            clearable
                            hide-details
                            item-text="name"
                            item-value="id"
                            autocomplete="off"
                            attach
            ></v-autocomplete>
            <v-text-field  class="my-4"
              v-model.number="postalCodeZone.adderAmount"
              label="Adder Amount"
              type="number"
              hide-details
            ></v-text-field>
            <v-btn class="my-3" @click="[addPostalCode = !addPostalCode, getAvailablePostalCodes()]"
                   color="primary" v-if="userStore.userHasFeatureAccessLevel('USERS', 'EDIT')">
              Add Postal Code to Zone
            </v-btn>
            <v-card v-if="addPostalCode" class="pa-3 mb-3">
              <v-autocomplete
                  :items="availablePostalCodes"
                  item-value="id"
                  item-text="postalCode"
                  label="New Postal Code"
                  return-object
                  v-model="selectedPostalCode"
                  @input="savePostalCodeToZone"
              ></v-autocomplete>
            </v-card>
            <v-data-table
                :headers="headers"
                :items="filteredPostalCodes"
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
                  <td class="text-right">
                    <v-btn small text color="primary"
                           @click="[itemToDelete = item, showDeleteDialog = true]">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </td>
                </tr>
              </template>
            </v-data-table>

          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deletePostalCodeFromZone"
                        @close-dialog="showDeleteDialog=false">
      Are you sure you want to delete this postal code: <strong>{{ itemToDelete.postalCode }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { mapStores } from 'pinia'
  import { useUserStore } from '@/stores/UserStorePinia.js'

  export default {
    name: 'ZipPostalCodeZone',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        dataLoading: true,
        itemToDelete: {},
        showDeleteDialog: false,
        addPostalCode: false,
        postalCodeZoneId: this.$route.params.id,
        postalCodeZone: {},
        selectedPostalCode: {},
        availablePostalCodes: [],
        metroAreas: [],
        metroAreaCustomFieldId: 185,
        headers: [
          {text: 'Postal Code', value: 'postalCode', show: true},
          {text: '', value: 'icons', show: true},
        ]
      }
    },
    computed: {
      ...mapStores(useUserStore),
      filteredPostalCodes() {
        return this.postalCodeZone?.postalCodes?.filter(o => !o.archived)
      }
    },
    async created () {
      this.getMetroAreas()
      this.getPostalCodeZone()
    },
    methods: {
      async getMetroAreas () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customField/${this.metroAreaCustomFieldId}`)
          this.metroAreas = data?.listOfValues
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
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
          this.postalCodeZone.postalCodes.push(data)
          this.availablePostalCodes = this.availablePostalCodes.filter(apc => apc.id !== data.id)
          this.selectedPostalCode = {}
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
      async deletePostalCodeFromZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/postalCode/zone/${this.postalCodeZoneId}/postalCode/${this.itemToDelete.id}`)
          this.itemToDelete.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Postal Code Removed from Zone')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing Postal Code from Zone')
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

