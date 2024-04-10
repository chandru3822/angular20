<template>
  <v-menu
    v-model="displayDropdown"
    bottom
    attach
    offset-y
    min-width="450"
    :close-on-content-click="false"
    style="z-index: 10"
  >
    <template #activator="{ on }">
      <a-btn
        variant="text"
        color="primary"
        size="x-small"
        :activation-handler="on"
        class="commission-detail-button"
        prepend-icon="mdi-information"
      ></a-btn>
    </template>
    <div>
      <v-card v-if="detailsLoading" class="square-card">
        <SpinnerInline :size="20" color="primary" />
      </v-card>
      <v-card v-else-if="!detailsLoading && fieldError" class="square-card">
        <v-card-title class="error--text">Error Loading Details</v-card-title>
        <v-card-text>
          <div class="error--text">{{ fieldErrorMsg }}</div>
        </v-card-text>
      </v-card>
      <v-card
        v-else-if="commissionDetails && commissionDetails.length > 0"
        class="square-card"
        flat
      >
        <v-card-title>
          *Customer's Current Monthly Payment
          {{ commissionDetails[0].monthlyCostTodayWithoutSolar }}
        </v-card-title>
        <v-card-text class="pt-0">
          <v-data-table
            :headers="headers"
            :items="commissionDetails"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            id="proposal-commission-detail-table"
            class="elevation-1"
          >
            <template #item="{ item, index }">
              <tr
                :class="{
                  'shaded-row': index % 2,
                  'selected-row': item.commissionKw === currentCommissionValue
                }"
              >
                <td>
                  {{ item.loanAmount | currency('', 2) }}
                </td>
                <td>
                  {{ item.monthlyPayment | currency('', 2) }}
                </td>
                <td>
                  <v-chip
                    v-if="item.recommended"
                    color="success lighten-1"
                    class="white--text"
                  >
                    {{ item.commissionKw }}
                  </v-chip>
                  <span v-else>{{ item.commissionKw }}</span>
                </td>
                <td>
                  {{ item.totalCommissions | currency('', 2) }}
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card-text>
      </v-card>
    </div>
  </v-menu>
</template>

<script setup>
import { getRequestWithParams } from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'
import { getCurrentInstance, toRefs, ref, watch } from 'vue'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const props = defineProps({
  proposalId: Number,
  customFieldGroups: Array,
  currentCommissionValue: Number,
  selectCallback: Function
})
const { proposalId, customFieldGroups, currentCommissionValue } = toRefs(props)

const displayDropdown = ref(false)
const detailsLoading = ref(true)
const fieldError = ref(false)
const fieldErrorMsg = ref('')
const commissionDetails = ref([])
const headers = ref([
  { text: 'Loan Amount', value: 'loanAmount', show: true },
  { text: 'Monthly Payment', value: 'monthlyPayment', show: true },
  { text: 'Commission in $/kW', value: 'commissionKw', show: true },
  { text: 'Total Commission', value: 'totalCommissions', show: true }
])
const fieldsToSend = ref([
  {
    name: 'Financial Product',
    cfgId: 27,
    cfgaId: 155,
    dataField: 'intValue',
    backendProp: 'financialProductId',
    value: null,
    required: true
  },
  {
    name: 'BRS Product',
    cfgId: 27,
    cfgaId: 147,
    dataField: 'intValue',
    backendProp: 'brsProductId',
    value: null,
    required: true
  }
])
watch(displayDropdown, async () => {
  if (displayDropdown.value) {
    await getCommissionDetails()
  }
})

const getFieldValue = (cfgId, cfgaId, dataValue) => {
  const cfg = customFieldGroups.value.find((cfg) => cfg.id === cfgId)
  const cf = cfg?.customFieldValues?.find(
    (cf) => cf.customFieldGroupAssignmentId === cfgaId
  )
  return cf ? cf[dataValue] : null
}

const getCommissionDetails = async () => {
  try {
    detailsLoading.value = true
    fieldsToSend.value.forEach((f) => {
      f.value = getFieldValue(f.cfgId, f.cfgaId, f.dataField)
    })
    let emptyRequiredFields = fieldsToSend.value.filter(
      (f) => f.required && !f.value
    )
    if (emptyRequiredFields.length === 0) {
      fieldError.value = false
      fieldErrorMsg.value = ''
      let params = {}
      fieldsToSend.value.forEach((f) => {
        params[f.backendProp] = f.value
      })
      console.log('params', params)
      const { data } = await getRequestWithParams(
        `/proposal/${proposalId.value}/commissionDetails`,
        { params },
        'blueraven',
        []
      )
      commissionDetails.value = data
    } else {
      fieldError.value = true
      const conjunction = emptyRequiredFields.length === 1 ? ' is' : ' and'
      let fieldString = ''
      emptyRequiredFields.forEach((f, idx) => {
        if (idx !== 0) {
          fieldString = fieldString + ' and '
        }
        fieldString = fieldString + f.name
      })
      fieldErrorMsg.value =
        fieldString + conjunction + ' required to load commission details.'
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    fieldError.value = true
    fieldErrorMsg.value = 'Error retrieving commission details'
    snackbar('ERROR', 'Error retrieving commission details')
  } finally {
    detailsLoading.value = false
  }
}
</script>

<style lang="scss">
#commission-detail-modal-header .v-toolbar__title {
  font-size: 14px;
}

.v-menu--attached {
  display: contents;
}
</style>

<style lang="scss" scoped>
.commission-detail-button {
  padding: 4px !important;
  height: 28px !important;
  margin-left: 5px;
  margin-right: -5px;
}
</style>
