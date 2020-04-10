<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Processes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newProject = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="IS_MOBILE">add</v-icon>
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
          <v-btn v-if="addNew" @click="addNewProcess">Save</v-btn>
          <v-list v-for="(p, index) in filterBy(processes, false, 'archived')"
                  :key="index">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left clickable" @click="goToProcess(p.id)">
                {{p.processName}}
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-btn @click="goToProcess(p.id)" text>
                  <v-icon>edit</v-icon>
                </v-btn>
              </v-list-item-action>
              <v-dialog
                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  v-model="p.deleteConfirm"
                  width="500">
                <template v-slot:activator="{ on }">
                  <v-list-item-action class="clickable" v-on="on">
                    <v-icon>delete</v-icon>
                  </v-list-item-action>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this process: <strong>{{ p.processName }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="p.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="[p.archived = true, deleteProcess(p.id)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
          <!--<v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
        </v-container>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import Snackbar from '@/components/Snackbar.vue'
import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE } from '@/helpers/helpers'

export default {
  name: 'Processes',
  mixins: [Vue2Filters.mixin],
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      IS_MOBILE,
      addNew: false,
      selectedProcessId: null,
      newProcess: {},
      companyId: this.$store.state.user.details.companyId,
      parentCompanyId: this.$store.state.user.details.highestParentCompanyId,
      userId: this.$store.state.user.details.id,
      processes: []
    }
  },
  computed: {
  },
  methods: {
    goToProcess(processId) {
      this.$router.push({path: `/settings/processes/${processId}`})
    },
    async getProcesses () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/processes`)
        this.processes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteProcess (processId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/processes/${processId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Process Deleted')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Process')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addNewProcess () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newProcess.companyId = this.companyId
        this.newProcess.parentCompanyId = this.parentCompanyId ? this.parentCompanyId : this.companyId
        this.newProcess.createdById = this.userId

        const {data} = await postRequest(`/processes`, this.newProcess)

        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$router.push({name: 'process', params: {id: data.id}})
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Process')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  async created () {
    this.getProcesses()
  }
}
</script>

<style scoped lang="scss">

</style>
