<template>
  <div id="org-container">
    <!--    modal for leaving with unsaved fields -->
    <confirmation-dialog :open-dialog="unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>
    <!--    end unsaved fields modal -->
    <!--    modal for editing contact fields -->
    <confirmation-dialog :open-dialog="showEditModal" @close-dialog="showEditModal = false" @confirm="validateForm">
      <template v-slot:title>Organization Overview</template>
      <v-form ref="orgEditForm">
        <v-text-field
          v-model="tempOrg.orgName"
          :readonly="!userCanEdit"
          :disabled="!userCanEdit"
          label="Organization Name"
        ></v-text-field>
        <v-select attach v-model="tempOrg.orgTypeId"
                  :items="orgTypes"
                  label="Organization Type"
                  :rules="requiredRules"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  item-text="orgType"
                  item-value="id"
                  @input="getOrgsByType(tempOrg.orgTypeId)"
        ></v-select>
        <v-autocomplete attach v-model="tempOrg.parentOrgId"
                        :items="parents"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Parent Organization"
                        item-text="orgName"
                        item-value="id"
        ></v-autocomplete>
        <v-autocomplete attach v-model="tempOrg.companyStateId"
                  :items="states"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="State"
                  clearable
                  item-text="state"
                  item-value="id"
        ></v-autocomplete>
        <v-autocomplete v-model="tempOrg.companyTimezoneId"
                        :items="companyTimezones"
                        label="Time Zone"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        hide-details
                        clearable
                        item-text="timezone"
                        item-value="id"
                        attach
        ></v-autocomplete>
        <h6 class="mt-1 red-text" v-if="tempOrg.schedulable && !tempOrg.companyTimezoneId">* Required when
          Schedulable
          Organization</h6>
        <div class="mb-3 mt-3">
          <label>Active:</label>
          <input type="checkbox" :disabled="!userIsAdmin" :readonly="!userIsAdmin" class="ml-2"
                 v-model="tempOrg.activeFlag">
        </div>
        <div class="mb-3">
          <label>Show in Scheduling Tool:</label>
          <input type="checkbox" :disabled="!userCanEdit" :readonly="!userCanEdit" class="ml-2"
                 v-model="tempOrg.schedulable">
        </div>
        <div class="mb-3" v-if="$store.getters.isParent(parentId)">
          <label>Make available in children:</label>
          <input type="checkbox" :readonly="!userCanEdit" :disabled="!userCanEdit"
                 class="ml-3" v-model="tempOrg.availableToChildren">
        </div>
      </v-form>
      <template v-slot:yes>save</template>
    </confirmation-dialog>
    <!--    end dialog -->
    <ThreeColumnLayout :header-text="org.orgName"
                       :auto-overflow-left="false">
      <template v-slot:back-btn>
        <v-btn fab text small color="primary" class="mr-2" @click="goToPath('/orgs')">
          <v-icon>mdi-view-list</v-icon>
        </v-btn>
      </template>
      <template v-slot:left-column>
        <div v-if="!$store.state.project.leftSideSplit && org && org.id"
             class="px-2 height-one-hunned overflow-y-auto">
          <PageOverview v-if="org && org.id"
                        page-name="Organization"
                        :show-edit-btn="userCanEdit"
                        @clickEdit="[tempOrg = cloneDeep(org), showEditModal = true]"
                        :details="overviewDetails"
                        @click-detail="goToPath(`/org/${org.parentOrgId}`, true)"
          ></PageOverview>
          <v-divider class="mt-4"></v-divider>
        </div>
      </template>
      <template v-slot:main-column>
        <div>
          <!-- this cannot be inside the v-if display or else the fixed toolbar doesn't work -->
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="albatross-header-3">
              Organization Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text color="primary" @click="setSplitColumnValue()" class="px-0">
                <v-icon v-if="!$store.state.project.manualColumnSplit" class="px-0">mdi-format-columns</v-icon>
                <v-icon v-else class="px-0">mdi-format-align-justify</v-icon>
              </v-btn>
              <div>
                <v-btn color="primary"
                       class="white--text mt-3"
                       v-if="userCanEdit"
                       :loading="fieldsLoading"
                       :disabled="fieldsSaving"
                       @click="saveOrg()">
                  Save Fields
                </v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div v-if="org && org.id && !fieldsLoading" style="overflow-x: hidden">
            <div class="px-4">
              <v-btn @click="[showChildOrgs = !showChildOrgs, showUsersAssignedToOrg = false]" :text="showChildOrgs"
                     color="primary" small>
                {{ showChildOrgs ? 'Hide' : 'Show' }} Child Organizations
              </v-btn>
              <br/>
              <v-btn @click="[showUsersAssignedToOrg = !showUsersAssignedToOrg, showChildOrgs = false]"
                     :text="showUsersAssignedToOrg" color="primary" small
                     class="mt-3">
                {{ showUsersAssignedToOrg ? 'Hide' : 'Show' }} Assigned Users
              </v-btn>
            </div>
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar px-4" dense
                       v-if="showUsersAssignedToOrg">
              <v-toolbar-title>
                Users Assigned to this Organization
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-data-table
              v-if="showUsersAssignedToOrg"
              :headers="headers"
              :items="usersInOrg"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1  square-card mx-4"
            >
              <template #no-data>
                <span class="default-text-color">No users found</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No users found</span>
              </template>

              <template #item="{ item:user }">
                <tr class="text-left" :class="{'shaded-row': usersInOrg.indexOf(user) % 2}">
                  <td class="text-left">{{ user.fullName }}</td>
                  <td class="text-left">{{ user.position }}</td>
                  <td class="text-right">
                    <v-btn small text class="anchor" @click="goToPath(`/user/${user.id}/details`, true)">
                      <v-icon>mdi-open-in-new</v-icon>
                    </v-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar px-4" dense v-if="showChildOrgs">
              <v-toolbar-title>
                Child Organizations
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-data-table
              :headers="childHeaders"
              :items="org.childOrgs"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1 square-card mx-4"
              v-if="showChildOrgs"
            >
              <template #no-data>
                <span class="default-text-color">No child orgs found</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No child orgs found</span>
              </template>

              <template #item="{ item }">
                <tr class="text-left" :class="{'shaded-row': org.childOrgs.indexOf(item) % 2}">
                  <td class="text-left">{{ item.orgName }}</td>
                  <td class="text-left">{{ item.orgType }}</td>
                  <td class="text-left">
                    <v-checkbox disabled readonly
                                v-model="item.activeFlag"/>
                  </td>
                  <td class="text-right">
                    <v-btn small text class="anchor" @click="goToPath(`/org/${item.id}`, true)">
                      <v-icon>mdi-open-in-new</v-icon>
                    </v-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>

            <v-row class="px-5">
              <v-col cols="12" class="text-left py-0 px-0">
                <v-form ref="orgForm">
                  <v-col
                    class="pt-0"
                    v-for="(cfg, index) in customFieldGroups"
                    :key="index"
                  >
                    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
                      <v-toolbar-title>
                        {{ cfg.groupName }}
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                      </v-toolbar-items>
                    </v-toolbar>

                    <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                      <v-row>
                        <v-col :cols="$store.state.project.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                        <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                      </v-row>

                    </v-card>
                  </v-col>

                </v-form>
              </v-col>
            </v-row>
          </div>
          <div v-else>
            <SpinnerInline centered :size="50" color="primary"/>
          </div>
        </div>
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="org && org.id"
                         :org-id="orgId"
                         :object-type-id="5"
                         :force-show-upload-btn="true"
                         :show-sms-tab="false"></ProjectActivity>
      </template>
    </ThreeColumnLayout>

  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar, logError
} from '@/helpers/helpers'
import {getOrgTypes, getOrgsByType} from '@/services/orgService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from "@/helpers/constants";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import SpinnerInline from '@/components/SpinnerInline'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import cloneDeep from 'lodash.clonedeep'
import Style from "@/views/blueraven/settings/proposalDesigner/panel/Style";
import {ProjectMutations} from "@/stores/ProjectStore";
import PageOverview from "../PageOverview";

export default {
  name: 'Org',
  components: {
    PageOverview,
    ConfirmationDialog,
    Style,
    SpinnerInline,
    ThreeColumnLayout,
    ProjectActivity,
    CustomValueInput,
  },
  data() {
    return {
      snackbar: {},
      org: {},
      tempOrg: {},
      showEditModal: false,
      customFieldGroups: [],
      usersInOrg: [],
      cloneDeep,
      headers: [
        {text: 'User', value: 'user', show: true},
        {text: 'Position', value: 'position', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      childHeaders: [
        {text: 'Organization', value: 'orgName', show: true},
        {text: 'Type', value: 'orgType', show: true},
        {text: 'Active?', value: 'activeFlag', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      orgTypes: [],
      unsavedFieldsModal: false,
      toPath: null,
      navigationOverride: false,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      parents: [],
      dirtyCfvs: [],
      companyTimezones: [],
      states: [],
      fieldsSaving: false,
      showChildOrgs: false,
      showUsersAssignedToOrg: false,
      fieldsLoading: true,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ORGS', 'EDIT'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('ORGS', 'ADMIN'),
      orgId: parseInt(this.$route.params.id),
      companyId: this.$store.state.user.details.companyId,
      parentId: this.$store.state.user.details.parentCompanyId,
    }
  },
  computed: {
    overviewDetails() {
      if (this.org) {
        return [
          {
            label: 'Status',
            type: constants.OVERVIEW_FIELD_TYPES.STATUS,
            value: this.org.activeFlag ? 'Active' : 'Inactive',
            active: this.org.activeFlag
          },
          {
            label: 'Type',
            type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
            value: this.org.orgType
          },
          {
            label: 'Parent',
            type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
            value: this.org.parentOrgName,
            clickable: true
          },
          {
            label: 'State',
            type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
            value: this.org.state
          },
          {
            label: 'Timezone',
            type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
            value: this.org.timezone
          },
          {
            label: 'Show in Scheduling Tool',
            type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
            value: this.org.schedulable ? 'Yes' : 'No'
          }
        ];
      }
      return []
    }
  },

  async created() {
    let requests = [
      this.getCustomFieldGroups(),
      this.getCompanyTimezones(),
      this.getOrgTypes(),
      this.getOrg(),
      this.getCompanyStates(),
      this.getUsersInOrg()
    ]
    await Promise.all(requests).then(async () => {
      this.fieldsLoading = false
      if (this.org.parentOrgTypeId) {
        this.getOrgsByType(this.org.parentOrgTypeId)
      }
    })
  },
  beforeRouteLeave(to, from, next) {
    // called when the route that renders this component is about to
    // be navigated away from.
    // has access to `this` component instance.
    if (this.navigationOverride || (this.dirtyCfvs.length === 0 && !this.dirtySystemFields)) {
      //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
      next()
    } else {
      this.toPath = to.path
      this.unsavedFieldsModal = true
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
    goToPath(path, targetBlank) {
      if (targetBlank) {
        let routerData = this.$router.resolve({path})
        window.open(routerData.href, '_blank')
      } else {
        this.$router.push(path)
      }
    },
    async validateForm() {
      if (this.$refs.orgEditForm.validate()) {
        await this.saveOrgSystemFields()
        this.showEditModal = false
      }
    },
    saveOrgSystemFields: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/org`, this.tempOrg)
        this.org = data
        this.showEditModal = false
        this.snackbar = getSnackbar('SUCCESS', 'Organization Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveOrg() {
      if (this.$refs.orgForm.validate()) {
        this.fieldsSaving = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.org.customFieldGroups = this.customFieldGroups
        try {
          // update dirty field values
          const {data} = await postRequest(`/customFieldValues/org/${this.orgId}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.snackbar = getSnackbar('SUCCESS', 'Organization Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = this.org.id ? 'Error Saving Organization' : 'Error Adding Organization'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/customFieldValues/org/${this.orgId}`)
        this.customFieldGroups = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyTimezones() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/timezone`)
        this.companyTimezones = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Timezones')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOrg() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/org/${this.orgId}`)
        this.org = data

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Organization')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOrgTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getOrgTypes()
        this.orgTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOrgsByType(orgTypeId) {
      try {
        const {data, status} = await getOrgsByType(orgTypeId)
        this.parents = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Parent Orgs')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUsersInOrg() {
      try {
        const {data, status} = await getRequest(`/org/${this.orgId}/users`)
        this.usersInOrg = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users In Org')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCompanyStates() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyStates()
        this.states = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field) || !this.userCanEdit
    }
  }
}
</script>

<style lang="scss">
.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}
</style>

<style lang="scss" scoped>
#org-container {
  width: 100vw;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.org-header {
  background-color: white;
}

.org-title {
  font-size: 30px;
}

.org-subtitle {
  font-size: 20px;
}

.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}

.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken1);
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

</style>

