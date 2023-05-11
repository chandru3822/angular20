<template>
<fragment>
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

<v-btn
  v-if="isSystemAdmin"
  fab
  absolute
  bottom
  right
  color="info"
  class="mb-16"
  @click="getQuery"
>
  <v-icon>mdi-database-eye-outline</v-icon>
</v-btn>

</fragment>
</template>

<script setup>

import { computed, getCurrentInstance, watch } from 'vue'
import { logError, postRequest, UUID } from '@/helpers/helpers'
import { ref } from 'vue'
import isEqual from 'lodash.isequal'
import { Fragment } from 'vue-frag'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
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

const isSystemAdmin = store.getters.isFullAdmin

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
    id: UUID(),
    class: 'text-no-wrap'
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

const getQuery = async () => {
  try {
    const {data} = await postRequest(`/smartlist/adhoc/query`, {
      smartlist: props.report,
      fields: props.fields,
      requirements: props.requirements
    })

    navigator.clipboard.writeText(data.query);
    snackbar('SUCCESS', 'Query copied to clipboard')

  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching query')
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

tr:nth-of-type(even) {
  @extend .shaded-row;
}

:deep(th) {

  span {
    font-size: 16px;
  }

  &:first-child {
    border-left: 1px solid var(--v-grey-lighten2) !important;
  }

  &:not(:last-child) {
    border-right: 1px solid var(--v-grey-lighten2) !important;
  }
}

td:not(:last-child) {
  border-right: 1px solid var(--v-grey-lighten2) !important;
}

</style>