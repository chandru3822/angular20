<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col>
        <v-app-bar flat class="elevation-1 call-group-bar">
          <v-toolbar-title class="pt-2" style="margin-top: 45px">Call Groups
            <div v-if="editGroup">
              <v-text-field text class="d-inline-block mt-4 edit-text"
                            label="Contacts per Phone Number"
                            type="text"
                            tabindex=1
                            v-model="maxCallCount">
              </v-text-field>
              <v-text-field text class="d-inline-block mt-4 edit-text"
                            type="text"
                            label="Days Per Period"
                            tabindex=1
                            v-model="daysPerPeriod">
              </v-text-field>
              <v-btn :disabled="!maxCallCount || !daysPerPeriod" text color="primaryCustom" @click="saveGroupInfo()">
                <v-icon>save</v-icon>
              </v-btn>
            </div>
            <div v-else>
              <b>Contacts per Phone Number:</b> {{maxCallCount}}
              <br/>
              <b>Time Period:</b> {{daysPerPeriod}} days
            </div>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanEdit" @click="editGroup = !editGroup">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text @click="[addNew = !addNew, newCallGroup = {}]" v-if="userCanAdd">
              {{'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-app-bar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Call Group Name"
                tabindex=1
                v-model="newCallGroup.callGroupName"
            ></v-text-field>
            <v-btn :disabled="!newCallGroup.callGroupName" @click="addCallGroup">Save</v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
                @input="debounceSearch"
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterCallGroups()"
              :fixed-header="true"
              :items-per-page="-1"
              disable-sort
              :loading="dataLoading"
              hide-default-footer
              class="elevation-1"
            >
              <template #item="{ item, index }">
                <tr>
                  <td class="text-left clickable" @click="goToCallGroup(item.id)">
                    <img v-if="item.maxCallCountHit"
                         name="userImg" src="../../../../assets/blueraven/alert_icon.jpg" class="icon-height"
                         title="All active phone numbers exceed max call count">
                    {{item.callGroupName}}
                  </td>
                  <td>{{item.postalCodesCount}}</td>
                  <td>{{item.activePhoneNumbersCount}}</td>
                  <td>
                    <v-select attach style="width: 100px" v-model="item.active" :items="items" @change="updateCallGroup(item)"></v-select>
                  </td>
                  <td class="text-right">
                    <v-btn small text @click="goToCallGroup(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-if="userCanDelete"
                      v-model="item.deleteConfirm"
                      width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn small text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="headline grey lighten-2"
                          primary-title
                        >
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this call group: <strong>{{ item.callGroupName }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="[item.archived = true, deleteCallGroup(item.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import debounce from 'lodash.debounce'
  import { getRequestWithParams, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'CallGroups',
    mixins: [Vue2Filters.mixin],

    data () {
      return {
        snackbar: {},
        addNew: false,
        search: null,
        newCallGroup: {},
        dataLoading: true,
        editGroup: false,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('CALL_GROUPS', 'DELETE'),
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        CallGroups: [],
        maxCallCount: 20,
        daysPerPeriod: 30,
        headers: [
          {text: 'Call Group Name', value: 'callGroupName', show: true},
          {text: 'No. Postal Codes', value: 'activePostalCodes', show: true},
          {text: 'Active Phone Numbers', value: 'activePhoneNumbers', show: true},
          {text: 'Status', value: 'active', show: true},
          {text: '', value: 'icons', show: true},
        ],
        items: [
          {text: 'Active', value: true},
          {text: 'Disabled', value: false}
        ]
      }
    },
    computed: {
    },
    methods: {
      debounceSearch: debounce( function () {
        //don't allow search to be null - causes issues
        // this.search = this.search || ''
        this.getCallGroups()
      }, 500),
      filterCallGroups () {
        return this.CallGroups.filter(cg => { return !cg.archived})
      },
      goToCallGroup(groupId) {
        this.$router.push({path: `/settings/callGroup/${groupId}/numbers`})
      },
      async getCallGroups () {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/callGroup`, { params: { searchQuery: this.search}}, 'blueraven')
          this.CallGroups = data
          this.daysPerPeriod = data[0].daysPerPeriod
          this.maxCallCount = data[0].maxCallCount
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCallGroup (groupId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/callGroup/${groupId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Call Group Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Call Group')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addCallGroup () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newCallGroup.maxCallCount = this.maxCallCount
          this.newCallGroup.daysPerPeriod = this.daysPerPeriod
          const {data} = await postRequest(`/callGroup/`, this.newCallGroup, 'blueraven')
          this.$router.push({path: `/settings/callGroup/${data.id}/codes`})
          this.snackbar = getSnackbar('SUCCESS', 'Call Group Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Call Group')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateCallGroup(item) {
        this.showError = false
        this.errorMsg = ''
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/callGroup/`, item, 'blueraven')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = 'Error updating Call Group'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveGroupInfo () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            maxCallCount: this.maxCallCount,
            daysPerPeriod: this.daysPerPeriod
          }
          await postRequest(`/callGroup/config`, params, 'blueraven')
          this.editGroup = false
          this.snackbar = getSnackbar('SUCCESS', 'Call Group settings saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Call Group')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created () {
      this.getCallGroups()
    }
  }
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
  .icon-height {
    height: 18px;
    width: 18px;
    margin-right: 5px;
  }
  .call-group-bar {
    min-height: 125px !important;
  }
  .edit-text {
    margin-left: 25px;
  }
</style>
