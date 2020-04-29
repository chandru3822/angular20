<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Export Proposal Log</v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>

        <DatetimePickerInput
          v-model="prop.startDate"
          :timezone="this.timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          label="Start Date"
        />
        <DatetimePickerInput
          v-model="prop.endDate"
          :timezone="this.timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          label="End Date"
        />
        <v-spacer></v-spacer>
        <v-btn @click="exportProposalLog">Export</v-btn>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { saveAs } from 'file-saver'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar, IS_MOBILE} from '@/helpers/helpers'
  import moment from "moment";

  export default {
    name: 'Export',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        timezone: this.$store.state.user.details.timezone.value,
        prop: {
          startDate: moment().subtract(1, 'w').format('MM/DD/YYYY'),
          endDate: moment().format('MM/DD/YYYY')
        },
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        expanded: []
      }
    },
    async created () {
    },
    methods: {
      async exportProposalLog () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            startDate: moment(this.prop.startDate).format('YYYY-MM-DD'),
            endDate: moment(this.prop.endDate).format('YYYY-MM-DD'),
          }
          const {data} = await postRequest(`/propTool/proposal/export`, params)
          let blob = new Blob([data], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, "proposal_log.csv");
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Proposal Logs')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

