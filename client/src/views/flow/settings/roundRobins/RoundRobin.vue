<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3"></v-breadcrumbs>
    <v-toolbar class="elevation-0">
      <v-toolbar-title class="pt-2">
        {{ roundRobin.roundRobinName }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanEdit" @click="editRoundRobin = !editRoundRobin">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <div v-if="!editRoundRobin" class="px-4 py-2">
      <div class="dtf">
        Distribution Time Frame: {{ roundRobin.distributionTimeFrameDays }} days
      </div>
      <div class="dtf">
        Schedulable Future Days:
        <span v-if="roundRobin.schedulableFutureDays">{{ roundRobin.schedulableFutureDays }} days</span>
        <span v-else>N/A</span>
      </div>
      <div  class="dtf">
        Timezone: {{ roundRobin.timezone }}
      </div>
      <div class="dtf">
        Uses Total Lead Allocation: {{ roundRobin.usesTotalLeadAllocation ? 'Yes' : 'No'}}
      </div>
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
                              v-model="roundRobin.roundRobinName">
                </v-text-field>
              </td>
            </tr>
            <tr>
              <td class="px-2">
                <v-text-field text
                              type="text"
                              label="Distribution Time Frame"
                              v-model="roundRobin.distributionTimeFrameDays">
                </v-text-field>
              </td>
              <td class="px-2">
                <v-text-field text
                              type="text"
                              label="Schedulable Future Days"
                              v-model="roundRobin.schedulableFutureDays">
                </v-text-field>
              </td>
            </tr>
            <tr>
              <td class="px-2">
                <v-autocomplete v-model="roundRobin.companyTimezoneId"
                                :items="companyTimezones"
                                label="Time Zone"
                                style="width: 200px;"
                                item-text="timezone"
                                item-value="id"
                                attach
                ></v-autocomplete>
              </td>
              <td class="px-2">
                <div class="allocation-label">Uses Total Lead Allocation?</div>
<!--                <v-checkbox label="Uses Total Lead Allocation?" v-model="roundRobin.usesTotalLeadAllocation"></v-checkbox>-->
                <v-simple-checkbox class="allocation-checkbox" label="Uses Total Lead Allocation?" v-model="roundRobin.usesTotalLeadAllocation"></v-simple-checkbox>

              </td>
              <td class="pl-5 pb-3">
                <v-btn color="primary" :disabled="!roundRobin.roundRobinName || !roundRobin.companyTimezoneId"
                       class="white--text" @click="saveRoundRobinInfo()">
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
    <v-tabs :optional="false" color="primary" id="round-robin-tabs"
            slot="extension"
            class="hello"
            dense
            background-color="white" v-model="model" slider-color="primary">
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
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'RoundRobin',

  data() {
    return {
      snackbar: {},
      model: '',
      tabs: [{
        label: 'Schedule To',
        path: `/settings/roundRobin/${this.$route.params.id}/scheduleTo`,
        display: true
      }, {
        label: 'Schedule By',
        path: `/settings/roundRobin/${this.$route.params.id}/scheduleBy`,
        display: true
      }, {
        label: 'Postal Codes',
        path: `/settings/roundRobin/${this.$route.params.id}/codes`,
        display: true
      }],
      editRoundRobin: false,
      constants,
      companyTimezones: [],
      roundRobin: {},
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
      roundRobinId: this.$route.params.id,
      dataLoading: true,
      breadcrumbs: [
        {
          text: 'Back to Round Robins',
          disabled: false,
          exact: true,
          to: `/settings/roundRobins`
        },
      ]
    }
  },
  async created() {
    this.getCompanyTimezones()
    await this.getRoundRobinDetails()
  },
  methods: {
    async saveRoundRobinInfo() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest(`/roundRobin`, this.roundRobin)
        this.editRoundRobin = false
        this.snackbar = getSnackbar('SUCCESS', 'Round Robin Name Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Round Robin Name')
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
    async getRoundRobinDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/roundRobin/${this.roundRobinId}`)
        this.roundRobin = data
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
.allocation-label {
  color: rgba(0, 0, 0, 0.6);
  font-size: 12px;
  width: 200px;
  display: flex;
  flex-direction: column;
}

.allocation-checkbox {
  align-self: start;
  margin-top: 8px;
}
</style>
<style lang="scss">
@media (max-width: 959px) {
  #round-robin-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #round-robin-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>

