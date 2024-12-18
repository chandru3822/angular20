<script setup>
/*
*@name AppointmentCreatedFunnelDrilldownDialog
*@author jess
*@date 12/6/24
*
*@description
*
*/

import {computed, ref, watch} from "vue";
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

const showTotalSystemSize = computed(() => {
  return funnelDrilldownRowCount.value > 0
})

</script>

<template>
  <v-dialog
      v-model="show"
      @input="$emit('close')"
  >
    <v-card id="funnel-drilldown">
      <v-card-title class="mb-1">
        <span class="title-large">{{ funnelDrilldownTitle }}</span>
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
          class="pt-2 d-flex justify-space-between"
      >
        <a-text-field
            v-model="funnelDrilldownSearch"
            placeholder="Type to filter..."
            single-line
            hide-details
            variant="outlined"
            density="compact"
        ></a-text-field>
        <v-spacer/>
        <span class="body-medium">
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

<!--            <tr-->
<!--                :class="[-->
<!--                    'text-sm-left',-->
<!--                    'row-hover',-->
<!--                    { 'shaded-row': !(index % 2) }-->
<!--                  ]"-->
<!--                :style="{-->
<!--                    'text-decoration': item.cancelled_date ? 'line-through' : ''-->
<!--                  }"-->
<!--            >-->
              <template #item.count="{item, index}"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                        class="px-0 text-center">
                {{ index + 1 }}
              </template>

              <template #item.project_id="{item}" :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
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
              </template>
              <template #item.project_process_step_event_id="{item}" v-if="selectedFunnel.funnel_type_id === 1" :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
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
              </template>
              <!--                <td :class="item.stage">{{ item.stage || '' }}</td>-->

              <template #item.appointment_date="{item}" :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
                {{
                  item.appointment_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.cancelled_date="{item}" :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
                {{ item.cancelled_date | formatDate('date', 'MM/DD/YYYY') }}
              </template>
              <template #item.date_created="{item}" v-if="funnelDrilldownHeaders[14]?.show" :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
                {{
                  item.date_created | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.appointment_coutcome="{item}"
                        :class="item.appointment_outcome_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[15]?.show"
              >
                {{ item.appointment_outcome || '' }}
              </template>
              <template #item.credit_decision_date="{item}"
                        :class="item.credit_decision_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[16]?.show"
              >
                {{
                  item.credit_decision_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.credit_check="{item}"
                        :class="item.credit_check_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[17]?.show"
              >
                {{ item.credit_check || '' }}
              </template>
              <template #item.installation_agreement_signed_date="{item}"
                        :class="item.installation_agreement_signed_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[18]?.show"
              >
                {{
                  item.installation_agreement_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.site_survey_verified_date="{item}"
                        :class="item.site_survey_verified_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[19]?.show"
              >
                {{
                  item.site_survey_verified_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.site_survey_completed_date="{item}"
                        :class="item.site_survey_completed_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[20]?.show"
              >
                {{
                  item.site_survey_completed_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.final_design_sent_to_homeowner_date="{item}"
                        :class="item.final_design_sent_to_homeowner_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[21]?.show"
              >
                {{
                  item.final_design_sent_to_homeowner_date
                      | formatDate('timestamp', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.final_design_signed_date="{item}"
                        :class="item.final_design_signed_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[22]?.show"
              >
                {{
                  item.final_design_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.proof_of_homeowners_insurance_obtained_date="{item}"
                        :class="item.proof_of_homeowners_insurance_obtained_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[23]?.show"
              >
                {{
                  item.proof_of_homeowners_insurance_obtained_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.utility_bill_verified_date="{item}"
                        :class="item.utility_bill_verified_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[24]?.show"
              >
                {{
                  item.utility_bill_verified_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.financial_agreement_signed_date="{item}"
                        :class="item.financial_agreement_signed_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[25]?.show"
              >
                {{
                  item.financial_agreement_signed_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.cash_down_payment="{item}"
                        :class="item.cash_down_payment_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[26]?.show"
              >
                {{
                  item.cash_down_payment | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.final_design_complete_date="{item}"
                        :class="item.final_design_complete_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[27]?.show"
              >
                {{
                  item.final_design_complete_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.substantial_completion_date="{item}"
                        :class="item.substantial_completion_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[28]?.show"
              >
                {{
                  item.substantial_completion_date
                      | formatDate('date', 'MM/DD/YYYY')
                }}
              </template>
              <template #item.checked_in_time="{item}"
                        :class="item.checked_in_time_date_class"
                        :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}"
                  v-if="funnelDrilldownHeaders[29]?.show"
              >
                {{
                  item.checked_in_time
                      | formatDate('timestamp', 'MM/DD/YYYY h:mm a')
                }}
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
      font-size: 14px;
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
