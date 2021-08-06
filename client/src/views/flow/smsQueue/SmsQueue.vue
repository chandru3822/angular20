<template>
  <v-container class="app-container">
    <v-row>
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">SMS Queue</v-toolbar-title>

        <v-spacer/>

        <v-select attach class="status-dropdown"
                  v-model="selectedStatus"
                  :items="messageStatuses"
                  label="Status"
                  item-text="text"
                  item-value="value"
                  hide-details
        />
        <v-btn
          color="primaryCustom"
          class="white--text mr-2 mb-3 filter-projects-btn"
          @click="filterProjects"
        >
          Go
        </v-btn>
      </v-toolbar>
    </v-row>

    <v-data-table
      :headers="headers"
      :items="displayedProjects"
      :fixed-header="true"
      :items-per-page="options.itemsPerPage"
      :footer-props="footerProps"
      single-expand
      :mobile-breakpoint="0"
      :expanded.sync="expanded"
      class="elevation-1 perf-table pb-md-5"
    >
      <template #no-data>
        NO DATA FOUND
      </template>

      <template #no-results>
        No parameters exist for this function
      </template>

      <template #item="{ item }">
        <tr class="text-left" :class="{'shaded-row': displayedProjects.indexOf(item) % 2}">
          <td>
            <v-checkbox v-model="item.priority" @change="updateMessage(item)"></v-checkbox>
          </td>
          <td class="text-left">
            <router-link text :to="`/project/${item.projectId}?secondaryTab=3`">
              {{ item.fullName }}
            </router-link>
          </td>
          <td class="text-left">{{ item.projectStatus }}</td>
          <td class="text-left truncated" :title="item.message">{{ item.message }}</td>
          <td class="text-left">{{ item.lastMessageReceived | formatDate('timestamp', 'M/D/YYYY h:mm a') }}</td>
          <td class="text-left">{{ item.lastMessageSent | formatDate('timestamp', 'M/D/YYYY h:mm a') }}</td>
          <td class="text-left">{{ item.lastMessageSentBy }}</td>
          <td class="text-left">
            <v-autocomplete v-model="item.owner"
                            :items="owners"
                            label="Select Owner"
                            item-text="fullName"
                            placeholder="Unassigned"
                            return-object
                            autocomplete="off"
                            @change="updateMessage(item)"
                            attach
            />
          </td>
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
import {getRequest, getRequestWithParams, getSnackbar, postRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'SmsQueue',
  data() {
    return {
      snackbar: {},
      constants,
      model: {},
      expanded: [],
      projects: [],
      displayedProjects: [],
      dashValues: [],
      performanceMetrics: [],
      owners: [],
      selectedStatus: false,
      messageStatuses: [
        {text: 'Unread', value: false},
        {text: 'Read', value: true}
      ],
      headers: [
        {text: 'Priority', value: 'priority', width: '50px', show: true},
        {text: 'Project Name', value: 'fullName', show: true},
        {text: 'Project Status', value: 'projectStatus', show: true},
        {text: 'Message', value: 'message', show: true},
        {text: 'Message Received', value: 'lastMessageReceived', show: true},
        {text: 'Last Message Sent', value: 'lastMessageSent', show: true},
        {text: 'Last Message Sent By', value: 'lastMessageSentBy', show: true},
        {text: 'Owner', value: 'owner', width: '150px', show: true},
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
    this.getProjects()
    this.getOwners()
  },
  methods: {
    async getProjects() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {page, itemsPerPage} = this.options
        const {data} = await getRequestWithParams(`/sms/queue`, {
          params: {
            page: page,
            size: itemsPerPage
          }
        });

        this.projects = data.content
        this.displayedProjects = data.content
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving Projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwners() {
      try {
        const {data} = await getRequest(`/sms/owners`)
        this.owners = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving Projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async updateOwner(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/sms/updateOwner`, item)
        this.snackbar = getSnackbar('SUCCESS', 'Message updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        item.owner = 'Unassigned'
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateMessage(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/sms/updateSms`, item)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        item.owner = 'Unassigned'
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving message')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterProjects() {
      this.displayedProjects = this.projects.filter(p => p.messageRead === this.selectedStatus);
    }
  }
}
</script>

<style scoped lang="scss">
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
