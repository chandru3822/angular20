<template>
  <v-container class="pa-0" id="closer-container">
    <v-toolbar flat color="transparent" :min-height="150">
      <v-toolbar-title>
        {{closer.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-card flat color="transparent" class="text-right mt-3">
          <strong>User ID: </strong>{{closer.userId}}<br/>
          <strong>Vendor Pay ID: </strong>{{closer.vendorPayId}}<br/>
          <strong>Position: </strong>{{closer.position}}<br/>
          <strong>Hire Date: </strong>{{closer.hireDate}}<br/>
          <strong>Position Effective Date: </strong>{{closer.positionStartDate | formatDate('date')}}
        </v-card>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Commission Plans
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanAdd"
                   @click="[planErrorObj = {}, addNewCommissionPlan = !addNewCommissionPlan, newCommissionPlan = {}, getCommissionPlans()]">
              <v-icon v-if="addNewCommissionPlan">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewCommissionPlan" class="square-card text-left pa-5">
          <v-autocomplete v-model="newCommissionPlan.id"
                          :items="commissionPlans"
                          label="Select a Plan to Add"
                          item-text="name"
                          item-value="id"
                          autocomplete="new-password"
          />
          <DatetimePickerInput
              v-model="newCommissionPlan.startDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
              @input="checkDates(newCommissionPlan.startDate, newCommissionPlan.endDate, closer.plans, planErrorObj)"
          />
          <DatetimePickerInput
              v-model="newCommissionPlan.endDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
              @input="checkDates(newCommissionPlan.startDate, newCommissionPlan.endDate, closer.plans, planErrorObj)"
          />
          <div v-if="planErrorObj.dateError" class="error--text mb-2">
            * Error: {{planErrorObj.dateErrorMsg}}
          </div>
          <div class="mb-2" v-if="planErrorObj.showNote">
            {{planErrorObj.noteMsg}}
          </div>
          <div>
            <v-btn color="primaryCustom" class="mr-3 white--text" @click="[addNewCommissionPlan = false, savePlan(newCommissionPlan, 2, true)]"
                   :disabled="planErrorObj.dateError || !newCommissionPlan.id || !newCommissionPlan.startDate">
              Save
            </v-btn>
            <v-btn color="secondaryCustom" @click="addNewCommissionPlan = !addNewCommissionPlan">
              Cancel
            </v-btn>
          </div>
        </v-card>
        <v-divider v-if="addNewCommissionPlan"></v-divider>
        <v-data-table
            :headers="planHeaders"
            :items="closer.plans"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            single-expand
            :expanded.sync="expanded"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available plans
          </template>

          <template #no-results>
            No available plans
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="New End Date"
              />
              <label>Note:</label>
              <v-textarea filled class="mt-4"
                          v-model="item.note">
              </v-textarea>
              <v-btn :disabled="!item.endDate && !item.note"
                     @click="[expanded = [], savePlan(item, 2)]">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.description}}</td>
              <td class="text-left">{{item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{item.endDate | formatDate('date')}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <v-btn small text @click="[expanded = [item], selectedIndex = index]"
                       v-if="!expanded.includes(item) && userCanEdit">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="[expanded = [], selectedIndex = index]"
                       v-if="expanded.includes(item)">cancel
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Override Plans Assigned To
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanAdd"
                   @click="[overrideErrorObj = {}, addNewOverridePlan = !addNewOverridePlan,
                                newOverridePlan = {}, getOverridePlans()]">
              <v-icon v-if="addNewOverridePlan">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewOverridePlan" class="square-card text-left pa-5">
          <v-autocomplete v-model="newOverridePlan.id"
                          :items="overridePlans"
                          label="Select a Plan to Add This User"
                          item-text="name"
                          item-value="id"
                          autocomplete="new-password"
          />
          <DatetimePickerInput
            v-model="newOverridePlan.startDate"
            :timezone="this.timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="Start Date"
            @input="checkDates(newOverridePlan.startDate, newOverridePlan.endDate, closer.overrides, overrideErrorObj)"
          />
          <DatetimePickerInput
            v-model="newOverridePlan.endDate"
            :timezone="this.timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="End Date"
            @input="checkDates(newOverridePlan.startDate, newOverridePlan.endDate, closer.overrides, overrideErrorObj)"
          />
          <div v-if="overrideErrorObj.dateError" class="error--text mb-2">
            * Error: {{overrideErrorObj.dateErrorMsg}}
          </div>
          <div class="mb-2" v-if="overrideErrorObj.showNote">
            {{overrideErrorObj.noteMsg}}
          </div>
          <v-btn color="primaryCustom" class="mr-3 white--text"
                 @click="[addNewOverridePlan = false, savePlan(newOverridePlan, 1, true)]"
                 :disabled="overrideErrorObj.dateError || !newOverridePlan.id || !newOverridePlan.startDate">
            Save
          </v-btn>
          <v-btn color="secondaryCustom" @click="addNewOverridePlan = !addNewOverridePlan">
            Cancel
          </v-btn>
        </v-card>
        <v-divider v-if="addNewOverridePlan"></v-divider>
        <v-data-table
            :headers="overrideHeaders"
            :items="closer.overrides"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :expanded.sync="overrideExpanded"
            single-expand
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available overrides
          </template>

          <template #no-results>
            No available overrides
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="New End Date"
                  @input="checkDates(item.startDate, item.endDate, closer.overrides, item, item.id)"
              />
              <label>Note:</label>
              <v-textarea filled class="mt-4"
                          v-model="item.note">
              </v-textarea>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{item.dateErrorMsg}}
              </div>
              <div class="mb-2" v-if="item.showNote">
                {{item.noteMsg}}
              </div>
              <v-btn :disabled="(!item.endDate && !item.note) || item.dateError "
                     @click="[overrideExpanded = [], savePlan(item, 1)]">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.planName}}</td>
              <td class="text-left">{{item.planDescription}}</td>
              <td class="text-left">{{item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{item.endDate | formatDate('date')}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <v-btn small text @click="[overrideExpanded = [item], overrideSelectedIndex = index]"
                       v-if="!overrideExpanded.includes(item) && userCanEdit">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="[overrideExpanded = [], overrideSelectedIndex = index]"
                       v-if="overrideExpanded.includes(item)">cancel
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Receiving Override Plans
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanAdd"
                   @click="[addNewReceivingPlan = !addNewReceivingPlan, cloneOverridePlan = {}, getOverridePlans()]">
              <v-icon v-if="addNewReceivingPlan">remove</v-icon>
              <v-icon v-else>mdi-content-copy</v-icon>
            </v-btn>
            <v-btn text @click="addOverridePlan()" v-if="userCanAdd" >
              <v-icon>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewReceivingPlan" class="square-card text-left pa-5">
          <v-autocomplete v-model="cloneOverridePlan"
                          :items="overridePlans"
                          label="Select a Plan to Clone"
                          item-text="name"
                          item-value="id"
                          return-object
                          autocomplete="new-password"
          />
          <v-card flat v-if="cloneOverridePlan && cloneOverridePlan.id">
            <v-card-title>Receiving Users</v-card-title>
            <div v-for="ru in cloneOverridePlan.receivingUsers">
              <input type="checkbox" class="mr-2" v-model="ru.selected">
              {{ru.name}}
            </div>
          </v-card>
          <v-card flat v-if="cloneOverridePlan && cloneOverridePlan.id">
            <v-card-title>Assigned Users</v-card-title>
            <div v-for="ru in cloneOverridePlan.assignedusers">
              <input type="checkbox" class="mr-2" v-model="ru.selected">
              {{ru.name}}
            </div>
          </v-card>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="clonePlan()"
                 :disabled="!cloneOverridePlan.id">
            Clone
          </v-btn>
        </v-card>
        <v-data-table
            :headers="receivingHeaders"
            :items="closer.receiving"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :expanded.sync="receivingExpanded"
            single-expand
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available plans
          </template>

          <template #no-results>
            No available plans
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': receivingSelectedIndex % 2}">
              <label>Note:</label>
              <v-textarea filled class="mt-4"
                          v-model="item.note">
              </v-textarea>
              <v-btn :disabled="!item.endDate && !item.note" @click="[addNewReceivingPlan = false, savePlan(item, 3)]">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <v-btn small text @click="[receivingExpanded = [item], receivingSelectedIndex = index]"
                       v-if="!receivingExpanded.includes(item) && userCanEdit">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="[receivingExpanded = [], receivingSelectedIndex = index]"
                       v-if="receivingExpanded.includes(item)">cancel
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import moment from 'moment'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Commission',
    components: {

      DatetimePickerInput
    },
    created() {
      this.getCloserDetails()
    },
    data() {
      return {
        snackbar: {},
        planErrorObj: {},
        overrideErrorObj: {},
        dataLoading: true,
        overrideSelectedIndex: null,
        selectedIndex: null,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT'),
        receivingSelectedIndex: null,
        commissionPlans: [],
        timezone: this.$store.state.user.details.timezone.value,
        overridePlans: [],
        newCommissionPlan: {},
        newOverridePlan: {},
        cloneOverridePlan: {},
        addNewCommissionPlan: false,
        addNewOverridePlan: false,
        addNewReceivingPlan: false,
        userId: this.$route.params.id,
        expanded: [],
        overrideExpanded: [],
        receivingExpanded: [],
        overrideHeaders: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'Position', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: 'Notes', value: 'note', show: true},
          {text: '', value: 'icons', show: true},
        ],
        planHeaders: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: 'Notes', value: 'note', show: true},
          {text: '', value: 'icons', show: true},
        ],
        receivingHeaders: [
          {text: 'Plan Name', value: 'name', show: true},
          {text: 'Notes', value: 'note', show: true},
          {text: '', value: 'icons', show: true},
        ],
        closer: {}
      }
    },
    methods: {
      async getCloserDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/closerDetails/${this.userId}`, 'blueraven')
          this.closer = data ? data[0] : []
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading User Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCommissionPlans () {
        if(this.addNewCommissionPlan) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/commissionManagement/plans`, 'blueraven')
            this.commissionPlans = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Commission Plans')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async getOverridePlans () {
        if(this.addNewOverridePlan || this.addNewReceivingPlan) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/commissionManagement/overrides/active`, 'blueraven')
            this.overridePlans = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Override Plans')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      checkDates(startDate, endDate, plans, item, existingId) {
        //item = where to track the error
        item.dateError = false

        if(startDate > endDate) {
          item.dateError = true
          item.dateErrorMsg = 'End Date cannot be before Start Date'
        } else {
          let overlap = []
          let hasActivePlan = false
          plans.forEach(p => {
            if(this.dateRangeOverlap(startDate, endDate, p, existingId)) {
              overlap.push(p)
            }
            // if any plan doesn't have an end date, then there is an active plan
            if(!p.endDate) {
              hasActivePlan = true
            }
          })
          if(overlap.length > 0) {
            item.dateError = true
            item.dateErrorMsg = 'Plans Cannot Overlap'
          } else if(!existingId && startDate && hasActivePlan) {
            item.showNote = true
            item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
          }
        }
      },
      dateRangeOverlap(start, end, plan, existingId) {
        //this will not allow them to go back in time to add plans before existing plans which seems to be ok
        if(plan.id === existingId) {
          // ignore overlap check for self on existing record
          return false
        } else {
          //this is used when adding a new plan
          return start <= plan.startDate || start <= plan.endDate
        }
      },
      async savePlan (item, type, isNew) {
        let params = {
          userId: this.userId,
          startDate: item.startDate,
          endDate: item.endDate,
          note: item.note,
          m1Allocation: item.m1Allocation,
          m2Allocation: item.m2Allocation
        }
        let url = ''
        //override == 1, commission = 2, receiving === 3
        if(type === 1) {
          if(isNew) {
            url = `/commissionManagement/overrides/${item.id}/assignedUsers`
          } else {
            url = `/commissionManagement/overrides/${item.id}/updateUser`
          }
        } else if(type === 2) {
          if(isNew) {
            url = `/commissionManagement/${item.id}/users`
          } else {
            url = `/commissionManagement/${item.id}/updateUser`
          }
        } else {
            url = `/commissionManagement/overrides/${item.id}/receivingUser`
        }
        try {
          const {data} = await postRequest(url, params, 'blueraven')
          //reset fields as needed
          if(type === 1) {
            this.overrideExpanded = []
            this.addNewOverridePlan = false
            this.newOverridePlan = {}
            if(isNew) {
              this.closer.overrides = data
            }
          } else if (type === 2) {
            this.expanded = []
            this.newCommissionPlan = {}
            this.addNewCommissionPlan = false
            if(isNew) {
              this.closer.plans = data
            }
          } else {
            this.receivingExpanded = []
            this.addNewReceivingPlan = false
          }
          this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async clonePlan () {
        let params = {
          receivingUsers: this.cloneOverridePlan.receivingUsers.filter(r => r.selected).map(r => r.userId),
          assignedUsers: this.cloneOverridePlan.assignedUsers.filter(r => r.selected).map(r => r.userId),
          userId: this.userId,
          backdateApprovalCreds: null,
        }
        try {
          const {data} = await postRequest(`/commissionManagement/overrides/${this.cloneOverridePlan.id}/clone`, params, 'blueraven')
          this.$router.push({name: 'override', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Plan to User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addOverridePlan() {
        try {
          const {data} = await postRequest(`/commissionManagement/overrides`, {}, 'blueraven')
          this.addReceivingUserToOverridePlan(data.id)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Creating New Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addReceivingUserToOverridePlan(overridePlanId) {
        let params = {
          userId: this.userId,
          m1Allocation: 0,
          m2Allocation: 0,
        }
        try {
          const {data} = await postRequest(`/commissionManagement/overrides/${overridePlanId}/receivingUsers`, params, 'blueraven')
          this.$router.push({name: 'override', params: {id: overridePlanId}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User to Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
</style>

