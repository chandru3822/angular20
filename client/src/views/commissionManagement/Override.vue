<template>
  <v-container class="pa-0" id="override-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        {{override.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="button-container">
          <v-dialog v-if="override.status !== 'ACTIVE'"
                    v-model="deleteConfirm"
                    width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Delete
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title>
                Confirm
              </v-card-title>

              <v-card-text class="pt-4">
                Are you sure you want to delete this plan?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="deleteConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primary"
                  text
                  @click="deleteConfirm = true; deleteOverride()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-dialog v-else
              v-model="inactivateConfirm"
              width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Inactivate
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                  class="headline grey lighten-2"
                  primary-title>
                Confirm
              </v-card-title>

              <v-card-text class="pt-4">
                Are you sure you want to inactivate this plan?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                    @click="inactivateConfirm = false">
                  No
                </v-btn>
                <v-btn
                    color="primary"
                    text
                    @click="inactivateConfirm = true; inactivateOverride()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-dialog v-if="override"
                    v-model="cloneDialog"
                    width="600"
          >
            <template v-slot:activator="{ on }">
              <v-btn color="primaryCustom" dark v-on="on">
                Clone
              </v-btn>
            </template>

            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title
              >
                Clone {{override.name}}
              </v-card-title>

              <v-card-text class="pt-4">
                <div class="mb-2">
                  This option allows you to copy an entire plan over. <br/>
                  By default, no users are copied over.
                </div>
                Users to Copy:
                <div v-for="u in override.receivingUsers">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}
                </div>
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  text
                  @click="cloneDialog = false; cloneStartDate = null"
                >
                  Cancel
                </v-btn>
                <v-btn
                  color="primaryCustom"
                  class="white--text"
                  @click="cloneDialog = false; cloneOverride(override.receivingUsers)"
                >
                  Clone
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-btn color="primaryCustom" dark v-else @click="cloneOverride()">
            Clone
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>


    <v-divider></v-divider>
    <v-form ref="overrideForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="override.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="override.description"></v-text-field>
              <v-select v-model="override.positionId"
                        :items="positions"
                        :disabled="override.assignedUsers.length > 0"
                        no-data-text="No Users Available"
                        label="Position Type"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Rate per kW ($)"
                            v-model="override.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-text-field text
                            label="Status"
                            v-model="override.status"></v-text-field>
              <v-text-field text
                            v-if="override.createdBy"
                            label="Created By"
                            v-model="override.createdBy.name"></v-text-field>
              <v-text-field text
                            label="Approved"
                            v-model="override.approved"></v-text-field>
              <v-text-field text
                            label="Approved By"
                            v-if="override.approvedBy"
                            v-model="override.approvedBy.name"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Receiving Overrides
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="receivingHeaders"
            :items="override.receivingUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.m1Allocation}}</td>
              <td class="text-left">{{item.m2Allocation}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Assigned to Override Plan
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :items="override.assignedUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import Vue2Filters from 'vue2-filters'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Override',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      this.getOverrideDetails()
    },
    watch: {
      $route(to, from) {
        // react to route changes...
        // this.$router.push({name: 'commission', params: {id: to.params.id}})
        // this.planId = to.params.id
        this.overrideId = to.params.id
        this.getOverrideDetails()
      },
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        cloneDialog: false,
        moment,
        cloneStartDate: null,
        timezone: this.$store.state.user.details.timezone.value,
        inactivateConfirm: false,
        deleteConfirm: false,
        overrideId: this.$route.params.id,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        receivingHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'M1 Allocation', value: 'm1Allocation', show: true},
          {text: 'M2 Allocation', value: 'm2Allocation', show: true},
        ],
        override: {
          approvedBy: {},
          createdBy: {},
          assignedUsers: []
        },
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ]
      }
    },
    methods: {
      async getOverrideDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.override = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        console.log('handle going to item', item)
      },
      async deleteOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Deleted')
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async cloneOverride (users) {
        console.log('CLONE', this.override)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            receivingUsers: users ? users.filter(u => u.selected).map(u => u.userId) : [],
            assignedUsers: [],
            backdateApprovalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/clone`, params, 'blueraven')
          console.log('randaLogger cloned Plan', data)
          this.$router.push({name: 'override', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Cloning Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivateOverride () {
        console.log('INACTIVATE', this.override)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/commissionManagement/overrides/${this.override}/inactivate`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Inactivated')
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Inactivating Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
.button-container {
  display: flex;
  align-items: center;
}
</style>

