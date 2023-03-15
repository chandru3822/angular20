<template>
  <v-container class="pa-0" id="residuals-container">
    <v-dialog v-model="showModal" class="square-card">
      <ResidualDetailModal :data="modalData"
                           :user-full-name="modalUserFullName"
                           @residualDetailModalClosed="showModal = false"
      ></ResidualDetailModal>
    </v-dialog>
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Residuals
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <!--        <v-btn text @click="goToDetails({})">-->
        <!--          <v-icon>add</v-icon>-->
        <!--        </v-btn>-->
      </v-toolbar-items>
    </v-toolbar>
    <v-toolbar v-if="!payrollLoading && !additionalPayrollDataNeeded" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title" :style="{'color': payrollStatus.textColor}">
        {{payrollStatus.message}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <v-btn v-if="payrollStatus.action && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')" :color="payrollStatus.actionColor"
                 class="white--text" @click="submitForApproval(payrollStatus.action)">
            {{payrollStatus.actionText}}
          </v-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
            v-if="payrollStatus.secondaryAction && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')"
            v-model="approveConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <v-btn v-on="on" :color="payrollStatus.secondaryActionColor" class="white--text ml-3">
                {{payrollStatus.secondaryActionText}}
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="text-h5 grey lighten-2"
                primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text class="pt-3">
                Are you sure you want to approve this residual?

                <DatetimePickerInput
                  v-model="payDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Date Paid"
                />
              </v-card-text>


              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="approveConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primary"
                  class="white--text"
                  :disabled="null == payDate"
                  @click="submitForApproval(payrollStatus.secondaryAction)">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-form ref="accountingForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat color="transparent" class="pa-3">
              <v-text-field text readonly label="Payroll ID #" v-model="currentResidual.id"></v-text-field>
              <DatetimePickerInput
                v-model="currentResidual.periodEnd"
                :timezone="this.timezone"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Period Ending"
              />
              <v-text-field text
                            label="Description"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="currentResidual.description"></v-text-field>

              <div class="text-left">
                <v-btn color="primary" dark v-if="userCanEdit" @click="saveChangesToResidual()">Save Changes</v-btn>
                <v-btn color="primary" class="ml-3" dark @click="exportResiduals()">Export</v-btn>
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-card-title>Project Override</v-card-title>
              <v-autocomplete v-model="projectId"
                              :items="projects"
                              :loading="projectsLoading"
                              :search-input.sync="projectSearch"
                              item-text="projectNameWithId"
                              label="Project..."
                              clearable
                              prepend-icon="search"
                              item-value="id"
                              autocomplete="off"
                              type="search"
                              @click:clear="projects = []"
                              attach
              >
                <template slot='item' slot-scope='{ item }'>
                  {{ item.projectName }} - {{ item.id }}
                </template>
              </v-autocomplete>
              <DatetimePickerInput
                v-model="projectOverrideDate"
                :timezone="this.timezone"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Override Date"
              />

              <div class="text-left">
                <v-btn color="primary"
                       :disabled="!projectId || !projectOverrideDate"
                       @click="saveOverrideDate()">Save</v-btn>
                <v-btn class="ml-3" text color="primary" @click="[projectId = null, projectSearch='', projects=[], projectOverrideDate = null]">Reset</v-btn>
              </div>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col class="pt-0">
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
            :headers="headers"
            :items="residuals"
            :fixed-header="true"
            :items-per-page="-1"
            :search="search"
            :show-select="payrollStatus.showSelect"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
          >
            <template #no-data>
              No available residuals
            </template>

            <template #no-results>
              No available residuals
            </template>

            <template v-slot:header.data-table-select="{ on, props }">
              <v-checkbox color="primary" v-model="selectAll" @change="toggleSelectAll()"></v-checkbox>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td v-if="payrollStatus.showSelect">
                  <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{item.firstName}}</td>
                <td class="text-left">{{item.lastName}}</td>
                <td class="text-left">{{item.employeeId}}</td>
                <td class="text-left">{{item.regionName}}</td>
                <td class="text-left">{{item.officeName}}</td>
                <td class="text-left">{{item.officeState}}</td>
                <td class="text-left">{{item.userPositionName}}</td>
                <td class="text-left">{{item.userStatusType}}</td>
                <td class="text-left">{{item.hireDate}}</td>
                <td class="text-left">{{item.userFullName}}</td>
                <td class="text-left">{{item.residualStartDate}}</td>
                <td class="text-left clickable">
                  <a @click="loadModalData(item, 1)">
                    {{item.lifetimeFdc}}
                  </a>
                </td>
                <td class="text-left">
                  <a @click="loadModalData(item, 2)">
                    {{item.qualifiedThisPeriodFdc}}
                  </a>
                </td>
                <td class="text-left">
                  <a @click="loadModalData(item, 3)">
                    {{item.fdsNotQualified}}
                  </a>
                </td>
                <td class="text-left">{{item.requiredFdcPerMonth}}</td>
                <td class="text-left">{{ item.residualEarned ? 'Yes' : 'No'}}</td>
                <td class="text-left">{{item.percentOfResidualEarned}}%</td>
                <td class="text-left">{{item.potentialResidual | currency('$', 0)}}</td>
                <td class="text-left">{{item.earnedResidual | currency('$', 0)}}</td>
                <td class="text-left">{{item.clawback | currency('$', 0)}}</td>
                <td class="text-left">
                  {{item.adjustmentOverride | currency('$', 0)}}

                  <v-dialog
                    v-if="userCanAdd"
                    v-model="item.dialog"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn x-small color="primary" dark fab class="ml-2" v-on="on"
                             @click="[delete item.adjustment, delete item.adjustmentNote]" >
                        <v-icon>add</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <v-text-field text
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      v-model.number="item.adjustment">
                        </v-text-field>
                        <v-textarea
                          label="Notes"
                          v-model="item.adjustmentNote"
                        ></v-textarea>
                      </v-card-text>
                      <v-divider></v-divider>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn @click="item.dialog = false">
                          Cancel
                        </v-btn>
                        <v-btn color="primary" class="white--text"
                               :disabled="!item.adjustment || item.adjustment === 0 || !item.adjustmentNote"
                               @click="addAdjustment(item)">
                          Add
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
                <td class="text-left">{{item.total | currency('$', 0)}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, getSnackbar, postRequest} from '@/helpers/helpers'
  import ResidualDetailModal from '@/views/blueraven/commissionManagement/ResidualDetailModal'
  import { saveAs } from 'file-saver'
  import sumBy from "lodash.sumby";
  import cloneDeep from 'lodash.clonedeep'

  export default {
    name: 'Residuals',
    components: {
      ResidualDetailModal
    },
    async created() {
      await this.getCurrentResidual()
      this.getResiduals()
    },
    watch: {
      projectSearch (val) {
        if(val === '') {
          this.projects = []
          this.projectId = null
          this.projectOverrideDate = null
          return
        } else if (val != null && !val.includes(' - ')) {
          this.projects = []
          this.getProjectsDebounced(val)
        }
      },
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        search: '',
        currentResidual: {},
        payrollStatus: {},
        projects: [],
        projectId: null,
        projectOverrideDate: null,
        projectSearch: '',
        projectsLoading: false,
        selectAll: false,
        approveConfirm: false,
        payDate: null,
        additionalPayrollDataNeeded: false,
        payrollLoading: true,
        masterSelectedUserIds: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT'),
        timezone: this.$store.state.user.details.timezone.value,
        showModal: false,
        modalUserFullName: '',
        modalData: [],
        headers: [
          {text: 'User First Name', value: 'firstName', show: true},
          {text: 'User Last Name', value: 'lastName', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Region', value: 'regionName', show: true},
          {text: 'Org Name', value: 'officeName', show: true},
          {text: 'Org State', value: 'officeState', show: true},
          {text: 'User Position', value: 'userPositionName', show: true},
          {text: 'User Status', value: 'userStatusType', show: true},
          {text: 'Hire Date', value: 'hireDate', show: true},
          {text: 'Usable Name', value: 'userFullName', show: true},
          {text: 'Residual Start Date', value: 'residualStartDate', show: true},
          {text: 'LTD Qualified FDS', value: 'lifetimeFdc', show: true},
          {text: 'Qualified FDS This Period', value: 'qualifiedThisPeriodFdc', show: true},
          {text: 'FDS Not Qualified This Period', value: 'fdsNotQualified', show: true},
          {text: 'Required FDS for Month', value: 'requiredFdcPerMonth', show: true},
          {text: 'Residual Earned', value: 'residualEarned', show: true},
          {text: '% of Residual Earned', value: 'percentOfResidualEarned', show: true},
          {text: 'Potential Residual', value: 'potentialResidual', show: true},
          {text: 'Earned Residual', value: 'earnedResidual', show: true},
          {text: 'Clawback', value: 'clawback', show: true},
          {text: 'Adjustment/Override', value: 'adjustmentOverride', show: true},
          {text: 'Total', value: 'total', show: true},
        ],
        residuals: []
      }
    },
    methods: {
      toggleSelectAll () {
        this.residuals.forEach(ad => {
          ad.selected = this.selectAll
        })
        if(this.selectAll) {
          this.currentResidual.selectedUserIds = this.residuals.map(ad => ad.userId)
        } else {
          this.currentResidual.selectedUserIds = []
        }
      },
      toggleSingleSelect(item) {
        if(item.selected) {
          this.currentResidual.selectedUserIds.push(item.userId)
        } else {
          this.currentResidual.selectedUserIds = this.currentResidual.selectedUserIds.filter(p => p !== item.userId)
        }
      },
      async getResiduals () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {}
          if(this.currentResidual?.status !== 'PENDING' && this.currentResidual?.status !== 'REJECTED') {
            params.selectedUserIds = this.currentResidual.selectedUserIds
          }

          const {data, status} = await getRequest(`/commissionManagement/residuals`, 'blueraven')
          this.residuals = data
          this.residuals.forEach(d => {
            d.selected = !!this.currentResidual.selectedUserIds?.includes(d.userId)
          })

          if(this.currentResidual?.selectedUserIds?.length === data.length) {
            this.selectAll = true
          }

          this.totalPay = sumBy(this.residuals,  function(o) { return o.selected ? o.current_pay : 0 })

          this.residuals = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Residuals')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addAdjustment (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: item.userId,
            amount: item.adjustment,
            note: item.adjustmentNote
          }
          await postRequest(`/payroll/residual/${this.currentResidual.id}/adjustments`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Adjustment Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          await this.getResiduals()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Adjustment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getProjectsDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getProjects(val)
        }, 500) /* 500ms throttle */
      },
      async getProjects (search) {
        try {
          const {data, status} = await getRequest(`/commissionManagement/residuals/projects?search=${search}`, 'blueraven')
          this.projects = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOverrideDate () {
        try {
          let params = {
            overrideDate: this.projectOverrideDate,
            projectId: this.projectId
          }
          const {data, status} = await postRequest(`/commissionManagement/residuals/projectOverride`, params, 'blueraven')
          this.projectId = null
          this.projectSearch = null
          this.projects = []
          this.projectOverrideDate = null
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = e?.data?.message || 'Error Loading Data'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadModalData (residualItem, typeId) {
        //typeId: 1 = lifetime qualified, 2 = qualified fds in period, 3 = fds not qualified this period
        this.showModal = false
        this.modalData = []
        this.modalUserFullName = ''
        try {
          let url = typeId === 1 ? `/commissionManagement/residuals/qualifiedLifetime/${residualItem.userId}` :
                    typeId === 2 ? `/commissionManagement/residuals/qualifiedPeriod/${residualItem.userId}` :
                      `/commissionManagement/residuals/notQualifiedPeriod/${residualItem.userId}`

          const {data, status} = await getRequest(url, 'blueraven')
          this.modalData = data
          this.modalUserFullName = residualItem.userFullName
          this.showModal = true
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCurrentResidual () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/payroll/residual/current`, 'blueraven', [])
          this.currentResidual = data

          this.masterSelectedUserIds = cloneDeep(this.currentResidual.userIds)
          this.getStatusColor()
          this.payrollLoading = false
          this.additionalPayrollDataNeeded = null == this.currentResidual.periodEnd || null == this.currentResidual.description
          // if(null != this.currentPayroll.periodEnd) {
          //   await this.getAccountingData()
          // } else {
          //   this.dataLoading = false
          //   this.accountingData = []
          // }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Current Payroll')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async submitForApproval (action) {
        //to avoid any unsaved changes prior to approval we are just saving changes prior to submitting
        const val = await this.saveChangesToResidual(true)
        //dont submit for approval if the save changes request failed
        if(val) {
          this.totalPay = sumBy(this.residuals,  function(o) { return o.selected ? o.current_pay : 0 })
          let selectedIds = this.residuals.filter(ad => ad.selected).map(ad => ad.userId)
          let params = {
            payDate: this.payDate
          }
          if(this.payrollStatus.showSelect && (!selectedIds || selectedIds.length === 0)) {
            this.snackbar = getSnackbar('WARNING', 'You must select at least one user.')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.$store.commit(AppMutations.SET_LOADING, true)
            try {
              await postRequest(`/payroll/residual/${this.currentResidual.id}/${action}`, params, 'blueraven')
              this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              //todo: reload residuals after approving
              await this.getCurrentResidual()
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error Updating')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        }
      },
      getStatusColor () {
        this.payrollStatus = {}
        switch(this.currentResidual.status) {
          case 'PENDING':
            this.payrollStatus.message = 'This payroll is pending.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primary'
            break
          case 'SUBMITTED':
            this.payrollStatus.message = 'This payroll has been Submitted.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = false
            this.payrollStatus.action = 'reject'
            this.payrollStatus.actionText = 'Reject'
            this.payrollStatus.actionColor = 'error'
            this.payrollStatus.secondaryAction = 'approve'
            this.payrollStatus.secondaryActionText = 'Approve'
            this.payrollStatus.secondaryActionColor = 'green'
            break
          case 'REJECTED':
            this.payrollStatus.message = 'This payroll has been Rejected.'
            this.payrollStatus.color = 'error'
            this.payrollStatus.textColor = 'white'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primary'
            break
          default:
            this.payrollStatus = {}
        }
      },
      async saveChangesToResidual (keepLoading) {
        let params = {
          description: this.currentResidual.description,
          periodEnd: this.currentResidual.periodEnd,
          userIds: this.currentResidual.selectedUserIds
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/payroll/residual/${this.currentResidual.id}`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.currentResidual = data
          this.totalPay = sumBy(this.accountingData,  function(o) { return o.selected ? o.current_pay : 0 })
          this.additionalPayrollDataNeeded = null == this.currentResidual.periodEnd || null == this.currentResidual.description
          this.getStatusColor()
          if(null != this.currentResidual.periodEnd) {
            await this.getCurrentResidual()
          } else {
            this.dataLoading = false
            this.accountingData = []
          }
          if(!keepLoading) {
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          return true
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return false
        }
      },
      async exportResiduals () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'Residuals.csv';
          let csvData = 'User First Name,User Last Name,Employee ID,Region,Org Name,Org State,User Position,User Status,Hire Date,Usable Name,Residual Start Date,LTD Qualified FDS,Qualified FDS This Period,FDS Not Qualified This Period,Required FDS for Month,Residual Earned, % of Residual Earned,Potential Residual,Earned Residual,Clawback,Adjustment/Override,Total';
          csvData += '\n';

          this.residuals.forEach(p => {
              csvData +=
                p.firstName + ',"' +
                p.lastName + '",' +
                p.employeeId + ',"' +
                p.regionName + '",' +
                "\"" + p.officeName + '\",' +
                p.officeState + ',' +
                p.userPositionName + ',"' +
                p.userStatusType + '",' +
                p.hireDate + ',' +
                p.userFullName + ',' +
                p.residualStartDate + ',' +
                p.lifetimeFdc + ',' +
                p.qualifiedThisPeriodFdc + ',' +
                p.fdsNotQualified + ',' +
                p.requiredFdcPerMonth + ',' +
                p.residualEarned + ',' +
                p.percentOfResidualEarned + ',"' +
                p.potentialResidual + '",' +
                p.earnedResidual + ',' +
                p.clawback + ',' +
                p.adjustmentOverride + ',' +
                p.total
              csvData += '\n';
          })

          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });

          saveAs(blob, filename);
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Residuals')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
  #residuals-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

