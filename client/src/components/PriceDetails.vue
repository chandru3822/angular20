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
              $ {{ formatNumber(commissionBase) }}
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
            <span class="text-subtitle-2 mr-2" :class="commissionTotal < 0 ? 'red--text' : 'grey--text'">Subtotal:</span>
            <span class="text-subtitle-1 font-weight-medium" :class="commissionTotal < 0 ? 'red--text' : ''">
              $ {{ formatNumber(commissionTotal) }}
            </span>
          </span>
        </v-expansion-panel-header>
        <v-expansion-panel-content class="child-expansion-panel-content">
          <v-simple-table dense class="commission-table">
            <template v-slot:default>
              <thead>
              <tr>
                <th class="text-left font-weight-bold">Item</th>
                <th class="text-right font-weight-bold">Amount</th>
              </tr>
              </thead>
              <tbody>
              <tr class="dense-row">
                <td class="caption light-blue lighten-5">Base</td>
                <td class="text-right caption light-blue lighten-5">${{ formatNumber(basePrice, true) }}</td>
              </tr>
              <!-- Show adder differences between Project and Proposal amounts -->
              <template v-for="(adder, index) in adderDifferences">
                <tr :key="'diff-' + index" class="dense-row">
                  <td class="caption">{{ adder.name }} Adjustment</td>
                  <td class="text-right caption" :class="adder.difference > 0 ? 'green--text' : 'red--text'">
                    {{ adder.difference > 0 ? '+' : '' }}${{ formatNumber(adder.difference, true) }}
                  </td>
                </tr>
              </template>
              </tbody>
            </template>
          </v-simple-table>
        </v-expansion-panel-content>
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
                :class="getAdderRowClass(adder, index)"
                class="dense-row"
              >
                <td class="caption">{{ adder.name }}</td>
                <td class="text-center caption">{{ adder.unitPrice }}</td>
                <td class="text-right caption">
                  <div class="d-flex justify-end align-center">
                    <!-- For custom adders with project amount but no proposal amount -->
                    <span v-if="isCustomProjectOnly(adder)" class="text-no-wrap">
                      ${{ formatNumber(adder.customProjectAdderAmount || adder.projectAdderAmount, true) }}
                    </span>

                    <!-- For normal cases with both values -->
                    <template v-else>
                      <!-- Show strikethrough project amount if appropriate -->
                      <span
                        v-if="adder.projectAdderAmount !== null &&
                          adder.projectAdderAmount !== undefined &&
                          adder.projectAdderAmount !== adder.proposalAdderAmount &&
                          adder.proposalAdderAmount !== null &&
                          adder.proposalAdderAmount !== undefined"
                          class="text-decoration-line-through mr-2 grey--text text-no-wrap">
                        ${{ formatNumber(adder.projectAdderAmount, true) }}
                      </span>

                      <!-- Show proposal amount with appropriate coloring -->
                      <span :class="{
                        'red--text': adder.proposalAdderAmount < adder.projectAdderAmount && adder.projectAdderAmount !== null && adder.proposalAdderAmount !== null,
                        'green--text': adder.proposalAdderAmount > adder.projectAdderAmount && adder.projectAdderAmount !== null && adder.proposalAdderAmount !== null,
                        'text-no-wrap': true
                      }">
                        ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                      </span>
                    </template>
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

const expandedPanels = ref([1, 2]) // Open both Commission and Estimated Adders by default (0=Base Price, 1=Commission, 2=Estimated Adders)
const showNotification = ref(false)
const notificationText = ref('')
const basePrice = ref(0)
const commissionBase = ref(0)
const adders = ref([])

const commissionBaseTotal = computed(() => {
  return basePrice.value // No need to multiply as API will provide the correct scale
})

/**
 * Computed property to find adders with differences between project and proposal amounts.
 * Also includes adders selected only on the project to show negative values in Commission.
 */
const adderDifferences = computed(() => {
  return adders.value
    .filter(adder => {
      // Include if selected on project only
      if (adder.selectedOnProjectOnly) return true;

      // Include if there are valid custom amounts to compare
      const hasProjectAmount = adder.customProjectAdderAmount !== null &&
                              adder.customProjectAdderAmount !== undefined;
      const hasProposalAmount = adder.customProposalAdderAmount !== null &&
                               adder.customProposalAdderAmount !== undefined;

      // Check specifically for custom adders with project amount but no proposal amount
      const isCustomAdderProjectOnly = adder.adderType === 'custom_adders' &&
                                     adder.customProjectAdderAmount &&
                                     adder.customProjectAdderAmount > 0 &&
                                     (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);

      return hasProjectAmount || hasProposalAmount || isCustomAdderProjectOnly;
    })
    .map(adder => {
      // For custom adders with only project amount, ensure we always show a negative diff
      const isCustomAdderProjectOnly = adder.adderType === 'custom_adders' &&
                                     adder.customProjectAdderAmount &&
                                     adder.customProjectAdderAmount > 0 &&
                                     (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);

      // Difference: Proposal amount - Project amount
      // Negative value means project has higher amount than proposal
      const difference = (adder.customProposalAdderAmount || 0) - (adder.customProjectAdderAmount || 0);

      return {
        id: adder.id,
        name: adder.name,
        difference: difference
      };
    });
});

/**
 * Calculate the total commission, including adder differences
 */
const commissionTotal = computed(() => {
  // Base amount plus sum of all adder differences
  const adderDifferencesTotal = adderDifferences.value.reduce(
    (total, adder) => total + adder.difference, 0
  );

  return commissionBaseTotal.value + adderDifferencesTotal;
})

/**
 * Calculate the total cost of all adders
 */
const adderTotal = computed(() => {
  return adders.value.reduce((total, adder) => {
    // For custom adders with only project amount, use the project amount
    if (isCustomProjectOnly(adder)) {
      return total + (adder.customProjectAdderAmount || adder.projectAdderAmount || 0);
    }
    // Otherwise use proposalAdderAmount for consistency
    return total + (adder.proposalAdderAmount || 0);
  }, 0)
})

/**
 * Process and transform raw adder data from API
 * @param {Array} adderData - Raw adder data from API response
 */
const processAdderData = (adderData) => {
  // Filter relevant adders first
  const filteredAdders = adderData.filter(adder => {
    // Include if selected on proposal
    if (adder.selectedProposalAdder) return true;

    // Include if selected on project
    if (adder.selectedProjectAdder) return true;

    // Include custom adders with positive proposal amounts
    if (adder.adderType === 'custom_adders' && adder.customProposalAdderAmount > 0) return true;

    // Include custom adders with positive project amounts (even if proposal amount is 0/null/undefined)
    if (adder.adderType === 'custom_adders' &&
        adder.customProjectAdderAmount &&
        adder.customProjectAdderAmount > 0) return true;

    // Include auto-applied adders with positive amounts
    if (adder.adderType === 'auto_applied_adder' &&
        adder.autoAppliedProposalAdderAmount &&
        adder.autoAppliedProposalAdderAmount > 0) return true;

    // Exclude everything else
    return false;
  });

  // Map to our internal adder format
  adders.value = filteredAdders.map(adder => {
    // Initialize with default values
    const result = {
      id: adder.id,
      fieldName: adder.fieldName,
      name: adder.fieldName || 'Unknown Adder',
      unitPrice: adder.quantity ? `${adder.quantity}` : 'Flat Rate',
      projectAdderAmount: 0,
      proposalAdderAmount: 0,
      customProjectAdderAmount: null,
      customProposalAdderAmount: null,
      adderType: adder.adderType,
      selectedOnProjectOnly: false,
      selectedOnProposalOnly: false
    };

    // Determine if selected on project and/or proposal
    const isSelectedOnProject = adder.selectedProjectAdder || false;
    const isSelectedOnProposal = adder.selectedProposalAdder || false;

    result.selectedOnProjectOnly = isSelectedOnProject && !isSelectedOnProposal;
    result.selectedOnProposalOnly = isSelectedOnProposal && !isSelectedOnProject;

    // Process by adder type
    if (adder.adderType === 'selected_adders') {
      result.projectAdderAmount = adder.selectedAdderAmount || 0;
      result.proposalAdderAmount = adder.selectedProposalAdderAmount || adder.selectedAdderAmount || 0;

      // If selected on project only, set custom amounts for commission calculation with negative value
      if (result.selectedOnProjectOnly) {
        result.customProjectAdderAmount = adder.selectedAdderAmount || 0;
        result.customProposalAdderAmount = 0;
      }
    }
    else if (adder.adderType === 'custom_adders') {
      result.projectAdderAmount = adder.customProjectAdderAmount || 0;
      result.proposalAdderAmount = adder.customProposalAdderAmount || 0;

      // Store custom amounts for difference calculation
      result.customProjectAdderAmount = adder.customProjectAdderAmount || null;
      result.customProposalAdderAmount = adder.customProposalAdderAmount || null;

      // Flag custom adders that have project amount but no proposal amount
      // This helps identify them for highlighting in the table and showing in commission differences
      if (adder.customProjectAdderAmount && adder.customProjectAdderAmount > 0 &&
          (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0)) {
        // Treat it similar to selectedOnProjectOnly for display purposes
        result.selectedOnProjectOnly = true;
      }
    }
    else if (adder.adderType === 'auto_applied_adder') {
      result.projectAdderAmount = adder.autoAppliedAdderAmount || 0;
      result.proposalAdderAmount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0;
    }

    // Set amount for backward compatibility
    result.amount = result.proposalAdderAmount;

    return result;
  })
}

/**
 * Format a number as a currency string with optional decimal places
 * @param {number} value - The number to format
 * @param {boolean} showDecimals - Whether to show decimal places
 * @returns {string} Formatted number string
 */
const formatNumber = (value, showDecimals = true) => {
  if (value === null || value === undefined) {
    return 'N/A'
  }
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: showDecimals ? 2 : 0,
    maximumFractionDigits: showDecimals ? 2 : 0
  }).format(value)
}

/**
 * Check if adder is a custom adder with only project amount
 * @param {Object} adder - The adder to check
 * @returns {boolean} True if it's a custom adder with project amount but no proposal amount
 */
const isCustomProjectOnly = (adder) => {
  return adder.adderType === 'custom_adders' &&
         adder.customProjectAdderAmount &&
         adder.customProjectAdderAmount > 0 &&
         (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);
}

/**
 * Determine CSS classes for an adder row based on its state
 * @param {Object} adder - The adder object
 * @param {number} index - Row index for alternating colors
 * @returns {Object} CSS class object
 */
const getAdderRowClass = (adder, index) => {
  const isEvenRow = index % 2 === 0;
  const hasProposalOnly = adder.proposalAdderAmount && !adder.projectAdderAmount;
  const hasProjectOnly = !adder.proposalAdderAmount && adder.projectAdderAmount;

  // Check for custom adders with project amount but no proposal amount
  const isCustomAdderProjectOnly = adder.adderType === 'custom_adders' &&
    adder.customProjectAdderAmount &&
    adder.customProjectAdderAmount > 0 &&
    (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);

  return {
    // Striped alternating color for base rows
    'light-blue lighten-5': isEvenRow && !hasProposalOnly && !adder.selectedOnProjectOnly && !isCustomAdderProjectOnly,

    // Gray for proposal-only adders
    'grey lighten-2': hasProposalOnly && !adder.selectedOnProjectOnly && !isCustomAdderProjectOnly,

    // Green for project-only adders (including selectedProjectAdder and custom adders with only project amount)
    'green lighten-4': hasProjectOnly || adder.selectedOnProjectOnly || isCustomAdderProjectOnly
  };
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
      basePrice.value = data.commission_amount || 0;
      commissionBase.value = data.base_amount || 0;
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
