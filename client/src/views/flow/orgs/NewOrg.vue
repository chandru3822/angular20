<template>
  <v-container>
    <v-card class="pa-3 text-left" >
      <v-card-title>
        Add Organization
        <v-spacer></v-spacer>
        <v-btn text class="mr-3" to="/orgs">Cancel</v-btn>
        <v-btn color="primaryCustom white--text" :disabled="loadingInsertFields"
               @click="validate">Save</v-btn>
      </v-card-title>

      <v-form ref="orgForm">
        <v-container>
          <v-row>
            <v-col cols="12">
              <v-text-field text
                            label="Organization Name"
                            :rules="requiredRules"
                            v-model="org.orgName"></v-text-field>
              <v-autocomplete v-model="selectedOrgType"
                        :items="orgTypes"
                        label="Organization Type"
                        :rules="requiredRules"
                        item-text="orgType"
                        item-value="id"
                        return-object
                        @input="getOrgsByType()"
                              attach
              ></v-autocomplete>
              <v-autocomplete v-model="org.parentOrgId"
                        :items="parents"
                        label="Parent Organization"
                        item-text="orgName"
                        item-value="id"
                              attach
              ></v-autocomplete>
              <div class="mb-3">
                <label>Show in Scheduling Tool:</label>
                <input type="checkbox" class="ml-2" v-model="org.schedulable">
              </div>
              <div class="mb-3" v-if="$store.getters.isParent(parentId)">
                <label>Make available in children:</label>
                <input type="checkbox" class="ml-3" v-model="org.availableToChildren">
              </div>
            </v-col>
          </v-row>
        </v-container>
        <SpinnerInline v-if="loadingInsertFields" :text="'Checking For Additional Fields...'" :size="20" color="primaryCustom"/>
        <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
          <h3>{{cfg.groupName}}</h3>
          <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                            :key="idx"
                            :callback="populateDirtyCfvs"
                            :required="cf.requireOnInsert"
                            :readonly="getReadOnly(cf)"
                            :field="cf"></CustomValueInput>
        </v-container>
      </v-form>

    </v-card>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getOrgTypes, getOrgsByType} from '@/services/orgService'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'NewLead',
    components: {
      SpinnerInline,
      CustomValueInput
    },
    data () {
      return {
        snackbar: {},
        selectedOrgType: null,
        org: {},
        orgTypes: [],
        loadingInsertFields: true,
        parents: [],
        dirtyCfvs: [],
        customFieldGroups: [],
        parentId: this.$store.state.user.details.parentCompanyId,
        requiredRules: constants.BASIC_REQUIRED_RULE,
        companyId: this.$store.state.user.details.companyId,
      }
    },
    created () {
      this.getCustomFieldGroups()
      this.getOrgTypes()
    },
    methods: {
      validate () {
        if (this.$refs.orgForm.validate()) {
          this.saveOrg()
        }
      },
      async getCustomFieldGroups () {
        this.loadingInsertFields = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldGroup/getOrgInsertFields`)
          this.customFieldGroups = data
          this.loadingInsertFields = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.loadingInsertFields = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOrg () {
        this.org.orgTypeId = this.selectedOrgType?.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.org.customFieldGroups = this.customFieldGroups
        try {
          const {data} = await putRequest(`/org`, this.org)
          this.$router.push({name: 'org', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Org')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgsByType () {
        // this gets the available parents
        if(this.selectedOrgType?.orgParentTypeId) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getOrgsByType(this.selectedOrgType?.orgParentTypeId)
            this.parents = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Parent Orgs')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.parents = []
        }
      },
      populateDirtyCfvs (field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if (!match) {
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
  .v-select ::v-deep .v-select__selection {
    color: var(--v-primaryText-base);
  }
</style>

