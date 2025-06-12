<template>
  <div class="proposal-skeleton">
    <ExpansionPanelSkeleton
      panelClass="mb-2"
      headerClass="parent-expansion-header price-details-header"
      titleWidth="100"
      showRightContent
      showButtons
      buttonCount="2"
      buttonWidth="60"
      hasContent
      contentClass="child-expansion-panel-content"
    />
    <ExpansionPanelGroupSkeleton :panels="priceDetailsPanels" />
  </div>
</template>

<script setup>
import ExpansionPanelGroupSkeleton from './ExpansionPanelGroupSkeleton.vue'
import ExpansionPanelSkeleton from './ExpansionPanelSkeleton.vue'

// Define the panel configurations
const priceDetailsPanels = [
  // Base Price Panel
  {
    panelClass: 'my-2',
    headerClass: '',
    hideActions: true,
    titleWidth: 80,
    showIcon: false,
    showRightContent: true,
    showButtons: false,
    subtitleWidth: 60,
    valueWidth: 80,
    hasContent: false
  },

  // Commission Panel
  {
    panelClass: 'mb-2',
    headerClass: '',
    hideActions: true,
    titleWidth: 100,
    showIcon: false,
    showRightContent: true,
    showButtons: false,
    subtitleWidth: 60,
    valueWidth: 80,
    hasContent: true,
    showTable: true,
    contentClass: 'child-expansion-panel-content',
    tableClass: 'commission-table',
    tableHeaders: [
      { text: 'Item', width: 40, cellWidth: 80, class: 'text-left font-weight-bold' },
      { text: 'Amount', width: 60, cellWidth: 60, class: 'text-right font-weight-bold', cellClass: 'text-right caption', alignment: 'right' }
    ],
    tableRows: 3
  },

  // Estimated Adders Panel
  {
    panelClass: '',
    headerClass: '',
    hideActions: true,
    titleWidth: 120,
    showIcon: true,
    showRightContent: true,
    showButtons: false,
    subtitleWidth: 60,
    valueWidth: 80,
    hasContent: true,
    showTable: true,
    contentClass: 'child-expansion-panel-content',
    tableClass: 'adder-table',
    tableHeaders: [
      { text: 'Item', width: 40, cellWidth: 80, class: 'text-left font-weight-bold' },
      { text: 'Unit Price', width: 70, cellWidth: 50, class: 'text-center font-weight-bold', cellClass: 'text-center caption', alignment: 'center' },
      { text: 'Total Amount', width: 90, cellWidth: 70, class: 'text-right font-weight-bold', cellClass: 'text-right caption', alignment: 'right' }
    ],
    tableRows: 4,
    variableRowWidths: true
  }
]
</script>
