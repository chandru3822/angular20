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
    <v-expansion-panels multiple focusable>
      <v-expansion-panel readonly class="child-expansion-panel">
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center">
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
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center">
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
          <v-simple-table dense>
            <template v-slot:default>
              <tbody>
              <tr>
                <td>Base</td>
                <td class="text-right">{{ formatNumber(commission.base) }}</td>
              </tr>
              <tr class="light-blue lighten-5">
                <td>Adjustment (Trenching Cost Update)</td>
                <td class="text-right">{{ formatNumber(commission.trenchingAdjustment) }}</td>
              </tr>
              <tr class="light-blue lighten-5">
                <td>Adjustment (Tree Trimming Cost Update)</td>
                <td class="text-right">{{ formatNumber(commission.treeTrimmingAdjustment) }}</td>
              </tr>
              </tbody>
            </template>
          </v-simple-table>
        </v-expansion-panel-content>
      </v-expansion-panel>

      <!-- Estimated Adders Card -->
      <v-expansion-panel class="child-expansion-panel">
        <v-expansion-panel-header hide-actions class="d-flex justify-space-between align-center">
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
            <span class="text-subtitle-1 font-weight-medium">$ {{ formatNumber(adderTotal) }}</span>
          </span>
        </v-expansion-panel-header>
        <v-expansion-panel-content class="child-expansion-panel-content">
          <v-simple-table dense bordered>
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
                  <span v-if="adder.oldAmount" class="text-decoration-line-through mr-2 grey--text">
                    {{ formatNumber(adder.oldAmount) }}
                  </span>
                  <span>{{ formatNumber(adder.amount) }}</span>
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
  data() {
    return {
      expanded: false,
      showNotification: false,
      notificationText: '',
      basePrice: 29700,
      commission: {
        base: 3000,
        trenchingAdjustment: 70,
        treeTrimmingAdjustment: 100
      },
      adders: [
        {
          name: 'Tree Trimming',
          unitPrice: '',
          oldAmount: 500,
          amount: 400
        },
        {
          name: 'Metal Roof',
          unitPrice: '115/panel',
          amount: 2760
        },
        {
          name: 'Smoke Detectors',
          unitPrice: 'Flat Rate',
          amount: 600
        },
        {
          name: 'Trenching',
          unitPrice: '',
          oldAmount: 1350,
          amount: 1280
        },
        {
          name: 'Panel Upgrade',
          unitPrice: '',
          amount: 2000
        },
        {
          name: 'Electrical Service Base Charge',
          unitPrice: '',
          amount: 1000
        }
      ]
    };
  },
  computed: {
    commissionTotal() {
      return this.commission.base + this.commission.trenchingAdjustment + this.commission.treeTrimmingAdjustment;
    },
    adderTotal() {
      return this.adders.reduce((total, adder) => total + adder.amount, 0);
    }
  },
  methods: {
    formatNumber(value) {
      return new Intl.NumberFormat('en-US').format(value);
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
  padding-right: -4px !important;
  margin-right: -4px !important;
}

.text-decoration-line-through {
  text-decoration: line-through;
}
</style>
