<template>
  <v-container>
    <confirm-delete-dialog-improved :open-confirm-delete-dialog="unsavedFieldsModal" @closeConfirmDeleteDialog="unsavedFieldsModal = false" @confirm-delete="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields.  Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirm-delete-dialog-improved>
    <v-breadcrumbs color="primary lighten-1" :items="breadcrumbs"></v-breadcrumbs>
    <v-row class="org-header elevation-1">
      <v-col cols="12" class="text-left">
        <div class="org-title">Organization</div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6" class="text-left">
        <v-form ref="orgForm">
          <div>
            <v-toolbar color="transparent" class="elevation-0">
              <v-toolbar-title>Summary</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text color="primary" :loading="fieldsLoading"
                       :disabled="fieldsSaving || (org.schedulable && !org.companyTimezoneId)"
                       @click="saveOrg()" v-if="userCanEdit">Save
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <v-text-field text
                            label="Organization Name"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            :rules="requiredRules"
                            @change="dirtySystemFields = true"
                            v-model="org.orgName"></v-text-field>
              <v-select attach v-model="org.orgTypeId"
                        :items="orgTypes"
                        label="Organization Type"
                        :rules="requiredRules"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @change="dirtySystemFields = true"
                        item-text="orgType"
                        item-value="id"
                        @input="getOrgsByType(org.orgTypeId)"
              ></v-select>
              <v-autocomplete attach v-model="org.parentOrgId"
                              :items="parents"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              @change="dirtySystemFields = true"
                              :append-outer-icon="org.parentOrgId ? `mdi-open-in-new` : null"
                              @click:append-outer="goToPath(`/org/${org.parentOrgId}`, true)"
                              label="Parent Organization"
                              item-text="orgName"
                              item-value="id"
              ></v-autocomplete>
              <v-select attach v-model="org.companyStateId"
                        :items="states"
                        @change="dirtySystemFields = true"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="State"
                        item-text="state"
                        item-value="id"
              ></v-select>
              <v-autocomplete v-model="org.companyTimezoneId"
                              :items="companyTimezones"
                              label="Time Zone"
                              @change="dirtySystemFields = true"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              hide-details
                              item-text="timezone"
                              item-value="id"
                              attach
              ></v-autocomplete>
              <h6 class="mt-1 red-text" v-if="org.schedulable && !org.companyTimezoneId">* Required when Schedulable
                Organization</h6>
              <div class="mb-3 mt-3">
                <label>Active:</label>
                <input type="checkbox" :disabled="!userIsAdmin" :readonly="!userIsAdmin" class="ml-2"
                       v-model="org.activeFlag" @change="dirtySystemFields = true">
              </div>
              <div class="mb-3">
                <label>Show in Scheduling Tool:</label>
                <input type="checkbox" :disabled="!userCanEdit" :readonly="!userCanEdit" class="ml-2"
                       v-model="org.schedulable" @change="dirtySystemFields = true">
              </div>
              <div class="mb-3" v-if="$store.getters.isParent(parentId)">
                <label>Make available in children:</label>
                <input type="checkbox" :readonly="!userCanEdit" :disabled="!userCanEdit"
                       @change="dirtySystemFields = true"
                       class="ml-3" v-model="org.availableToChildren">
              </div>
            </v-card>
          </div>
          <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
            <v-toolbar color="transparent" class="elevation-0">
              <v-toolbar-title>{{ cfg.groupName }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                                :key="cf.id"
                                :required="cf.required"
                                :callback="populateDirtyCfvs"
                                :readonly="getReadOnly(cf)"
                                :field="cf"></CustomValueInput>
            </v-card>
          </div>
        </v-form>
      </v-col>
      <v-col cols="12" md="6" class="text-left pa-0 mt-3 px-3">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Users in Org</v-toolbar-title>
          </v-toolbar>
          <v-card class="square-card" color="white">
            <v-data-table
              :headers="headers"
              :items="usersInOrg"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1"
            >
              <template #no-data>
                No users found
              </template>

              <template #no-results>
                No users found
              </template>

              <template #item="{ item:user }">
                <tr class="text-left" :class="{'shaded-row': usersInOrg.indexOf(user) % 2}">
                  <td class="text-left">{{ user.fullName }}</td>
                  <td class="text-left">{{ user.position }}</td>
                  <td class="text-right">
                    <v-btn small text @click="goToPath(`/user/${user.id}/details`, true)">
                      <v-icon>mdi-open-in-new</v-icon>
                    </v-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
        </div>
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Child Organizations</v-toolbar-title>
          </v-toolbar>
          <v-card class="square-card" color="white">
            <v-data-table
              :headers="childHeaders"
              :items="org.childOrgs"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1"
            >
              <template #no-data>
                No child orgs found
              </template>

              <template #no-results>
                No child orgs found
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
                    <v-btn small text @click="goToPath(`/org/${item.id}`, true)">
                      <v-icon>mdi-open-in-new</v-icon>
                    </v-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
        </div>
        <Attachments :object-type-id="5" :org-id="orgId"/>
      </v-col>
    </v-row>

  </v-container>
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
  getSnackbar
} from '@/helpers/helpers'
import {getOrgTypes, getOrgsByType} from '@/services/orgService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import Attachments from '@/views/flow/components/Attachments'
import constants from "@/helpers/constants";
import ConfirmDeleteDialogImproved from "@/ConfirmDeleteDialogImproved";

  export default {
    name: 'Org',
    components: {
      ConfirmDeleteDialogImproved,

    CustomValueInput,
    Attachments
  },
  data() {
    return {
      breadcrumbs: [
        {
          text: 'Back to Organizations',
          disabled: false,
          exact: true,
          to: `/orgs`
        },
      ],
      snackbar: {},
      org: {},
      customFieldGroups: [],
      usersInOrg: [],
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
      dirtySystemFields: false,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      parents: [],
      dirtyCfvs: [],
      companyTimezones: [],
      states: [],
      fieldsSaving: false,
      fieldsLoading: true,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ORGS', 'EDIT'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('ORGS', 'ADMIN'),
      orgId: parseInt(this.$route.params.id),
      companyId: this.$store.state.user.details.companyId,
      parentId: this.$store.state.user.details.parentCompanyId,
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
    goToPath(path, targetBlank) {
      if (targetBlank) {
        let routerData = this.$router.resolve({path})
        window.open(routerData.href, '_blank')
      } else {
        this.$router.push(path)
      }
    },
    async saveOrg() {
      if (this.$refs.orgForm.validate()) {
        this.fieldsSaving = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.org.customFieldGroups = this.customFieldGroups
        try {
          const {status} = await putRequest(`/org`, this.org)
          // update dirty field values
          const {data} = await postRequest(`/customFieldValues/org/${this.orgId}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.dirtySystemFields = false
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

<style lang="scss" scoped>
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
</style>

