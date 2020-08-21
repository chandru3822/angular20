<template>
<v-row id="project-details-container">
  <v-col cols="12" lg="6" class="pt-0">

    <v-col v-if="isFieldsLoading">
      <SpinnerInline :size="20" color="primary"/>
    </v-col>

    <v-col
      v-else
      :class="{ 'mt-4': index !== 0 }"
      class="py-0"
      v-for="(group, index) in customFieldGroups"
      :key="index"
    >
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>{{group.groupName}}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
        <v-btn
          v-if="index === 0"
          text
          @click="updateFieldGroups">Save</v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4 text-left square-card">
        <CustomValueInput
          v-for="(field, idx) in group.customFieldValues"
          :key="idx"
          :callback="populateDirtyCfvs"
          :readonly="getReadOnly(field)"
          :showFieldName="false"
          :field="field"
        />
      </v-card>
    </v-col>

    <v-col>
      <v-row>
        <Attachments :projectId="projectId"/>
      </v-row>
    </v-col>
  </v-col>

  <v-col cols="12" lg="6" class="text-left pt-0">
    <v-col class="pt-0">
      <v-row>
        <v-toolbar color="transparent" class="elevation-0">
          <v-toolbar-title>Active Process Steps</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AddProcessStep
              v-if="project.processId"
              class="d-inline-block"
              :project-id="projectId"
              :process-id="project.processId"
              @step-added="getProcessSteps"
            />
            <v-btn
              small
              text
              v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')"
              class="d-inline-block"
              @click="$router.push({name: 'projectAdmin', params: {projectId}})"
            >
              <v-icon>edit</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>

        <v-col cols="12" v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primary"/>
        </v-col>

        <v-col cols="12" v-else class="pt-0">
          <ActiveProjectProcessStepSnippet
            :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)"
            :projectId="projectId"
            :contactId="project.contactId"/>
        </v-col>
      </v-row>
    </v-col>

    <v-fade-transition>
      <v-col
        v-show="!isProcessStepsExpanded"
        cols="12"
        class="text-right pt-0"
      >
        <span @click="isProcessStepsExpanded = true" class="clickable">
          Expand All Process Steps <v-icon>mdi-menu-down</v-icon>
        </span>
      </v-col>
    </v-fade-transition>

    <v-expand-transition>
      <v-col v-show="isProcessStepsExpanded">
        <v-row>
          <v-col cols="12">
            <v-row class="justify-space-around align-center">
              <v-col class="text-left pb-0">
                <h3>All Process Steps</h3>
              </v-col>
              <v-col class="text-right pb-0">
              <span @click="isProcessStepsExpanded = false" class="clickable">
                Collapse All Process Steps <v-icon>mdi-menu-down</v-icon>
              </span>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="12" class="pt-0">
                <v-divider/>
              </v-col>
            </v-row>
          </v-col>

          <v-col cols="12" v-if="isProcessStepsLoading">
            <SpinnerInline :size="20" color="primary"/>
          </v-col>

          <v-col cols="12" v-else>
            <template v-for="step in processStepsByName">
              <h4 class="text-left work-type-header">{{step.processStepName}}</h4>
              <ProjectProcessStepSnippet
                :key="step.processStepName"
                :steps="step.processSteps"
                :projectId="projectId"
                :contactId="project.contactId"/>
            </template>
          </v-col>

        </v-row>
      </v-col>
    </v-expand-transition>
  </v-col>

  <Snackbar :snackbar="snackbar"/>
</v-row>
</template>

<script>

import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import Snackbar from '@/components/Snackbar.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import AddProcessStep from '@/views/flow/components/AddProcessStep'

export default {
  name: 'ProjectDetails',
  components: {
    SpinnerInline,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    Attachments,
    Snackbar,
    CustomValueInput,
    AddProcessStep
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true,
      dirtyCfvs: [],
      snackbar: {},
      isProcessStepsExpanded: false,
      companyId: this.$store.state.user.details.companyId,
      project: {},
    }
  },
  created () {
    this.getProject()
    this.getFieldGroups()
    this.getProcessSteps()
  },
  computed: {
    processStepsByName () {
      const names = [...new Set(this.processSteps.map(step => step.processStepName))]

      return names.map(processStepName => {
        return {
          processStepName,
          processSteps: this.processSteps.filter(step => step.processStepName === processStepName)
        }
      })
    }
  },
  methods: {
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
      } catch (e) {
        logError(e)
      }
    },
    getProcessSteps: async function () {
      try {
       const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
       this.processSteps = data
     } catch (e) {
       logError(e)
     } finally {
       this.isProcessStepsLoading = false
     }
    },
    getFieldGroups: async function () {
      try {
        const {data} = await getRequest(`/customFieldValues/project/${this.projectId}`)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isFieldsLoading = false
      }
    },
    async getAvailableOwners () {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //@TODO: @randa, pretty sure the contact list will work for process steps and projects but double checking
        const {data} = await getRequest(`/project/owners`)
        this.availableOwners = data

        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateFieldGroups: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Project Fields')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if(!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field)
    }
  }
}
</script>

<style lang="scss" scoped>
#project-details-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}
.project-title {
  font-size: 20px;
}
.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 48px;
  }
}
</style>

<style lang="scss">
.manage-btn {

  margin-left: 12px;

  & > .v-btn__content {
    color: white !important;
  }
}
</style>
