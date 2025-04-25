<template>
  <GenericCostDialog
    :open-dialog="openDialog"
    :items="costItems"
    :headers="headers"
    title="Adder Cost"
    dialog-class="adder-cost-dialog"
    dialog-id="adderCostDialog"
    total-label="Subtotal"
    :persistent="false"
    @close-dialog="$emit('close-dialog', false)"
    @apply="handleApply"
    @cancel="handleCancel"
  />
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import GenericCostDialog from '@/components/GenericCostDialog.vue';
import { postRequest } from '@/helpers/helpers';
import { useAppStore } from '@/stores/AppStore.js';

const appStore = useAppStore();

const props = defineProps({
  openDialog: Boolean,
  existingAdders: {
    type: Object,
    default: () => ({})
  },
  proposalId: {
    type: [Number, String],
    required: true
  },
  commissionStrategyId: {
    type: [Number, String],
    default: 123
  },
  storageId: {
    type: [Number, String],
    default: 123
  }
});

const emit = defineEmits(['close-dialog', 'apply-costs', 'cancel']);

// Use the default headers from GenericCostDialog
const headers = [
  { text: 'Description', value: 'description', width: '30%', align: 'left' },
  { text: 'Other', value: 'other', width: '15%', align: 'left' },
  { text: 'Quantity', value: 'quantity', width: '15%', align: 'left' },
  { text: 'Charge Amount (Total)', value: 'amount', width: '25%', align: 'right', class: 'text-right' },
  { text: 'Apply', value: 'apply', width: '15%', align: 'center' }
];

// Create a reactive array for the cost items
const costItems = ref([]);
const adderData = ref([]);


// Format amount as currency for display purposes only
const formatCurrency = (value, adderType) => {
  if (value === null || value === undefined) return '--';
  
  // Don't format currency for custom_adders - return the raw value
  if (adderType === 'custom_adders') {
    // Return the exact number value, not formatted as currency
    return value;
  }

  // For other adder types, format as currency with 2 decimal places
  return `$${value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
};

const fetchAdderData = async () => {
  try {
    appStore.loading = true;

    const params = {
      proposalId: props.proposalId,
      commissionStrategyId: props.commissionStrategyId ?? 123,
      storageId: props.storageId ?? 123
    };

    const { data } = await postRequest(
      `/proposal/${props.proposalId}/adders`,
      params,
      'blueraven'
    );

    // Store all adder data without filtering out auto adders
    adderData.value = data;

    // Transform the adder data into the format needed for the dialog
    const transformedItems = data.map(adder => {
      // Determine the adder type and set fields accordingly
      let itemType, amount, applied, rawAmount;

      if (adder.adderType === 'auto_applied_adder') {
        // For auto-applied adders, check if they have a valid amount
        const autoAmount = adder.autoAppliedAdderAmount || adder.autoAppliedProposalAdderAmount;
        if (!autoAmount || autoAmount === 0) {
          // Skip auto-applied adders with null or 0 amount
          return null;
        } else {
          itemType = 'auto_applied_adder';
          rawAmount = autoAmount;
          amount = formatCurrency(rawAmount, 'auto_applied_adder');
          applied = true;
        }
      } else if (adder.adderType === 'custom_adders') {
        itemType = 'custom_adders';
        rawAmount = adder.customProposalAdderAmount === 0 ? 0 : (adder.customProposalAdderAmount || 0);
        // Don't format custom adder amounts - pass exact value
        amount = formatCurrency(rawAmount, 'custom_adders');

        // Auto-apply if amount is greater than 0
        applied = (rawAmount > 0) ? true : (adder.selectedProposalAdder || false);
      } else {
        itemType = 'selected_adders';
        rawAmount = adder.selectedAdderAmount;
        amount = formatCurrency(rawAmount, 'selected_adders');
        applied = adder.selectedProposalAdder || false;
      }

      // Format quantity for display
      const displayQuantity = adder.quantity
        ? adder.quantity.toString()
        : (['selected_adders', 'custom_adders'].includes(adder.adderType) ? 'Limited to 1' : 'Auto');

      const item = {
        id: adder.id || `adder-${adder.fieldName.replace(/\s+/g, '-').toLowerCase()}`,
        type: itemType,
        description: adder.fieldName,
        other: '',
        quantity: displayQuantity,
        rawQuantity: adder.quantity,
        amount: amount,
        rawAmount: rawAmount,
        applied: applied,
        adderType: adder.adderType
      };

      // Add custom fields for custom adder type
      if (adder.adderType === 'custom_adders') {
        // Special handling to ensure 0 values are properly handled
        const customAmount = adder.customProposalAdderAmount === 0 ? 0 : (adder.customProposalAdderAmount || 0);
        
        // For custom adders, use a plain number type instead of currency to prevent formatting issues
        item.customFields = {
          amount: {
            type: 'number',
            label: 'Amount',
            value: customAmount,
            includeInTotal: true
          }
        };
      }

      return item;
    });

    // Filter out null items (auto-applied adders with null or 0 amount)
    costItems.value = transformedItems.filter(item => item !== null);
  } catch (error) {
    appStore.showSnack('ERROR', 'Error retrieving proposal adders');
    console.error('Error retrieving proposal adders:', error);
  } finally {
    appStore.loading = false;
  }
};

watch(() => props.existingAdders, (newValue) => {
  if (newValue && Object.keys(newValue).length > 0) {
    try {
      // If existingAdders has items, apply them to our costItems
      if (newValue.items) {
        // First reset all items to ensure a clean state
        costItems.value.forEach(item => {
          // Auto-applied adders should always stay applied
          if (item.type !== 'auto_applied_adder') {
            item.applied = false;
          }
        });

        // Then apply the current state from existingAdders
        costItems.value.forEach(item => {
          const existingItem = newValue.items[item.id];

          // Only process if the item exists in the current state
          if (existingItem !== undefined) {
            if (typeof existingItem === 'boolean') {
              item.applied = existingItem;
            } else if (typeof existingItem === 'object' && item.type === 'custom_adders') {
              item.applied = true;
            } else if (typeof existingItem === 'string' || typeof existingItem === 'number') {
              item.applied = true;
              if (item.type === 'custom_adders' && item.customFields?.amount) {
                item.customFields.amount.value = existingItem;
                item.rawAmount = existingItem;
              }
            }
          }
        });
      }
    } catch (e) {
      console.error('Error initializing adder data', e);
    }
  }
}, { immediate: true, deep: true });

// Fetch data on dialog open
// Create a ref to store if we've already fetched the data at least once
const dataFetched = ref(false);

watch(() => props.openDialog, (isOpen) => {
  if (isOpen) {
    // Only fetch data the first time or when explicitly requested
    if (!dataFetched.value) {
      fetchAdderData();
      dataFetched.value = true;
    }
  }
  // We don't need to do anything when the dialog closes
  // as the parent component will handle this through event handlers
});

onMounted(() => {
  if (props.openDialog) {
    fetchAdderData();
    dataFetched.value = true;
  }
});

// Create a function to explicitly refresh data if needed
const refreshData = () => {
  fetchAdderData();
  dataFetched.value = true;
};

// Expose this function to parent component
defineExpose({
  refreshData
});

// Handle cancel button click
const handleCancel = () => {
  // Reset data fetch state to ensure a clean next opening
  dataFetched.value = false;

  // Emit both events to ensure parent component updates
  emit('close-dialog', false);
  emit('cancel');
};

const handleApply = async (result) => {
  try {
    appStore.loading = true;

    // Create the right format for the parent component without API call
    const appliedCosts = {
      totalCost: parseFloat(result.total.replace(/,/g, '')),
      // Include ALL selected adders with their applied state (true or false)
      selectedAdderIds: result.items
        .filter(item => item.type === 'selected_adders' && item.applied)
        .map(item => item.id),
      // Track explicitly unselected adders to properly remove them
      unselectedAdderIds: result.items
        .filter(item => item.type === 'selected_adders' && !item.applied)
        .map(item => item.id),
      customAdders: result.items
        .filter(item => item.type === 'custom_adders')
        .map(item => {
          // Explicitly handle 0 values
          let amount = 0;
          if (item.customFields?.amount?.value === '0' || item.customFields?.amount?.value === 0) {
            amount = 0;
          } else if (item.customFields?.amount?.value !== undefined) {
            amount = parseFloat(item.customFields.amount.value);
          } else if (item.rawAmount !== undefined) {
            amount = parseFloat(item.rawAmount);
          }

          // Default to Numeric value
          let dataTypeId = 4;
          if (item.customFields?.amount?.type === 'currency') {
            dataTypeId = 4;
          }

          // Make sure we include all custom adders regardless of amount
          return {
            id: item.id,
            fieldName: item.description,
            amount: amount, // Include exact amount value, especially for 0
            adderType: 'custom_adders',
            // For visual display: show as selected if amount > 0
            selectedProposalAdder: amount > 0,
            // Force inclusion in final payload
            includeInAPI: true,
            sendToAPI: true,
            customAdderDataType: dataTypeId
          };
        }),
      // Use the items directly from GenericCostDialog
      allItems: result.items
    };

    // REMOVED: Don't refetch data from API, which would override our applied changes
    // This allows the parent component to retain these changes when reopening the dialog
    // await fetchAdderData();

    // Don't reset fetch state - we want to retain the current state for reopening
    // dataFetched.value = false;

    // Emit the apply-costs event with the processed data
    emit('apply-costs', appliedCosts);

    // Explicitly close the dialog
    emit('close-dialog', false);
  } catch (error) {
    appStore.showSnack('ERROR', 'Error processing adders');
    console.error('Error processing adders:', error);

    // In case of error, close the dialog
    emit('close-dialog', false);
  } finally {
    appStore.loading = false;
  }
};
</script>

<style lang="scss" scoped>
/* All table styling is now handled by GenericCostDialog */
</style>
