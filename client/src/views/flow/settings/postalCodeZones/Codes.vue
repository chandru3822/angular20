<template>
  <v-container class="pa-0" id="codes-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Postal Codes
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanAdd" @click="[addCode = !addCode, newCode = '']">
              <v-icon v-if="addCode">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addCode" class="square-card text-left pa-5">
          <v-text-field text
                        label="Postal Code"
                        counter
                        type="number"
                        maxlength="5"
                        v-model="newCode">
          </v-text-field>
          <div class="error-text mb-3" v-if="showError">{{errorMsg}}</div>
          <v-btn color="primary" class="mr-3 white--text" @click="addCodeToZone()"
                 :disabled="!newCode">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addCode"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="codeSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table
          :headers="codeHeaders"
          :items="filterPostalCodes()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="codeSearch"
          :loading="dataLoading"
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.postalCode}}</td>
              <td>
                <v-btn v-if="userCanEdit" text color="primary" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteCodeFromZone"
                                 @close-dialog="closeDeleteDialog">
      Are you sure you want to remove this postal code: <strong>{{ itemToDeletePostalCode }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'Codes',
    components: {ConfirmationDialog},
    data() {
      return {
        snackbar: {},
        postalCodes: [],
        showError: false,
        errorMsg: '',
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
        //per carlin 10-31-22 - users with edit should be able to delete postal codes from a RR
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
        zoneId: this.$route.params.id,
        dataLoading: true,
        addCode: false,
        newCode: '',
        codeSearch: '',
        codeHeaders: [
          {text: 'Postal Code', value: 'postalCode', show: true},
          {text: '', value: 'icons', show: true},
        ],
        showDeleteDialog: false,
        itemToDelete: null
      }
    },
    computed: {
      itemToDeletePostalCode(){
        return this.itemToDelete ? this.itemToDelete.postalCode : ''
      }
    },
    created () {
      this.getCodesForZone()
    },
    methods: {
      filterPostalCodes () {
        return this.postalCodes?.length ? this.postalCodes.filter(pc => { return !pc.archived}) : []
      },
      async getCodesForZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/zone/${this.zoneId}/codes`)
          this.postalCodes = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCodeFromZone () {
        const code = this.itemToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/postalCode/zone/code/${code.id}`)
          code.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing Postal Code')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.closeDeleteDialog()
      },
      async addCodeToZone () {
        if(this.newCode?.toString()?.length === 5) {
          this.showError = false
          this.errorMsg = ''
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            let params = {
              postalCodeZoneId: this.zoneId,
              postalCode: this.newCode
            }
            const {data, status} = await postRequest(`/postalCode/zone/addCode`, params)
            this.postalCodes.push(data)
            this.addCode = false
            this.newCode = {}
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            let msg = e.data?.message?.includes('Postal Code Already In Use') ? e.data.message : 'Error Adding Postal Code'
            this.snackbar = getSnackbar('ERROR', msg)
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.showError = true
          this.errorMsg = 'ERROR: Postal Code must be 5 digits'
        }
      },
      closeDeleteDialog(){
        this.showDeleteDialog = false
        this.itemToDelete = null
      }
    }
  }
</script>

<style lang="scss">
  #codes-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
</style>


