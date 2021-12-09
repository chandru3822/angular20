<template>
<v-row id="project-details-container" v-if="project && project.id" class="mt-2">
  <v-col cols="12" lg="12" class="pt-0">
    <v-col v-if="isFieldsLoading">
      <SpinnerInline :size="20" color="primaryCustom"/>
    </v-col>

    <div v-else>
      <v-col
        :class="{ 'mt-4': index !== 0 }"
        class="py-0"
        v-for="(group, index) in displayedGroups"
        :key="index"
      >
        <v-toolbar color="transparent" class="elevation-0 process-step-toolbar">
          <v-toolbar-title>{{group.groupName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          <v-btn
            v-if="index === 0 && userCanEdit"
            text
            :disabled="fieldsSaving"
            @click="[fieldsSaving = true, updateFieldGroups()]">Save</v-btn>
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
    </div>

  </v-col>

</v-row>
</template>

<script>

import {handleHidingGlobalLoader, getRequest, postRequest, logError, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'

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
    CustomValueInput,
    AddProcessStep
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      menuOpen: false,
      fieldsSaving: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      isProcessStepsLoading: false,
      isFieldsLoading: true,
      dirtyCfvs: [],
      snackbar: {},
      isProcessStepsExpanded: false,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created () {
    this.getProcessSteps()
    this.getFieldGroups()
  },
  props: {
    project: Object,
    selectedTab: Object
  },
  computed: {
    displayedGroups () {
      return this.selectedTab?.id ? this.customFieldGroups.filter(cfg => cfg.companyObjectTypeTabId === this.selectedTab.id ) : this.customFieldGroups
    },
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
    getDirtyFieldsCount() {
      return this.dirtyCfvs?.length || 0
    },
    getProcessSteps: async function () {
      try {
      this.isProcessStepsLoading = true
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
        const {data} = await getRequest(`/customFieldValues/project/${this.projectId}`, null, [])
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isFieldsLoading = false
      }
    },
    updateFieldGroups: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.dirtyCfvs)
        if (this.dirtyCfvs.length > 0) {
          this.getProcessSteps()
        }
        this.dirtyCfvs = []
        this.customFieldGroups = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Project Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } finally {
        this.fieldsSaving = false
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if(!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field) || !this.userCanEdit
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
.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}
.manage-btn {

  margin-left: 12px;

  & > .v-btn__content {
    color: white !important;
  }
}
</style>
