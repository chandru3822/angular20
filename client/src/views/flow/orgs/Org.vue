<template>
  <v-container>
    <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
    <v-row class="org-header elevation-1">
      <v-col xs-12 class="text-left">
        <div class="org-title">Organization</div>
      </v-col>
    </v-row>
    <v-row>
      <v-col xs-6 class="text-left">
        <div>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>Summary</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text @click="saveOrg">Save</v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <v-text-field text
                          label="Organization Name"
                          v-model="org.orgName"></v-text-field>
            <v-select v-model="org.orgTypeId"
                      :items="orgTypes"
                      label="Organization Type"
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
          </v-card>
        </div>
        <div class="mt-4" v-for="cfg in customFieldGroups">
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="pa-4">
            <CustomValueInput v-for="cf in cfg.customFieldValues" :readonly="false" :field="cf"></CustomValueInput>
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
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getOrgTypes, getOrgsByType} from '@/services/orgService'

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
        orgId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    async created () {
      this.getCustomFieldGroups()
      this.getOrgTypes()
      await this.getOrg()
      this.getOrgsByType()
    },
    methods: {
      async saveOrg() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.org.customFieldGroups = this.customFieldGroups
        try {
          const {data} = await putRequest(`/org`, this.org)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Organization')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCustomFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldValues/org`, { params: {
              primaryId: this.orgId
            }})
          this.customFieldGroups = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
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

