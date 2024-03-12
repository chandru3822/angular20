<template>
  <v-card id="score-drilldown" class="square-card" v-if="!columnsLoading">
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">
        {{user}}
        <div class="toolbar-subtitle">{{startDate | formatDate('date', 'M/D/YYYY')}} - {{ endDate | formatDate('date', 'M/D/YYYY')}}</div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <AlbatrossButton
            variant="text"
            color="primary"
            @click="$emit('scoreDialogClosed')"
            text="Close"
        ></AlbatrossButton>
      </v-toolbar-items>
    </v-toolbar>
    <v-data-table
        :headers="columns"
        :items="results"
        :fixed-header="true"
        :items-per-page="-1"
        single-expand
        :loading="resultsLoading"
        :mobile-breakpoint="0"
        hide-default-header
        hide-default-footer
        class="elevation-0"
    >
      <template #no-data>
        <span class="default-text-color">NO RESULTS</span>
      </template>

      <template #header="{ props: { headers } }">
        <thead class="v-data-table-header">
        <tr>
          <th v-for="(column, idx) in headers" :key="idx" class="py-2">
            {{ column.header }}
          </th>
        </tr>
        </thead>
      </template>

      <template #no-results>
        NO RESULTS
      </template>

      <template #item="{ item, index }">
        <tr class="text-left" :class="{'shaded-row': index % 2}">
          <td class="text-left" v-for="([key, value], idx) in Object.entries(item)">
            <span v-if="columns[idx].dataTypeId === 1">{{ value | formatDate('date', 'M/D/YYYY')}}</span>
            <span v-else-if="columns[idx].dataTypeId === 2">{{ value | formatDate('timestamp', 'M/D/YYYY h:mm a')}}</span>
            <span v-else>{{ value }}</span>
          </td>
        </tr>
      </template>

      <template v-slot:body.append="{headers}">
        <tr>
          <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

            <div v-if="i === columns.length - 2" class="text-right">
              Total Score:
            </div>
            <div v-if="header.header === 'Score'">
              {{totalScore}}
            </div>
            <!--            <div v-if="header.value === 'current_pay'">-->
            <!--              {{ totalPay | currency('$', 2) }}-->
            <!--            </div>-->

          </td>
        </tr>
      </template>

    </v-data-table>
  </v-card>
</template>

<script setup>

import {getRequest, logError, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import sumBy from 'lodash.sumby'
import {getRequestWithParams} from "@/helpers/helpers"
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'
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
  tournamentId: Number,
  userId: Number,
  user: String,
  startDate: String,
  endDate: String,
})
const { tournamentId, userId, user, startDate, endDate } = toRefs(props)

//this is all dumb. i cant figure out how to make a dialog reload the "created" function when it is opened for a second time
watch([userId, tournamentId, endDate, startDate], async() => {
  await onLoad()
})

const totalScore = ref(0)
const results = ref([])
const columns = ref([])
const columnsLoading = ref(true)
const dataLoading = ref(true)
const resultsLoading = ref(true)

onMounted(async () => {
  await onLoad()
})

const onLoad = async () => {
  totalScore.value = 0
  columnsLoading.value = true
  results.value = []
  columns.value = []
  dataLoading.value = true
  getResults()
  await getColumns()
  dataLoading.value = false
}
const getColumns = async() => {
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}/columns`, 'blueraven')
    columns.value = data
    columnsLoading.value = false
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching columns')

  }
}
const getResults = async() => {
  try {
    let params = {
      startDate: startDate.value,
      endDate: endDate.value,
      userId: userId.value
    }
    const {data} = await getRequestWithParams(`/tournament/${tournamentId.value}/scores`, { params }, 'blueraven')
    results.value = data.length > 0 ? data : []
    totalScore.value = sumBy(results.value,  function(o) { return o.score || 0 })
    resultsLoading.value = false
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching scores')

  }
}
</script>

<style lang="scss">
#score-drilldown .v-data-table__wrapper {
  height: calc(100vh - 325px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#score-drilldown {
  height: calc(100vh - 250px);
  min-height: 300px;
}
</style>

