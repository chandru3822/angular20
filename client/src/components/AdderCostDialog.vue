<template>
  <GenericCostDialog
    :open-dialog="openDialog"
    :items="costItems"
    :headers="headers"
    title="Adder Cost"
    dialog-class="adder-cost-dialog"
    dialog-id="adderCostDialog"
    total-label="Total Cost"
    @close-dialog="$emit('close-dialog', false)"
    @apply="handleApply"
    @cancel="$emit('cancel')"
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
  }
});

const emit = defineEmits(['close-dialog', 'apply-costs', 'cancel']);

// Define table headers
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
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '--';

  // Always show 2 decimal places for consistency
  return `$${value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
};

// Parse currency string back to number
const parseCurrency = (value) => {
  if (typeof value === 'number') return value;
  if (!value || value === '--') return 0;

  return parseFloat(value.replace(/[$,]/g, ''));
};

const fetchAdderData = async () => {
  try {
    appStore.loading = true;

    const params = {
      proposalId: props.proposalId,
      commissionStrategyId: 123, // Hardcoded for now
      storageId: 123 // Hardcoded for now
    };

    const { data } = await postRequest(
      `/proposal/${props.proposalId}/adders`,
      params,
      'blueraven'
    );

    // Store the raw adder data
    adderData.value = data;

    // Transform the adder data into the format needed for the dialog
    const transformedItems = data.map(adder => {
      // Determine the adder type and set fields accordingly
      let itemType, amount, applied, rawAmount;

      if (adder.adderType === 'auto_applied_adder') {
        itemType = 'auto_applied_adder';
        rawAmount = adder.autoAppliedAdderAmount;
        amount = formatCurrency(rawAmount);
        applied = true;
      } else if (adder.adderType === 'custom_adders') {
        itemType = 'custom_adders';
        rawAmount = adder.customProposalAdderAmount;
        amount = formatCurrency(rawAmount);

        // Auto-apply if amount is greater than 0
        applied = (rawAmount > 0) ? true : (adder.selectedProposalAdder || false);
      } else {
        itemType = 'selected_adders';
        rawAmount = adder.selectedAdderAmount;
        amount = formatCurrency(rawAmount);
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
        item.customFields = {
          amount: {
            type: 'currency',
            label: 'Amount',
            value: adder.customProposalAdderAmount,
            includeInTotal: true
          }
        };
      }

      return item;
    });

    costItems.value = transformedItems;
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
        costItems.value.forEach(item => {
          const existingItem = newValue.items[item.id];
          if (existingItem !== undefined) {
            if (typeof existingItem === 'boolean') {
              item.applied = existingItem;
            } else if (typeof existingItem === 'object' && item.type === 'custom_adders') {
              item.applied = true;
            } else if (typeof existingItem === 'string' || typeof existingItem === 'number') {
              item.applied = true;
              if (item.type === 'custom_adders' && item.customFields.amount) {
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
watch(() => props.openDialog, (isOpen) => {
  if (isOpen && costItems.value.length === 0) {
    fetchAdderData();
  }
});

onMounted(() => {
  if (props.openDialog) {
    fetchAdderData();
  }
});

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
        .filter(item => item.type === 'custom_adders' && item.applied)
        .map(item => {
          let amount = 0;
          if (item.customFields?.amount?.value) {
            amount = parseFloat(item.customFields.amount.value);
          } else if (item.rawAmount) {
            amount = parseFloat(item.rawAmount);
          }

          return {
            id: item.id,
            fieldName: item.description,
            amount: amount,
            adderType: 'custom_adders',
            selectedProposalAdder: true
          };
        }),
      // Include all adder items with their current applied state and custom field values for accurate tracking
      allItems: result.items.map(item => {
        const resultItem = {
          id: item.id,
          type: item.type,
          applied: item.applied
        };
        
        // Include the customFields if they exist
        if (item.customFields) {
          resultItem.customFields = item.customFields;
        }
        
        return resultItem;
      })
    };

    // Emit the apply-costs event with the processed data
    emit('apply-costs', appliedCosts);
    
    // No need to close dialog here, as GenericCostDialog will handle the closing
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
/* Make sure the charge amount column is right-aligned */
:deep(.v-data-table) {
  td:nth-child(4) {
    text-align: right !important;
  }
  
  .amount-column,
  .text-right {
    text-align: right !important;
    width: 100% !important;
    display: block !important;
  }
}

/* Make sure header alignment is correct */
:deep(.v-data-table__header tr th:nth-child(4)) {
  text-align: right !important;
}
</style>