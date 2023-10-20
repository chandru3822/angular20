<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Postal Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newPostalCode = {}, getStates()]" v-if="userCanAdd">
              <span v-if="!addNew">{{ 'Add New' }}</span>
              <span v-else>{{ 'Cancel' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-form ref="postalCodeForm">
              <v-text-field
                label="Postal Code"
                tabindex=1
                counter
                maxlength="10"
                @keypress="isNumberOrHyphen"
                :rules="postalCodeRules"
                v-model="newPostalCode.postalCode"
              ></v-text-field>
              <v-text-field
                label="Place Name"
                tabindex=1
                v-model="newPostalCode.placeName"
              ></v-text-field>
              <v-autocomplete
                :items="states"
                item-value="id"
                item-text="state"
                clearable
                label="State"
                v-model="newPostalCode.stateId"
              ></v-autocomplete>
              <v-btn color="primary"
                     :disabled="!newPostalCode.postalCode || !newPostalCode.placeName || !newPostalCode.stateId"
                     @click="validateForm" class="mb-3">Save
              </v-btn>
            </v-form>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                clearable
                prepend-inner-icon="search"
                label="Search postal codes"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :search="search"
              :items="filterPostalCodes()"
              :fixed-header="true"
              :options.sync="options"
              :footer-props="footerProps"
              disable-sort
              :mobile-breakpoint="0"
              :loading="dataLoading"
              class="elevation-1 round-robin-table table-striped"
            >

              <template #item="{ item, index }">
                <tr class="clickable">
                  <td class="text-left" @click="goToPostalCode(item)">
                    {{ item.postalCode }}
                  </td>
                  <td class="text-left" @click="goToPostalCode(item)">{{ item.placeName }}</td>
                  <td class="text-left" @click="goToPostalCode(item)">{{ item.zoneName }}</td>
                  <td class="text-left" @click="goToPostalCode(item)">{{ item.stateAbbreviation }}</td>
                  <td class="text-left" @click="goToPostalCode(item)">{{ item.roundRobinName }}</td>
                  <td class="text-left" @click="goToPostalCode(item)">{{ item.callGroupName }}</td>
                  <td class="text-left">
                    <v-checkbox disabled readonly v-model="item.disqualified">{{ item.disqualified }}</v-checkbox>
                  </td>
                  <td class="text-left">
                    <v-checkbox disabled readonly v-model="item.selfGenOnly">{{ item.selfGenOnly }}</v-checkbox>
                  </td>
                  <td class="text-left">
                    <v-checkbox disabled readonly v-model="item.insideSales">{{ item.insideSales }}</v-checkbox>
                  </td>
                  <td class="text-left">
                    <v-checkbox disabled readonly v-model="item.salesPartners">{{ item.salesPartners }}</v-checkbox>
                  </td>
                  <td class="text-right">
                    <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                           @click="goToPostalCode(item)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="userCanDelete" icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                           @click="[itemToDelete=item, showDeleteDialog=true]">
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
    <ConfirmationDialog
      :open-dialog="showDeleteDialog"
      @confirm="deletePostalCode"
      @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this postal code: <strong>{{ itemToDeleteName }}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import {
  handleHidingGlobalLoader,
  isNumberOrHyphen,
  getRequest,
  deleteRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import constants from "@/helpers/constants";
import {getStates} from "@/services/stateService";

export default {
  name: 'PostalCodes',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],

  data() {
    return {
      snackbar: {},
      addNew: false,
      isNumberOrHyphen,
      search: null,
      newPostalCode: {},
      states: [],
      dataLoading: true,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        itemsPerPage: 100
      },
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
      companyId: this.$store.state.user.details.companyId,
      userId: this.$store.state.user.details.id,
      postalCodeRules: constants.POSTAL_CODE_FIVE_REQUIRED_RULES,
      postalCodes: [],
      headers: [
        {text: 'Postal Code', value: 'postalCode', show: true},
        {text: 'Name', value: 'placeName', show: true},
        {text: 'Zone', value: 'zoneName', show: true},
        {text: 'State', value: 'state', show: true},
        {text: 'Round Robin', value: 'roundRobinName', show: true},
        {text: 'Call Group', value: 'callGroupName', show: true},
        {text: 'Disqualified', value: 'disqualified', show: true},
        {text: 'Self-Gen Only', value: 'selfGenOnly', show: true},
        {text: 'Inside Sales', value: 'insideSales', show: true},
        {text: 'Sales Partners', value: 'salesPartners', show: true},
        {text: '', value: 'icons', show: true},
      ],
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  computed: {
    itemToDeleteName() {
      return this.itemToDelete ? this.itemToDelete.postalCode : '';
    }
  },
  methods: {
    async validateForm() {
      if (this.$refs.postalCodeForm.validate()) {
        await this.addPostalCode()
      }
    },
    async getStates() {
      if (this.addNew) {
        try {
          const {data, status} = await getStates()
          this.states = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    filterPostalCodes() {
      return this.postalCodes.filter(pcz => {
        return !pcz.archived
      })
    },
    goToPostalCode(pc) {
      this.$router.push({path: `/settings/zip/postalCode/${pc.id}`})
    },
    async getPostalCodes() {
      this.dataLoading = true
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/postalCode`)
        this.postalCodes = data
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
    async deletePostalCode() {
      this.itemToDelete.archived = true
      const postalCodeId = this.itemToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/postalCode/${postalCodeId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Postal Code Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Postal Code')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async addPostalCode() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/postalCode`, this.newPostalCode)
        this.$router.push({path: `/settings/zip/postalCode/${data.id}`})
        this.snackbar = getSnackbar('SUCCESS', 'Postal Code Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = e?.data?.message ? e.data.message : 'Error Adding Postal Code'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeDeleteDialog() {
      this.showDeleteDialog = false;
      this.itemToDelete = null;
    }
  },
  async created() {
    this.getPostalCodes()
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

