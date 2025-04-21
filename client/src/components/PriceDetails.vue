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
      <v-expansion-panel readonly class="my-2">
        <v-expansion-panel-header hide-actions>
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
      <v-expansion-panel class="mb-2">
        <v-expansion-panel-header readonly hide-actions>
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
<!--        <v-expansion-panel-content class="child-expansion-panel-content">-->
<!--          <v-simple-table dense class="commission-table">-->
<!--            <template v-slot:default>-->
<!--              <thead>-->
<!--              <tr>-->
<!--                <th class="text-left font-weight-bold">Item</th>-->
<!--                <th class="text-right font-weight-bold">Amount</th>-->
<!--              </tr>-->
<!--              </thead>-->
<!--              <tbody>-->
<!--              <tr class="dense-row">-->
<!--                <td class="caption light-blue lighten-5">Base</td>-->
<!--                <td class="text-right caption light-blue lighten-5">${{ formatNumber(commissionBaseTotal, true) }}</td>-->
<!--              </tr>-->
<!--              </tbody>-->
<!--            </template>-->
<!--          </v-simple-table>-->
<!--        </v-expansion-panel-content>-->
      </v-expansion-panel>

      <!-- Estimated Adders Card -->
      <v-expansion-panel>
        <v-expansion-panel-header hide-actions >
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
          <v-simple-table dense class="adder-table">
            <template v-slot:default>
              <thead>
              <tr>
                <th class="text-left font-weight-bold">Item</th>
                <th class="text-center font-weight-bold">Unit Price</th>
                <th width="180" class="text-right font-weight-bold">Total Amount</th>
              </tr>
              </thead>
              <tbody>
              <tr
                v-for="(adder, index) in adders"
                :key="index"
                :class="{ 'light-blue lighten-5': index % 2 === 0 }"
                class="dense-row"
              >
                <td class="caption">{{ adder.name }}</td>
                <td class="text-center caption">{{ adder.unitPrice }}</td>
                <td class="text-right caption">
                  <div class="d-flex justify-end align-center">
                    <span v-if="adder.customProjectAdderAmount !== null && adder.customProjectAdderAmount !== undefined && adder.customProjectAdderAmount !== adder.customProposalAdderAmount" class="text-decoration-line-through mr-2 grey--text text-no-wrap">
                      ${{ formatNumber(adder.customProjectAdderAmount, true) }}
                    </span>
                    <span :class="{
                      'red--text': adder.customProposalAdderAmount < adder.customProjectAdderAmount && adder.customProjectAdderAmount > 0,
                      'green--text': adder.customProposalAdderAmount > adder.customProjectAdderAmount && adder.customProjectAdderAmount > 0,
                      'text-no-wrap': true
                    }">
                      ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                    </span>
                  </div>
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

<script setup>
import { ref, computed, watch, onMounted } from 'vue'

import { getRequest } from '@/helpers/helpers'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()

const props = defineProps({
  proposalId: {
    type: [Number, String],
    required: true
  },
  adderData: {
    type: Array,
    default: () => []
  }
})

const expandedPanels = ref([2]) // All panels expanded by default (0=Base Price, 1=Commission, 2=Estimated Adders)
const showNotification = ref(false)
const notificationText = ref('')
const basePrice = ref(0)
const commission = ref({
  base: 0,
})
const adders = ref([])

const commissionBaseTotal = computed(() => {
  return commission.value.base
})

const commissionTotal = computed(() => {
  return commissionBaseTotal.value
})

const adderTotal = computed(() => {
  return adders.value.reduce((total, adder) => {
    // Use proposalAdderAmount if available, otherwise fallback to amount for backward compatibility
    return total + (adder.proposalAdderAmount || adder.amount || 0)
  }, 0)
})

const processAdderData = (adderData) => {
  adders.value = adderData
    // Include adders of all types
    .filter(adder =>
      adder.selectedProposalAdder ||
      (adder.adderType === 'custom_adders' && adder.customProposalAdderAmount > 0) ||
      (adder.adderType === 'auto_applied_adder'))
    .map(adder => {
      let projectAmount = 0
      let proposalAmount = 0

      if (adder.adderType === 'selected_adders') {
        projectAmount = adder.selectedAdderAmount || 0
        proposalAmount = adder.selectedProposalAdderAmount || adder.selectedAdderAmount || 0
      } else if (adder.adderType === 'custom_adders') {
        projectAmount = adder.customAdderAmount || 0
        proposalAmount = adder.customProposalAdderAmount || 0
      } else if (adder.adderType === 'auto_applied_adder') {
        projectAmount = adder.autoAppliedAdderAmount || 0
        proposalAmount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0
      }

      return {
        id: adder.id,
        fieldName: adder.fieldName,
        name: adder.fieldName || 'Unknown Adder',
        unitPrice: adder.quantity ? `${adder.quantity}` : 'Flat Rate',
        projectAdderAmount: projectAmount,
        proposalAdderAmount: proposalAmount,
        customProjectAdderAmount: adder.customProjectAdderAmount || null,
        customProposalAdderAmount: adder.customProposalAdderAmount || null,
        adderType: adder.adderType,
        // Keep amount for backward compatibility
        amount: proposalAmount
      }
    })
}

const formatNumber = (value, showDecimals = true) => {
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: showDecimals ? 2 : 0,
    maximumFractionDigits: showDecimals ? 2 : 0
  }).format(value)
}

// Function to fetch base and commission amounts from the backend
const fetchPriceDetailAmounts = async () => {
  if (!props.proposalId) return;

  try {
    appStore.loading = true;

    const { data } = await getRequest(
      `/proposal/${props.proposalId}/adders/details`,
      'blueraven'
    );

    if (data) {
      basePrice.value = data.base_amount || 0;
      commission.value.base = data.commission_amount || 0;
    }
  } catch (error) {
    console.error('Error fetching price detail amounts:', error);
    // Optional: Show error notification
    showNotification.value = true;
    notificationText.value = 'Error loading price details. Please refresh the page.';
  } finally {
    appStore.loading = false;
  }
};

// Watch for changes in adder data
watch(() => props.adderData, (newAdderData) => {
  if (newAdderData && newAdderData.length > 0) {
    processAdderData(newAdderData);
    // Also refresh price details when adders change
    fetchPriceDetailAmounts();
  }
}, { immediate: true, deep: true })

// Call fetchPriceDetailAmounts when component mounts
onMounted(() => {
  fetchPriceDetailAmounts();
});

// Watch for changes in proposal ID and refetch data when it changes
watch(() => props.proposalId, (newProposalId, oldProposalId) => {
  if (newProposalId && newProposalId !== oldProposalId) {
    fetchPriceDetailAmounts();
  }
});
</script>

<style scoped>
.price-details {
  max-width: 100%;
}

.child-expansion-panel-content {
  width: 100%;
}

.text-decoration-line-through {
  text-decoration: line-through;
}

.v-expansion-panel-content ::v-deep .v-expansion-panel-content__wrap {
  padding: 0;
}

.dense-row td {
  padding: 0 0 0 0;
}

.adder-table, .commission-table {
  width: 100%;
}

</style>
