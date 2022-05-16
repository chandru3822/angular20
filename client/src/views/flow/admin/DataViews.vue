<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Data Views</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newDataView = {}, getCompanyProcesses()]" v-if="is7oaksAdmin">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Data View</h3>
          <div class="mb-3">
            <v-form ref="dataViewForm">
            <v-text-field text v-model="newDataView.displayName"
                          :rules="requiredRules"
                          label="Display Name" />
            <v-text-field text v-model="newDataView.viewName"
                          :rules="tableNameRule"
                          label="Table Name (all lower case, underscores instead of spaces)" />
              <v-select label="Company Processes"
                        v-model="selectedCompanyProcesses"
                        :items="companyProcesses"
                        item-text="processName"
                        placeholder="Select"
                        multiple
                        return-object>
              </v-select>
            </v-form>
          </div>
          <div class="mb-3 error--text" v-if="saveError">
            {{saveErrorMsg}}
          </div>
          <v-btn :disabled="!newDataView.displayName || !newDataView.viewName || selectedCompanyProcesses.length === 0"
                 color="primaryCustom" class="white--text mr-2"
                 @click="validateForm(newDataView, true)">
            Save
          </v-btn>
          <v-btn @click="[addNew = !addNew, newDataView = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="dataViews"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No data
          </template>

          <template #item="{ item }">
            <tr  class="text-left" @click="goToView(item.id)" :class="{'shaded-row': dataViews.indexOf(item) % 2}">
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.viewName }}</td>
              <td class="text-right">
                <v-btn small text>
                  <v-icon>edit</v-icon>
                </v-btn>

              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'DataViews',

    data() {
      return {
        snackbar: {},
        constants,
        addNew: false,
        saveError: false,
        saveErrorMsg: '',
        dataViews: [],
        companyProcesses: [],
        selectedCompanyProcesses: [],
        requiredRules: constants.BASIC_REQUIRED_RULE,
        is7oaksAdmin: this.$store.getters.isFullAdmin,
        tableNameRule: [
          () => (this.newDataView.viewName != null && this.newDataView.viewName !== '') || "Field to Update is required",
          v => (!v || (v && (v.length >= 5))) || 'Must be 5 characters or more',
          v => (!v || (v && (v.length <= 60))) || 'Must be 60 characters or less',
          v => (!v || (v && (v.indexOf(' ') <= 0))) || 'Cannot contain whitespace',
          v => (!v || (v && (v.indexOf('__') <= 0))) || "All word dividers must be a single '_'",
          v => (!v || (/^[a-z]+(?:_+[a-z]+)*$/.test(v))) || "Table Name must be all lowercase, no symbols except '_' and must start and end with a letter",
          v => (!v || (v && (!constants.RESERVED_SQL_WORDS.includes(v)))) || "Cannot use reserved words",
        ],
        newDataView: {},
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        headers: [
          { text: 'Display Name', value: 'displayName', show: true },
          { text: 'Table Name', value: 'viewName', width: 80, show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ]
      }
    },
    async created () {
      await this.getDataViews()
    },
    methods: {
      async getCompanyProcesses() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/processes`)
          this.companyProcesses = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error loading processes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      validateForm(view, isNew) {
        this.saveError = false
        let match = this.dataViews?.find(dv => dv.viewName === view.viewName)
        if(match) {
          this.saveError = true
          this.saveErrorMsg = 'Table Name already in use'
        } else if (this.$refs.dataViewForm?.validate()) {
          this.saveDataView(view, isNew)
        }
      },
      async goToView(id) {
        this.$router.push(`/admin/dataView/${id}`)
      },
      async saveDataView(dv, isNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          dv.companyProcessIds = this.selectedCompanyProcesses.map(cp => cp.id)
          const {data, status} = await postRequest(`/dataView`, dv)
          if(isNew){
            this.dataViews.push(data)
            this.addNew = false
            this.selectedCompanyProcesses = []
            this.newDataView = {}
            this.snackbar = getSnackbar('SUCCESS', 'Data View Added')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.snackbar = getSnackbar('SUCCESS', 'Data View Updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Data View' : 'Error Updating Data View')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getDataViews() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dataView`)
          this.dataViews = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Data Views')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
