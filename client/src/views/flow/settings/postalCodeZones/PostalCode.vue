<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3"></v-breadcrumbs>
    <v-toolbar class="elevation-0">
      <v-toolbar-title class="pt-2">
        {{ zone.zoneName }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text v-if="userCanEdit" @click="editZone = !editZone">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <div v-if="!editZone" class="px-4 py-2">
      <div class="dtf">
        Distribution Time Frame: {{ zone.distributionTimeFrameDays }} days
      </div>
      <div class="dtf">
        Schedulable Future Days:
        <span v-if="zone.schedulableFutureDays">{{ zone.schedulableFutureDays }} days</span>
        <span v-else>N/A</span>
      </div>
      <div  class="dtf" v-if="zone.remote">{{ zone.timezone }}</div>
    </div>
    <div v-else>
      <v-row>
        <v-col cols="12" md="6">
          <table style="width: 100%">
            <tr>
              <td colspan="2" class="px-2">
                <v-text-field text
                              type="text"
                              label="Name"
                              v-model="zone.zoneName">
                </v-text-field>
              </td>
            </tr>
            <tr>
              <td class="px-2">
                <v-text-field text
                              type="text"
                              label="Distribution Time Frame"
                              v-model="zone.distributionTimeFrameDays">
                </v-text-field>
              </td>
              <td class="px-2">
                <v-text-field text
                              type="text"
                              label="Schedulable Future Days"
                              v-model="zone.schedulableFutureDays">
                </v-text-field>
              </td>
            </tr>
            <tr>
              <td class="px-2">
                <v-autocomplete v-model="zone.companyTimezoneId"
                                :items="companyTimezones"
                                label="Time Zone"
                                v-if="zone.remote"
                                style="width: 200px;"
                                item-text="timezone"
                                item-value="id"
                                attach
                ></v-autocomplete>
              </td>
              <td class="pl-5 pb-3">
                <v-btn color="primaryCustom" dark class="white--text" @click="saveZoneInfo()">
                  <v-icon>save</v-icon>
                  Save
                </v-btn>
              </td>
            </tr>
          </table>
        </v-col>
      </v-row>
    </div>
    <v-divider></v-divider>
    <!--    <v-toolbar dense color="white" tabs flat class="elevation-1">-->
    <v-tabs :optional="false" color="primaryCustom"
            slot="extension"
            class="hello"
            dense
            background-color="white" v-model="model" slider-color="primaryCustom">
      <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
        {{ tab.label }}
      </v-tab>
    </v-tabs>
    <v-divider></v-divider>
    <!--    </v-toolbar>-->
    <router-view class="mt-1 pt-0 postal-code-view"/>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'PostalCode',

  data() {
    return {
      snackbar: {},
      model: '',
      tabs: [{
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
      companyTimezones: [],
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
  async created() {
    await this.getZoneDetails()
    if (this.zone?.remote) {
      this.getCompanyTimezones()
    }
  },
  methods: {
    async saveZoneInfo() {
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
    async getCompanyTimezones() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/timezone`)
        this.companyTimezones = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Timezones')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getZoneDetails() {
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

<style lang="scss" scoped>
.dtf {
  font-size: 14px;
}
</style>

