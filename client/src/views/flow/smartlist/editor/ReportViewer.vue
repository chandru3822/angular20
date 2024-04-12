<template>
  <v-data-table
    :loading="isDataLoading"
    :headers="headers"
    :items="reportData"
    :items-per-page="25"
    fixed-header
    :footer-props="footerProps"
    class="rounded-0"
  >
    <template #no-data>
      <span v-if="requirements.length > 0">No available report data</span>
      <span v-else
        >Select at least one column and one filter to view data preview</span
      >
    </template>

    <template #no-results> No available report data </template>

    <template #item="{ item }">
      <tr>
        <td v-for="field in item" :key="UUID()" class="text-left">
          {{ field }}
        </td>
      </tr>
    </template>

    <template #top>
      <a-btn
          v-if="isSystemAdmin"
          html-style="position:absolute; bottom: 10px; right: 10px;"
          color="info"
          class="mb-16"
          @click="getQuery"
          prepend-icon="mdi-database-eye-outline"
      ></a-btn>
    </template>
  </v-data-table>
</template>

<script setup>
import { computed, getCurrentInstance, ref, watch } from 'vue'
import { logError, postRequest, UUID } from '@/helpers/helpers'
import {
  requestInterceptor,
  responseInterceptor,
} from '@/helpers/interceptors'
import isEqual from 'lodash.isequal'
import axios from 'axios'
import constants from '@/helpers/constants'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()

const snackbar = vueInstance.$snackbar

const http = axios.create({
  baseURL: `${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/flow`,
})
http.interceptors.request.use(requestInterceptor)
http.interceptors.response.use((response) => {
  if (response.status !== 200 && response.status !== 500) {
    responseInterceptor({ response })
  }

  return response
})

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

const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})

const isSystemAdmin = userStore.isSystemAdmin
const reportData = ref([])
const isDataLoading = ref(false)
const isUpdateQueued = ref(false)

watch(
  () => [props.report, props.fields, props.requirements],
  async (
    [newReport, newFields, newRequirements],
    [oldReport, oldFields, oldRequirements]
  ) => {
    if (isDataLoading.value) {
      return
    }

    if (
      !props.report?.objectTypeId ||
      props.fields?.length < 1 ||
      props.requirements.length < 1
    ) {
      reportData.value = []
      return
    }

    //fetch new data only if report, fields, or reqs have changed
    if (
      !isEqual(newReport, oldReport) ||
      !isEqual(newFields, oldFields) ||
      !isEqual(newRequirements, oldRequirements)
    ) {
      if (isDataLoading.value) {
        isUpdateQueued.value = true
        emit('queued')
      } else {
        // If data type is changed, only call processQueue if we aren't switching to/from Project Details
        if (
          oldReport.objectType == newReport.objectType ||
          (oldReport.objectType != newReport.objectType &&
            !(
              oldReport.objectType == 'Data View' ||
              newReport.objectType == 'Data View'
            ))
        ) {
          processQueue()
        }
      }
    }
  }
)

const headers = computed(() => {
  return props.fields.map((f) => ({
    text: f.name,
    value: f.name,
    id: UUID(),
    class: 'text-no-wrap'
  }))
})

const processQueue = async () => {
  try {
    appStore.loading = true
    isDataLoading.value = true
    isUpdateQueued.value = false
    reportData.value = []

    const response = await http.post(
      `/smartlist/adhoc?timezone=${userStore.timezone.value}`,
      {
        smartlist: props.report,
        fields: props.fields,
        requirements: props.requirements
      }
    )
    reportData.value = response.data
    emit('updated')
  } catch (e) {
    //@TODO: #smartlistsv2 - Frontend needs to know backend message here. Want a better way
    const errMessage = e.response.data.message
    appStore.loading = false
    if (errMessage.includes('An event smartlist must have at least 1 event type column')) {
      snackbar('ERROR', errMessage)
    } else {
      snackbar('ERROR', 'Error while fetching smartlist data')
    }
  } finally {
    isDataLoading.value = false
    appStore.loading = false
    if (isUpdateQueued.value) {
      processQueue()
    }
  }
}

const getQuery = async () => {
  try {
    const { data } = await postRequest(`/smartlist/adhoc/query`, {
      smartlist: props.report,
      fields: props.fields,
      requirements: props.requirements
    })

    navigator.clipboard.writeText(data.query)
    snackbar('SUCCESS', 'Query copied to clipboard')
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching query')
  }
}
</script>

<style scoped lang="scss">
@import '@/styles/main.scss';

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
