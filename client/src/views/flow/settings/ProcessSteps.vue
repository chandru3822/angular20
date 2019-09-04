<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar class="testing elevation-1">
        <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newStep = {}">
            {{'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <v-text-field v-if="addNew"
            label="Process Step Name"
            tabindex=1
            v-model="newStep.processStepName"
        ></v-text-field>
        <v-btn v-if="addNew" :disabled="!newStep.processStepName" @click="addProcessStep">Save</v-btn>
        <v-list v-for="(ps, index) in filterBy(processSteps, false, 'archived')"
                :key="index">
          <v-list-item :class="{'shaded-row': index % 2}">
            <v-list-item-content>
              {{ps.processStepName}}
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-btn :to="{ path: `/settings/processStep/${ps.id}/components`}" text>
                <v-icon>edit</v-icon>
              </v-btn>
            </v-list-item-action>
            <v-dialog
                v-model="ps.deleteConfirm"
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
                  Are you sure you want to delete this process step: <strong>{{ ps.processStepName }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="ps.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="ps.archived = true; deleteProcessStep(ps.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import { getSnackbar } from '@/helpers/helpers'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        addNew: false,
        newStep: {},
        selectedProcessStepId: null,
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        processSteps: []
      }
    },
    computed: {
    },
    methods: {
      async getProcessSteps () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep`)
          this.processSteps = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteProcessStep (processStepId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/api/v1/flow/${this.companyId}/processStep/${processStepId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Process Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/api/v1/flow/${this.companyId}/processStep`, this.newStep)
          this.$router.push({path: `/settings/processStep/${data.id}/components`})
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Process Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created () {
      this.getProcessSteps()
    }
  }
</script>

<style scoped lang="scss">


</style>
