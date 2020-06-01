<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        </v-toolbar>
        <v-toolbar flat class="app-toolbar">
  <!--        <v-toolbar-title class="app-title">-->
  <!--          {{ processStep.processStepName }}-->
  <!--        </v-toolbar-title>-->
          <v-text-field class="d-inline-block mt-4" v-if="editName" v-model="processStep.processStepName"></v-text-field>
          <span v-else>
            {{  processStep.processStepName }}
          </span>
          <v-btn class="d-inline-block" small text v-if="editName" @click="saveProcessStep()">
            <v-icon>save</v-icon>
          </v-btn>
          <v-btn class="d-inline-block" small text v-else @click="editName = true">
            <v-icon>edit</v-icon>
          </v-btn>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs>
              <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
              <v-tab :to="`/settings/processStep/${processStepId}/components`">
                UI Components
              </v-tab>
              <v-tab :to="`/settings/processStep/${processStepId}/actions`">
                Actions
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepCustomFieldGroups,
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        constants,
        changesMade: false,
        editName: false,
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/processSteps`
          },
        ]
      }
    },
    computed: {
    },
    async created () {
      this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}`)
          this.processStep = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.editName = false
          await putRequest(`/processStep`, this.processStep)
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Process Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

    }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>
