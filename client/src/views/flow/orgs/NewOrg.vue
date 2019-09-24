<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add Organization
        <v-spacer></v-spacer>
        <v-btn text class="mr-3" to="/orgs">Cancel</v-btn>
        <v-btn color="primary" dark @click="validate">Save</v-btn>
      </v-card-title>

      <v-form ref="orgForm">
        <v-container>
          <v-row>
            <v-col xs-12>
              <v-text-field text
                            label="Organization Name"
                            :rules="requiredRules"
                            v-model="org.orgName"></v-text-field>
              <v-select v-model="org.orgTypeId"
                        :items="orgTypes"
                        label="Organization Type"
                        :rules="requiredRules"
                        item-text="orgType"
                        item-value="id"
                        @input="getOrgsByType()"
              ></v-select>
              <v-select v-model="org.parentOrgId"
                        :items="parents"
                        label="Parent Organization"
                        item-text="orgName"
                        item-value="id"
              ></v-select>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
      <v-container class="text-left" v-for="cfg in customFieldGroups" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
        <h3>{{cfg.groupName}}</h3>
        <CustomValueInput v-for="cf in cfg.customFieldValues" :readonly="false" :field="cf"></CustomValueInput>
      </v-container>
    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, BASIC_REQUIRED_RULE, EMAIL_RULES, getSnackbar} from '@/helpers/helpers'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getOrgTypes, getOrgsByType} from '@/services/orgService'

  const { VUE_APP_ENV } = process.env

  export default {
    name: 'NewLead',
    components: {
      Snackbar,
      CustomValueInput
    },
    data () {
      return {
        snackbar: {},
        org: {},
        orgTypes: [],
        parents: [],
        customFieldGroups: [],
        requiredRules: BASIC_REQUIRED_RULE,
        companyId: this.$store.state.user.details.companyId,
      }
    },
    created () {
      //todo: use only for testing
      if(VUE_APP_ENV === 'local') {
        this.setFakeOrg()
      }
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldGroup/getOrgInsertFields`)
          this.customFieldGroups = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOrg () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.org.customFieldGroups = this.customFieldGroups
        try {
          const {data} = await putRequest(`/org`, this.org)
          this.$router.push({name: 'org', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Org')
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
      async getOrgsByType () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgsByType(this.org.orgTypeId)
          this.parents = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Parent Orgs')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      setFakeOrg () {
        this.org = {
          orgName: 'Randa Test',
          orgTypeId: 1
        }
      }
    }

  }
</script>

<style lang="scss" scoped>
</style>

