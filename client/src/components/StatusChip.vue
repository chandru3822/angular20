<template>
  <v-chip
    small
    :color="statusColor"
    text-color="white"
    :class="customClass"
  >
    {{ statusText }}
  </v-chip>
</template>

<script setup>
  import { computed } from 'vue'

  const props = defineProps({
    status: {
      type: String,
      required: true
    },
    statusMap: {
      type: Object,
      default: () => ({
        APPROVED: { color: 'success', text: 'Approved' },
        PENDING: { color: 'warning', text: 'Pending' },
        INACTIVE: { color: 'grey', text: 'Inactive' },
        ACTIVE: { color: 'success', text: 'Active' },
        DRAFT: { color: 'grey darken-1', text: 'Draft' },
        REJECTED: { color: 'error', text: 'Rejected' },
        ERROR: { color: 'error', text: 'Error' },
        COMPLETED: { color: 'success', text: 'Completed' },
        IN_PROGRESS: { color: 'primary', text: 'In Progress' },
        CANCELLED: { color: 'grey darken-1', text: 'Cancelled' }
      })
    },
    customClass: {
      type: String,
      default: ''
    }
  })

  // Get the status color
  const statusColor = computed(() => {
    const statusConfig = props.statusMap[props.status] || { color: 'grey' }
    return statusConfig.color
  })

  // Get the status text
  const statusText = computed(() => {
    const statusConfig = props.statusMap[props.status] || { text: props.status }
    return statusConfig.text
  })
</script>
