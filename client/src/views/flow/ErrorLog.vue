<template>
  <v-container id="users-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Error Log</v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filterErrors()"
            :fixed-header="true"
            disable-sort
            :mobile-breakpoint="0"
            :loading="dataLoading"
            hide-default-footer
            :calculate-widths="true"
            class="elevation-1 fix-column-width-bug"
        >
          <template #no-data>
            <span class="default-text-color">No available errors</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available errors</span>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.featureName}}</td>
              <td class="text-left">{{item.errorMessage}}</td>
              <td class="text-left">{{item.errorLogStatus}}</td>
              <td>
                <v-btn small text color="primary" @click="logToDelete=item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!logToDelete" @confirm="[logToDelete.archived = true, deleteError()]" @close-dialog="logToDelete = null">
      Are you sure you want to delete this error log?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'ErrorLog',
    components: {ConfirmationDialog},
    data () {
      return {
        dialog: false,
        snackbar: {},
        errors: [],
        dataLoading: true,
        headers: [
          { text: 'Feature', value: 'featureName', show: true},
          { text: 'Error', value: 'errorMessage', show: true},
          { text: 'Status', value: 'errorLogStatus', show: true},
          {text: '', value: 'icons', show: true},
        ],
        logToDelete: null
      }
    },
    computed: {},
    created () {
      this.getErrors()
    },
    methods: {
      async getErrors () {
      this.dataLoading = true
        try {
          const {data} = await getRequest(`/errorLog`)
          this.errors = data
          this.dataLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Error Logs')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.dataLoading = false
        }
      },
      async deleteError () {
        const id = this.logToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const {status} = await deleteRequest(`/errorLog/${id}`)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Error Deleting Log')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterErrors () {
        return this.errors.filter(e => { return !e.archived})
      },
    }
  }
</script>

<style lang="scss">
  #users-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
  .filter-header-non-select {
    padding-bottom: 12px !important;
  }

  .user-filter-select,
  .user-filter-select .v-input__control,
  .user-filter-select .v-input__control .v-input__slot,
  .user-filter-select .v-input__control .v-input__slot fieldset {
    height: 40px !important;
    min-height: 40px !important;
  }
  .user-filter-select .v-select__selections {
    padding: 0 0 5px 0 !important;
    height: 40px !important;
  }
  .user-filter-select .v-input__append-inner {
    margin-top: 5px !important;
  }
</style>

<style lang="scss" scoped>
  #users-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
  .user-table {
    margin-top: 2px;
  }
  .user-column {
    overflow: hidden;
  }
</style>

