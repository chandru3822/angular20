<script setup>
/*
*@name FunnelDrilldownDialogWithLotsOfColumns
*@author jess
*@date 12/16/24
*
*@description
*
*/

import {computed, ref} from "vue";
import constants from '@/helpers/constants'
import {useUserStore} from "@/stores/UserStore.js";
const userStore = useUserStore()

const props = defineProps({
  value: Boolean,
  funnelDrilldownTitle: String,
  funnelDrilldownData: Array,
  funnelDrilldownLoading: Boolean,
  funnelDrilldownHeaders: Array,
  selectedFunnel: Object,
  totalSystemSize: Number
})

const emit = defineEmits(['close', 'export'])
const show = computed(() => {
  return props.value
})

const funnelDrilldownSearch = ref('')
const funnelDrilldownRowCount = ref(0)
const filteredFunnelDrilldownData = ref([])
const footerProps = ref({
  showFirstLastPage: !constants.IS_MOBILE,
  firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
  lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]
})

const visibleFunnelDrilldownHeaders = () => {
  return props.funnelDrilldownHeaders.filter((header) => header.show === true)
}
const filteredFunnelDrilldownItems = (filteredItems) => {
  filteredFunnelDrilldownData.value = filteredItems
  funnelDrilldownRowCount.value = filteredItems.length
}

</script>

<template>
  <v-dialog
      v-model="show"
      @input="$emit('close')"
  >
    <v-card id="funnel-drilldown">
      <v-card-title class="mb-1">
        <span id="funnel-drilldown-title" class="title-large">{{ funnelDrilldownTitle }}</span>
        <v-spacer></v-spacer>
        <a-btn
            color="primary"
            class="mr-4 mb-2"
            @click="$emit('export')"
            text="Export"
        ></a-btn>
        <a
            class="close-modal-x pb-3"
            title="Close"
            @click="$emit('close')"
        >×</a
        >
      </v-card-title>
      <v-divider></v-divider>
      <v-card-title
          v-if="funnelDrilldownData.length > 0"
          id="funnel-drilldown-search"
          class="pt-2"
      >
        <a-text-field
            v-model="funnelDrilldownSearch"
            placeholder="Type to filter..."
            single-line
            hide-details
            variant="outlined"
            density="compact"
        ></a-text-field>
        <span id="funnel-drilldown-row-count">
            Records:
            {{ funnelDrilldownRowCount + '/' + funnelDrilldownData.length }}
          </span>
      </v-card-title>

      <v-card-text>
        <v-data-table
            id="funnel-drilldown-table"
            class="elevation-1 table-striped"
            :class="{ 'mt-6': funnelDrilldownData.length === 0 }"
            :headers="visibleFunnelDrilldownHeaders()"
            fixed-header
            :items="funnelDrilldownData"
            @current-items="filteredFunnelDrilldownItems"
            :search="funnelDrilldownSearch"
            :height="
              funnelDrilldownRowCount > 0
                ? constants.IS_MOBILE
                  ? 'calc(100vh - 250px)'
                  : 'calc(100vh - 395px)'
                : '105px'
            "
            dense
            multi-sort
            :sort-by="[]"
            :sort-desc="[]"
            :loading="funnelDrilldownLoading"
            :items-per-page="500"
            :footer-props="footerProps"
        >
          <template
              v-if="funnelDrilldownData.length > 0"
              #item="{ item, index }"
          >
            <tr
                :class="[
                  'text-sm-left',
                  'row-hover',
                  { 'shaded-row': !(index % 2) }
                ]"
                :style="{
                  'text-decoration': item.cancelled_date ? 'line-through' : ''
                }"
            >
              <td style="text-align: center">
                {{ index + 1 }}
              </td>
              <td v-if="funnelDrilldownHeaders[1]?.show">
                {{ item.owner_name || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[2]?.show">
                {{ item.office || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[3]?.show">
                {{ item.state || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[4]?.show">
                {{ item.metro_area || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[5]?.show">
                {{ item.status_type || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[6]?.show">
                {{ item.project_name || item.customer_name || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[7]?.show">
                <router-link
                    text
                    v-if="
                      item.project_id && userStore.userHasFeature('PROJECTS')
                    "
                    :to="`/project/${item.project_id}/status`"
                >
                  {{ item.project_id }}
                </router-link>
                <div v-else>{{ item.project_id || '' }}</div>
              </td>
              <td
                  v-if="
                    selectedFunnel.funnel_type_id === 1 &&
                    funnelDrilldownHeaders[8]?.show
                  "
              >
                <router-link
                    text
                    v-if="
                      item.project_id &&
                      item.project_process_step_id &&
                      item.project_process_step_event_id &&
                      userStore.userHasFeature('EVENTS')
                    "
                    :to="`/project/${item.project_id}/processStep/${item.project_process_step_id}/event/${item.project_process_step_event_id}`"
                >
                  {{ item.project_process_step_event_id }}
                </router-link>
                <div v-else>
                  {{ item.project_process_step_event_id || '' }}
                </div>
              </td>
              <!--                <td :class="item.stage">{{ item.stage || '' }}</td>-->
              <td
                  v-if="funnelDrilldownHeaders[9]?.show"
                  :class="item.source_name_class"
              >
                {{ item.source_name || '' }}
              </td>
              <td
                  v-if="funnelDrilldownHeaders[10]?.show"
                  :class="item.system_size_class"
              >
                {{ item.system_size || '' }}
              </td>
              <td
                  v-if="funnelDrilldownHeaders[11]?.show"
                  :class="item.financier_class"
              >
                {{ item.financier || '' }}
              </td>
              <td v-if="funnelDrilldownHeaders[12]?.show">
                {{
                  item.appointment_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </td>
              <td v-if="funnelDrilldownHeaders[13]?.show">
                {{ item.cancelled_date | formatDate('date', 'MM/DD/YYYY') }}
              </td>
              <td v-if="funnelDrilldownHeaders[14]?.show">
                {{
                  item.date_created | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.appointment_outcome_class"
                  v-if="funnelDrilldownHeaders[15]?.show"
              >
                {{ item.appointment_outcome || '' }}
              </td>
              <td
                  :class="item.credit_decision_date_class"
                  v-if="funnelDrilldownHeaders[16]?.show"
              >
                {{
                  item.credit_decision_date | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.credit_check_class"
                  v-if="funnelDrilldownHeaders[17]?.show"
              >
                {{ item.credit_check || '' }}
              </td>
              <td
                  :class="item.installation_agreement_signed_date_class"
                  v-if="funnelDrilldownHeaders[18]?.show"
              >
                {{
                  item.installation_agreement_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.site_survey_verified_date_class"
                  v-if="funnelDrilldownHeaders[19]?.show"
              >
                {{
                  item.site_survey_verified_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.site_survey_completed_date_class"
                  v-if="funnelDrilldownHeaders[20]?.show"
              >
                {{
                  item.site_survey_completed_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.final_design_sent_to_homeowner_date_class"
                  v-if="funnelDrilldownHeaders[21]?.show"
              >
                {{
                  item.final_design_sent_to_homeowner_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.final_design_signed_date_class"
                  v-if="funnelDrilldownHeaders[22]?.show"
              >
                {{
                  item.final_design_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="
                    item.proof_of_homeowners_insurance_obtained_date_class
                  "
                  v-if="funnelDrilldownHeaders[23]?.show"
              >
                {{
                  item.proof_of_homeowners_insurance_obtained_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.utility_bill_verified_date_class"
                  v-if="funnelDrilldownHeaders[24]?.show"
              >
                {{
                  item.utility_bill_verified_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.financial_agreement_signed_date_class"
                  v-if="funnelDrilldownHeaders[25]?.show"
              >
                {{
                  item.financial_agreement_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.cash_down_payment_class"
                  v-if="funnelDrilldownHeaders[26]?.show"
              >
                {{
                  item.cash_down_payment | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.final_design_complete_date_class"
                  v-if="funnelDrilldownHeaders[27]?.show"
              >
                {{
                  item.final_design_complete_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.substantial_completion_date_class"
                  v-if="funnelDrilldownHeaders[28]?.show"
              >
                {{
                  item.substantial_completion_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </td>
              <td
                  :class="item.checked_in_time_date_class"
                  v-if="funnelDrilldownHeaders[29]?.show"
              >
                {{
                  item.checked_in_time
                      | formatDate('timestamp', 'MM/DD/YYYY h:mm a')
                }}
              </td>
            </tr>
          </template>
          <template v-if="showTotalSystemSize" v-slot:body.append>
            <tr id="total-system-size-row">
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td id="total-system-size-label">Total Size:</td>
              <td>{{ totalSystemSize ? totalSystemSize : 0 }}</td>
            </tr>
          </template>

          <template #no-data>
            <div class="my-3 funnel-drilldown-no-data-msg">
              No data is available for the selected date range.
            </div>
          </template>

          <template #no-results>
            <div class="my-3 funnel-drilldown-no-data-msg">
              No matching records found.
            </div>
          </template>
        </v-data-table>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <a-btn
            class="text-capitalize mr-4 mb-2"
            color="primary"
            @click="$emit('close')"
            text="Close"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<style scoped lang="scss">
#funnel-drilldown {
  .missing {
    background-color: rgba(204, 0, 0, 0.5);
  }

  .v-card__title {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
    padding-right: 24px;
    padding-left: 24px;
    padding-bottom:0;

    #funnel-drilldown-title {
      font-family: 'Roboto Condensed', sans-serif;
      //font-size: 14px;
      line-height: 24px;
      word-break: normal;
      padding-top: 5px;
    }
  }

  .close-modal-x {
    font-size: 20px;
    margin-left: 15px;

    &:hover {
      font-weight: bolder;
    }
  }

  #funnel-drilldown-search {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: center;

    ::v-deep {
      .v-input {
        max-width: 70%;
      }

      input,
      #funnel-drilldown-row-count {
        font-size: 11px;
      }
    }
  }

  #funnel-drilldown-table {
    ::v-deep .v-data-table__wrapper {
      max-height: calc(100vh - 250px);
    }

    ::v-deep {
      th,
      td {
        font-size: 10px;
        padding: 5px;
      }

      th {
        line-height: 14px;

        .v-data-table-header__icon {
          font-size: 12px !important;
          padding-bottom: 2px;
        }
      }
    }

    #total-system-size-row:hover {
      background-color: transparent !important;
    }

    #total-system-size-label {
      font-weight: bold;
      text-align: right;
    }

    .customer-name {
      text-transform: capitalize;
    }

    .funnel-drilldown-no-data-msg {
      text-align: left;
      margin-left: 25px;
    }
  }

  .v-card__text {
    padding-bottom: 0;
  }


}

</style>
