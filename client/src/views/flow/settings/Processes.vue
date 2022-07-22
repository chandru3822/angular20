<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Processes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newProject = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newProcess.processName"
                        placeholder="Enter new process name"
                        label="Process">
          </v-text-field>
          <v-btn color="primary" :disabled="!newProcess.processName" v-if="addNew" @click="addNewProcess">Save</v-btn>
          <v-list v-for="(p, index) in filterBy(processes, false, 'archived')"
                  :key="index">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left clickable" @click="goToProcess(p.id)">
                {{p.processName}}
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-btn @click="goToProcess(p.id)" text color="primary">
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-list-item-action>
              <v-btn
                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  @click="processToDelete=p" color="primary" text
              >
                <v-icon>delete</v-icon>
              </v-btn>
              <ConfirmationDialog :open-dialog="!!processToDelete" @confirm="deleteProcess" @close-dialog="processToDelete = null">
                Are you sure you want to delete this process: <strong>{{ processToDeleteName }}</strong>?

              </ConfirmationDialog>
            </v-list-item>
          </v-list>
          <!--<v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'

import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'Processes',
  components: {ConfirmationDialog, ConfirmDeleteDialog},
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      constants,
      addNew: false,
      selectedProcessId: null,
      newProcess: {},
      companyId: this.$store.state.user.details.companyId,
      parentCompanyId: this.$store.state.user.details.highestParentCompanyId,
      userId: this.$store.state.user.details.id,
      processes: [],
      processToDelete: null
    }
  },
  computed: {
    processToDeleteName() {
      return this.processToDelete ? this.processToDelete.processName : ''
    }
  },
  methods: {
    goToProcess(processId) {
      this.$router.push({path: `/settings/processes/${processId}`})
    },
    async getProcesses () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/processes`)
        this.processes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteProcess() {
      const processId = this.processToDelete.id
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/processes/${processId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Process Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.processToDelete.archived = true
      this.processToDelete = null
    },
    async addNewProcess () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newProcess.companyId = this.companyId
        this.newProcess.parentCompanyId = this.parentCompanyId ? this.parentCompanyId : this.companyId
        this.newProcess.createdById = this.userId

        const {data, status} = await postRequest(`/processes`, this.newProcess)

        handleHidingGlobalLoader(this, status)
        this.$router.push({name: 'process', params: {id: data.id}})
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  async created () {
    this.getProcesses()
  }
}
</script>
