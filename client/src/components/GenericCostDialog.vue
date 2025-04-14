<template>
  <v-dialog
    :class="dialogClass"
    v-model="show"
    :retain-focus="retainFocus"
    :width="width"
    @click:outside="cancel"
    :id="dialogId"
    :ref="dialogId"
    :persistent="persistent"
  >
    <v-card>
      <v-card-title
        class="albatross-header-2 lighten-2 pb-1 d-flex justify-space-between align-center"
        primary-title
      >
        <span>{{ title }}</span>
        <v-btn icon @click="cancel">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-card-title>
      <v-divider />

      <!-- Table container with fixed height and scrolling -->
      <div class="table-container">
        <v-card-text class="pt-3 pb-0">
          <v-data-table
            :headers="headers"
            :items="tableItems"
            :items-per-page="-1"
            hide-default-footer
            disable-sort
            disable-pagination
            class="elevation-0"
            fixed-header
            height="500"
          >
            <template v-slot:item="{ item, index }">
              <tr :class="{ 'shaded-row': index % 2, 'selected-row': item.applied }">
                <!-- Description with tooltip if available -->
                <td :class="{ 'font-weight-bold': item.applied }">
                  <div class="description-container">
                    <span class="description-text">{{ item.description }}</span>
                    <v-tooltip v-if="item.tooltip" top max-width="400">
                      <template v-slot:activator="{ on, attrs }">
                        <a-btn
                          size="small"
                          icon
                          class="information-icon"
                          color="var(--v-grey-base)"
                          v-bind="attrs"
                          :activation-handler="on"
                          append-icon="mdi-information"
                        ></a-btn>
                      </template>
                      <span>{{ item.tooltip }}</span>
                    </v-tooltip>
                  </div>
                </td>
                <!-- Dynamic columns based on headers -->
                <template v-for="header in headers.slice(1, headers.length - 1)">
                  <td :key="header.value">
                    <!-- Input fields for customField type -->
                    <template v-if="item.type === 'custom_adders' && item.customFields && item.customFields[header.value]">
                      <!-- Select field -->
                      <v-select
                        v-if="item.customFields[header.value].type === 'select'"
                        v-model="item.customFields[header.value].value"
                        :items="item.customFields[header.value].options"
                        :label="item.customFields[header.value].label"
                        dense
                        hide-details
                        @input="handleCustomFieldInput(item)"
                      />

                      <!-- Text field -->
                      <v-text-field
                        v-else-if="item.customFields[header.value].type === 'text'"
                        v-model="item.customFields[header.value].value"
                        :label="item.customFields[header.value].label"
                        dense
                        hide-details
                        @input="handleCustomFieldInput(item)"
                      />

                      <!-- Number field -->
                      <v-text-field
                        v-else-if="item.customFields[header.value].type === 'number'"
                        v-model="item.customFields[header.value].value"
                        :label="item.customFields[header.value].label"
                        type="number"
                        dense
                        hide-details
                        @input="handleCustomFieldInput(item)"
                      />

                      <!-- Currency field -->
                      <v-text-field
                        v-else-if="item.customFields[header.value].type === 'currency'"
                        v-model="item.customFields[header.value].value"
                        :label="item.customFields[header.value].label"
                        prefix="$"
                        dense
                        hide-details
                        @input="handleCustomFieldInput(item)"
                      />
                    </template>

                    <span v-else class="field-value" :class="{
                      'text--secondary': item[header.value] === 'Auto' || item[header.value] === 'Limited to 1',
                      'font-weight-bold': item.applied && item[header.value] !== 'Limited to 1' && item[header.value] !== 'Auto'
                    }">
                      {{ item[header.value] }}
                    </span>
                  </td>
                </template>

                <!-- Apply Switch -->
                <td class="text-center" v-if="item.type === 'selected_adders'">
                  <v-switch
                    v-model="item.applied"
                    hide-details
                  />
                </td>
                <td v-else-if="item.type === 'custom_adders'">
                  <v-icon
                    v-model="item.applied"
                    v-if="item.applied"
                    hide-details
                    disabled
                    color="--v-primary-base"
                  >
                    mdi-check
                  </v-icon>
                </td>
                <td v-else>
                  <v-icon
                    v-model="item.applied"
                    hide-details
                    disabled
                    color="--v-primary-base"
                  >
                    mdi-check
                  </v-icon>
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card-text>
      </div>

      <v-divider></v-divider>

      <v-card-actions class="px-4 py-3 pb-1">
        <div class="font-weight-medium">{{ totalLabel }}: ${{ calculatedTotal }}</div>
        <v-spacer></v-spacer>
        <v-btn
          text
          :color="cancelButtonColor"
          @click="cancel"
          class="text-capitalize mr-2"
        >
          {{ cancelButtonText }}
        </v-btn>
        <v-btn
          :color="applyButtonColor"
          class="elevation-2 text-capitalize"
          @click="apply"
          :disabled="!hasAppliedItems"
          :readonly="!hasAppliedItems"
        >
          {{ applyButtonText }}
        </v-btn>
      </v-card-actions>
      <div class="text-body-2 grey--text pa-4">
        <strong>Selected Adders:&nbsp;</strong>
        <div>
          <div class="pb-3 grey--text text-caption" v-if="appliedItemsSummary">
            {{ appliedItemsSummary }}
          </div>
        </div>
      </div>

    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  openDialog: Boolean,
  retainFocus: {
    type: Boolean,
    default: false
  },
  width: {
    type: Number,
    default: 800
  },
  title: {
    type: String,
    default: 'Generic Dialog'
  },
  dialogClass: {
    type: String,
    default: 'generic-dialog'
  },
  dialogId: {
    type: String,
    default: 'genericDialog'
  },
  persistent: {
    type: Boolean,
    default: true
  },
  headers: {
    type: Array,
    default: () => [
      { text: 'Description', value: 'description', width: '30%' },
      { text: 'Other', value: 'other', width: '15%' },
      { text: 'Quantity', value: 'quantity', width: '15%' },
      { text: 'Charge Amount', value: 'amount', width: '25%' },
      { text: 'Apply', value: 'apply', width: '15%', align: 'center' }
    ]
  },
  items: {
    type: Array,
    default: () => []
  },
  totalLabel: {
    type: String,
    default: 'Total Cost'
  },
  cancelButtonText: {
    type: String,
    default: 'Cancel'
  },
  applyButtonText: {
    type: String,
    default: 'Apply'
  },
  cancelButtonColor: {
    type: String,
    default: 'primary'
  },
  applyButtonColor: {
    type: String,
    default: 'primary'
  }
});

const emit = defineEmits(['close-dialog', 'apply', 'cancel']);

const show = computed(() => {
  return props.openDialog;
});

const tableItems = ref([]);

watch(() => props.items, (newItems) => {
  if (newItems && newItems.length > 0) {
    tableItems.value = JSON.parse(JSON.stringify(newItems));

    // Auto-apply for auto_applied_adder type items
    tableItems.value.forEach(item => {
      if (item.type === 'auto_applied_adder') {
        item.applied = true;
      }
    });
  }
}, { immediate: true, deep: true });

watch(() => props.openDialog, (newVal) => {
  if (newVal && props.items && props.items.length > 0) {
    // Reset all items to their default state
    tableItems.value = JSON.parse(JSON.stringify(props.items));

    // Auto-apply for auto_applied_adder type items
    tableItems.value.forEach(item => {
      if (item.type === 'auto_applied_adder') {
        item.applied = true;
      }
    });
  }
});

// Automatically apply custom adders when value > 0
const handleCustomFieldInput = (item) => {
  if (item.type === 'custom_adders') {
    // Check if any custom field has a value > 0 for currency/number fields
    const hasValue = Object.values(item.customFields).some(field => {
      if (field.type === 'currency' || field.type === 'number') {
        const numValue = parseFloat(field.value);
        return !isNaN(numValue) && numValue > 0; // Only consider values > 0
      } else if (field.type === 'text') {
        return field.value !== '';
      } else if (field.type === 'select') {
        // For select, we consider it has a value if it's not the default or empty
        return field.value !== '' && field.value !== null;
      }
      return false;
    });

    if (hasValue) {
      item.applied = true;
    } else {
      // If the value is 0 or empty, auto-disable
      const currencyField = Object.values(item.customFields).find(field =>
        field.type === 'currency' || field.type === 'number'
      );

      if (currencyField) {
        const numValue = parseFloat(currencyField.value);
        if (isNaN(numValue) || numValue <= 0) {
          item.applied = false;
        }
      }
    }
  }
};

const hasAppliedItems = computed(() => {
  return tableItems.value.some(item => item.applied && item.type !== 'auto_applied_adder');
});

const appliedItemsSummary = computed(() => {
  const appliedItems = tableItems.value.filter(item => item.applied);

  if (appliedItems.length === 0) {
    return '';
  }

  return appliedItems.map(item => {
    let text = item.description;

    // Add price information if available
    if (item.type === 'custom_adders' && item.customFields) {
      // For custom items with user-defined values
      if (item.customFields.other && item.customFields.quantity) {
        // For items like trenching with type and size
        const type = item.customFields.other.value || '';
        const size = item.customFields.quantity.value ? `${item.customFields.quantity.value}ft` : '';

        if (type || size) {
          text += ` (${type}${type && size ? ', ' : ''}${size})`;
        }
      }
    }

    return text;
  }).join(', ');
});

// Parse currency string to number
const parseCurrency = (value) => {
  if (typeof value === 'number') return value;
  if (!value || value === '--') return 0;

  return parseFloat(value.replace(/[$,]/g, ''));
};

// Calculate the total based on applied items
const calculatedTotal = computed(() => {
  let total = 0;

  tableItems.value.forEach(item => {
    if (item.applied) {
      if (item.type === 'custom_adders') {
        // Check if there's a currency or number field that should contribute to total
        const amountField = Object.entries(item.customFields || {}).find(
          ([key, field]) => field.type === 'currency' || (field.type === 'number' && field.includeInTotal)
        );

        if (amountField) {
          const [, field] = amountField;
          total += parseFloat(field.value) || 0;
        } else if (item.rawAmount !== undefined) {
          // Use the raw amount value if available
          total += item.rawAmount;
        } else if (item.amount && item.amount !== '--') {
          // Fall back to parsing the amount field if it exists
          total += parseCurrency(item.amount);
        }
      } else if (item.rawAmount !== undefined) {
        // Use the raw amount value if available
        total += item.rawAmount;
      } else if (item.amount && item.amount !== '--') {
        // For selected and auto adders, parse the amount field
        total += parseCurrency(item.amount);
      }
    }
  });

  // Format with commas for thousands
  return total.toLocaleString();
});

// Handle apply action
const apply = () => {
  // Collect all applied items and their values
  const result = {
    total: calculatedTotal.value,
    items: tableItems.value.map(item => {
      // Include all items, not just applied ones, to preserve their state
      const resultItem = {
        id: item.id,
        type: item.type,
        description: item.description,
        applied: item.applied,
        rawAmount: item.rawAmount
      };

      // Add standard fields
      props.headers.slice(1, props.headers.length - 1).forEach(header => {
        if (item[header.value]) {
          resultItem[header.value] = item[header.value];
        }
      });

      // Add custom fields if present
      if (item.type === 'custom_adders' && item.customFields) {
        resultItem.customFields = {};
        Object.keys(item.customFields).forEach(key => {
          resultItem.customFields[key] = item.customFields[key].value;
        });
      }

      return resultItem;
    })
  };

  emit('apply', result);
  emit('close-dialog', false);
};

// Handle cancel action
const cancel = () => {
  emit('cancel');
  emit('close-dialog', false);
};
</script>

<style lang="scss" scoped>
.generic-dialog {
  // Table container with fixed height and scrolling
  .table-container {
    max-height: 500px;
    overflow-y: auto;
    overflow-x: hidden;
  }

  // Style for Auto or Limited labels
  .field-value {
    &.text--secondary {
      font-size: 12px;
      color: rgba(0, 0, 0, 0.6);
      font-weight: normal;
    }
  }

  // Clean up table styles
  ::v-deep .v-data-table {
    .v-data-table__wrapper {
      overflow-x: hidden; // Prevent horizontal scrollbar
    }

    th {
      font-weight: 500;
      white-space: nowrap;
      position: sticky;
      top: 0;
      z-index: 1;
      background-color: white;
    }

    tr {
      height: 48px;
    }
  }

  // Make switches more compact
  ::v-deep .v-input--switch {
    margin-top: 0;
  }
}

.description-container {
  position: relative;
  padding-right: 32px;
}

.description-text {
  display: block;
  word-break: break-word;
}

.information-icon {
  position: absolute;
  top: 0;
  right: 0;
}

::v-deep .v-tooltip__content {
  max-width: 400px;
  word-break: break-word;
  white-space: normal;
  overflow-wrap: break-word;
}

.tooltip-text {
  display: block;
  text-align: left;
}
</style>
