<template>
  <v-container id="sms-queue-container">
    <v-row>
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">SMS Queue</v-toolbar-title>

        <v-spacer/>

        <v-select class="status-dropdown mr-3"
                  v-model="selectedObjectTypeId"
                  :items="objectTypes"
                  label="Type"
                  item-text="text"
                  item-value="value"
                  hide-details
        />

        <v-select class="status-dropdown"
                  v-model="selectedStatus"
                  :items="messageStatuses"
                  label="Status"
                  item-text="text"
                  item-value="value"
                  hide-details
        />
        <a-btn
            color="primary"
            variant="text"
            small
            class="filter-projects-btn"
            @click="getQueue()"
            prepend-icon="mdi-filter"
        ></a-btn>
      </v-toolbar>
    </v-row>

    <v-data-table
        :headers="headers"
        :items="queue"
        :fixed-header="true"
        :items-per-page="options.itemsPerPage"
        :footer-props="footerProps"
        single-expand
        :mobile-breakpoint="0"
        :expanded.sync="expanded"
        class="elevation-1 perf-table pb-md-5"
    >
      <template #no-data>
        <span class="default-text-color">NO DATA FOUND</span>
      </template>

      <template #no-results>
        <span class="default-text-color">No parameters exist for this function</span>
      </template>

      <template #item="{ item }">
        <tr class="text-left" :class="{'shaded-row': queue.indexOf(item) % 2}">
          <td class="text-left">
            {{ item.objectTypeId === 1 ? 'Project' : 'User'}}
          </td>
          <td class="text-left sent-to-column">
            <router-link v-if="item.projectId" text :to="`/project/${item.projectId}/status`">
              {{ item.projectName }} - {{ item.projectStatusType}}
            </router-link>
            <router-link v-else text :to="`/user/${item.sentToUserId}/details`">
              {{ item.sentToUserName }}
            </router-link>
          </td>
          <td class="text-left truncated">
            <v-tooltip left max-width="300">
              <template v-slot:activator="{ on: tooltip }">
                <div v-on="{ ...tooltip }" class="d-inline-block mt-4">
                  {{ item.message }}
                </div>
              </template>
              <span>{{ item.message }}</span>
            </v-tooltip>
          </td>
          <td class="text-left">{{ item.twilioDelivered | formatDate('timestamp', 'M/D/YYYY h:mm a') }}</td>
          <td class="text-left">{{ item.created | formatDate('timestamp', 'M/D/YYYY h:mm a') }}</td>
          <td class="text-left">{{ item.sentByUserName }}</td>
          <td class="text-left">
            <v-select
                v-model="item.messageRead"
                :items="messageStatuses"
                label="Status"
                item-text="text"
                item-value="value"
                @change="updateMessage(item)"/>
          </td>
        </tr>
      </template>
    </v-data-table>

  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, getRequestWithParams,  postRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'

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

const model = ref({})
const expanded = ref([])
const queue = ref([])
const dashValues = ref([])
const performanceMetrics = ref([])
const owners = ref([])
const selectedStatus = ref(-1)
const selectedObjectTypeId = ref(-1)
const objectTypes = ref([
  {text: 'All', value: -1},
  {text: 'Project', value: 1},
  {text: 'User', value: 3},
])
const messageStatuses = ref([
  {text: 'All', value: -1},
  {text: 'Unread', value: false},
  {text: 'Read', value: true},
])
const headers = ref([
  {text: 'Type', value: 'objectTypeId', show: true},
  {text: 'Sent To', value: 'blah', show: true},
  {text: 'Message', value: 'message', show: true},
  {text: 'Received', value: 'twilioDelivered', show: true},
  {text: 'Sent', value: 'created', show: true},
  {text: 'Sent By', value: 'sentByUserName', show: true},
  {text: 'Status', value: 'messageRead', width: '150px', show: true}
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({page: 1,itemsPerPage: 100})
const pagination = ref({})

onMounted(async() => {
  getQueue()
})

const getQueue = async() => {
  try {
    appStore.loading = true
    const {page, itemsPerPage} = options.value
    let params = {
      page: page - 1, //page needs to start at 0, not 1
      size: itemsPerPage,
      objectTypeId: selectedObjectTypeId.value
    }

    if (selectedStatus.value !== -1) {
      params.messageRead = selectedStatus.value
    }
    const {data, status} = await getRequestWithParams(`/sms/queue`, {params});

    queue.value = data.content
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving Queue')

    appStore.loading = false
  }
}
const updateMessage = async(item) => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/sms/updateSms`, item)
    handleHidingGlobalLoader( status)
  } catch (e) {
    item.owner = 'Unassigned'
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving message')

    appStore.loading = false
  }
}
</script>

<style lang="scss">
#sms-queue-container .v-data-table__wrapper {
  height: calc(100vh - 240px);
  min-height: 300px;
}

#sms-queue-container .v-data-footer__pagination {
  display: none !important;
}
</style>

<style scoped lang="scss">
.sent-to-column {
  max-width: 300px;
}

.truncated {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-dropdown {
  max-width: 200px;
  z-index: 1000;
}

.filter-projects-btn {
  margin-left: 10px;
}
</style>
