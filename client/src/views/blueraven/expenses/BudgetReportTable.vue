<template>
  <v-card class="mt-3">
    <v-card-title class="primary lighten-9" primary-title>
      Budget Details
    </v-card-title>
    <v-card-text class="pt-4">
      <table class="detail-table">
        <tr>
          <td class="detail-column detail-column-header" colspan="2">
            {{ budget.budget_name }}
          </td>
        </tr>
        <tr>
          <td class="detail-column default-text-color">Budget Amount:</td>
          <td class="detail-column default-text-color text-right">{{ budget.amount || 0 | currency('$', 2) }}</td>
        </tr>
        <tr>
          <td class="detail-column clickable default-text-color">Pending Approval:</td>
          <td class="detail-column default-text-color text-right">{{ budget.pending_review || 0 | currency('$', 2) }}</td>
        </tr>
<!--        <tr>-->
<!--          <td class="detail-column default-text-color clickable">Pending Approval:</td>-->
<!--          <td class="detail-column default-text-color text-right">{{ budget.pending_approval || 0 | currency('$', 2) }}</td>-->
<!--        </tr>-->
        <tr>
          <td class="detail-column default-text-color clickable">Pending Payment:</td>
          <td class="detail-column default-text-color text-right">{{ budget.pending_payment || 0 | currency('$', 2) }}</td>
        </tr>
        <tr>
          <td class="detail-column default-text-color clickable">Paid:</td>
          <td class="detail-column default-text-color text-right">{{ budget.paid || 0 | currency('$', 2) }}</td>
        </tr>
        <!--                <tr>-->
        <!--                  <td class="detail-column">Other:</td>-->
        <!--                  <td class="detail-column text-right">{{ br.paid || 0 | currency('$', 2) }}</td>-->
        <!--                </tr>-->
        <tr>
          <td class="detail-column default-text-color bold">Remaining Budget:</td>
          <td class="detail-column default-text-color text-right bold">{{
              budget.remaining_budget || 0 | currency('$', 2)
            }}
          </td>
        </tr>
      </table>
    </v-card-text>
  </v-card>

</template>

<script setup>
import DatetimePickerInput from "@/components/DatetimePickerInput"
import SpinnerInline from "@/components/SpinnerInline.vue";
import { toRefs } from 'vue'

const props = defineProps({
    budget: Object
})
const { budget } = toRefs(props)

</script>

<style scoped lang="scss">
.detail-table {
  width: 100%;
  margin-top: 10px;
  border-collapse: collapse;
}

.detail-column {
  width: 50%;
}

.detail-column-header {
  font-weight: bold;
  font-size: 14px;
}

.total-row {
  border-top: solid 1px #D8D8D8;
  font-weight: bold;
}
</style>
