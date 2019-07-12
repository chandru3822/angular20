<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Processes</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newProject = {}">
            {{addNew ? 'Cancel' : 'Add New'}}
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
          <v-list-item>
            <v-list-item-content>
              <v-text-field class="one-hunned" v-if="selectedProcessId === p.id" v-model="p.processName">
              </v-text-field>
              <div v-else>{{p.processName}}</div>
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-btn :to="{ path: `/settings/process/${p.id}`}" text>
                <v-icon>edit</v-icon>
              </v-btn>
            </v-list-item-action>
            <v-dialog
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
                      @click="p.archived = true; deleteProcess(p.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
        <!--<v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

export default {
  name: 'Processes',
  mixins: [Vue2Filters.mixin],
  data () {
    return {
      addNew: false,
      selectedProcessId: null,
      newProcess: {},
      companyId: this.$store.state.user.details.companyId,
      parentCompanyId: this.$store.state.user.details.parentCompanyId,
      userId: this.$store.state.user.details.id,
      processes: []
    }
  },
  computed: {
  },
  methods: {
    async getProcesses () {
      const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processes`)
      this.processes = data
    },
    async deleteProcess (processId) {
      await deleteRequest(`/api/v1/flow/companies/${this.companyId}/processes/${processId}`)
    },
    async addNewProcess () {
      this.newProcess.companyId = this.companyId
      this.newProcess.parentCompanyId = this.parentCompanyId ? this.parentCompanyId : this.companyId
      this.newProcess.createdById = this.userId

      const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/processes`, this.newProcess)

      // add it to the records already on the screen
      this.processes.push(data)
      this.processes = orderBy(this.processes, [p => p.processName.toLowerCase()])

      // reset the new process fields
      this.addNew = false
      this.newProcess = {}
    },
    // async saveProcess (p) {
    //   this.selectedProcessId = null
    //   p.modifiedById = this.userId
    //   await putRequest(`/api/v1/flow/companies/${this.companyId}/processes`, p)
    // }
  },
  async created () {
    this.getProcesses()
  }
}
</script>

<style scoped lang="scss">

</style>
