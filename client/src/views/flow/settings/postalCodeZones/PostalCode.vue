<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3"></v-breadcrumbs>
    <v-app-bar color="white" tabs flat class="elevation-1">
      <v-toolbar-title class="pt-2">
        <div v-if="editZone">
          <v-text-field text class="d-inline-block mt-4"
                        type="text"
                        label="Name"
                        v-model="zone.zoneName">
          </v-text-field>
          <v-text-field text class="d-inline-block mt-4 ml-3"
                        type="text"
                        label="Distribution Time Frame"
                        v-model="zone.distributionTimeFrameDays">
          </v-text-field>
          <v-text-field text class="d-inline-block mt-4 ml-3"
                        type="text"
                        label="Schedulable Future Days"
                        v-model="zone.schedulableFutureDays">
          </v-text-field>
          <v-btn text color="primaryCustom" @click="saveZoneInfo()">
            <v-icon>save</v-icon>
          </v-btn>
        </div>
        <div v-else>
          {{zone.zoneName}}

          <div class="dtf">
            Distribution Time Frame: {{zone.distributionTimeFrameDays}} days
          </div>
          <div class="dtf mb-2">
            Schedulable Future Days:
            <span v-if="zone.schedulableFutureDays">{{zone.schedulableFutureDays}} days</span>
            <span v-else>N/A</span>
          </div>


        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text v-if="userCanEdit" @click="editZone = !editZone">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
      <v-tabs :optional="false" color="primaryCustom"
              slot="extension"
              class="hello"
              dense
              background-color="white" v-model="model" slider-color="primaryCustom">
        <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
          {{tab.label}}
        </v-tab>
      </v-tabs>
    </v-app-bar>
    <router-view class="mt-1 pt-0 postal-code-view"/>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, deleteRequest, putRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'PostalCode',

    data() {
      return {
        snackbar: {},
        model: '',
        tabs: [ {
          label: 'Schedule To',
          path: `/settings/postalCode/${this.$route.params.id}/scheduleTo`,
          display: true
        }, {
          label: 'Schedule By',
          path: `/settings/postalCode/${this.$route.params.id}/scheduleBy`,
          display: true
        }, {
          label: 'Postal Codes',
          path: `/settings/postalCode/${this.$route.params.id}/codes`,
          display: true
        }],
        editZone: false,
        constants,
        zone: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        zoneId: this.$route.params.id,
        dataLoading: true,
        breadcrumbs: [
          {
            text: 'Back to Round Robins',
            disabled: false,
            exact: true,
            to: `/settings/postalCodes`
          },
        ]
      }
    },
    created () {
      this.getZoneDetails()
    },
    methods: {
      async saveZoneInfo () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/postalCode/zone`, this.zone)
          this.editZone = false
          this.snackbar = getSnackbar('SUCCESS', 'Zone Name Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Zone Name')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getZoneDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/postalCode/zone/${this.zoneId}`)
          this.zone = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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

<style lang="scss">
</style>

<style lang="scss" scoped>
  .dtf {
    font-size: 14px;
  }
</style>

