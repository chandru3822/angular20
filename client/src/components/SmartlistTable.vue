<template>
  <div>
    <v-toolbar class="elevation-1" width="100%">
      <v-text-field
          v-model="search"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
      ></v-text-field>
      <v-spacer />
      <a-btn
          variant="text"
          color="primary"
          :disabled="isLoading"
          @click="showConfirmDialog = true"
          text="Export"
          prepend-icon="mdi-cloud-download"
      ></a-btn>
    </v-toolbar>

    <v-divider />

    <v-data-table
        :items="reportData"
        :headers="headers"
        :loading="isLoading"
        :footer-props="footerProps"
        fixed-header
        :options.sync="options"
        :search="search"
        multi-sort
    >
      <template #no-data>
        No available report data
      </template>

      <template #no-results>
        No available report data
      </template>

      <template #item="{item: row}">
        <tr
            class="clickable"
            @click="selectRow(row)"
        >
          <template
              v-for="(field, key) in row"
          >
            <td
                v-if="key !== 'project_id' && key !== 'contact_id'"
                :key="key"
                class="text-left"
            >
              <router-link class="router-link-td elevation-0 square-card"
                           color="transparent" :to="type === 'PROJECT' ? `/project/${row.project_id}/status` :
                                                        type === 'CONTACT' ? `/contact/${row.contact_id}` : ''">
                {{field}}
              </router-link>
            </td>
          </template>
        </tr>
      </template>
    </v-data-table>

    <ExportDialog
        :show="showConfirmDialog"
        :totalItems="reportData.length"
        @cancel="showConfirmDialog = false"
        @confirm="[showConfirmDialog = false, generateReport()]"
    />
  </div>
</template>

<script setup>

import {logError, getRequestWithParams, getRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ExportDialog from '@/components/ExportDialog'
import saveAs from 'file-saver'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  smartlistId: Number,
  type: String
})
const { smartlistId, type } = toRefs(props)

const reportData = ref([])
const isLoading = ref(false)
const headers = ref([])
const options = ref({itemsPerPage: 100})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const showConfirmDialog = ref(false)
const search = ref('')

const emit = defineEmits(['row-selected'])

watch(smartlistId, (newValue, oldValue) => {
  getSmartlistData();
}, { immediate: true })

const getSmartlistData = async() =>{
  try {
    isLoading.value = true
    const params = {timezone: userStore.timezone}
    const {data} = await getRequestWithParams(`/smartlistv1/${smartlistId.value}/data`, {params})
    reportData.value = data.data
    headers.value = data.headers.map(h => ({text: h.name, value: h.name, id: h.id}))
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}
const generateReport = async () =>{
  try {
    appStore.loading = true
    const {data} = await getRequest(`/smartlistv1/${smartlistId.value}/csv`)
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    });
    saveAs(blob, "smartlist.csv");
  } catch (e) {
    snackbar('ERROR', e.message)

    logError(e)
  } finally {
    appStore.loading = false
  }
}
const selectRow =  (row) => {
  emit('row-selected', row)
}
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";
tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
