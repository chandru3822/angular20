<template>
  <v-simple-table dense :class="tableClass">
    <template v-slot:default>
      <thead v-if="showHeaders">
        <tr>
          <th
            v-for="(header, index) in headers"
            :key="`header-${index}`"
            :class="header.class || 'font-weight-bold'"
          >
            <FormFieldSkeleton
              type="text"
              :width="header.width || 60"
            />
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="rowIndex in rows"
          :key="`row-${rowIndex}`"
          :class="rowClass"
        >
          <td
            v-for="(header, colIndex) in headers"
            :key="`cell-${rowIndex}-${colIndex}`"
            :class="header.cellClass || 'caption'"
          >
            <div v-if="header.alignment === 'right'" class="d-flex justify-end align-center">
              <FormFieldSkeleton
                type="text"
                :width="getCellWidth(header, rowIndex, colIndex)"
              />
            </div>
            <div v-else-if="header.alignment === 'center'" class="d-flex justify-center align-center">
              <FormFieldSkeleton
                type="text"
                :width="getCellWidth(header, rowIndex, colIndex)"
              />
            </div>
            <FormFieldSkeleton
              v-else
              type="text"
              :width="getCellWidth(header, rowIndex, colIndex)"
            />
          </td>
        </tr>
      </tbody>
    </template>
  </v-simple-table>
</template>

<script setup>
import FormFieldSkeleton from './FormFieldSkeleton.vue'

const props = defineProps({
  headers: {
    type: Array,
    required: true,
    // Expected format: [{ text: 'Header', width: 60, cellWidth: 80, cellClass: 'text-right', alignment: 'right' }]
  },
  rows: {
    type: Number,
    default: 3
  },
  tableClass: {
    type: String,
    default: ''
  },
  rowClass: {
    type: String,
    default: 'dense-row'
  },
  showHeaders: {
    type: Boolean,
    default: true
  },
  variableRowWidths: {
    type: Boolean,
    default: false
  }
})

const getCellWidth = (header, rowIndex, colIndex) => {
  // If variable widths are enabled, vary the width slightly for each row
  if (props.variableRowWidths && header.cellWidth) {
    return header.cellWidth + (rowIndex * 5) + (colIndex * 3)
  }
  
  // Use specified cell width or fall back to header width
  return header.cellWidth || header.width || 60
}
</script>