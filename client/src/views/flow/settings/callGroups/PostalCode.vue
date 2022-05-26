<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3 back-link"></v-breadcrumbs>
    <v-app-bar color="white" tabs flat class="elevation-1 call-group-bar">
      <v-toolbar-title class="pt-2">
        <div v-if="editGroup">
          <v-text-field text class="d-inline-block mt-4 edit-text"
                        type="text"
                        label="Name"
                        tabindex=1
                        v-model="group.callGroupName">
          </v-text-field>
          <v-btn text color="primary" @click="saveGroupInfo()">
            <v-icon>save</v-icon>
          </v-btn>
        </div>
        <div v-else style="margin-top: 30px">
          <b>Call Group Name:</b> {{group.callGroupName}}
        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text v-if="userCanEdit" @click="editGroup = !editGroup">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
      <v-tabs :optional="false" color="primary"
              slot="extension"
              class="hello"
              dense
              background-color="white" v-model="model" slider-color="primary" style="margin-top: 60px">
        <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
          {{tab.label}}
        </v-tab>
      </v-tabs>
    </v-app-bar>
    <router-view class="mt-1 pt-0"/>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'PostalCode',

    data() {
      return {
        snackbar: {},
        model: '',
        tabs: [
          {
            label: 'Phone Numbers',
            path: `/settings/callGroup/${this.$route.params.id}/numbers`,
            display: true
          },
          {
          label: 'Postal Codes',
          path: `/settings/callGroup/${this.$route.params.id}/codes`,
          display: true
          }
        ],
        editGroup: false,
        constants,
        group: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT'),
        callGroupId: this.$route.params.id,
        dataLoading: true,
        breadcrumbs: [
          {
            text: 'Back to Call Groups',
            disabled: false,
            exact: true,
            to: `/settings/callGroups`
          },
        ]
      }
    },
    created () {
      this.getCallGroupDetails()
    },
    methods: {
      async saveGroupInfo () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/callGroup/`, this.group, 'blueraven')
          this.group = data
          this.editGroup = false
          this.snackbar = getSnackbar('SUCCESS', 'Call Group saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Call Group')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCallGroupDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/callGroup/${this.callGroupId}`, 'blueraven')
          this.group = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss" scoped>
  .dtf {
    font-size: 14px;
  }
  .call-group-bar {
    min-height: 150px;
  }
  .edit-text {
    margin-left: 25px;
  }
  .back-link
  {
    margin-bottom: 15px;
  }
</style>

