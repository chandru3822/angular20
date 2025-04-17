<template>
  <div class="price-details">
    <!-- Notification Alert -->
    <v-alert
      v-if="showNotification"
      dismissible
      color="amber lighten-4"
      border="left"
      colored-border
      class="mb-4"
      @input="showNotification = false"
    >
      <div class="d-flex align-center">
        <div>
          {{ notificationText }}
        </div>
      </div>
    </v-alert>

    <!-- Base Price Card -->
    <v-expansion-panels multiple v-model="expandedPanels">
      <v-expansion-panel readonly class="child-expansion-panel">
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center panel-header-sticky">
          <span class="text-subtitle-1 font-weight-medium">
            Base Price
          </span>
          <span class="d-flex align-center justify-end ml-auto">
            <span class="text-subtitle-2 grey--text mr-2">Subtotal:</span>
            <span class="text-subtitle-1 font-weight-medium">
              $ {{ formatNumber(basePrice) }}
            </span>
          </span>
        </v-expansion-panel-header>
      </v-expansion-panel>

      <!-- Commission Card -->
      <v-expansion-panel class="child-expansion-panel">
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center panel-header-sticky">
          <span class="text-subtitle-1 font-weight-medium">
            Commission
          </span>
          <span class="d-flex align-center justify-end ml-auto">
            <span class="text-subtitle-2 grey--text mr-2">Subtotal:</span>
            <span class="text-subtitle-1 font-weight-medium">
              $ {{ formatNumber(commissionTotal) }}
            </span>
          </span>
        </v-expansion-panel-header>
        <v-expansion-panel-content class="child-expansion-panel-content">
          <v-simple-table dense class="commission-table">
            <template v-slot:default>
              <tbody>
              <tr>
                <td>Base</td>
                <td class="text-right">${{ formatNumber(commissionBaseTotal, true) }}</td>
              </tr>
              <tr class="light-blue lighten-5">
                <td>Adjustment (Trenching Cost Update)</td>
                <td class="text-right">${{ formatNumber(commission.trenchingAdjustment, true) }}</td>
              </tr>
              <tr class="light-blue lighten-5">
                <td>Adjustment (Tree Trimming Cost Update)</td>
                <td class="text-right">${{ formatNumber(commission.treeTrimmingAdjustment, true) }}</td>
              </tr>
              </tbody>
            </template>
          </v-simple-table>
        </v-expansion-panel-content>
      </v-expansion-panel>

      <!-- Estimated Adders Card -->
      <v-expansion-panel class="child-expansion-panel">
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center panel-header-sticky">
          <span class="text-subtitle-1 font-weight-medium d-flex align-center">
            Estimated Adders
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
                <v-icon small class="ml-1" color="grey" v-on="on">mdi-information-outline</v-icon>
              </template>
              <span>Additional costs for your installation</span>
            </v-tooltip>
          </span>
          <span class="d-flex align-center justify-end ml-auto">
            <span class="text-subtitle-2 grey--text mr-2">Subtotal:</span>
            <span class="text-subtitle-1 font-weight-medium">${{ formatNumber(adderTotal, true) }}</span>
          </span>
        </v-expansion-panel-header>
        <v-expansion-panel-content class="child-expansion-panel-content">
          <v-simple-table dense bordered class="adder-table">
            <template v-slot:default>
              <thead>
              <tr>
                <th class="text-left font-weight-bold">Item</th>
                <th class="text-center font-weight-bold">Unit Price</th>
                <th class="text-right font-weight-bold">Total Amount</th>
              </tr>
              </thead>
              <tbody>
              <tr
                v-for="(adder, index) in adders"
                :key="index"
                :class="{ 'light-blue lighten-5': index % 2 === 0 }"
              >
                <td>{{ adder.name }}</td>
                <td class="text-center">{{ adder.unitPrice }}</td>
                <td class="text-right">
                  <span v-if="adder.projectAdderAmount && adder.projectAdderAmount !== adder.proposalAdderAmount" class="text-decoration-line-through mr-2 grey--text">
                    ${{ formatNumber(adder.projectAdderAmount, true) }}
                  </span>
                  <span :class="{
                    'red--text': adder.proposalAdderAmount > adder.projectAdderAmount && adder.projectAdderAmount > 0,
                    'green--text': adder.proposalAdderAmount < adder.projectAdderAmount && adder.projectAdderAmount > 0
                  }">
                    ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                  </span>
                </td>
              </tr>
              </tbody>
            </template>
          </v-simple-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script>
export default {
  name: 'PriceDetails',
  props: {
    proposalId: {
      type: [Number, String],
      required: true
    },
    adderData: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      expandedPanels: [0, 1, 2], // All panels expanded by default (0=Base Price, 1=Commission, 2=Estimated Adders)
      showNotification: false,
      notificationText: '',
      basePrice: 29700,
      commission: {
        base: 3000,
        trenchingAdjustment: 0,
        treeTrimmingAdjustment: 0
      },
      adders: []
    };
  },
  watch: {
    adderData: {
      immediate: true,
      handler(newAdderData) {
        if (newAdderData && newAdderData.length > 0) {
          this.processAdderData(newAdderData);
          this.extractSpecialAdderAdjustments(newAdderData);
        }
      }
    }
  },
  computed: {
    commissionBaseTotal() {
      // Base amount that includes the tree trimming and trenching adjustments
      return this.commission.base;
    },
    commissionTotal() {
      return this.commissionBaseTotal + this.commission.trenchingAdjustment + this.commission.treeTrimmingAdjustment;
    },
    adderTotal() {
      return this.adders.reduce((total, adder) => {
        // Use proposalAdderAmount if available, otherwise fallback to amount for backward compatibility
        return total + (adder.proposalAdderAmount || adder.amount || 0);
      }, 0);
    }
  },
  methods: {
    processAdderData(adderData) {
      this.adders = adderData
        .filter(adder => adder.selectedProposalAdder || (adder.adderType === 'custom_adders' && adder.customProposalAdderAmount > 0))
        .map(adder => {
          let projectAmount = 0;
          let proposalAmount = 0;

          if (adder.adderType === 'selected_adders') {
            projectAmount = adder.selectedAdderAmount || 0;
            proposalAmount = adder.selectedProposalAdderAmount || adder.selectedAdderAmount || 0;
          } else if (adder.adderType === 'custom_adders') {
            projectAmount = adder.customAdderAmount || 0;
            proposalAmount = adder.customProposalAdderAmount || 0;
          } else if (adder.adderType === 'auto_applied_adder') {
            projectAmount = adder.autoAppliedAdderAmount || 0;
            proposalAmount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0;
          }

          return {
            id: adder.id,
            fieldName: adder.fieldName,
            name: adder.fieldName || 'Unknown Adder',
            unitPrice: adder.quantity ? `${adder.quantity}` : 'Flat Rate',
            projectAdderAmount: projectAmount,
            proposalAdderAmount: proposalAmount,
            adderType: adder.adderType,
            // Keep amount for backward compatibility
            amount: proposalAmount
          };
        });
    },
    extractSpecialAdderAdjustments(adderData) {
      // Initialize default values
      this.commission.trenchingAdjustment = 0;
      this.commission.treeTrimmingAdjustment = 0;

      // Look for Tree Trimming and Trenching adders
      const trenchingAdder = adderData.find(adder =>
        adder.fieldName && adder.fieldName.toLowerCase().includes('trenching'));

      const treeTrimmingAdder = adderData.find(adder =>
        adder.fieldName && adder.fieldName.toLowerCase().includes('tree trimming'));

      // Set commission adjustments if found
      if (trenchingAdder && trenchingAdder.selectedProposalAdder) {
        const amount = trenchingAdder.adderType === 'custom_adders'
          ? trenchingAdder.customProposalAdderAmount || 0
          : trenchingAdder.selectedProposalAdderAmount || trenchingAdder.selectedAdderAmount || 0;

        // Calculate adjustment - typically a small percentage
        this.commission.trenchingAdjustment = Math.round(amount * 0.02);
      }

      if (treeTrimmingAdder && treeTrimmingAdder.selectedProposalAdder) {
        const amount = treeTrimmingAdder.adderType === 'custom_adders'
          ? treeTrimmingAdder.customProposalAdderAmount || 0
          : treeTrimmingAdder.selectedProposalAdderAmount || treeTrimmingAdder.selectedAdderAmount || 0;

        // Calculate adjustment - typically a small percentage
        this.commission.treeTrimmingAdjustment = Math.round(amount * 0.03);
      }
    },
    formatNumber(value, showDecimals = true) {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: showDecimals ? 2 : 0,
        maximumFractionDigits: showDecimals ? 2 : 0
      }).format(value);
    }
  }
}
</script>

<style scoped>
.price-details {
  max-width: 100%;
}

.child-expansion-panel-content {
  width: 100%;
  padding: 0 !important;
  margin: 0 !important;
}

.text-decoration-line-through {
  text-decoration: line-through;
}

.panel-header-sticky {
  position: sticky !important;
  top: 0 !important;
  z-index: 5 !important;
  background-color: white !important;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1) !important;
  min-height: 48px !important;
  height: 48px !important;
}

/* Apply consistent height to all expansion panel headers */
::v-deep .v-expansion-panel-header {
  min-height: 48px !important;
  height: 48px !important;
  padding: 0 16px !important;
}

::v-deep .v-expansion-panel--active > .v-expansion-panel-header {
  border-bottom: 1px solid rgba(0, 0, 0, 0.12);
}

.v-expansion-panel-content ::v-deep .v-expansion-panel-content__wrap {
  padding: 0;
}

.text-right {
  text-align: right;
}

::v-deep .v-data-table td,
::v-deep .v-simple-table td,
::v-deep .v-simple-table th {
  padding: 0 8px !important; /* Reduce padding for all table cells */
}

/* Fix borders and alignment for tables */
::v-deep .v-simple-table {
  border-collapse: collapse;
  width: 100%;

  th, td {
    padding: 8px !important;
  }

  tr {
    border-bottom: 1px solid rgba(0, 0, 0, 0.12);
  }
}

/* Specific styles for the commission table */
.commission-table {
  width: 100%;
  margin: 0 !important;

  ::v-deep table {
    width: 100%;
  }

  ::v-deep td, ::v-deep th {
    padding: 8px !important;
  }
}

/* Specific styles for the adder table */
.adder-table {
  width: 100%;
  margin: 0 !important;

  ::v-deep table {
    width: 100%;
  }

  ::v-deep td, ::v-deep th {
    padding: 8px !important;
  }
}
</style>
