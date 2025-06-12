<template>
  <v-expansion-panel :class="panelClass">
    <v-expansion-panel-header :class="headerClass" :hide-actions="hideActions">
      <!-- Left side content (title) -->
      <span class="d-flex align-center">
        <FormFieldSkeleton
          type="text"
          :width="titleWidth"
        />
        <!-- Optional icon skeleton -->
        <FormFieldSkeleton
          v-if="showIcon"
          type="text"
          width="16"
          custom-class="ml-1"
        />
      </span>
      
      <!-- Right side content (subtitle/buttons) -->
      <span v-if="showRightContent" class="d-flex align-center justify-end ml-auto">
        <!-- Action buttons skeleton -->
        <template v-if="showButtons">
          <FormFieldSkeleton
            v-for="i in buttonCount"
            :key="`button-${i}`"
            type="button"
            :width="buttonWidth"
            :custom-class="i < buttonCount ? 'mr-2' : ''"
          />
        </template>
        
        <!-- Subtitle skeleton -->
        <template v-else>
          <FormFieldSkeleton
            type="text"
            :width="subtitleWidth"
            custom-class="mr-2"
          />
          <FormFieldSkeleton
            type="text"
            :width="valueWidth"
          />
        </template>
      </span>
    </v-expansion-panel-header>
    
    <!-- Panel content -->
    <v-expansion-panel-content v-if="hasContent" :class="contentClass">
      <!-- Table content -->
      <TableSkeleton
        v-if="showTable"
        :headers="tableHeaders"
        :rows="tableRows"
        :table-class="tableClass"
      />
      
      <!-- Form field content (for configuration panels) -->
      <template v-else-if="contentType === 'form-fields'">
        <FormFieldSkeleton
          v-for="i in formFieldCount"
          :key="`field-${i}`"
          type="list-item-two-line"
          custom-class="my-2"
        />
      </template>
      
      <!-- Adders content (for adders panel) -->
      <template v-else-if="contentType === 'adders'">
        <FormFieldSkeleton
          type="text"
          custom-class="my-4"
        />
        <FormFieldSkeleton
          type="text"
          width="150"
          custom-class="mb-2"
        />
      </template>
      
      <!-- Custom content slot -->
      <slot v-else />
    </v-expansion-panel-content>
  </v-expansion-panel>
</template>

<script setup>
import FormFieldSkeleton from './FormFieldSkeleton.vue'
import TableSkeleton from './TableSkeleton.vue'

defineProps({
  // Panel styling
  panelClass: {
    type: String,
    default: ''
  },
  headerClass: {
    type: String,
    default: ''
  },
  contentClass: {
    type: String,
    default: ''
  },
  hideActions: {
    type: Boolean,
    default: false
  },
  
  // Header content
  titleWidth: {
    type: [String, Number],
    default: 100
  },
  showIcon: {
    type: Boolean,
    default: false
  },
  showRightContent: {
    type: Boolean,
    default: true
  },
  
  // Buttons (for Configuration header)
  showButtons: {
    type: Boolean,
    default: false
  },
  buttonCount: {
    type: Number,
    default: 2
  },
  buttonWidth: {
    type: [String, Number],
    default: 60
  },
  
  // Subtitle (for Price Details header)
  subtitleWidth: {
    type: [String, Number],
    default: 60
  },
  valueWidth: {
    type: [String, Number],
    default: 80
  },
  
  // Content
  hasContent: {
    type: Boolean,
    default: true
  },
  showTable: {
    type: Boolean,
    default: false
  },
  tableHeaders: {
    type: Array,
    default: () => []
  },
  tableRows: {
    type: Number,
    default: 3
  },
  tableClass: {
    type: String,
    default: ''
  },
  
  // Content types
  contentType: {
    type: String,
    default: '',
    validator: value => ['', 'form-fields', 'adders'].includes(value)
  },
  formFieldCount: {
    type: Number,
    default: 2
  }
})
</script>