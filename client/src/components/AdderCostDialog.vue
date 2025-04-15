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
  { text: 'Description', value: 'description', width: '30%' },
  { text: 'Other', value: 'other', width: '15%' },
  { text: 'Quantity', value: 'quantity', width: '15%' },
  { text: 'Charge Amount (Total)', value: 'amount', width: '25%' },
  { text: 'Apply', value: 'apply', width: '15%', align: 'center' }
];

// Create a reactive array for the cost items
const costItems = ref([]);
const adderData = ref([]);

// Format amount as currency for display purposes only
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '--';

  // Handle decimal vs whole numbers - show decimals only if present
  if (value === Math.floor(value)) {
    return `$${value.toLocaleString()}`;
  } else {
    return `$${value.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }
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

    // Create proper request data format that matches ProposalAdderRequest
    const requestData = {
      adderItems: result.items
        // For selected_adders, include all of them - backend will handle the filtering based on applied status
        .filter(item => item.type === 'selected_adders' || item.type === 'custom_adders')
        .map(item => {
          const adderItem = {
            id: item.id,
            adderType: item.type,
            fieldName: item.description,
            applied: item.applied
          };

          // Add amount for custom adders
          if (item.type === 'custom_adders') {
            let amount = 0;
            if (item.customFields?.amount?.value) {
              amount = parseFloat(item.customFields.amount.value);
            } else if (item.rawAmount) {
              amount = parseFloat(item.rawAmount);
            }

            if (!isNaN(amount)) {
              adderItem.customAdderAmount = amount;
            }
          }

          return adderItem;
        })
    };

    console.log('Sending adder items to API:', JSON.stringify(requestData));

    const response = await postRequest(
      `/proposal/${props.proposalId}/adders/update`,
      requestData,
      'blueraven'
    );

    console.log('Adder update response:', response);

    // Create the right format for the parent component
    const appliedCosts = {
      totalCost: parseFloat(result.total.replace(/,/g, '')),
      selectedAdderIds: result.items
        .filter(item => item.type === 'selected_adders' && item.applied)
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
        })
    };

    emit('apply-costs', appliedCosts);
  } catch (error) {
    appStore.showSnack('ERROR', 'Error updating adders');
    console.error('Error updating adders:', error);
  } finally {
    appStore.loading = false;
    emit('close-dialog', false);
  }
};
</script>
