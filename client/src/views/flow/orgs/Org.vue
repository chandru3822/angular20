<template>
  <v-container>
    <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
    <v-row class="org-header elevation-1">
      <v-col cols="12" class="text-left">
        <div class="org-title">Organization</div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" md="6" class="text-left">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Summary</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text @click="saveOrg" v-if="userCanEdit">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <v-text-field text
                          label="Organization Name"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="org.orgName"></v-text-field>
            <v-select v-model="org.orgTypeId"
                      :items="orgTypes"
                      label="Organization Type"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      item-text="orgType"
                      item-value="id"
                      @input="getOrgsByType(org.orgTypeId)"
            ></v-select>
            <v-select v-model="org.parentOrgId"
                      :items="parents"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      label="Parent Organization"
                      item-text="orgName"
                      item-value="id"
            ></v-select>
            <v-select v-model="org.companyStateId"
                      :items="states"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      label="State"
                      item-text="state"
                      item-value="id"
            ></v-select>
            <v-autocomplete v-model="org.companyTimezoneId"
                      :items="companyTimezones"
                      label="Time Zone"
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      item-text="timezone"
                      item-value="id"
            ></v-autocomplete>
            <div class="mb-3">
              <label>Active:</label>
              <input type="checkbox" :disabled="!userCanEdit" :readonly="!userCanEdit" class="ml-2" v-model="org.activeFlag">
            </div>
            <div class="mb-3">
              <label>Show in Scheduling Tool:</label>
              <input type="checkbox" :disabled="!userCanEdit" :readonly="!userCanEdit" class="ml-2" v-model="org.schedulable">
            </div>
            <div class="mb-3" v-if="$store.getters.isParent(parentId)">
              <label>Make available in children:</label>
              <input type="checkbox" :readonly="!userCanEdit" :disabled="!userCanEdit"
                     class="ml-3" v-model="org.availableToChildren">
            </div>
          </v-card>
        </div>
        <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                              :key="cf.id"
                              :callback="populateDirtyCfvs"
                              :readonly="getReadOnly(cf)"
                              :field="cf"></CustomValueInput>
          </v-card>
        </div>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getStates} from '@/services/stateService'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import {getOrgTypes, getOrgsByType} from '@/services/orgService'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'

  export default {
    name: 'Org',
    components: {
      Snackbar,
      CustomValueInput
    },
    data () {
      return {
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/orgs`
          },
        ],
        snackbar: {},
        org: {},
        customFieldGroups: [],
        orgTypes: [],
        parents: [],
        dirtyCfvs: [],
        companyTimezones: [],
        states: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ORGS', 'EDIT'),
        orgId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        parentId: this.$store.state.user.details.parentCompanyId,
      }
    },
    async created () {
      this.getCustomFieldGroups()
      this.getCompanyTimezones()
      this.getOrgTypes()
      await this.getOrg()
      this.getOrgsByType(this.org.parentOrgTypeId)
      this.getStates()
    },
    methods: {
      async saveOrg() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.org.customFieldGroups = this.customFieldGroups
        try {
          await putRequest(`/org`, this.org)
          // update dirty field values
          const {data} = await postRequest(`/customFieldValues/org/${this.orgId}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.snackbar = getSnackbar('SUCCESS', 'Organization Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = this.org.id ? 'Error Saving Organization' : 'Error Adding Organization'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateDirtyCfvs(field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if(!match) {
          this.dirtyCfvs.push(field)
        }
      },
      async getCustomFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/customFieldValues/org/${this.orgId}`)
          this.customFieldGroups = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyTimezones() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/timezone`)
          this.companyTimezones = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Timezones')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrg () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/org/${this.orgId}`)
          this.org = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Organization')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgTypes()
          this.orgTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgsByType (orgTypeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgsByType(orgTypeId)
          this.parents = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Parent Orgs')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
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
</style>

