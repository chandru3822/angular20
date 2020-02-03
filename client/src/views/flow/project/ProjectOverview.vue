<template>
<v-row id="project-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="4" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/lead/${customer.id}`">{{ customer.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}
        </div>
      </v-col>

      <v-col cols="8" class="pb-0">
        <v-row justify="end" class="pb-0">
          <UserCard
            name="Riley Burgess"
            role="Setter"
            location="Colorado"
            imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
            class="user-card"/>

          <UserCard
            name="Mike Falls"
            role="Closer"
            location="Colorado"
            imageUrl="https://s3.amazonaws.com/blueraven-apps/brLogo-57.png"
            class="user-card"/>
        </v-row>
      </v-col>

    </v-row>
  </v-col>

  <v-col cols="12" lg="6">

    <v-col v-if="isFieldsLoading">
      <SpinnerInline :size="20" color="primary"/>
    </v-col>

    <v-col
      v-else
      class="mt-4"
      v-for="(group, index) in customFieldGroups"
      :key="index"
    >
<!--      <ProjectFieldGroup :group="group"/>-->
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>{{group.groupName}}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <!--              <v-btn text @click="saveLead">Save</v-btn>-->
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4 text-left">
        <CustomValueInput
          v-for="(field, idx) in group.customFieldValues"
          :key="idx"
          :readonly="field.ancillaryCustomFieldGroupAssignmentId !== null"
          :showFieldName="false"
          :field="field"
        />
      </v-card>
    </v-col>

    <v-col>
      <v-row>
        <v-col cols="12">
          <h3 class="text-left">Active Process Steps</h3>
        </v-col>

        <v-col cols="12" v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primary"/>
        </v-col>

        <v-col cols="12" v-else>
          <ActiveProjectProcessStepSnippet :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)" :projectId="projectId"/>
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
              <ProjectProcessStepSnippet :steps="step.processSteps" :projectId="projectId"/>
            </template>
          </v-col>

        </v-row>
      </v-col>
    </v-expand-transition>

    <v-col>
      <v-row>
        <Attachments :projectId="projectId"/>
      </v-row>
    </v-col>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">

    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
    />
  </v-col>

  <Snackbar :snackbar="snackbar"/>
</v-row>
</template>

<script>

import {getRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import ProjectFieldGroup from '@/views/flow/project/ProjectFieldGroup'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import Snackbar from '@/components/Snackbar.vue'
import UserCard from '@/views/flow/components/UserCard'
import CustomValueInput from '@/views/flow/components/CustomValueInput'

export default {
  name: 'ProjectOverview',
  components: {
    SpinnerInline,
    ProjectFieldGroup,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    Attachments,
    NotesAndActivity,
    Snackbar,
    UserCard,
    CustomValueInput
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true,
      notes: [],
      snackbar: {},
      isProcessStepsExpanded: false,
      companyId: this.$store.state.user.details.companyId,
      customer: {}
    }
  },
  created () {
    this.getFieldGroups()
    this.getProcessSteps()
    this.getNotes()
    this.getCustomer()
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
    getNotes: async function () {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectNotes`, {
          params: {
            primaryId: this.projectId
          }
        })
        this.notes = data
      } catch {
        console.log('done gone boom')
      }
    },
    getCustomer: async function () {
      try {
        const{data} = await getRequest(`/customer/project/${this.projectId}`)
        this.customer = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#project-container {
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

.user-card {
  margin-left: 10px;
  margin-right: 10px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 48px;
  }
}
</style>
