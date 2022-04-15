<template>
  <v-dialog v-model="isOpen" max-width="950" @input="closeMilestoneDialog">
    <v-card>
      <v-card-title class="mb-1">
        <span id="drilldown-title">{{ milestoneDrilldownTitle }}</span>
        <a class="close-modal-x pb-3" title="Close" @click="closeMilestoneDialog">×</a>
      </v-card-title>

      <v-card-text>
        <v-data-table
            id="setter-drilldown-table"
            :headers="headers"
            :items="drilldownData"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            fixed-header
            dense
            hide-default-footer
            class="elevation-1"
        >
          <template v-if="drilldownData.length > 0" #item="{ item, index }">
            <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
              <td class="text-left">{{ index + 1 }}</td>
              <td class="text-left customer-name">{{ item.customer_name || '' }}</td>
              <td class="text-left">{{ item.id || '' }}</td>
              <td class="text-left">{{ item.source || '' }}</td>
              <td class="text-left">{{ item.appointment_date | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
              <td class="text-left">{{ item.appointment_outcome || '' }}</td>
            </tr>
          </template>

          <template #no-data>
            <div v-if="(currentQuarter < 4) && (selectedQuarter > currentQuarter)" class="my-3">
              Data is not yet available for the selected quarter.
            </div>
            <div v-else class="my-3">
              No data is available for the selected quarter.
            </div>
          </template>
        </v-data-table>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn class="white--text text-capitalize mr-4 mb-2" color="primaryButton"
               @click="closeMilestoneDialog">
          Close
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

</template>

<script>
import moment from "moment";
import {DashboardTypeEnum} from "@/views/blueraven/closerDashboard/incentive_constants";

export default {
  name: "SetterMilestoneDrilldown",
  props: {
    selectedQuarter: Number,
    drilldownData: [],
    isOpen: Boolean
  },
  data () {
    return {
      currentQuarter: moment().quarter(),
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Project ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'Appointment Date', value: 'appointment_date', show: true },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true }
      ],
    }
  },
  watch: {
    isOpen () {
    }
  },
  computed: {
    milestoneDrilldownTitle () {
      return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + DashboardTypeEnum.SETTER.drilldown.label + this.selectedQuarter
    },
  },
  methods: {
    closeMilestoneDialog() {
      this.$emit('close-drilldown')
    }
  }
}
</script>

<style lang="scss" scoped>
.v-card__title {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  align-items: center;
}

#drilldown-title {
  font-family: "Roboto Condensed", sans-serif;
  font-size: 14px;
}

.close-modal-x {
  font-size: 20px;

  &:hover {
    font-weight: bolder;
  }
}

#drilldown-table {
  ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 250px);
  }

  th, td {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 10px;
  }

  .customer-name {
    text-transform: capitalize;
  }
}

@media (min-width: 737px) {

  #drilldown-title {
    font-size: 18px;
  }

  #drilldown-table {
    th, td {
      font-size: 12px;
    }
  }
}

@media (min-width: 1070px) {
  #drilldown-title {
    font-size: 24px;
  }
}

</style>
