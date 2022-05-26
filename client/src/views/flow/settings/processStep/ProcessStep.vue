<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/processSteps'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <div class="flex-display pt-3 px-3 mb-4" style="width: 100%">
          <div style="width: 100%">
            <span class="page-title" v-if="!editName">{{ processStep.processStepName }}</span>
            <v-text-field v-else color="primary"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="processStep.processStepName"
                          label="Process Step Name"></v-text-field>
            <div>
              <label class="mt-4">Allow Non-Admin to Add to Project:</label>
              <input class="ml-3" type="checkbox" :readonly="!userCanEdit" @input="saveProcessStep($event,false)"
                     :disabled="!userCanEdit" v-model="processStep.nonAdminAdd">
            </div>
          </div>
          <div class="text-right" v-if="userCanEdit">
            <v-btn text v-if="!editName" class="" @click="[oldName = processStep.processStepName, editName = !editName]">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text class="" v-else @click="saveProcessStep($event,true)">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn text  v-if="editName" class="" @click="[processStep.processStepName = oldName, editName = !editName]">
              cancel
            </v-btn>
          </div>
        </div>
        <v-tabs class="tabs-bar" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>

        <router-view :non-admin-add="processStep.nonAdminAdd"/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'

  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { handleHidingGlobalLoader, getRequest, putRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepCustomFieldGroups,
    },
    data () {
      return {
        snackbar: {},
        constants,
        editName: false,
        oldName: null,
        processStepId: this.$route.params.id,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        tabs: [
          {
            id: 1,
            label: 'UI Components',
            path: `/settings/processStep/${this.$route.params.id}/components`,
          },
          {
            id: 2,
            label: 'Custom Field Groups',
            path: `/settings/processStep/${this.$route.params.id}/customFieldGroups`,
          },
          {
            id: 3,
            label: 'Actions',
            path: `/settings/processStep/${this.$route.params.id}/actions`,
          },
          {
            id: 4,
            label: 'events',
            path: `/settings/processStep/${this.$route.params.id}/events`,
          }
        ]
      }
    },
    computed: {
      //this should not be so hard
      activeTab: {
        get: function() {
          return this.$route?.path?.includes('/event') ? `/settings/processStep/${this.$route.params.id}/events` : null
        },
        set: function(val) {
          return val
        }
      }
    },
    async created () {
      this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/processStep/${this.processStepId}`)
          this.processStep = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveProcessStep(e, closeEditor) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //vue is weird and doesn't update this value before the @input is called
          this.processStep.nonAdminAdd = e.target.checked || false
          const {status} = await putRequest(`/processStep`, this.processStep)
          this.editName = false
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Process Step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
.page-title {
  font-size: 18px;
  font-weight: 200;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
