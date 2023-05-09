<template>
<v-data-table
  :loading="isDataLoading"
  :headers="headers"
  :items="reportData"
  fixed-header
  class="rounded-0"
>
  <template #no-data>
    No available report data
  </template>

  <template #no-results>
    No available report data
  </template>

  <template #item="{item}">
    <tr>
      <td
        v-for="field in item"
        :key="UUID()"
        class="text-left"
      >
        {{ field }}
      </td>
    </tr>
  </template>
</v-data-table>
</template>

<script setup>

import { computed, getCurrentInstance, watch } from 'vue'
import { logError, postRequest, UUID } from '@/helpers/helpers'
import { ref } from 'vue'
import isEqual from 'lodash.isequal'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar


const props = defineProps({
  report: {
    type: Object,
    required: true
  },
  fields: {
    type: Array,
    required: true
  },
  requirements: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['updated', 'queued'])

const reportData = ref([])
const isDataLoading = ref(false)
const isUpdateQueued = ref(false)

watch(
  () => [props.report, props.fields, props.requirements],
  async ([newReport, newFields, newRequirements], [oldReport, oldFields, oldRequirements]) => {

    if (isDataLoading.value) {
      return
    }

    if (!props.report?.objectTypeId || props.fields?.length < 1 || props.requirements.length < 1) {
      reportData.value = []
      return
    }

    //fetch new data only if report, fields, or reqs have changed
    if (!isEqual(newReport, oldReport) || !isEqual(newFields, oldFields) || !isEqual(newRequirements, oldRequirements)) {
      if (isDataLoading.value) {
        isUpdateQueued.value = true
        emit('queued')
      } else {
        processQueue()
      }
    }
  }
)

const headers = computed(() => {
  return props.fields.map(f => ({
    text: f.name,
    value: f.name,
    id: UUID()
  }))
})

const processQueue = async () => {
  try {
    isDataLoading.value = true
    isUpdateQueued.value = false
    reportData.value = []
    const {data} = await postRequest(`/smartlist/adhoc?limit=40`, {
      smartlist: props.report,
      fields: props.fields,
      requirements: props.requirements
    })

    reportData.value = data
    emit('updated')
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error while fetching smartlist data')
  } finally {
    isDataLoading.value = false
    if (isUpdateQueued.value) {
      processQueue()
    }
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

tr:nth-of-type(even) {
  @extend .shaded-row;
}

th {
  :not(:last-child) {
    border-right: 1px solid rgba(0, 0, 0, 0.12) !important;
  }
}

td:not(:last-child) {
  border-right: 1px solid rgba(0, 0, 0, 0.12) !important;
}


</style>