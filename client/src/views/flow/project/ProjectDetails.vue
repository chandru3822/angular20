<template>
  <div id="project-details-container" class="py-0">
    <div class="pa-0 height-one-hunned">
      <div class="project-header" v-if="!tabsLoading">
        <v-tabs v-if="tabs.length > 0"
                background-color="transparent"
                v-model="selectedTab.uniqueIdentifier"
                show-arrows>
          <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
          <v-tab v-for="t in tabs" :key="t.id"
                 @click="tabSelection(t)">
            {{ t.tabName }}
          </v-tab>
        </v-tabs>
        <v-tabs v-else background-color="transparent">
          <v-tab>
            Project Details
          </v-tab>
        </v-tabs>
        <v-toolbar color="secondary" class="elevation-0 process-step-toolbar mx-6"
                   v-if="displayedGroups && displayedGroups.length > 0">
          <v-toolbar-title class="albatross-header-2">{{ selectedTab.tabName }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text
                   @click="setSplitColumnValue()">
              <v-icon v-if="!$store.state.project.manualColumnSplit">mdi-format-columns</v-icon>
              <v-icon v-else>mdi-format-align-justify</v-icon>
            </v-btn>
            <div>
              <v-btn
                v-if="userCanEdit"
                color="primaryCustom"
                class="white--text mt-3"
                :loading="isFieldsLoading"
                :disabled="fieldsSaving"
                @click="updateFieldGroups()">Save Fields
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </div>
      <div class="project-fields-container px-3" ref="projectFieldsContainer">
        <v-form ref="projectForm">
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
                <v-toolbar-title class="albatross-header-4">{{ group.groupName }}</v-toolbar-title>
              </v-toolbar>
              <v-card class="px-4 text-left square-card">
                <v-row>
                  <v-col :cols="$store.state.project.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                    <CustomValueInput
                      v-for="(field, idx) in getCustomFieldValuesToDisplay(group.customFieldValues,1)"
                      :key="idx"
                      :required="field.required"
                      :callback="populateDirtyCfvs"
                      :readonly="getReadOnly(field)"
                      :showFieldName="false"
                      :field="field"
                    />
                  </v-col>
                  <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
                    <CustomValueInput
                      v-for="(field, idx) in getCustomFieldValuesToDisplay(group.customFieldValues, 2)"
                      :key="idx"
                      :required="field.required"
                      :callback="populateDirtyCfvs"
                      :readonly="getReadOnly(field)"
                      :showFieldName="false"
                      :field="field"
                    />
                  </v-col>
                </v-row>
              </v-card>
            </v-col>
          </div>
        </v-form>
      </div>
    </div>

  </div>
</template>

<script>

import {
  handleHidingGlobalLoader,
  getRequest,
  postRequest,
  logError,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import {ProjectMutations} from '@/stores/ProjectStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import {getCustomFieldReadOnly} from '@/services/customFieldService'

export default {
  name: 'ProjectDetails',
  components: {
    SpinnerInline,
    CustomValueInput,
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      tabs: [],
      tabsLoading: true,
      selectedTab: {},
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
      // windowWidth: window.innerWidth,
      // splitColumnMinWidth: 1700
    }
  },
  created() {
    window.document.title = `${this.project.projectName} - Project Details`
    this.getProjectTabs()
    this.getProcessSteps()
    this.getFieldGroups()
  },
  mounted() {
    // window.addEventListener('resize', () => {
    //   this.windowWidth = window.innerWidth
    // })
  },
  props: {
    project: Object,
  },
  computed: {
    displayedGroups() {
      return this.selectedTab?.id ? this.customFieldGroups.filter(cfg => cfg.companyObjectTypeTabId === this.selectedTab.id) : this.customFieldGroups
    },
    processStepsByName() {
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
    setSplitColumnValue() {
      //flip the flag
      this.$store.commit(ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT)
    },
    getCustomFieldValuesToDisplay(values, columnNum) {
      if (this.$store.state.project.manualColumnSplit) {
        return values.filter(function (element, index, values) {
          return (index % 2 === (columnNum === 1 ? 0 : 1));
        });
      } else {
        return values
      }
    },
    tabSelection(t) {
      this.selectedTab = t
      this.$refs.projectFieldsContainer.scrollTop = 0
    },
    getProjectTabs: async function () {
      this.tabsLoading = true
      try {
        let params = {
          projectId: parseInt(this.projectId)
        }
        const {data} = await getRequestWithParams(`/objectTypeTab/project`, {params})
        this.tabs = data
        this.selectedTab = this.tabs?.length > 0 ? data[0] : {}
      } catch (e) {
        logError(e)
      } finally {
        this.tabsLoading = false
      }
    },
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
      if (this.$refs.projectForm.validate()) {
        this.fieldsSaving = true
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.dirtyCfvs)
          if (this.dirtyCfvs.length > 0) {
            this.getProcessSteps()
          }
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.snackbar = getSnackbar('SUCCESS', 'Fields Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Project Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } finally {
          this.fieldsSaving = false
        }
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
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
  padding-left: 0 !important;
  padding-right: 0 !important;
  max-height: 100%;
  height: 100%;
  position: relative;
}

.project-header {
}

.project-fields-container {
  overflow: auto;
  height: calc(100% - 115px);
  padding-bottom: 20px !important;
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
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.manage-btn {

  margin-left: 12px;

  & > .v-btn__content {
    color: white !important;
  }
}
</style>
