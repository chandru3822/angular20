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
        <v-btn
          color="primary"
          text small
          class="filter-projects-btn"
          @click="getQueue()"
        >
          <v-icon>mdi-filter</v-icon>
        </v-btn>
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

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, getSnackbar, postRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'SmsQueue',
  data() {
    return {
      snackbar: {},
      constants,
      model: {},
      expanded: [],
      queue: [],
      dashValues: [],
      performanceMetrics: [],
      owners: [],
      selectedStatus: -1,
      selectedObjectTypeId: -1,
      objectTypes: [
        {text: 'All', value: -1},
        {text: 'Project', value: 1},
        {text: 'User', value: 3},
      ],
      messageStatuses: [
        {text: 'All', value: -1},
        {text: 'Unread', value: false},
        {text: 'Read', value: true},
      ],
      headers: [
        {text: 'Type', value: 'objectTypeId', show: true},
        {text: 'Sent To', value: 'blah', show: true},
        {text: 'Message', value: 'message', show: true},
        {text: 'Received', value: 'twilioDelivered', show: true},
        {text: 'Sent', value: 'created', show: true},
        {text: 'Sent By', value: 'sentByUserName', show: true},
        {text: 'Status', value: 'messageRead', width: '150px', show: true}
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        page: 1,
        itemsPerPage: 100
      },
      pagination: {},
    }
  },
  async created() {
    this.getQueue()
  },
  methods: {
    async getQueue() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {page, itemsPerPage} = this.options
        let params = {
          page: page - 1, //page needs to start at 0, not 1
          size: itemsPerPage,
          objectTypeId: this.selectedObjectTypeId
        }

        if (this.selectedStatus !== -1) {
          params.messageRead = this.selectedStatus
        }
        const {data, status} = await getRequestWithParams(`/sms/queue`, {params});

        this.queue = data.content
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving Queue')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateMessage(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest(`/sms/updateSms`, item)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        item.owner = 'Unassigned'
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving message')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
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
