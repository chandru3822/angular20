<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Postal Code Zones</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newZone = {}]" v-if="userCanAdd">
              <span v-if="!addNew">{{'Add New'}}</span>
              <span v-else>{{'Cancel'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Zone Name"
                tabindex=1
                v-model="newZone.zoneName"
            ></v-text-field>

            <v-btn color="primary" :disabled="!newZone.zoneName"
                   @click="addPostalCodeZone" class="mb-3">Save</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search zones"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :search="search"
              :items="filterPostalCodeZones()"
              :fixed-header="true"
              :options.sync="options"
              :footer-props="footerProps"
              disable-sort
              :mobile-breakpoint="0"
              :loading="dataLoading"
              class="elevation-1 round-robin-table table-striped"
            >

              <template #item="{ item, index }">
                <tr class="">
                  <td class="clickable text-left"  @click="goToZone(item)">
                    {{ item.zoneName }}
                  </td>
                  <td class="text-right">
                    <v-btn small icon @click="goToZone(item)"
                           :large="$vuetify.breakpoint.smAndDown" color="primary">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="userCanDelete" icon :large="$vuetify.breakpoint.smAndDown" color="primary" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
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
        @confirm="deletePostalCodeZone"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this zone: <strong>{{itemToDeleteName}}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import {  handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import constants from "@/helpers/constants";

  export default {
    name: 'PostalCodeZones',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        addNew: false,
        search: null,
        newZone: {},
        dataLoading: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('POSTAL_CODE', 'DELETE'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        postalCodeZones: [],
        headers: [
          {text: 'Zone Name', value: 'zoneName', show: true},
          {text: '', value: 'icons', show: true, width: "100"},
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
      goToZone(zone) {
        this.$router.push({path: `/settings/zip/zone/${zone.id}`})
      },
      filterPostalCodeZones () {
        return this.postalCodeZones.filter(pcz => { return !pcz.archived})
      },
      async getPostalCodeZones () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/zones`)
          this.postalCodeZones = data
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
      async deletePostalCodeZone () {
        this.itemToDelete.archived = true
        const postalCodeZoneId = this.itemToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/postalCode/zone/${postalCodeZoneId}`)
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
      async addPostalCodeZone () {
        // this.$store.commit(AppMutations.SET_LOADING, true)
        // try {
        //   const {data, status} = await postRequest(`/roundRobin`, this.newZone)
        //   this.$router.push({path: `/settings/roundRobin/${data.id}/scheduleTo`})
        //   this.snackbar = getSnackbar('SUCCESS', 'Round Robin Added')
        //   this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //   handleHidingGlobalLoader(this, status)
        // } catch (e) {
        //   console.error('*** ERROR ***', e)
        //   this.snackbar = getSnackbar('ERROR', 'Error Adding Round Robin')
        //   this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //   this.$store.commit(AppMutations.SET_LOADING, false)
        // }
      },
      closeDeleteDialog() {
        this.showDeleteDialog = false;
        this.itemToDelete = null;
      }
    },
    async created () {
      this.getPostalCodeZones()
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

