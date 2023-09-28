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
            <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanAdd" @click="[reloadAvailable(), addCode = !addCode, newCode = {}]">
              <v-icon v-if="addCode">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addCode" class="square-card text-left pa-5">
          <v-autocomplete
              :items="availablePostalCodes"
              item-value="id"
              item-text="postalCode"
              label="Postal Code"
              return-object
              v-model="newCode"
          ></v-autocomplete>
          <div class="error-text mb-3" v-if="showError">{{errorMsg}}</div>
          <v-btn color="primary" class="mr-3 white--text" @click="addCodeToRoundRobin()"
                 :disabled="!newCode.id">
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
        <v-data-table id="round-robin-codes-table"
          :headers="codeHeaders"
          :items="filterPostalCodes()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="codeSearch"
          :loading="dataLoading"
          class="elevation-0 table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available postal codes</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left code-col">{{item.postalCode}}</td>
              <td :class="{'text-right': $vuetify.breakpoint.smAndDown}">
                <v-btn v-if="userCanEdit" icon :large="$vuetify.breakpoint.smAndDown" color="primary" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteCodeFromRoundRobin"
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
    name: 'PostalCodes',
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
        roundRobinId: this.$route.params.id,
        dataLoading: true,
        addCode: false,
        codeDeleted: false,
        newCode: {},
        availablePostalCodes: [],
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
      this.getCodesAssignedToRoundRobin()
      this.getAvailablePostalCodes()
    },
    methods: {
      reloadAvailable() {
        if(this.codeDeleted) {
          this.getAvailablePostalCodes()
        }
      },
      filterPostalCodes () {
        return this.postalCodes?.length ? this.postalCodes.filter(pc => { return !pc.archived}) : []
      },
      async getAvailablePostalCodes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/roundRobin/${this.roundRobinId}/availableCodes`)
          this.availablePostalCodes = data
          //this makes it reload the available list any time one has been deleted locally
          this.codeDeleted = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCodesAssignedToRoundRobin () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/roundRobin/${this.roundRobinId}/codes`)
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
      async deleteCodeFromRoundRobin () {
        const code = this.itemToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/roundRobin/code/${code.id}`)
          code.archived = true
          this.codeDeleted = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing Postal Code')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.closeDeleteDialog()
      },
      async addCodeToRoundRobin () {
        if(this.newCode.id) {
          this.showError = false
          this.errorMsg = ''
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            // let params = {
            //   postalCode:
            // }
            const {data, status} = await postRequest(`/roundRobin/${this.roundRobinId}/addCode`, this.newCode)
            this.postalCodes.push(data)
            this.addCode = false
            this.availablePostalCodes = this.availablePostalCodes.filter(apc => apc.id !== this.newCode.id)
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
<style scoped lang="scss">
@media (max-width: 770px) {
  .code-col {
    width: 100%;
  }
}
</style>
<style lang="scss">
  #codes-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
  @media (max-width: 770px) {
    #round-robin-codes-table {
      padding-bottom: 12px;
      div.v-data-footer {
        display: inline-block;
        width: 100%;
        padding-bottom: 12px;

        div.v-data-footer__select {
          justify-content: center;
        }

        div.v-data-footer__pagination {

        }

        div.v-data-footer__icons-before {
          display: inline;
          margin-left: calc(50% - 36px);
        }

        div.v-data-footer__icons-after {
          display: inline;
        }

      }
    }
  }

</style>


