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
                  <td class="text-right caption">
                    <template v-if="adder.difference >= 0">+${{ formatNumber(adder.difference, true) }}</template>
                    <template v-else>-${{ formatNumber(Math.abs(adder.difference), true) }}</template>
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
                :class="[
                  {'shaded-row': index % 2},
                  {'grey lighten-3 text-decoration-line-through': shouldShowStrikethrough(adder)},
                  {'green lighten-5': shouldShowGreen(adder)}
                ]"
                class="dense-row"
              >
                <td class="caption" :class="{
                  'text-decoration-line-through grey--text': shouldShowStrikethrough(adder),
                  'green-text-color': shouldShowGreen(adder)
                }">{{ adder.name }}</td>
                <td class="text-center caption" :class="{
                  'text-decoration-line-through grey--text': shouldShowStrikethrough(adder),
                  'green-text-color': shouldShowGreen(adder)
                }">{{ adder.unitPrice }}</td>
                <td class="text-right caption">
                  <div class="d-flex justify-end align-center">
                    <!-- For custom adders with project amount but no proposal amount -->
                    <span v-if="isCustomProjectOnly(adder)" class="text-no-wrap">
                      ${{ formatNumber(adder.customProjectAdderAmount || adder.projectAdderAmount, true) }}
                    </span>

                    <!-- For normal cases with both values -->
                    <template v-else>
                      <!-- Auto-applied adders always shown as regular without styling -->
                      <template v-if="adder.adderType === 'auto_applied_adder'">
                        <span class="text-no-wrap">
                          ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                        </span>
                      </template>

                      <!-- Only show difference styling if adder is explicitly selected on project or proposal (not auto-applied) -->
                      <template v-else-if="(adder.selectedOnProjectOnly || adder.selectedOnProposalOnly || adder.adderType === 'custom_adders') && hasReviewDate">
                        <!-- Custom adders: Handle display based on value comparison -->
                        <template v-if="adder.adderType === 'custom_adders'">
                          <!-- When both values exist and are greater than 0 -->
                          <template v-if="adder.customProjectAdderAmount > 0 && adder.customProposalAdderAmount > 0">
                            <!-- When values are equal and both > 0, show in black with no strikethrough -->
                            <template v-if="adder.customProjectAdderAmount === adder.customProposalAdderAmount">
                              <span class="text-no-wrap">
                                ${{ formatNumber(adder.customProjectAdderAmount, true) }}
                              </span>
                            </template>
                            <!-- When project amount is GREATER than proposal amount -->
                            <template v-else-if="adder.customProjectAdderAmount > adder.customProposalAdderAmount">
                              <span class="text-decoration-line-through mr-2 grey--text text-no-wrap">
                                ${{ formatNumber(adder.customProposalAdderAmount, true) }}
                              </span>
                              <span class="green-text-color text-no-wrap">
                                ${{ formatNumber(adder.customProjectAdderAmount, true) }}
                              </span>
                            </template>
                            <!-- When proposal amount is GREATER than project amount -->
                            <template v-else>
                              <span class="text-decoration-line-through mr-2 grey--text text-no-wrap">
                                ${{ formatNumber(adder.customProposalAdderAmount, true) }}
                              </span>
                              <span class="green-text-color text-no-wrap">
                                ${{ formatNumber(adder.customProjectAdderAmount, true) }}
                              </span>
                            </template>
                          </template>
                          <!-- When only one value exists or other cases -->
                          <template v-else>
                            <span class="text-no-wrap" :class="{
                            'text-decoration-line-through grey--text': shouldShowStrikethrough(adder),
                            'green-text-color': shouldShowGreen(adder)
                            }">
                              ${{ formatNumber(adder.customProposalAdderAmount || adder.customProjectAdderAmount || 0, true) }}
                            </span>
                          </template>
                        </template>

                        <!-- For selected adders -->
                        <template v-else>
                          <!-- If both selectedProjectAdder and selectedProposalAdder are null, show regular styling -->
                          <template v-if="adder.adderType === 'selected_adders' &&
                                       adder.selectedOnProjectOnly === null &&
                                       adder.selectedOnProposalOnly === null">
                            <span class="text-no-wrap">
                              ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                            </span>
                          </template>

                          <!-- Otherwise, apply normal difference styling -->
                          <template v-else>
                            <!-- When selected on project but NOT on proposal -->
                            <template v-if="adder.selectedOnProjectOnly">
                              <span class="green-text-color text-no-wrap">
                                ${{ formatNumber(adder.projectAdderAmount, true) }}
                              </span>
                            </template>

                            <!-- When selected on proposal but NOT on project -->
                            <template v-else-if="adder.selectedOnProposalOnly">
                              <span class="text-decoration-line-through mr-2 grey--text text-no-wrap">
                                ${{ formatNumber(adder.proposalAdderAmount, true) }}
                              </span>
                            </template>

                            <!-- When amounts are different but both are selected -->
                            <template v-else-if="adder.proposalAdderAmount !== adder.projectAdderAmount &&
                                    adder.projectAdderAmount !== null &&
                                    adder.proposalAdderAmount !== null">
                              <span class="text-no-wrap">
                                ${{ formatNumber(adder.proposalAdderAmount, true) }}
                              </span>
                            </template>

                            <!-- When both amounts are the same -->
                            <template v-else>
                              <span class="text-no-wrap">
                                ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                              </span>
                            </template>
                          </template>
                        </template>
                      </template>

                      <!-- For non-selected adders, just show the regular amount without styling -->
                      <template v-else>
                        <span class="text-no-wrap">
                          ${{ formatNumber(adder.proposalAdderAmount || adder.amount || 0, true) }}
                        </span>
                      </template>
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
  },
  projectAddersLastReviewedDate: {
    type: [String, Date, null],
    default: null
  }
})

const expandedPanels = ref([1, 2]) // Open both Commission and Estimated Adders by default (0=Base Price, 1=Commission, 2=Estimated Adders)
const showNotification = ref(false)
const notificationText = ref('')
const basePrice = ref(0)
const commissionBase = ref(0)
const adders = ref([])

// Direct reference to basePrice since they're equivalent
const commissionBaseTotal = computed(() => basePrice.value)
const hasReviewDate = computed(() => props.projectAddersLastReviewedDate !== null && props.projectAddersLastReviewedDate !== undefined)

/**
 * Computed property to find adders with differences between project and proposal amounts.
 * Only includes differences for adders that have selectedProjectAdder or selectedProposalAdder = true,
 * or custom adders with different amounts.
 * Excludes adders with zero difference.
 */
const adderDifferences = computed(() => {
  if (!hasReviewDate.value) {
    return [];
  }

  return adders.value
    .filter(adder => {
      // Never include auto-applied adders in commission differences
      if (adder.adderType === 'auto_applied_adder') {
        return false;
      }

      // For selected adders, only include if they are explicitly selected (not if both are null)
      if (adder.adderType === 'selected_adders') {
        // If both selectedProjectAdder and selectedProposalAdder are null, don't include
        if (adder.selectedOnProjectOnly === false && adder.selectedOnProposalOnly === false) {
          return false;
        }
        return adder.selectedOnProjectOnly || adder.selectedOnProposalOnly;
      }

      // For custom adders, include if there's a difference in amounts
      if (adder.adderType === 'custom_adders') {
        return (adder.customProjectAdderAmount !== adder.customProposalAdderAmount &&
          (adder.customProjectAdderAmount !== null || adder.customProposalAdderAmount !== null));
      }

      return false;
    })
    .map(adder => {
      // Calculate difference: Proposal amount - Project amount for normal adders
      // For custom adders, always calculate Greater amount - Lesser amount for commission
      let difference;
      const proposalAmount = adder.customProposalAdderAmount || adder.proposalAdderAmount || 0;
      const projectAmount = adder.customProjectAdderAmount || adder.projectAdderAmount || 0;
      difference = proposalAmount - projectAmount;

      return {
        id: adder.id,
        name: adder.name,
        difference: difference
      };
    })
    // Filter out adders with zero difference
    .filter(adder => adder.difference !== 0);
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
    // For custom adders, always use the greater amount between project and proposal
    if (adder.adderType === 'custom_adders') {
      const projectAmount = adder.customProjectAdderAmount || adder.projectAdderAmount || 0;
      const proposalAmount = adder.customProposalAdderAmount || adder.proposalAdderAmount || 0;
      return total + Math.max(projectAmount, proposalAmount);
    }

    // For adders with only project amount (no proposal amount), use the project amount
    if (adder.selectedOnProjectOnly || isCustomProjectOnly(adder)) {
      return total + (adder.customProjectAdderAmount || adder.projectAdderAmount || 0);
    }

    // Otherwise use proposalAdderAmount for all other cases
    return total + (adder.proposalAdderAmount || 0);
  }, 0)
})

/**
 * Process and transform raw adder data from API
 * @param {Array} adderData - Raw adder data from API response
 */
const processAdderData = (adderData) => {
  // Filter relevant adders first - keep only those that should be displayed
  const filteredAdders = adderData.filter(adder => {
    // Exclude project-only adders when projectAddersLastReviewedDate is null
    if (!hasReviewDate.value &&
      adder.adderType === 'selected_adders' &&
      adder.selectedProjectAdder &&
      !adder.selectedProposalAdder) {
      return false;
    }

    // Include if selected on either proposal or project
    return adder.selectedProposalAdder ||
      adder.selectedProjectAdder ||
      // Include custom adders with any positive amount
      (adder.adderType === 'custom_adders' &&
        (adder.customProposalAdderAmount > 0 ||
          (adder.customProjectAdderAmount && adder.customProjectAdderAmount > 0))) ||
      // Include auto-applied adders with positive amounts
      (adder.adderType === 'auto_applied_adder' &&
        adder.autoAppliedProposalAdderAmount > 0)
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

    // Set selection flags, only if adder is explicitly selected
    result.selectedOnProjectOnly = isSelectedOnProject && !isSelectedOnProposal;
    result.selectedOnProposalOnly = hasReviewDate.value
      ? (isSelectedOnProposal && !isSelectedOnProject)
      : false;

    // Process based on adder type
    switch (adder.adderType) {
      case 'selected_adders':
        // Apply differences only if explicitly selected on project or proposal
        if (isSelectedOnProject || isSelectedOnProposal) {
          result.projectAdderAmount = isSelectedOnProject ? (adder.selectedAdderAmount || 0) : 0;
          result.proposalAdderAmount = isSelectedOnProposal ? (adder.selectedAdderAmount || 0) : 0;

          // Handle project-only selection
          if (result.selectedOnProjectOnly) {
            result.customProjectAdderAmount = adder.selectedAdderAmount || 0;
            result.customProposalAdderAmount = 0;
          }

          // Handle proposal-only selection
          if (result.selectedOnProposalOnly) {
            result.customProjectAdderAmount = 0;
            result.customProposalAdderAmount = adder.selectedAdderAmount || 0;
          }
        } else {
          // If not selected, just use the amount without showing differences
          result.projectAdderAmount = adder.selectedAdderAmount || 0;
          result.proposalAdderAmount = adder.selectedAdderAmount || 0;
        }
        break;

      case 'custom_adders':
        if (hasReviewDate.value) {
          result.customProposalAdderAmount = adder.customProjectAdderAmount || 0;
          result.customProjectAdderAmount = adder.customProjectAdderAmount || null;
        }
        result.customProposalAdderAmount = adder.customProposalAdderAmount || null;
        result.customProposalAdderAmount = adder.customProposalAdderAmount || 0;

        // Flag custom adders with only project amount
        if (adder.customProjectAdderAmount > 0 &&
          (!adder.customProposalAdderAmount || adder.customProposalAdderAmount <= 0)) {
          result.selectedOnProjectOnly = true;
        }

        // Flag custom adders with only proposal amount
        if (adder.customProposalAdderAmount > 0 &&
          (!adder.customProjectAdderAmount || adder.customProjectAdderAmount <= 0)
          && hasReviewDate.value) {
          result.selectedOnProposalOnly = true;
        }
        break;

      case 'auto_applied_adder':
        result.projectAdderAmount = adder.autoAppliedAdderAmount || 0;
        result.proposalAdderAmount = adder.autoAppliedProposalAdderAmount || adder.autoAppliedAdderAmount || 0;
        break;
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
    adder.customProjectAdderAmount > 0 &&
    (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);
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
    showNotification.value = true;
    notificationText.value = 'Error loading price details. Please refresh the page.';
  } finally {
    appStore.loading = false;
  }
};

/**
 * Helper method to determine if an adder should have strikethrough styling
 */
const shouldShowStrikethrough = (adder) => {
  // Apply strikethrough to both selected_adders and custom_adders with the specific condition
  if (adder.adderType === 'selected_adders') {
    return adder.selectedOnProposalOnly && !isCustomProjectOnly(adder);
  } else if (adder.adderType === 'custom_adders') {
    // For custom adders, apply strikethrough when proposal value > 0 but project value = 0
    return adder.customProposalAdderAmount > 0 &&
           (!adder.customProjectAdderAmount || adder.customProjectAdderAmount === 0) &&
           hasReviewDate.value;
  }
  return false;
}

/**
 * Helper method to determine if an adder should have green styling
 */
const shouldShowGreen = (adder) => {
  if (adder.adderType === 'selected_adders') {
    return adder.selectedOnProjectOnly && !isCustomProjectOnly(adder);
  } else if (adder.adderType === 'custom_adders') {
    // For custom adders, apply green styling when project value > 0 but proposal value = 0
    return adder.customProjectAdderAmount > 0 &&
           (!adder.customProposalAdderAmount || adder.customProposalAdderAmount === 0);
  }
  return false;
}

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

.green-text-color {
  color: #388E3B !important;
}

</style>
