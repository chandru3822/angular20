<template>
  <v-container id="users-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Users</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newUser" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'ADD')">
              <v-icon>add</v-icon>
              Add User
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              clearable
              label="Search users..."
              v-model="filters.search"
              @input="debounceGetUsers"
          ></v-text-field>
          <v-checkbox
              class="pt-5 ml-3"
              dense
              v-model="primaryPositionsOnly"
              label="Primary Only"
              @change="handleOrgFilterChange(false)"
          />
          <span class="flex-display justify-end user-selected" @click="selectedUsersDialog = true">{{this.usersSelected}} user(s) selected</span>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="msgDialog = true" :disabled="allUsersLoading">
              <v-icon v-if="constants.IS_MOBILE">email</v-icon>
              <span v-else>Send Email/Text</span>
            </v-btn>
            <v-btn text color="primary" @click="handleOrgFilterChange(true)">
              <v-icon v-if="constants.IS_MOBILE">filter_list</v-icon>
              <span v-else>Reset Filters</span>
            </v-btn>

            <v-btn text color="primary" @click="exportCsv">
              <v-icon v-if="constants.IS_MOBILE">mdi-cloud-download</v-icon>
              <span v-else>Export</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="users"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            ref="pageable-table"
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
                <v-autocomplete v-model="filters.orgs[header.level]"
                          :items="header.orgs"
                          v-if="header.orgFilter"
                          item-text="orgName"
                          item-value="id"
                          return-object
                          multiple
                          placeholder="Select..."
                          height="35px"
                          outlined
                          class="user-filter-select"
                          @change="handleOrgFilterChange(false, header.level)"
                >
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
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
                </v-autocomplete>
                <v-autocomplete v-model="filters.statuses"
                          :items="statuses"
                          v-else-if="header.statusFilter"
                          multiple
                          item-text="userStatusType"
                          item-value="id"
                          outlined
                          placeholder="Select..."
                          height="35px"
                          class="user-filter-select"
                          @input="getUsers()"
                >
                  <v-list-item
                      slot="prepend-item"
                      ripple
                      @click="toggleSelectAllStatuses()"
                  >
                    <v-list-item-action>
                      <v-icon>{{ icon }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item>
                  <v-divider
                      slot="prepend-item"
                      class="mt-2"
                  ></v-divider>
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
                    <v-chip small v-if="index === 0 && filters.statuses.length < 2">
                      <span>{{ item.userStatusType }}</span>
                    </v-chip>
                    <span
                        v-if="index === 1 && filters.statuses.length >= 2"
                        class="primary--text text-caption"
                    >{{ filters.statuses.length }} selected</span>
                  </template>
                </v-autocomplete>
                <v-autocomplete v-model="filters.positions"
                          :items="positions"
                          v-else-if="header.positionFilter"
                          item-text="position"
                          item-value="id"
                          multiple
                          placeholder="Select..."
                          height="35px"
                          outlined
                          class="user-filter-select"
                          @input="getUsers(false)"
                >
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
                    <v-chip small v-if="index === 0 && filters.positions && filters.positions.length < 2">
                      <span>{{ item.position }}</span>
                    </v-chip>
                    <span
                        v-if="index === 1 && filters.positions && filters.positions.length >= 2"
                        class="primary--text text-caption"
                    >{{ filters.positions.length }} selected</span>
                  </template>
                </v-autocomplete>
                <v-checkbox v-else-if="header.selectFilter"
                            :disabled="allUsersLoading"
                            v-model="selectAllUsers" @change="toggleSelectAllUsers()"></v-checkbox>
                <v-text-field outlined
                              v-else-if="header.value !== 'phoneExtension'"
                              hide-details
                              class="filter-input"
                    v-model="filters[header.value]" @input="debounceGetUsers"></v-text-field>
                <div v-else style="height: 35px;"></div>
              </th>
            </tr>
            </thead>
          </template>

          <template #item="{ item, index }">
            <tr
              :class="{'shaded-row': index % 2}"
            >
              <td><v-checkbox v-model="item.selected" :disabled="allUsersLoading" @change="toggleSingleSelect(item)"></v-checkbox></td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.firstName}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.lastName}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.email}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.phoneNumber}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.phoneExtension}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.userStatusType}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable">{{item.position || 'N/A'}}</td>
              <td @click="clickRow(item.id)" class="text-left user-column clickable" v-for="(f, index) in orgFilters" :key="index">
                {{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}
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
          <v-btn
            @click="selectedUsersDialog = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="msgDialog" max-width="800px">
      <v-card>
        <v-card-title class="text-h5" primary-title>
            Send Bulk Emails/Texts
        </v-card-title>
          <v-toolbar-items>
        <v-tabs color="secondary" background-color="primary" slot="extension" dark slider-color="secondary">
            <v-tab @click="messageTab = 1">
              Emails
            </v-tab>
            <v-tab @click="messageTab = 2">
              Texts
            </v-tab>
        </v-tabs>
          </v-toolbar-items>
        <v-divider></v-divider>
        <div v-if="messageTab == 1"  class="pa-5">
          <v-autocomplete
            v-model="selectedUsers"
            :items="allUsers"
            multiple
            clearable
            label="To"
            item-text="fullName"
            item-value="id"
            height="35px"
            @click:clear="clearUsersAutocomplete()"
            class="d-inline-block mr-3 user-autocomplete">
            <v-divider
              slot="prepend-item"
              class="mt-2"
            ></v-divider>
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
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
          </v-autocomplete>

          <v-select attach
                    label="From"
                      v-model="fromEmail"
                      :items="fromEmails"
                      item-text="email"
                      item-value="email"
            />

            <v-text-field v-model="emailSubject" label="Subject"></v-text-field>
            <b>Message </b><span class="count-span pl-2">Characters: {{this.emailCharacterCount}}  Words: {{this.emailWordCount}}</span>
            <quill-editor
                class="py-3"
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

            <span class="flex-display justify-end pa-4 pt-0">{{this.usersSelected}} user(s) selected</span>
            <v-card-actions class="flex-display justify-end px-4 pt-0">
              <v-btn
                text color="primary"
                @click="cancelSendMessageDialog">
                Cancel
              </v-btn>
              <v-btn
                color="primary" class="white--text mr-2 "
                :disabled="this.disableSendEmail"
                @click="sendMessage(true, false)">
                Send Emails Only
              </v-btn>
              <v-btn
                color="primary" class="white--text"
                :disabled="this.disableSendEmail || this.disableSendText"
                @click="sendMessage(true, true)">
                Send Both
              </v-btn>
            </v-card-actions>
        </div>
        <div v-else-if="messageTab == 2" style="height:700px;" class="pa-5">
            <v-autocomplete
              v-model="selectedUsers"
              :items="allUsers"
              multiple
              clearable
              label="To"
              item-text="fullName"
              item-value="id"
              height="35px"
              @click:clear="clearUsersAutocomplete()"
              class="d-inline-block mr-3 user-autocomplete">
              <v-divider
                slot="prepend-item"
                class="mt-2"
              ></v-divider>
              <template
                slot="selection"
                slot-scope="{ item, index }"
              >
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
            </v-autocomplete>
            <span class="count-span flex-display">Characters: {{this.textCharacterCount}} (153 Character limit)</span>

            <v-textarea solo v-model="textMessage"
                        auto-grow
                        rows="7"
                        placeholder="Enter your message..." class="py-3"></v-textarea>

            <v-file-input
                dense
                outlined
                color="primary"
                label="Upload image"
                v-model="textFile"
                @change="uploadTextAttachment"
                @click:clear="[textFile = null, textMediaUrls = []]"
                style="width: 245px"
            />

            <span class="flex-display justify-end pa-4 pt-0">{{this.usersSelected}} user(s) selected</span>
            <v-card-actions class="flex-display justify-end px-4 pt-0">
              <v-btn
                text color="primary"
                @click="cancelSendMessageDialog">
                Cancel
              </v-btn>
              <v-btn
                color="primary" class="white--text mr-2"
                :disabled="this.disableSendText"
                @click="sendMessage(false, true)">
                Send Text Only
              </v-btn>
              <v-btn
                color="primary" class="white--text"
                :disabled="this.disableSendEmail || this.disableSendText"
                @click="sendMessage(true, true)">
                Send Both
              </v-btn>
            </v-card-actions>
        </div>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { Actions } from '@/store'

  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, logError} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import debounce from 'lodash.debounce'
  import cloneDeep from 'lodash.clonedeep'
  import {getOrgFilters} from '@/services/orgService'
  import max from 'lodash.max'
  import 'quill/dist/quill.snow.css'
  import {quillEditor} from 'vue-quill-editor'
  import { saveAs } from 'file-saver'
  import axios from 'axios'

  const defaultEmailMessage = '${user.firstName},\n'

  export default {
    name: 'Users',
    components: {QuillEditor: quillEditor},
    watch: {
      options: {
        handler() {
          if(!this.initialLoad) {
            this.getUsers()
          }
        }
      },
      page() {
        let table = this.$refs['pageable-table'];
        let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

        this.$vuetify.goTo(table); // to table
        this.$vuetify.goTo(table, {container: wrapper}); // to header
      }
    },
    data () {
      return {
        delay: 500,
        constants,
        dialog: false,
        snackbar: {},
        users: [],
        initialLoad: true,
        allUsers: [],
        selectedLevel: null,
        masterOrgFilterList: [],
        orgFilters: [],
        statuses: [],
        positions: [],
        descending: true,
        footerProps: {
          'items-per-page-options': [10, 50, 100, 1000, 3000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        totalUsers: 0,
        dataLoading: true,
        headers: [
          { text: '', value: 'selectBox', selectFilter:true, show: true, width: '50px' },
          { text: 'First Name', value: 'firstName', show: true, width: '125px' },
          { text: 'Last Name', value: 'lastName', show: true, width: '125px' },
          { text: 'Email', value: 'email', show: true, width: '275px' },
          { text: 'Phone', value: 'phone', show: true, width: '115px' },
          { text: 'Ext', value: 'phoneExtension', show: true, width: '75px' },
          { text: 'User Status', value: 'userStatusType', statusFilter: true, show: true, width: '175px' },
          { text: 'Position', value: 'position', positionFilter: true, show: true, width: '175px' },
        ],
        filters: {
          search: '',
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          orgs: {},
          statuses: [],
          positions: []
        },
        usersTableHeaders: [
          { text: 'Name', value: 'fullName', show: true, width: '125px' },
          { text: 'Position', value: 'position', show: true, width: '125px' }
        ],
        selectAllUsers: false,
        selectedUsers: [],
        selectedUsersDetails: [],
        msgDialog: false,
        selectedUsersDialog: false,
        messageTab: 1,
        page: 1,
        fromEmail: '',
        fromEmails: [],
        emailSubject: '',
        emailMessage: defaultEmailMessage,
        textMessage: '',
        emailCharacterCount: 0,
        emailWordCount: 0,
        textCharacterCount: 0,
        emailAttachments: [],
        textMediaUrls: [],
        emailFile: null,
        textFile: null,
        primaryPositionsOnly: true,
        source: null,
        allUsersLoading: false,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {
      selectAll () {
        return this.filters.statuses.length === this.statuses.length
      },
      selectSome () {
        return this.filters.statuses.length > 0 && !this.selectAll
      },
      icon () {
        if (this.filters.statuses && this.statuses && this.filters.statuses.length === this.statuses.length) {
          return 'check_box'
        }
        if (this.selectSome) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      usersSelected () {
        return this.selectedUsers.length;
      },
      disableSendEmail() {
          return !(this.fromEmail.trim().length > 0 && this.emailSubject.trim().length > 0 && this.emailMessage.trim().length > 0 && this.usersSelected)
      },
      disableSendText() {
          return !(this.textMessage.trim().length > 0 && this.usersSelected)
      }
    },
    beforeRouteEnter(to, from, next) {
      //if coming to this page from the user details - use the previously used search
      next((vm) => {
        let useSavedSearch = false
        if(from?.fullPath.includes('/user/')) {
          JSON.parse(localStorage.getItem('store'))
          if(localStorage.getItem('userFilters') != null) {
            vm.filters = JSON.parse(localStorage.getItem('userFilters'))
            useSavedSearch = true
          }
        } else {
          localStorage.removeItem('userFilters')
        }
        // getStatuses calls getUsers because we have to know company statuses before we can filter the list
        vm.getStatuses(useSavedSearch)
      });
    },
    created () {
      this.getPositions()
      this.getOrgFilters(true)
      this.getEmailSenders()
    },
    methods: {
      cancelSendMessageDialog(){
        this.textMediaUrls = []
        this.emailAttachments = []
        this.emailFile = null
        this.textFile = null
        this.msgDialog = false
      },
      clickRow(id){
        this.$router.push({name: 'userDetails', params: {id}})
      },
      debounceGetUsers: debounce( function () {
        this.getUsers()
      }, 500),
      async getAllUsers () {
        // Get allUsers once
        // this was loading twice if a search was done prior to completing this request. putting it in its own fn that is called by the created method fixes that
        this.allUsersLoading = true
        //removing global loader since now it just waits for this to finish before you can send a text
        // this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          //could default these params since we want all users
          const params = {
            search: this.filters.search,
            firstName: this.filters.firstName,
            lastName: this.filters.lastName,
            email: this.filters.email,
            phone: this.filters.phone,
            statuses: this.filters.statuses,
            positions: this.filters.positions,
            orgs: this.getOrgIdsForMax(),
            primaryFlag: this.primaryPositionsOnly
          }
          const {data, status} = await postRequest(`/user/search?page=0&size=9999`, params)
          this.allUsers = data?.content || []
          this.allUsersLoading = false
          // handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving All Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.allUsersLoading = false
          // this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUsers () {
        localStorage.setItem('userFilters', JSON.stringify(this.filters))

        if(this.source){
          this.source.cancel()
        }
        const CancelToken = axios.CancelToken
        this.source = CancelToken.source()

        if (this.filters.statuses && this.filters.statuses.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          this.dataLoading = true
          const { page, itemsPerPage } = this.options

          try {
            const params = {
              search: this.filters.search,
              firstName: this.filters.firstName,
              lastName: this.filters.lastName,
              email: this.filters.email,
              phone: this.filters.phone,
              statuses: this.filters.statuses,
              positions: this.filters.positions,
              orgs: this.getOrgIdsForMax(),
              //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
              primaryFlag: this.primaryPositionsOnly
            }

            const {data, status} = await postRequest(`/user/search?page=${page-1}&size=${itemsPerPage}`, params, null, [], {
              source: this.source,
              cancelToken: this.source.token
            })

            if(status) {
              this.users = data?.content || []
              this.totalUsers = data?.totalElements || 0

              this.users.forEach(u => {
                // If the user isn't already a selected user, add to list of selected users
                if (this.selectedUsers.indexOf(u.id) !== -1) {
                  u.selected = true;
                }
              })
            }
            this.dataLoading = false
            this.initialLoad = false
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.dataLoading = false
          this.users = []
        }
      },
      async getOrgFilters (initialLoad) {
        // filter out any org filters that were left empty like {"4": []}
        Object.keys(this.filters.orgs).forEach(key => {
          if (this.filters.orgs[key] && this.filters.orgs[key].length === 0) {
            delete this.filters.orgs[key]
          }
        })
        try {
          if(Object.keys(this.filters.orgs).length > 0) {
            //org filters are being used. load their orgs again and repopulate the org lists accordingly
            const params = {
              orgs: this.getOrgIds()
            }
            const {data} = await postRequest(`/org/orgHierarchyFilter`, params, null, [])
            data.forEach(d => {
              //get index of the each header
              let index = this.headers.findIndex(h => h.level === d.orgLevelId)
              if(d.orgLevelId === this.selectedLevel) {
                // if it is the same as the selected level reset the list values to the master list
                let masterIndex = this.masterOrgFilterList.findIndex(mf => mf.orgLevelId === d.orgLevelId)
                this.headers[index].orgs = this.masterOrgFilterList[masterIndex].orgs
              }else {
                // otherwise use the new result list of orgs
                this.headers[index].orgs = d.orgs
              }
            })
          } else if(initialLoad) {
            //org filters not used yet and is initial load, get the full list of orgs and use those, also populate master list
            const {data} = await getOrgFilters()
            this.masterOrgFilterList = cloneDeep(data)
            this.orgFilters = cloneDeep(this.masterOrgFilterList)
            this.resetHeaderOrgs()
          } else {
            //org filters were unset and is not initial load, reset headers to master list
            this.filters.orgs = {}
            this.orgFilters = cloneDeep(this.masterOrgFilterList)
            this.resetHeaderOrgs()
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Filters')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      resetHeaderOrgs(){
        this.orgFilters.forEach(f => {
          let index = this.headers.findIndex(h => h.level === f.orgLevelId)
          if(index > -1) {
            this.headers[index].orgs = f.orgs
          } else {
            this.headers.push({
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
      },
      async getStatuses (useSavedSearch) {
        //started using a global loader to ensure they don't search before allUsers get loaded
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/statuses`, null, [])
          this.statuses = data
          if(!useSavedSearch) {
            this.filters.statuses = this.statuses.filter(s => s.hasAccess).map(s => s.id)
          }
          //removed the await because this page takes forever to load. instead, you cannot send email/text until the allUsersLoading is false
          this.getAllUsers()
          await this.getUsers()
          // this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions () {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      toggleSelectAllStatuses () {
        this.$nextTick(() => {
          if (this.selectAll) {
            this.filters.statuses = []
            this.getUsers()
          } else {
            this.filters.statuses = this.statuses.map(s => s.id)
            this.getUsers()
          }
        })
      },
      toggleSingleSelect(item) {
        if (item.selected) {
          this.selectedUsers.push(item.id)
          this.selectedUsersDetails.push(item)
          // Synchronize the selection of allUsers with users
          this.allUsers.filter(u => u.id === item.id)[0].selected = true;
        } else {
          this.selectedUsers = this.selectedUsers.filter(u => u !== item.id)
          this.selectedUsersDetails = this.selectedUsersDetails.filter(u => u.id !== item.id)
          // Synchronize the selection of allUsers with users
          this.allUsers.filter(u => u.id === item.id)[0].selected = false;
          this.selectAllUsers = false
        }
      },
      toggleSingleSelectAutocomplete(item) {
        if (item.selected) {
          item.selected = false;
          this.selectedUsers = this.selectedUsers.filter(u => u !== item.id)
          this.selectedUsersDetails = this.selectedUsersDetails.filter(u => u.id !== item.id)
          this.selectAllUsers = false
          // Synchronize the selection of users with allUsers
          this.users.filter(u => u.id === item.id)[0].selected = false;
        } else {
          item.selected = true;
          this.selectedUsers.push(item.id)
          this.selectedUsersDetails.push(item)
          // Synchronize the selection of users with allUsers
          this.users.filter(u => u.id === item.id)[0].selected = true;
        }
      },
      clearUsersAutocomplete() {
        this.selectedUsers = []
        this.selectedUsersDetails = []
        this.users.forEach(u => {
          u.selected = false
        });
        this.allUsers.forEach(u => {
          u.selected = false
        });
      },
      toggleSelectAllUsers () {
        this.selectedUsers = []
        this.selectedUsersDetails = []

        this.users.forEach(u => {
          u.selected = this.selectAllUsers

          // If the user isn't already a selected user, add to list of selected users
          if (this.selectAllUsers && this.selectedUsers.indexOf(u.id) === -1) {
            this.selectedUsers.push(u.id)
            this.selectedUsersDetails.push(u)
          }
        })
      },
      getOrgNameForFilter(hierarchy, filterOrgLevelId, isExport = false) {
        const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
        return result?.orgName ?? (isExport ? '' : 'N/A')
      },
      getOrgIdsForMax(resetSelected) {
        let maxKey = max(Object.keys(this.filters.orgs))
        if(resetSelected){
          this.selectedLevel = parseInt(maxKey)
        }
        return this.filters.orgs && maxKey ? this.filters.orgs[maxKey].map(o => o.id) : []
      },
      getOrgIds() {
        if(this.filters.orgs && this.filters.orgs[this.selectedLevel] && this.filters.orgs[this.selectedLevel].length > 0){
          return this.filters.orgs ? this.filters.orgs[this.selectedLevel].map(o => o.id) : []
        } else {
          return this.getOrgIdsForMax(true)
        }
      },
      handleOrgFilterChange (reset, selectedLevel) {
        this.selectedLevel = selectedLevel
        if(reset) {
          this.filters.orgs = {}
          this.orgFilters = cloneDeep(this.masterOrgFilterList)
          this.filters.positions = []
          this.filters.statuses = this.statuses.filter(s => s.hasAccess).map(s => s.id)
          this.filters.search = ''
          this.filters.firstName = ''
          this.filters.lastName = ''
          this.filters.email = ''
          this.filters.phone = ''

        } else {
          Object.keys(this.filters.orgs).forEach(k => {
            if(k > this.selectedLevel) {
              delete this.filters.orgs[k]
            }
          })
          //reload the filters
          this.getOrgFilters()
        }

        this.selectAllUsers = false
        //reload the users
        this.getUsers()
      },
      itemChecked(level, item) {
        if (this.filters.orgs[level] && this.filters.orgs[level].length > 0) {
          let match = this.filters.orgs[level].find(of => of.id === item.id)
          return match != null
        } else {
          return false;
        }
      },
      async sendMessage(sendEmail, sendText) {
          try {
              this.$store.commit(AppMutations.SET_LOADING, true)
              //BR is aware that this will not allow them to truly select all users or to select more than 1000 records at a time
              const userIds = this.selectedUsers;
              const requests = []
              if (sendEmail) {
                const sendEmailFn = (async ()=> {
                  const formData = new FormData()
                  formData.append('subject', this.emailSubject);
                  formData.append('from', this.fromEmail);
                  formData.append('userIds', userIds);
                  formData.append('template', this.emailMessage);

                  this.emailAttachments.forEach(e => {
                    formData.append('attachments', e);
                  });

                  return postRequest(`/communication/sendEmails`, formData)
                })()
                requests.push(sendEmailFn)
              }

              if (sendText) {
                  const sendTextFn = postRequest(`/communication/sendTexts`, {
                    userIDs: userIds,
                    message: this.textMessage,
                    mediaURLs: this.textMediaUrls
                  })
                requests.push(sendTextFn)
              }
              await Promise.all(requests)

              let msg = 'Message sent'
              if (sendEmail && sendText){
                msg = 'Both Email and Text messages were sent successfully'
              } else if (sendEmail) {
                  msg = 'Email messages were sent successfully'
              }else{
                msg = 'Text messages were sent successfully'
              }

              this.snackbar = getSnackbar('SUCCESS', msg)

              this.msgDialog = false
              this.emailSubject= ''
              this.emailMessage= defaultEmailMessage
              this.fromEmail = ''
              this.textMessage= ''
              this.textMediaUrls = []
              this.emailAttachments = []
              this.emailFile = null
              this.textFile = null
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
          }  catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error sending content')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
          }
      },
      onEmailMessageChange({ text }) {
          this.emailCharacterCount = text.trim().length;
          this.emailWordCount = text.trim().split(' ').length;
      },
      uploadEmailAttachment: function (files) {
        this.emailAttachments = files
      },
      uploadTextAttachment: async function (file) {
        try {
          if (!file){
            return
          }

          this.$store.commit(AppMutations.SET_LOADING, true)
          // @TODO: The actions needs to change when genericising this component. Writing this line made me feel dirty
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file,
            attachmentTypeId: 3,
            sourceId: 1,
            displayName: file.name.substr(0, file.name.lastIndexOf('.')),
            callback: async (newAttachment) => {
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.textMediaUrls = [...this.textMediaUrls, newAttachment.url]
            }
          })
        } catch(e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getEmailSenders() {
        try {
          const {data} = await getRequest(`/emailAddress/${this.companyId}`, null)
          this.fromEmails = data.map(e => e.emailAddress)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Email Addresses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async exportCsv() {
        try {
          const params = {
            search: this.filters.search,
            firstName: this.filters.firstName,
            lastName: this.filters.lastName,
            email: this.filters.email,
            phone: this.filters.phone,
            statuses: this.filters.statuses,
            positions: this.filters.positions,
            orgs: this.getOrgIdsForMax(),
            //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
            primaryFlag: this.primaryPositionsOnly
          }

          const {data} = await postRequest(`/user/search?page=0&size=9999`, params)

          let csv = ''

          this.headers.forEach(h => {
            if (h.text !== '') {
              csv += `${h.text},`
            }
          })

          csv = `${csv.slice(0, -1)}\n`

          data.content.forEach(u => {
            csv += `${u.firstName},${u.lastName},${u.email},${u.phoneNumber || ''},'${u.phoneExtension || ''},${u.userStatusType},${u.position || ''},`

            this.orgFilters.forEach(f => {
              csv += `${this.getOrgNameForFilter(u.hierarchy, f.orgLevelId, true)},`
            })

            csv += '\n'
          })

          const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
          saveAs(blob, 'Users.csv')
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error exporting user data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    }
  }
</script>

<style lang="scss">
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

</style>

