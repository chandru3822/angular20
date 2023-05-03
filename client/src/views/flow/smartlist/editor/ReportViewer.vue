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

import { computed, getCurrentInstance, watchEffect } from 'vue'
import { logError, postRequest, UUID } from '@/helpers/helpers'
import { ref } from 'vue'

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

const reportData = ref([])
const isDataLoading = ref(false)

watchEffect(async () => {
  if (!props.report?.objectTypeId || props.fields?.length < 1 || props.requirements.length < 1) {
    reportData.value = []
    return
  }

  getData()
})

const headers = computed(() => {
  return props.fields.map(f => ({
    text: f.name,
    value: f.name,
    id: UUID()
  }))
})

const getData = async () => {
  try {
    isDataLoading.value = true
    reportData.value = []
    const {data} = await postRequest(`/smartlist/adhoc?limit=40`, {
      smartlist: props.report,
      fields: props.fields,
      requirements: props.requirements
    })

    reportData.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error while fetching smartlist data')
  } finally {
    isDataLoading.value = false
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>