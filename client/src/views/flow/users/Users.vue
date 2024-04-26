<template>
  <v-container id="users-container" v-if="!showImages">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Users</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                to="/newUser"
                color="primary"
                v-if="userStore.userHasFeatureAccessLevel('USERS', 'ADD')"
                prepend-icon="add"
                text="Add User"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <a-text-field
              class="mt-5"
              prepend-inner-icon="search"
              clearable
              label="Search users..."
              v-model="filters.search"
              @input="debounceGetUsers"
          ></a-text-field>
          <v-checkbox
              class="pt-5 ml-3"
              dense
              v-model="primaryPositionsOnly"
              label="Primary Only"
              @change="handleOrgFilterChange(false)"
          />
          <span class="flex-display justify-end user-selected" @click="selectedUsersDialog = true">{{usersSelected}} user(s) selected</span>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="toggleImages()"
                :disabled="allUsersLoading"
                :prepend-icon="constants.IS_MOBILE ? 'mdi-view-grid-outline' : ''"
                :text="constants.IS_MOBILE ? '' : 'View Images'"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="msgDialog = true"
                :disabled="allUsersLoading"
                :prepend-icon="constants.IS_MOBILE ? 'email' : ''"
                :text="constants.IS_MOBILE ? '' : 'Send Email/Text'"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="handleOrgFilterChange(true)"
                :prepend-icon="constants.IS_MOBILE ? 'filter_list' : ''"
                :text="constants.IS_MOBILE ? '' : 'Reset Filters'"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="exportCsv"
                :prepend-icon="constants.IS_MOBILE ? 'mdi-cloud-download' : ''"
                :text="constants.IS_MOBILE ? '' : 'Export'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="users"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            ref="pageableTable"
            :page.sync="page"
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalUsers"
            hide-default-header
            :calculate-widths="true"
            class="elevation-1 fix-column-width-bug user-table"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #header="{ props: { headers } }">
            <thead class="v-data-table-header">
            <tr>
              <th v-for="header in headers" :key="header.text" class="py-2"
                  :class="{'filter-header-non-select': !header.orgFilter && !header.statusFilter}"
                  :style="{width: header.width ? header.width : 'auto',
                          'padding-bottom': !header.orgFilter && !header.statusFilter ? '13px !important' : ''}">
                {{ header.text }}
                <a-autocomplete v-model="filters.orgs[header.level]"
                                :items="header.orgs"
                                v-if="header.orgFilter"
                                item-title="orgName"
                                item-value="id"
                                return-object
                                multiple
                                placeholder="Select..."
                                height="35px"
                                variant="outlined"
                                class="user-filter-select"
                                @change="handleOrgFilterChange(false, header.level)"
                >
                  <template  v-slot:selection="{item, index}">
                    <v-chip small v-if="index === 0 && filters.orgs[header.level] && filters.orgs[header.level].length < 2">
                      <span>{{ item.orgName }}</span>
                    </v-chip>
                    <span
                      v-if="index === 1 && filters.orgs[header.level] && filters.orgs[header.level].length >= 2"
                      class="primary--text text-caption"
                    >{{ filters.orgs[header.level].length }} selected</span>
                  </template>
                  <template #item="{ item }">
                    <div class="v-list-item__action">
                      <div class="v-simple-checkbox">
                        <div class="v-input--selection-controls__ripple primary--text">

                        </div>
                        <i v-if="itemChecked(header.level, item)" aria-hidden="true" class="v-icon notranslate material-icons theme--light">check_box</i>
                        <i v-else aria-hidden="true" class="v-icon notranslate material-icons theme--light">check_box_outline_blank</i>
                      </div>
                    </div>
                    <div v-if="header.showType">{{item.orgName}} ({{item.orgType}})</div>
                    <div v-else>{{item.orgName}}</div>
                  </template>
                </a-autocomplete>
                <a-autocomplete v-model="filters.statuses"
                                :items="statuses"
                                v-else-if="header.statusFilter"
                                multiple
                                item-title="userStatusType"
                                item-value="id"
                                variant="outlined"
                                placeholder="Select..."
                                height="35px"
                                class="user-filter-select"
                                @input="getUsers(true)"
                >
                  <template  v-slot:prepend-item>
                    <v-list-item
                      ripple
                      @click="toggleSelectAllStatuses()"
                    >
                      <v-list-item-action>
                        <v-icon>{{ icon }}</v-icon>
                      </v-list-item-action>
                      <v-list-item-title>Select All</v-list-item-title>
                    </v-list-item>
                    <v-divider
                      class="mt-2"
                    ></v-divider>
                  </template>
                  <template  v-slot:selection="{item, index}">
                    <v-chip small v-if="index === 0 && filters.statuses.length < 2">
                      <span>{{ item.userStatusType }}</span>
                    </v-chip>
                    <span
                      v-if="index === 1 && filters.statuses.length >= 2"
                      class="primary--text text-caption"
                    >{{ filters.statuses.length }} selected</span>
                  </template>
                </a-autocomplete>
                <a-autocomplete v-model="filters.positions"
                                :items="positions"
                                v-else-if="header.positionFilter"
                                item-title="position"
                                item-value="id"
                                multiple
                                placeholder="Select..."
                                height="35px"
                                variant="outlined"
                                class="user-filter-select"
                                @input="getUsers(true)"
                >
                  <template  v-slot:selection="{item, index}">
                    <v-chip small v-if="index === 0 && filters.positions && filters.positions.length < 2">
                      <span>{{ item.position }}</span>
                    </v-chip>
                    <span
                      v-if="index === 1 && filters.positions && filters.positions.length >= 2"
                      class="primary--text text-caption"
                    >{{ filters.positions.length }} selected</span>
                  </template>
                </a-autocomplete>
                <v-checkbox v-else-if="header.selectFilter"
                            :disabled="allUsersLoading"
                            v-model="selectAllUsers" @change="toggleSelectAllUsers()"></v-checkbox>
                <a-text-field variant="outlined"
                              v-else-if="header.value !== 'phoneExtension'"
                              hide-details
                              class="filter-input"
                              v-model="filters[header.value]"
                              @input="debounceGetUsers">
                </a-text-field>
                <div v-else style="height: 35px;"></div>
              </th>
            </tr>
            </thead>
          </template>

          <template #item="{ item, index }">
            <tr
              :class="{'shaded-row': index % 2}" v-if="!showImages">
              <td><v-checkbox v-model="item.selected" :disabled="allUsersLoading" @change="toggleSingleSelect(item)"></v-checkbox></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.firstName}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.lastName}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.email}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.phoneNumber}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.phoneExtension}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.userStatusType}}</router-link></td>
              <td class="text-left user-column clickable"><router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">{{item.position || 'N/A'}}</router-link></td>
              <td class="text-left user-column clickable" v-for="(f, index) in orgFilters" :key="index">
                <router-link class="router-link-td elevation-0 square-card" :to="`/user/${item.id}/details`">
                  {{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}
                </router-link>
              </td>
            </tr>
          </template>
        </v-data-table>

      </v-col>
    </v-row>

    <v-dialog v-model="selectedUsersDialog" max-width="700px" class="selected-users-dialog">
      <v-card>
        <v-card-title>
          <span class="text-h5">Selected Users</span>
        </v-card-title>
        <v-data-table
          :headers="usersTableHeaders"
          :items="selectedUsersDetails"
          :footer-props="footerProps"
          :fixed-header="true"
          disable-sort
          class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No users available</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No users available</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left">{{item.fullName}}</td>
              <td class="text-left">{{item.position}}</td>
            </tr>
          </template>
        </v-data-table>
        <v-card-actions class="flex-display justify-end">
          <a-btn @click="selectedUsersDialog = false" color="unset" text="Close"></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="msgDialog" max-width="800px">
      <v-card>
        <v-card-title class="body-large justify-space-between" primary-title>
            Send Bulk Emails/Texts
            <a class="close-modal-x pb-3" title="Close" @click="cancelSendMessageDialog">×</a>
        </v-card-title>
          <v-toolbar-items>
        <v-tabs color="primary" slot="extension" slider-color="primary" class="message-tabs">
            <v-tab @click="messageTab = 1">
              Emails
            </v-tab>
            <v-tab @click="messageTab = 2">
              SMS
            </v-tab>
        </v-tabs>
          </v-toolbar-items>
        <v-divider></v-divider>
        <div v-if="messageTab === 1"  class="pa-6">
          <label class="mr-2">To:</label>
          <a-autocomplete
            v-model="selectedUsers"
            :items="allUsers"
            multiple
            clearable
            label="Select user(s)"
            item-title="fullName"
            item-value="id"
            height="35px"
            @click:clear="clearUsersAutocomplete()"
            class="d-inline-block mr-3 user-autocomplete">
            <template  v-slot:prepend-item>
              <v-divider
                class="mt-2"
              ></v-divider>
            </template>
            <template  v-slot:selection="{item, index}">
              <v-chip small v-if="index === 0 && selectedUsers && selectedUsers.length < 2">
                <span>{{ item.fullName }}</span>
              </v-chip>
              <span
                v-if="index === 1 && selectedUsers && selectedUsers.length >= 2"
                class="primary--text text-caption"
              >{{ selectedUsers.length }} selected</span>
            </template>

            <template #item="data">
              <template>
                <v-list-item dense>
                  <v-list-item-action>
                    <v-checkbox @change="toggleSingleSelectAutocomplete(data.item)" :input-value="data.item.selected"></v-checkbox>
                  </v-list-item-action>
                  <v-list-item-title>
                    <div @click="toggleSingleSelectAutocomplete(data.item)">{{ data.item.fullName }}</div>
                  </v-list-item-title>
                </v-list-item>
              </template>
            </template>
          </a-autocomplete>

          <div class="mb-3 flex-display">
            <label class="mt-5 mr-2">From:</label>
            <a-select attach
                      label="Select email"
                      v-model="fromEmail"
                      :items="fromEmails"
                      item-title="email"
                      item-value="email"
                      class="select-email"
            />
          </div>

            <v-text-field v-model="emailSubject" label="Subject"></v-text-field>
            <b>Message </b><span class="count-span pl-2">Characters: {{emailCharacterCount}}  Words: {{emailWordCount}}</span>
            <quill-editor
                class="py-3 rich-text-editor"
                v-model="emailMessage"
                @change="onEmailMessageChange($event)"
            />

            <v-file-input
                dense
                outlined
                multiple
                v-model="emailFile"
                label="Upload attachment(s)"
                @change="uploadEmailAttachment"
                @click:clear="[emailFile=null, emailAttachments = []]"
                style="width: 255px"
            />

            <v-card-actions class="flex-display justify-end pt-0 px-0">
              <a-btn
                  variant="text"
                  color="primary"
                  @click="cancelSendMessageDialog"
                  text="Cancel"
              ></a-btn>
              <a-btn
                  color="primary"
                  :disabled="disableSendEmail"
                  @click="sendMessage(true, false)"
                  text="Send Email"
              ></a-btn>
            </v-card-actions>
        </div>
        <div v-else-if="messageTab === 2" class="pa-6">
            <span>You will not be assigned to bulk conversations sent from this screen. If you wish to stay on top of
            conversations, use Inbox to send messages. <br></span>
            <label class="mr-2">To:</label>
            <a-autocomplete
              v-model="selectedUsers"
              :items="allUsers"
              multiple
              clearable
              item-title="fullName"
              item-value="id"
              height="35px"
              @click:clear="clearUsersAutocomplete()"
              class="d-inline-block mr-3 user-autocomplete">
              <template  v-slot:prepend-item>
                <v-divider
                  class="mt-2"
                ></v-divider>
              </template>
              <template  v-slot:selection="{item, index}">
                <v-chip small v-if="index === 0 && selectedUsers && selectedUsers.length < 2">
                  <span>{{ item.fullName }}</span>
                </v-chip>
                <span
                  v-if="index === 1 && selectedUsers && selectedUsers.length >= 2"
                  class="primary--text text-caption"
                >{{ selectedUsers.length }} selected</span>
              </template>
            </a-autocomplete>

          <div class="flex-display justify-end">
            <a-textarea v-model="textMessage"
                        auto-grow
                        rows="4"
                        variant="outlined"
                        placeholder="Enter message here" class="message-text-area py-1 pr-3"></a-textarea>

              <v-tooltip bottom small>
                <template v-slot:activator="{on, attrs}">
                  <a-btn
                      icon
                      color="primary"
                      v-bind="attrs"
                      :activation-handler="on"
                      class="mt-1 templateButton"
                      prepend-icon="article"
                  ></a-btn>
                </template>
                <span class="albatross-body-3">Templates</span>
              </v-tooltip>
            <v-menu v-model="menuOpen" top left offset-y activator=".templateButton" :close-on-content-click="false">
              <v-card class="template-dialog" width="295px">
                <v-card-title>
                  <span class="albatross-header-4-new">Add Template</span>
                </v-card-title>
                <v-card-text>
                  <a-select label="Template"
                            class="template-selector pt-1"
                            v-model="selectedTemplate"
                            :items="selectableTemplates"
                            item-title="title"
                            item-value="id"
                            ref="templateSelect"
                            return-object
                            @change="handleTemplateSelection">

                    <template v-slot:item="{ props, item }">
                      <!-- HTML that describes how select should render items when the select is open -->
                      <div class="ellipse">
                        <h4 class="template-title">{{ item.title }}<br /></h4>
                        <span class="template-message">{{ item.message }}</span>
                      </div>
                    </template>
                  </a-select>
                </v-card-text>
              </v-card>
            </v-menu>

            <v-file-input
                dense
                outlined
                multiple
                hide-input
                color="primary"
                v-model="textFiles"
                @change="uploadTextAttachment"
                @click:clear="[textFiles = [], textMediaUrls = []]"
            />
          </div>
          <span v-if="textFiles.length > 0">Attached {{ attachmentsText }}</span>

          <v-card-actions class="flex-display justify-end px-0 pt-0 ml-2">
            <a-btn
                variant="text"
                color="primary"
                @click="cancelSendMessageDialog"
                text="Cancel"
            ></a-btn>
            <a-btn
                color="primary"
                :disabled="disableSendText.value"
                @click="sendMessage(false, true)"
                text="Send SMS"
            ></a-btn>
          </v-card-actions>
        </div>
      </v-card>
    </v-dialog>
  </v-container>
  <v-container  v-else>
    <a-btn
        size="small"
        variant="text"
        color="primary"
        @click="toggleImages()"
        prepend-icon="mdi-chevron-left"
        text="Back to users"
    ></a-btn>

    <v-row style="width: 90%; margin-left: auto; margin-right: auto;" >
      <a-autocomplete v-for="header of headers"
                      v-model="filters.orgs[header.level]"
                      :items="header.orgs"
                      :label="header.text"
                      v-if="header.orgFilter"
                      item-title="orgName"
                      item-value="id"
                      return-object
                      multiple
                      placeholder="Select..."
                      height="35px"
                      variant="outlined"
                      class="user-images-filter-select"
                      @change="changeImageFilter(false, header.level)"
      >
      </a-autocomplete>
      <a-autocomplete attach
                      label="Users per page"
                      v-model="usersPerPage"
                      :items="usersPerPageOptions"
                      item-title="email"
                      item-value="email"
                      class="user-images-filter-select"
                      auto-select-first
                      variant="outlined"
                      @change="returnToPageOne()"
      />
      <a-btn
          variant="text"
          color="primary"
          @click="changeImageFilter(true)"
          :prepend-icon="constants.IS_MOBILE ? 'filter_list' : ''"
          :text="constants.IS_MOBILE ? '' : 'Reset Filters'"
      ></a-btn>
    </v-row>
    <div v-if="userImagesLoading" class="section-spinner">
      <br>
      <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
    </div>
    <user-images :users="imageUsers" :headers = "headers" :users-per-page="usersPerPage" v-if="!userImagesLoading"
                 :startingUser="(currentPage-1)*(usersPerPage)" :endingUser="min((currentPage)*(usersPerPage), imageUsers.length)">

    </user-images>
    <span v-if="!userImagesLoading">{{min((currentPage-1)*(usersPerPage) + 1, totalUsers.value)}} - {{min((currentPage)*(usersPerPage), totalUsers.value)}} of {{totalUsers}} </span>
    <a-btn
        icon
        :disabled="leftArrowDisabled"
        v-if="!userImagesLoading"
        @click="previousPage()"
        prepend-icon="mdi-arrow-left"
    ></a-btn>
    <a-btn
        icon
        v-if="!userImagesLoading"
        :disabled="rightArrowDisabled"
        @click="nextPage()"
        prepend-icon="mdi-arrow-right"
    ></a-btn>
  </v-container>

</template>

<script setup>


import {handleHidingGlobalLoader, getRequest, postRequest,  logError, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'
import cloneDeep from 'lodash.clonedeep'
import {getOrgFilters} from '@/services/orgService'
import max from 'lodash.max'
import 'quill/dist/quill.snow.css'
import {quillEditor} from 'vue-quill-editor'
import { saveAs } from 'file-saver'
import axios from 'axios'
import UserImages from "./UserImages";
import UsersFilter from "@/views/flow/users/UsersFilter.vue";
import { useFileStore } from '@/stores/FileStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const fileStore = useFileStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify

const defaultEmailMessage = '${user.firstName},\n'

const delay = ref(500)
const dialog = ref(false)
const users = ref([])
const initialLoad = ref(true)
const currentPage = ref(1)
const allUsers = ref([])
const imageUsers = ref([])
const selectedLevel = ref(null)
const pageableTable = ref(null)
const templateSelect = ref(null)
const masterOrgFilterList = ref([])
const orgFilters = ref([])
const statuses = ref([])
const positions = ref([])
const descending = ref(true)
const footerProps = ref({
  'items-per-page-options': [10, 50, 100, 1000, 3000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const totalUsers = ref(0)
const dataLoading = ref(true)
const conversationIsLoading = ref(false)
const usersPerPageOptions = ref([10,100,1000])
const usersPerPage = ref(10)
const teamsAssociatedToUser = ref(null)
const userImagesLoading = ref(true)
const headers = ref([
  { text: '', value: 'selectBox', selectFilter:true, show: true, width: '50px' },
  { text: 'First Name', value: 'firstName', show: true, width: '125px' },
  { text: 'Last Name', value: 'lastName', show: true, width: '125px' },
  { text: 'Email', value: 'email', show: true, width: '275px' },
  { text: 'Phone', value: 'phone', show: true, width: '115px' },
  { text: 'Ext', value: 'phoneExtension', show: true, width: '75px' },
  { text: 'User Status', value: 'userStatusType', statusFilter: true, show: true, width: '175px' },
  { text: 'Position', value: 'position', positionFilter: true, show: true, width: '175px' },
])
const filters = ref({search: '',firstName: '',lastName: '',email: '',phone: '',orgs: {},statuses: [],positions: []})
const usersTableHeaders = ref([
  { text: 'Name', value: 'fullName', show: true, width: '125px' },
  { text: 'Position', value: 'position', show: true, width: '125px' }
])
const showImages = ref(false)
const selectAllUsers = ref(false)
const selectedUsers = ref([])
const selectedUsersDetails = ref([])
const msgDialog = ref(false)
const selectedUsersDialog = ref(false)
const messageTab = ref(1)
const page = ref(1)
const fromEmail = ref('')
const fromEmails = ref([])
const emailSubject = ref('')
const emailMessage = ref(defaultEmailMessage)
const textMessage = ref('')
const emailCharacterCount = ref(0)
const emailWordCount = ref(0)
const textCharacterCount = ref(0)
const emailAttachments = ref([])
const textMediaUrls = ref([])
const emailFile = ref(null)
const textFiles = ref([])
const primaryPositionsOnly = ref(true)
const source = ref(null)
const allUsersLoading = ref(false)
const attachmentTypeId = ref(9)
const templateTeams = ref([])
const selectedTemplate = ref(null)
const selectableTemplates = ref([])
const menuOpen = ref(false)

watch(options, (newVal) => {
  if(!initialLoad.value) {
    getUsers()
  }
}, { deep: true });

watch(page, async() => {
  let table = pageableTable.value;
  let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

  vuetify.goTo(table); // to table
  vuetify.goTo(table, {container: wrapper}); // to header
})

const companyId = computed(() => {
  return userStore.details.companyId
})
const leftArrowDisabled = computed(() => {
  return currentPage.value == 1;
})
const rightArrowDisabled = computed(() => {
  return currentPage.value*usersPerPage.value >= totalUsers.value;
})
const selectAll = computed(() => {
  return filters.value.statuses.length === statuses.value.length
})
const selectSome = computed(() => {
  return filters.value.statuses.length > 0 && !selectAll.value
})
const icon = computed(() => {
  if (filters.value.statuses && statuses.value && filters.value.statuses.length === statuses.value.length) {
    return 'check_box'
  }
  if (selectSome.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const usersSelected = computed(() => {
  return selectedUsers.value.length;
})
const disableSendEmail = computed(() => {
  return !(fromEmail.value.trim().length > 0 && emailSubject.value.trim().length > 0 && emailMessage.value.trim().length > 0 && usersSelected.value)
})
const disableSendText = computed(() => {
  return !((textMessage.value.trim().length > 0 || textMediaUrls.value.length > 0) && usersSelected.value)
})
const attachmentsText = computed(() => {
  if (textFiles.value.length == 1) {
    return textFiles.value[0].name
  }
  else if (textFiles.value.length > 1) {
    return textFiles.value.length + ' files'
  }
})
const useSavedFilter = computed(() => {
  return route.params.useSavedFilter
})

onMounted(() => {
  getPositions()
  getTheOrgFilters(true)
  getEmailSenders()
  fetchTeamsForUser()

  if(useSavedFilter.value === 'true') {
    JSON.parse(localStorage.getItem('store'))
    if(localStorage.getItem('userFilters') != null) {
      filters.value = JSON.parse(localStorage.getItem('userFilters'))
    }
  } else {
    localStorage.removeItem('userFilters')
  }
  // getStatuses calls getUsers because we have to know company statuses before we can filter the list
  getStatuses(useSavedFilter.value === 'true')
})

const handleUpdateStatusesListEmit = (newList) => {
  filters.value.statuses = newList
  getUsers(true)
}
const handleUpdatePositionsListEmit = (newList) => {
  filters.value.positions = newList
  getUsers(true)
}
const handleUpdateOrgListEmit = (newList, headerLevel) => {
  let orgFilterList = []
  let tempFilters = orgFilters.value
  tempFilters.filter((oFilter) => oFilter.orgLevelId === headerLevel).forEach((o) => newList.forEach((i) => {
    o.orgs.forEach((j) => {
      if (j.id === i) {
        orgFilterList.push(j)
      }
    })
  }))
  filters.value.orgs[headerLevel] = orgFilterList
  handleOrgFilterChange(false, headerLevel)
}
const handleTemplateSelection = () => {
  textMessage.value += selectedTemplate.value.message
  menuOpen.value = false
  selectedTemplate.value = null
  templateSelect.value.reset();
}
const cancelSendMessageDialog = ()=> {
  textMediaUrls.value = []
  emailAttachments.value = []
  emailFile.value = null
  textFiles.value = []
  msgDialog.value = false
  textMessage.value = ''
}
const nextPage = async()=> {
  currentPage.value++;
  await getUserImage();
}
const previousPage = async()=> {
  currentPage.value--;
  await getUserImage();
}
const getUserImage = async () => {
  await getImageUsers()
  userImagesLoading.value = true
  let userIds = [];
  for(let user of imageUsers.value){
    userIds.push(user.id);
  }
  let params = {
    sourceIds: encodeURI(userIds),
    attachmentTypeId: 9
  }

  let data = [];
  while(userIds.length > 0){
    params.sourceIds =  encodeURI(userIds.slice(0,min(userIds.length,100)));
    userIds = userIds.slice(min(userIds.length,100), userIds.length)
    if(Object.keys(data).length > 0) {
      data = Object.assign({}, data, (await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})).data);
    }
    else{
      data = (await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})).data;
    }
  }

  if (data) {
    imageUsers.value.forEach(user => {
      if (user.id && data[user.id]) {
        user.imageUrl = data[user.id]
      }

      if (user.imageUrl) {
        user.userImageAltText = 'Photo of ' + user.name + ', a Blue Raven Solar employee'
      } else {
        user.userImageAltText = 'User photo placeholder'
      }
    })
    userImagesLoading.value = false
  } else {
    userImagesLoading.value = false
  }
}
const clickRow = (id)=> {
  router.push({name: 'userDetails', params: {id}})
}
const toggleImages = async()=> {
  userImagesLoading.value = true;
  showImages.value = !showImages.value;
  if(showImages.value) {
    currentPage.value = 1;
  }
  await changeImageFilter(true);
}
const debounceGetUsers = debounce((query) => {
  if(filters.value.search == null){
    filters.value.search = '';
  }
  getUsers(true)
}, 500)

const getAllUsers = async () => {
  // Get allUsers once
  // this was loading twice if a search was done prior to completing this request. putting it in its own fn that is called by the created method fixes that
  allUsersLoading.value = true
  //removing global loader since now it just waits for this to finish before you can send a text
  // appStore.loading = true

  try {
    //could default these params since we want all users
    const params = {
      search: filters.value.search,
      firstName: filters.value.firstName,
      lastName: filters.value.lastName,
      email: filters.value.email,
      phone: filters.value.phone,
      statuses: filters.value.statuses,
      positions: filters.value.positions,
      orgs: getOrgIdsForMax(),
      primaryFlag: primaryPositionsOnly.value
    }
    const {data, status} = await postRequest(`/user/search?page=0&size=9999`, params)
    allUsers.value = data?.content || []
    imageUsers.value = allUsers.value
    allUsersLoading.value = false
    // handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving All Users')

    allUsersLoading.value = false
    // appStore.loading = false
  }
}
const min = (x, y)=> {
  if(x < y){
    return x;
  }
  else{
    return y;
  }
}
const getUsers = async (resetPage) => {
  localStorage.setItem('userFilters', JSON.stringify(filters.value))

  if(resetPage) {
    options.value.page = 1
  }

  if(source.value){
    source.value.cancel()
  }
  const CancelToken = axios.CancelToken
  source.value = CancelToken.source()

  if (filters.value.statuses && filters.value.statuses.length > 0) {
    appStore.loading = true
    dataLoading.value = true
    const { page, itemsPerPage } = options.value

    try {
      const params = {
        search: filters.value.search,
        firstName: filters.value.firstName,
        lastName: filters.value.lastName,
        email: filters.value.email,
        phone: filters.value.phone,
        statuses: filters.value.statuses,
        positions: filters.value.positions,
        orgs: getOrgIdsForMax(),
        //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
        primaryFlag: primaryPositionsOnly.value
      }
      const {data, status} = await postRequest(`/user/search?page=${page-1}&size=${options.value.itemsPerPage}`, params, null, [], {
        source: source.value,
        cancelToken: source.value.token
      })

      if(status) {
        users.value = data?.content || []
        totalUsers.value = data?.totalElements || 0

        users.value.forEach(u => {
          // If the user isn't already a selected user, add to list of selected users
          if (selectedUsers.value.indexOf(u.id) !== -1) {
            u.selected = true;
          }
        })
      }
      dataLoading.value = false
      initialLoad.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Users')

      appStore.loading = false
    }
  } else {
    dataLoading.value = false
    users.value = []
  }
}
const returnToPageOne = async()=> {
  currentPage.value = 1;
  await getUserImage();
}
const getImageUsers = async (resetPage) => {
  localStorage.setItem('userFilters', JSON.stringify(filters.value))

  if(resetPage) {
    options.value.page = 1
  }

  if(source.value){
    source.value.cancel()
  }
  const CancelToken = axios.CancelToken
  source.value = CancelToken.source()

  if (filters.value.statuses && filters.value.statuses.length > 0) {
    appStore.loading = true
    dataLoading.value = true
    const { page, itemsPerPage } = options.value

    try {
      const params = {
        search: filters.value.search,
        firstName: filters.value.firstName,
        lastName: filters.value.lastName,
        email: filters.value.email,
        phone: filters.value.phone,
        statuses: filters.value.statuses,
        positions: filters.value.positions,
        orgs: getOrgIdsForMax(),
        //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
        primaryFlag: primaryPositionsOnly.value
      }

      const {data, status} = await postRequest(`/user/search?page=${currentPage.value-1}&size=${usersPerPage.value}`, params, null, [], {
        source: source.value,
        cancelToken: source.value.token
      })

      if(status) {
        imageUsers.value = data?.content || []
        totalUsers.value = data?.totalElements || 0

        imageUsers.value.forEach(u => {
          // If the user isn't already a selected user, add to list of selected users
          if (selectedUsers.value.indexOf(u.id) !== -1) {
            u.selected = true;
          }
        })
      }
      dataLoading.value = false
      initialLoad.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Users')

      appStore.loading = false
    }
  } else {
    dataLoading.value = false
    imageUsers.value = []
  }
}
const getTheOrgFilters = async (initialLoad) => {
  // filter out any org filters that were left empty like {"4": []}
  Object.keys(filters.value.orgs).forEach(key => {
    if (filters.value.orgs[key] && filters.value.orgs[key].length === 0) {
      delete filters.value.orgs[key]
    }
  })
  try {
    if(Object.keys(filters.value.orgs).length > 0) {
      //org filters are being used. load their orgs again and repopulate the org lists accordingly
      const params = {
        orgs: getOrgIds()
      }
      const {data} = await postRequest(`/org/orgHierarchyFilter`, params, null, [])
      data.forEach(d => {
        //get index of the each header
        let index = headers.value.findIndex(h => h.level === d.orgLevelId)
        if(d.orgLevelId === selectedLevel.value) {
          // if it is the same as the selected level reset the list values to the master list
          let masterIndex = masterOrgFilterList.value.findIndex(mf => mf.orgLevelId === d.orgLevelId)
          headers.value[index].orgs = masterOrgFilterList.value[masterIndex].orgs
        }else {
          // otherwise use the new result list of orgs
          headers.value[index].orgs = d.orgs
        }
      })
    } else if(initialLoad) {
      //org filters not used yet and is initial load, get the full list of orgs and use those, also populate master list
      const {data} = await getOrgFilters()
      masterOrgFilterList.value = cloneDeep(data)
      orgFilters.value = cloneDeep(masterOrgFilterList.value)
      resetHeaderOrgs()
    } else {
      //org filters were unset and is not initial load, reset headers to master list
      filters.value.orgs = {}
      orgFilters.value = cloneDeep(masterOrgFilterList.value)
      resetHeaderOrgs()
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Org Filters')

    appStore.loading = false
  }
}
const resetHeaderOrgs = ()=> {
  orgFilters.value.forEach(f => {
    let index = headers.value.findIndex(h => h.level === f.orgLevelId)
    if(index > -1) {
      headers.value[index].orgs = f.orgs
    } else {
      headers.value.push({
        text: f.levelName,
        value: f.levelName,
        sortable: false,
        show: true,
        level: f.orgLevelId,
        orgFilter: true,
        showType: f.showType,
        orgs: f.orgs,
        width: '225px'
      })
    }
  })
}
const getStatuses = async (useSavedSearch) => {
  //started using a global loader to ensure they don't search before allUsers get loaded
  appStore.loading = true
  try {
    const {data} = await getRequest(`/user/statuses`, null, [])
    statuses.value = data
    if(!useSavedSearch) {
      filters.value.statuses = statuses.value.filter(s => s.hasAccess).map(s => s.id)
    }
    //removed the await because this page takes forever to load. instead, you cannot send email/text until the allUsersLoading is false
    getAllUsers()
    await getUsers()
    // appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving User Statuses')

    appStore.loading = false
  }
}
const getPositions = async () => {
  try {
    const {data} = await getRequest(`/position`)
    positions.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Positions')

    appStore.loading = false
  }
}
const toggleSelectAllStatuses =  () => {
  vueInstance.$nextTick(() => {
    if (selectAll.value) {
      filters.value.statuses = []
      getUsers(true)
    } else {
      filters.value.statuses = statuses.value.map(s => s.id)
      getUsers(true)
    }
  })
}
const toggleSingleSelect = (item) => {
  if (item.selected) {
    selectedUsers.value.push(item.id)
    selectedUsersDetails.value.push(item)
    // Synchronize the selection of allUsers with users
    allUsers.value.filter(u => u.id === item.id)[0].selected = true;
  } else {
    selectedUsers.value = selectedUsers.value.filter(u => u !== item.id)
    selectedUsersDetails.value = selectedUsersDetails.value.filter(u => u.id !== item.id)
    // Synchronize the selection of allUsers with users
    allUsers.value.filter(u => u.id === item.id)[0].selected = false;
    selectAllUsers.value = false
  }
}
const toggleSingleSelectAutocomplete = (item) => {
  if (item.selected) {
    item.selected = false;
    selectedUsers.value = selectedUsers.value.filter(u => u !== item.id)
    selectedUsersDetails.value = selectedUsersDetails.value.filter(u => u.id !== item.id)
    selectAllUsers.value = false
    // Synchronize the selection of users with allUsers
    users.value.filter(u => u.id === item.id)[0].selected = false;
  } else {
    item.selected = true;
    selectedUsers.value.push(item.id)
    selectedUsersDetails.value.push(item)
    // Synchronize the selection of users with allUsers
    users.value.filter(u => u.id === item.id)[0].selected = true;
  }
}
const clearUsersAutocomplete = () => {
  selectedUsers.value = []
  selectedUsersDetails.value = []
  users.value.forEach(u => {
    u.selected = false
  });
  allUsers.value.forEach(u => {
    u.selected = false
  });
}
const toggleSelectAllUsers =  () => {
  selectedUsers.value = []
  selectedUsersDetails.value = []

  users.value.forEach(u => {
    u.selected = selectAllUsers.value

    // If the user isn't already a selected user, add to list of selected users
    if (selectAllUsers.value && selectedUsers.value.indexOf(u.id) === -1) {
      selectedUsers.value.push(u.id)
      selectedUsersDetails.value.push(u)
    }
  })
}
const getOrgNameForFilter = (hierarchy, filterOrgLevelId, isExport = false) => {
  const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
  return result?.orgName ?? (isExport ? '' : 'N/A')
}
const getOrgIdsForMax = (resetSelected) => {
  let maxKey = max(Object.keys(filters.value.orgs).map(n => parseInt(n)))
  if(resetSelected){
    selectedLevel.value = parseInt(maxKey)
  }
  return filters.value.orgs && maxKey ? filters.value.orgs[maxKey].map(o => o.id) : []
}
const getOrgIds = () => {
  if(filters.value.orgs && filters.value.orgs[selectedLevel.value] && filters.value.orgs[selectedLevel.value].length > 0){
    return filters.value.orgs ? filters.value.orgs[selectedLevel.value].map(o => o.id) : []
  } else {
    return getOrgIdsForMax(true)
  }
}
const changeImageFilter = async(reset, selectedLevel)=> {
  currentPage.value = 1;
  await handleImageFilterChange(reset, selectedLevel);
  await getUserImage();
}
const handleOrgFilterChange =  (reset, selectedLevelHere) => {
  selectedLevel.value = selectedLevelHere
  if(reset) {
    filters.value.orgs = {}
    orgFilters.value = cloneDeep(masterOrgFilterList.value)
    filters.value.positions = []
    filters.value.statuses = statuses.value.filter(s => s.hasAccess).map(s => s.id)
    filters.value.search = ''
    filters.value.firstName = ''
    filters.value.lastName = ''
    filters.value.email = ''
    filters.value.phone = ''

  } else {
    Object.keys(filters.value.orgs).forEach(k => {
      if(k > selectedLevel.value) {
        delete filters.value.orgs[k]
      }
    })
    //reload the filters
    getOrgFilters()
  }

  selectAllUsers.value = false
  //reload the users
  getUsers(true)
}
const handleImageFilterChange = async (reset, selectedLevelHere) => {
  selectedLevel.value = selectedLevelHere
  if(reset) {
    filters.value.orgs = {}
    orgFilters.value = cloneDeep(masterOrgFilterList.value)
    filters.value.positions = []
    filters.value.statuses = statuses.value.filter(s => s.hasAccess).map(s => s.id)
    filters.value.search = ''
    filters.value.firstName = ''
    filters.value.lastName = ''
    filters.value.email = ''
    filters.value.phone = ''

  } else {
    Object.keys(filters.value.orgs).forEach(k => {
      if(k > selectedLevel.value) {
        delete filters.value.orgs[k]
      }
    })
    //reload the filters
    getOrgFilters();
  }

  selectAllUsers.value = false
  //reload the users
}
const itemChecked = (level, item) => {
  if (filters.value.orgs[level] && filters.value.orgs[level].length > 0) {
    let match = filters.value.orgs[level].find(of => of.id === item.id)
    return match != null
  } else {
    return false;
  }
}
const fetchTeamsForUser = async () => {
  try {
    conversationIsLoading.value = true
    const { data, status } = await getRequest(`/smsTeam/getTeamsForUser`)
    appStore.loading = false
    teamsAssociatedToUser.value = data
    for (let team of teamsAssociatedToUser.value){
      templateTeams.value.push(team.id);
    }
    handleHidingGlobalLoader(this, status)
    await getSmsTeamTemplates();
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching SMS Teams')
    conversationIsLoading.value = false
  }
}
const getSmsTeamTemplates = async() => {
  try {
    selectedTemplate.value = null
    if (teamsAssociatedToUser.value.length < 1) {
      return
    }

    const { data } = await getRequest(`/messaging/templates/` + templateTeams.value)
    selectableTemplates.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving templates')

  }
}
const sendMessage = async(sendEmail, sendText) => {
  try {
    appStore.loading = true
    //BR is aware that this will not allow them to truly select all users or to select more than 1000 records at a time
    const userIds = selectedUsers.value;
    const requests = []
    if (sendEmail) {
      const sendEmailFn = (async ()=> {
        const formData = new FormData()
        formData.append('subject', emailSubject.value);
        formData.append('from', fromEmail.value);
        formData.append('userIds', userIds);
        formData.append('template', emailMessage.value);

        emailAttachments.value.forEach(e => {
          formData.append('attachments', e);
        });

        return postRequest(`/communication/sendEmails`, formData)
      })()
      requests.push(sendEmailFn)
      await Promise.all(requests)
    }

    if (sendText) {
      if (textMessage.value && textMessage.value.length > 1599) {
        let textOverflowLength = textMessage.value.length - 1599;
        appStore.showSnack('ERROR', 'Message exceeds the 1600 character limit by ' + textOverflowLength + ' characters. ')

        messageSuccess.value = false
        appStore.loading = false
        return;
      }

      let params = {
        userIDs: userIds,
        message: textMessage.value,
        mediaURLs: textMediaUrls.value
      }

      await postRequest(`/communication/sendTexts`, params)
    }
  }  catch (e) {
    console.error('*** ERROR ***', e)
    let message = e?.message ? 'Error Sending Message: ' + e.message :
        e?.data?.message ? 'Error Sending Message: ' + e.data.message : 'Error Sending Message'
    const matches = message.match(/"(.*?)"/);
    if (matches && matches.length > 1) {
      message = 'Error Sending Message: ' + matches[1]
    }

    appStore.showSnack('ERROR', message)

    appStore.loading = false
    return
  }

  let msg = 'Message sent'
  if (sendEmail && sendText){
    msg = 'Both Email and Text messages were sent successfully'
  } else if (sendEmail) {
    msg = 'Email messages were sent successfully'
  } else{
    msg = 'Text messages were sent successfully'
  }

  appStore.showSnack('SUCCESS', msg)
  msgDialog.value = false
  emailSubject.value= ''
  emailMessage.value= defaultEmailMessage
  fromEmail.value = ''
  textMessage.value= ''
  textMediaUrls.value = []
  emailAttachments.value = []
  emailFile.value = null
  textFiles.value = []

  appStore.loading = false
}
const onEmailMessageChange = ({ text }) => {
  emailCharacterCount.value = text.trim().length;
  emailWordCount.value = text.trim().split(' ').length;
}
const uploadEmailAttachment = (files) => {
  emailAttachments.value = files
}
const uploadTextAttachment = async (files) => {
  try {
    if (!files){
      return
    }

    for (let file of files) {
      appStore.loading = true
      // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
      await fileStore.uploadFile({
        file,
        attachmentTypeId: 3,
        sourceId: 1,
        displayName: file.name.substr(0, file.name.lastIndexOf('.')),
        callback: async (newAttachment) => {
          appStore.loading = false
          textMediaUrls.value.push(newAttachment.url)
        }
      })
    }
  } catch(e) {
    appStore.loading = false
    logError(e)
    appStore.showSnack('ERROR', 'Error Uploading File')

  }
}
const getEmailSenders = async() => {
  try {
    const {data} = await getRequest(`/emailAddress/${companyId.value}`, null)
    fromEmails.value = data.map(e => e.emailAddress)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Email Addresses')

  }
}
const exportCsv = async() => {
  try {
    const params = {
      search: filters.value.search,
      firstName: filters.value.firstName,
      lastName: filters.value.lastName,
      email: filters.value.email,
      phone: filters.value.phone,
      statuses: filters.value.statuses,
      positions: filters.value.positions,
      orgs: getOrgIdsForMax(),
      //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
      primaryFlag: primaryPositionsOnly.value
    }

    const {data} = await postRequest(`/user/search?page=0&size=9999`, params)

    let csv = ''

    headers.value.forEach(h => {
      if (h.text !== '') {
        csv += `${h.text},`
      }
    })

    csv = `${csv.slice(0, -1)}\n`

    data.content.forEach(u => {
      csv += `${u.firstName},${u.lastName},${u.email},${u.phoneNumber || ''},'${u.phoneExtension || ''},${u.userStatusType},${u.position || ''},`

      orgFilters.value.forEach(f => {
        csv += `${getOrgNameForFilter(u.hierarchy, f.orgLevelId, true)},`
      })

      csv += '\n'
    })

    const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
    saveAs(blob, 'Users.csv')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error exporting user data')

  }
}
</script>

<style lang="scss">
#users-container .v-data-footer__pagination {
  display: none !important;
}

#users-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
.filter-header-non-select {
  padding-bottom: 12px !important;
}

.user-filter-select,
.user-filter-select .v-input__control,
.user-filter-select .v-input__control .v-input__slot,
.user-filter-select .v-input__control .v-input__slot fieldset {
  height: 40px !important;
  min-height: 40px !important;
}
.user-filter-select .v-select__selections {
  padding: 0 0 5px 0 !important;
  height: 40px !important;
}
.user-filter-select .v-input__append-inner {
  margin-top: 5px !important;
}
.ql-editor{
  min-height:200px;
}
</style>

<style lang="scss" scoped>
#users-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
.user-table {
  margin-top: 2px;
}
.user-column {
  overflow: hidden;
}
.count-span {
  font-size: 0.85em;
  color: var(--v-grey-darken2);
}
.user-selected {
  margin-left: 150px;
}
.user-autocomplete {
  width: 350px;
}
::v-deep .user-filter-select .v-label{
  vertical-align: center;
}

.user-images-filter-select,
.user-images-filter-select .v-input__control,
.user-images-filter-select .v-input__control .v-input__slot,
.user-images-filter-select .v-input__control .v-input__slot fieldset {
  height: 40px !important;
  min-height: 40px !important;
  width:10%;
}
.user-images-filter-select .v-select__selections {
  padding: 0 0 5px 0 !important;
  height: 40px !important;
}
.user-images-filter-select .v-input__append-inner {
  margin-top: 5px !important;
}
.select-email {
  max-width: 60%;
}

.template-dialog {
  max-width: 500px;
}

.message-text-area {
  width: 100%;
}

.message-tabs {
  margin-left: 24px;
}

.close-modal-x {
  font-size: 30px;

  &:hover {
    font-weight: bolder;
  }
}

.select-check {
  color: var(--v-primary-base) !important;
}

.ellipse {
  white-space: nowrap;
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 450px;
}

</style>
