<template>
  <v-card>
    <v-card-title class="mb-1">
      <span v-if="startDate === endDate" class="drilldown-title">{{ milestone.name }} on {{ startDate | formatDate('date', 'MM/DD/YYYY') }}</span>
      <span v-else class="drilldown-title">{{ milestone.name }} {{ startDate | formatDate('date', 'MM/DD/YYYY') }} - {{ endDate | formatDate('date', 'MM/DD/YYYY') }}</span>
      <a class="close-modal-x pb-3" title="Close" @click="closeCallback">×</a>
    </v-card-title>

    <v-card-text>
      <v-data-table
        id="drilldown-table"
        :headers="visibleDrilldownHeaders"
        :items="drilldownData"
        :footer-props="footerProps"
        :items-per-page="500"
        :mobile-breakpoint="0"
        fixed-header
        dense
        class="elevation-1"
      >

        <template #header.additionalFieldValue="{}">
          <span v-if="drilldownData && drilldownData[0]">{{ drilldownData[0].additional_field_label }}</span>
        </template>

        <template #header.dateValue="{}">
          <span v-if="drilldownData && drilldownData[0]">{{ drilldownData[0].date_label }}</span>
        </template>

        <template v-if="drilldownData.length > 0" #item="{ item, index }" class="table-body">
          <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
            <td class="text-left">{{ index + 1 }}</td>
            <td class="text-left">{{ item.project_id }}</td>
            <td class="text-left customer-name">{{ item.customer_name }}</td>
            <td class="text-left">{{ item.state }}</td>
            <td class="text-left">{{ item.source_name }}</td>
            <td class="text-left">{{ item.date_value | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
            <td class="text-left" v-if="milestone.has_additional_column">
              <span v-if="item.additional_field_as_date">{{item.additional_field_value | formatDate('date', 'MM/DD/YYYY')}}</span>
              <span v-else>{{ item.additional_field_value }}</span>
            </td>
          </tr>
        </template>

        <template #no-data>
          <div class="my-3">
            No data was found for the specified date range.
          </div>
        </template>
      </v-data-table>
    </v-card-text>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn id="drilldown-close-btn" class="white--text text-capitalize mr-4 mb-2"
             color="primaryButton" @click="closeCallback">
        Close
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
  import constants from '@/helpers/constants'
  import DatetimePickerInput from "@/components/DatetimePickerInput"
  import Snackbar from '@/components/Snackbar.vue'
  import {AppMutations} from '@/stores/AppStore'
  import {getRequestWithParams, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'companyDashboardDrilldown',
    components: {
      DatetimePickerInput,
      Snackbar
    },
    props: {
      milestone: Object,
      drilldownData: Array,
      loadPartners: Boolean,
      closeCallback: Function,
      startDate: String,
      endDate: String
    },
    computed: {
      visibleDrilldownHeaders () {
        return this.drilldownHeaders.filter(header => header.show === true)
      }
    },
    created() {
      if (this.$store?.state?.user?.details?.timezone?.value) {
        this.timezone = this.$store.state.user.details.timezone.value
      }
      // this.getDrilldownData()
    },
    data() {
      return {
        snackbar: {},
        constants,
        headers: [],
        timezone: 'US/Mountain',
        isLoading: true,
        dashValues: [],
        drilldownHeaders: [
          {text: '', value: '', show: true, sortable: false}, // 0
          {text: 'Project ID', value: 'project_id', show: true}, // 1
          {text: 'Customer Name', value: 'customer_name', show: true}, // 2
          {text: 'State', value: 'state', show: true}, // 3
          {text: 'Source', value: 'source_name', show: true}, // 4
          {text: '', value: 'dateValue', show: true}, // 5
          {text: '', value: 'additionalFieldValue', show: this.milestone.has_additional_column}, // 6
        ],
        // drilldownData: [],
        footerProps: {
          showFirstLastPage: !constants.IS_MOBILE,
          firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
          lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
          itemsPerPageText: constants.IS_MOBILE ? '' : 'Rows per page:',
          itemsPerPageOptions: [100, 500, 1000, 2000]
        }
      }
    },
    methods: {

    }

  }
</script>

<style lang="scss">
  #drilldown-table .v-data-table__wrapper {
    height: calc(100vh - 330px);
    min-height: 300px;
  }

  .drilldown-dialog {
    //this is changed if media width > 450
    min-width: 100% !important;
  }

</style>

<style lang="scss" scoped>
  .close-modal-x {
    font-size: 20px;

    &:hover {
      font-weight: bolder;
    }
  }

  .v-card__title {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: center;
  }

  .drilldown-title {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 14px;
  }

  #drilldown-close-btn {
    font-size: 10px;
    height: 25px;
  }

  @media (min-width: 450px) {
    .drilldown-dialog {
      min-width: 379px;
    }
  }

  @media (min-width: 769px) {
    .drilldown-title {
      font-size: 18px;
    }

    #drilldown-table {
      th, td {
        font-size: 12px;
      }

      ::v-deep {
        .v-data-footer {
          padding: initial;
        }
      }
    }

    #drilldown-close-btn {
      font-size: 14px;
      height: 35px;
    }
  }
</style>
