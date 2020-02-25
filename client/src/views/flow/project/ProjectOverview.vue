<template>
<v-row id="project-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/customer/${customer.id}`">{{ customer.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}
        </div>
      </v-col>

      <v-col cols="4" class="lead-owner pb-2 text-right">
        <div v-if="!displayChangeOwner">
          <div v-if="project.owner && project.owner.userId">
            <v-avatar
              :tile="false"
              :size="25"
              color="grey lighten-4"
              class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{project.owner.fullName}}<br/>
            {{project.owner.position}}
          </div>
        </div>
        <div v-if="displayChangeOwner">
          <v-autocomplete v-model="project.owner"
                          :items="availableOwners"
                          label="Select Owner"
                          item-text="fullName"
                          return-object
                          autocomplete="off"
                          @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="customer.owner && customer.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
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
          <ActiveProjectProcessStepSnippet
            :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)"
            :projectId="projectId"
            :customerId="customer.id"/>
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
                :steps="step.processSteps"
                :projectId="projectId"
                :customerId="customer.id"/>
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

import {getRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import Snackbar from '@/components/Snackbar.vue'
import CustomValueInput from '@/views/flow/components/CustomValueInput'

export default {
  name: 'ProjectOverview',
  components: {
    SpinnerInline,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    Attachments,
    NotesAndActivity,
    Snackbar,
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
      customer: {},
      displayChangeOwner: false,
      availableOwners: [],
      project: {}
    }
  },
  created () {
    this.getProject()
    this.getFieldGroups()
    this.getProcessSteps()
    this.getNotes()
    this.getCustomer()
    this.getAvailableOwners()
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
        //@TODO: @randa, pretty sure the customer list will work for process steps and projects but double checking
        const {data} = await getRequest(`/customer/owners`)
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
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.customFieldGroups)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Update Project Fields')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
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
    },
    updateOwner: async function () {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/project/${this.projectId}/owner`, this.project.owner)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
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
