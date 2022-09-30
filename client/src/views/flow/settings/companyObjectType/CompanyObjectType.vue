<template>
  <v-container class="custom-field-group-container pa-6">
    <v-row>
      <v-col cols="12" class="shrink">
        <router-link :to="`/settings/companyObjectTypes`">Back</router-link>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{ objectType.objectType }} - Custom Field Groups
          </v-toolbar-title>
          <v-spacer />
          <v-text-field v-if="addNew"
                        v-model="newGroup.groupName"
                        placeholder="Enter new group name"
                        append-outer-icon="save"
                        @click:append-outer="addCustomFieldGroup"
                        label="Custom Field Group" />
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newGroup = {}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>

        </v-toolbar>
        <v-card flat class="mb-4 pt-3 px-3">
          Note: Some company specific screens ignore the display order and group name of Custom Fields Groups
          represented here.
        </v-card>
        <CompanyCustomFieldGroup v-if="customFieldGroups.length && objectType.id != null" :object-type="objectType" :custom-field-groups="customFieldGroups" @group-deleted="getCustomFieldGroups"/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import constants from '@/helpers/constants'
import CompanyCustomFieldGroup from './CompanyCustomFieldGroup'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader, postRequest} from "@/helpers/helpers";
import cloneDeep from "lodash.clonedeep";

export default {
  name: 'CompanyObjectType',
  components: {
    CompanyCustomFieldGroup
  },
  data () {
    return {
      snackbar: {},
      constants,
      companyObjectTypeId: this.$route.params.id,
      objectType: {},
      customFieldGroups:[],
      addNew: false,
      newGroup: {
        groupName: null
      },
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
    }
  },
  computed:{

  },
  created () {
    this.getObjectType()
    this.getCustomFieldGroups()
  },
  methods: {
    async getObjectType() {
      //we have to get the object type details to determine if it can use ancillary fields
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/objectType/getByType/${this.$route.params.id}`, 'blueraven')
        this.objectType = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
          params: {
            companyObjectTypeId: this.$route.params.id
          }
        }, 'blueraven')
        this.customFieldGroups = cloneDeep(data.map(d => {
          d.customFields.forEach(cf => cf.hasConditionalOnId = !!cf.conditionalOnId)
          return d
        }))
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async addCustomFieldGroup() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.objectTypeId = parseInt(this.$route.params.id)
        const { data, status } = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup, 'blueraven')
        this.newGroup = {}
        this.addNew = false
        // add the new type to the list
        this.customFieldGroups.push(data)
        this.snackbar = getSnackbar('SUCCESS', 'Group Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Custom Field Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

  }
}
</script>
