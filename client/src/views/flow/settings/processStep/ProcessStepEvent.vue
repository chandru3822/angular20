<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">{{ selectedEvent.eventName }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
        <v-card class="pa-4">
          <v-autocomplete
            v-model="selectedEvent.initialCompanyEventStatusTypeId"
            :items="companyEventStatuses"
            label="Initial Event Status"
            item-text="eventStatusType"
            item-value="id"
          >
            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              {{ data.item.eventStatusType }} ({{ data.item.rootEventStatusType }})
            </template>
          </v-autocomplete>
          <v-btn class="white--text"
                 color="primaryButton"
                 @click="saveEventDetails(selectedEvent)"
          >Save</v-btn>
        </v-card>
      </v-col>

      <ProcessStepWorkQueueTypes v-if="!eventLoading && selectedEvent.id" :event="selectedEvent"></ProcessStepWorkQueueTypes>

      <ProcessStepRequirements :callback="populateRequirements" :event-requirements="true"></ProcessStepRequirements>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Event Actions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNewEventAction = !addNewEventAction]" v-if="userCanAdd">
              <v-icon v-if="!addNewEventAction">add</v-icon>
              {{ addNewEventAction ? 'Cancel' : 'Add Action' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNewEventAction">
          <v-text-field text
                        label="Action Name"
                        v-model="newEventAction.actionName">
          </v-text-field>
          <v-autocomplete
            v-model="newEventAction.companyEventStatusTypeId"
            :items="companyEventStatuses"
            label="Change Event Status To"
            item-text="eventStatusType"
            item-value="id"
            clearable
          ></v-autocomplete>
          <v-autocomplete
            v-model="newEventAction.companyProcessStepStatusTypeId"
            :items="processStepStatuses"
            label="Change Process Step Status To"
            item-text="processStepStatusType"
            item-value="id"
            clearable
          >
            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
            </template>
          </v-autocomplete>
          <v-btn class="white--text"
                 color="primaryButton"
                 @click="saveEventAction(newEventAction)"
                 :disabled="!newEventAction.actionName || (!newEventAction.companyEventStatusTypeId && !newEventAction.companyProcessStepStatusTypeId)"
          >Add Action</v-btn>
        </v-card>
        <v-data-table
          v-if="!addNewEventAction"
          :headers="actionHeaders"
          :items="filterEventActions()"
          :items-per-page="-1"
          :sort-desc="[false]"
          :sort-by="['displayOrder']"
          :mobile-breakpoint="0"
          single-expand
          disable-sort
          :expanded.sync="expanded"
          hide-default-footer
          class="event-actions-table elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No actions for this event
          </template>

          <template #no-results>
            No actions for this event
          </template>

          <template #expanded-item="{ headers, item: action }">
            <td :colspan="headers.length" class="pa-4">
              <v-text-field text
                            label="Action Name"
                            v-model="action.actionName">
              </v-text-field>
              <v-autocomplete
                v-model="action.companyEventStatusTypeId"
                :items="companyEventStatuses"
                label="Change Event Status To"
                item-text="eventStatusType"
                item-value="id"
                clearable
              ></v-autocomplete>
              <v-autocomplete
                v-model="action.companyProcessStepStatusTypeId"
                :items="processStepStatuses"
                label="Change Process Step Status To"
                item-text="processStepStatusType"
                item-value="id"
                clearable
              >
                <template slot="item" slot-scope="data">
                  <!-- HTML that describes how select should render items when the select is open -->
                  {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                </template>
              </v-autocomplete>

              <v-card flat class="pb-5">
                <table>
                  <tr>
                    <td>Require Start Time</td>
                    <td><input type="checkbox" class="ml-2" checked disabled readonly></td>
                  </tr>
                  <tr>
                    <td>Require End Time</td>
                    <td><input type="checkbox" class="ml-2" v-model="action.requireEndTime"></td>
                  </tr>
                  <tr>
                    <td>Require Resource</td>
                    <td><input type="checkbox" class="ml-2" v-model="action.requireResource"></td>
                  </tr>
                  <tr>
                    <td class="pt-3">Allow Multiple Uses</td>
                    <td class="pt-3"><input type="checkbox" class="ml-2" v-model="action.multipleUses"></td>
                  </tr>
                  <tr>
                    <td>Hide From Web</td>
                    <td><input type="checkbox" class="ml-2" v-model="action.hideFromWeb"></td>
                  </tr>
                  <tr>
                    <td>Hide From Mobile</td>
                    <td><input type="checkbox" class="ml-2" v-model="action.hideFromMobile"></td>
                  </tr>
                </table>
              </v-card>

              <!--              <v-btn class="white&#45;&#45;text"-->
              <!--                     color="primaryButton"-->
              <!--                     @click="saveEventAction(action)"-->
              <!--              >Save Action</v-btn>-->

              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Current Logic</v-toolbar-title>
                <v-spacer></v-spacer>
                <v-toolbar-items
                  v-if="((action.processStepEventLogicList && action.processStepEventLogicList.length > 0) || action.alwaysEnabled) && userCanEdit">
                  <v-btn text
                         @click="[action.logicListChanged = true, action.processStepEventLogicList = [], action.alwaysEnabled = false]">
                    <v-icon>clear</v-icon>
                    Clear All
                  </v-btn>
                </v-toolbar-items>
              </v-toolbar>
              <v-card flat class="text-left px-3" color="transparent">
                <v-btn small class="ml-1 mr-1 mt-1"
                       :disabled="!userCanEdit"
                       v-for="(l, index) in filterBy(action.processStepEventLogicList, false, 'archived')" :key="index"
                       @click="[l.archived = true, action.logicListChanged = true]">
                  {{ l.processStepEventRequirementId ? l.requirementNbr : l.operationType }}
                </v-btn>
                <v-btn small class="ml-1 mr-1 mt-1" v-if="action.alwaysEnabled"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.alwaysEnabled = !action.alwaysEnabled]">
                  Always Enabled
                </v-btn>
              </v-card>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Available Operations</v-toolbar-title>
              </v-toolbar>
              <v-card flat class="text-left px-3" color="transparent">
                <v-btn small class="ml-1 mr-1 mt-1" v-for="(ot, index) in operationTypes" :key="index"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.alwaysEnabled = false, action.processStepEventLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})]">
                  {{ ot.operationType }}
                </v-btn>
                <v-btn small class="ml-1 mr-1 mt-1"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.processStepEventLogicList = [], action.alwaysEnabled = true]">
                  Always Enabled
                </v-btn>
              </v-card>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
              </v-toolbar>
              <v-card flat class="text-left mb-4 px-3" color="transparent">
                <v-btn small class="ml-1 mr-1 mt-1" v-for="r in selectedEvent.requirements" :key="r.id"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.alwaysEnabled = false, action.processStepEventLogicList.push({ requirementNbr: r.requirementNbr, processStepEventRequirementId: r.id, archived: false })]">
                  {{ r.requirementNbr }}
                </v-btn>
              </v-card>
              <v-divider></v-divider>
              <div v-if="actionLogicError" class="error-text ml-3 mt-3">
                <strong>* ERROR: </strong>{{ actionLogicErrorMsg }}
              </div>
              <v-btn v-if="userCanEdit" class="mt-4 ml-3 mb-4"
                     :disabled="!action.actionName || (!action.companyProcessStepStatusTypeId && !action.companyEventStatusTypeId)"
                     @click="validateActionLogicString(action, true)" >
                <v-icon class="mr-2">save</v-icon>
                Save Changes
              </v-btn>

              <v-toolbar flat>
                <v-toolbar-title class="app-title">Event Custom Fields</v-toolbar-title>
              </v-toolbar>
              <v-data-table
                :headers="eventActionFieldHeaders"
                :items="filteredCustomFields(action)"
                disable-sort
                :items-per-page="-1"
                :mobile-breakpoint="0"
                hide-default-footer
                class="elevation-1 fix-column-width-bug square-card"
              >
                <template #no-data>
                  No custom fields for this event
                </template>

                <template #no-results>
                  No custom fields for this event
                </template>

                <template #item="{ item, index }">
                  <tr :class="{'shaded-row': index % 2}">
                    <td class="text-left"><strong>{{item.groupName}}:</strong> {{item.fieldName}}</td>
                    <td class="text-center">
                      <v-checkbox type="checkbox" class="ml-2" v-model="item.required"
                                  :key="requiredKey"
                                  @click="alterRequiredFlag(true, item, action.id)"/>
                    </td>
                    <td class="text-center">
                      <v-checkbox class="ml-2" v-model="item.optional"
                                  :key="optionalKey"
                                  @click="alterRequiredFlag(false, item, action.id)"/>
                    </td>
                  </tr>
                </template>
              </v-data-table>
            </td>
          </template>

          <template #item="{ item: action, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text v-if="userCanEdit" icon small class="handle">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">{{action.actionName}}</td>
              <td class="text-left">{{action.eventStatusType || 'N/A'}}</td>
              <td class="text-left">{{action.processStepStatusType || 'N/A'}}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn text @click="[expanded = [action]]" v-if="!expanded.includes(action)">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn text @click="expanded = []" v-else>cancel
                  </v-btn>
                  <v-dialog
                    v-if="userCanEdit"
                    v-model="action.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this event action?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="action.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteActionFromEvent(action)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepRequirements from "@/views/flow/settings/processStep/ProcessStepRequirements";
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import ProcessStepWorkQueueTypes from './ProcessStepWorkQueueTypes'

  export default {
    name: 'ProcessStepEvent',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepRequirements,
      ProcessStepWorkQueueTypes
    },
    mounted() {
      let table = document.querySelector('.event-actions-table tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({newIndex, oldIndex}) {
          const rowSelected = _self.selectedEvent?.processStepEventActions.splice(oldIndex, 1)[0]
          _self.selectedEvent?.processStepEventActions.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.selectedEvent?.processStepEventActions)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if (save) {
              let rows = _self.selectedEvent?.processStepEventActions
              rows[idx].newDisplayOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      })
    },
    data() {
      return {
        snackbar: {},
        companyEventStatuses: [],
        processStepStatuses: [],
        newEventStatuses: [],
        selectedEvent: {
          processStepEventActions: []
        },
        expanded: [],
        eventLoading: true,
        addNewEventAction: false,
        newEventAction: {},
        addRequiredField: false,
        addOptionalField: false,
        requiredKey: 0,
        optionalKey: 0,
        eventCustomFields: [],
        requiredFieldCfga: null,
        optionalFieldCfga: null,
        actionHeaders: [
          {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
          {text: 'Action Name', value: 'actionName', show: true},
          {text: 'Change Event Status To', value: 'companyEventStatusType', show: true},
          {text: 'Change Process Step Status To', value: 'companyProcessStepStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        processStepId: this.$route.params.id,
        eventId: parseInt(this.$route.params.eventId),
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        eventActionFieldHeaders: [
          {text: 'Field', value: 'fieldName', show: true},
          {text: 'Required', value: 'required', width: '75px', show: true},
          {text: 'Optional', value: 'groupName', width: '75px', show: true},
        ],
        // actionLogic stuff
        operationTypes: [],
        actionLogicError: false,
        actionLogicErrorMsg: '',
        invalidTypeCombos: [
          '1,2', // open and close paren next to each other
          '2,1', // close then open paren next to each other -- right, this isn't valid? `(8)(17)`
          '0,0', // two requirements right next to each other
          '3,4', // AND OR next to each other
          '1,3', // open paren then AND
          '1,4', // open paren then OR
          '5,2', // not then close paren
          '5,3', // not then and
          '5,4', // not then or
          '3,3', // and and
          '4,4', // or or
          '5,5', // not not
          '0,5', // requirement then not ...needs and/or in between
        ],
        //doing these as strings since the filtered list will be too
        invalidFirsts: ['2', '3', '4'],
        invalidLasts: ['1', '3', '4', '5']
      }
    },
    computed: {},
    async created() {
      //get event details
      this.getCompanyProcessStepStatuses()
      await this.getEventDetails()
      this.getAssignedEventStatusTypes()
      this.getOperationTypes()
    },
    methods: {
      //populate requirements so that events can use them any time they change from the requirements component
      populateRequirements(reqs) {
        this.selectedEvent.requirements = reqs
      },
      async getEventDetails() {
        try {
          this.eventLoading = true
          const {data} = await getRequest(`/processStep/${this.processStepId}/event/${this.eventId}`)
          this.selectedEvent = data
          this.eventLoading = false
        } catch (e) {
          this.eventLoading = true
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.companyStatusesLoading = false
        }
      },
      async getAssignedEventStatusTypes() {
          try {
            const {data} = await getRequest(`/event/${this.selectedEvent.eventId}/status`)
            this.companyEventStatuses = data
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.companyStatusesLoading = false
          }
      },
      async getCompanyProcessStepStatuses() {
        try {
          const {data} = await getCompanyAssignedToProcessStep(this.processStepId)
          this.processStepStatuses = data
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          logError(e)
        }
      },
      filterEventActions() {
        // return this.selectedEvent?.processStepEventActions.filter(e => {
        //   return !e.archived
        // })
        return orderBy(this.selectedEvent?.processStepEventActions.filter(psea => { return !psea.archived}), [psea => psea.displayOrder])
      },
      async saveEventDetails(psEvent) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/event/${psEvent.eventId}`, psEvent)
          this.snackbar = getSnackbar('SUCCESS', 'Event Updated')
          this.expanded = []
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteActionFromEvent(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${action.id}`)
          action.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveEventAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action`, action)
          if(!action.id) {
            this.addNewEventAction = false
            this.newEventAction = {}
            this.selectedEvent.processStepEventActions.push(data)
          } else {
            action.eventStatusType = data.eventStatusType
            action.processStepStatusType = data.processStepStatusType
          }
          this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      validateActionLogicString(item, saveChanges) {
        // using 0 to represent a logic item using a requirement
        // 1 = (  2 = )  3 = AND  4 = OR  5 = NOT

        //filter the logic list to exclude any archived
        let nonArchivedLogic = item.processStepEventLogicList?.filter(l => !l.archived)

        //compare number of open vs closing paren (probably not a perfect check but catches a lot)
        let countOpenParen = nonArchivedLogic?.filter(l => l.operationTypeId === 1)?.length
        let countCloseParen = nonArchivedLogic?.filter(l => l.operationTypeId === 2)?.length

        //get the type ids so we can loop through them and count parens as we go
        let operationTypeIds = nonArchivedLogic?.map(l => l.operationTypeId ?? 0)
        let openCount = 0, closeCount = 0, parenProblem = false

        //this part checks the parens more closely based on the order they appear in
        operationTypeIds?.forEach(id => {
          if (id === 1) {
            openCount++
          } else if (id === 2) {
            closeCount++
          }
          //after each id, check if close > open. if so, there is a problem
          if (closeCount > openCount) {
            parenProblem = true
          }
        })

        // turn the operation type ids into a string we can compare to invalid sequences
        let operationTypeString = operationTypeIds?.toString()

        // get the first and last operations to compare to invalid first and last options
        let firstOperationTypeId = operationTypeString?.charAt(0)
        let lastOperationTypeId = operationTypeString?.slice(-1)

        if (countOpenParen !== countCloseParen || parenProblem) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Logic is missing opening or closing parenthesis.'
        } else if (this.invalidTypeCombos.some(v => operationTypeString?.includes(v))) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Logic is invalid.'
        } else if (this.invalidFirsts.includes(firstOperationTypeId)) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Invalid first logic operation.'
        } else if (this.invalidLasts.includes(lastOperationTypeId)) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Invalid last logic operation.'
        } else {
          this.actionLogicError = false
          this.actionLogicErrorMsg = ''
          if (saveChanges) {
            this.updateAction(item)
          }
        }
      },
      async getOperationTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/operation`)
          this.operationTypes = orderBy(data, [o => o.operationType.toLowerCase()])
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          action.processStepEventLogicList = action.processStepEventLogicList.filter(l => {
            return !l.archived
          })

          // build the list of psr's that need to be set to immutable  do that if the save is successful
          const psrListToUpdate = action.processStepEventLogicList.filter(l => {
            return l.processStepEventRequirementId && !l.processStepRequirementImmutable
          })

          const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.eventId}/action`, action)
          // this forces the list to update the values displayed ... using action = data did not work
          action.actionType = data.actionType
          action.processStepStatusType = data.processStepStatusType
          action.processStepEventLogicList = data.processStepEventLogicList
          action.triggerAutomatically = data.triggerAutomatically
          this.actionExpanded = []

          //update the necessary psr's to immutable
          if (psrListToUpdate.length > 0) {
            psrListToUpdate.forEach(psr => {
              let match = this.selectedEvent.requirements.find(r => r.id === psr.processStepEventRequirementId)
              match.immutable = true
            })
          }

          this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async alterRequiredFlag(requiredChanged, item, actionId) {
        //flip the flags as they change
        if(requiredChanged && item.required) {
          item.optional = false
          this.optionalKey++
        } else if (!requiredChanged && item.optional) {
          item.required = false
          this.requiredKey++
        }

      try {
        const {data} = await putRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${actionId}`, item)
        //resetting the id in case it got archived/added a new one, etc. this will keep multiple updates to the same field working without refreshing the screen
        item.id = data
        this.snackbar = getSnackbar('SUCCESS', 'Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/order`, rows)
          this.snackbar = getSnackbar('SUCCESS', 'Action Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Action Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
      filteredCustomFields(action) {
        return action.customFields.filter(cf => {
          return cf.dataTypeId !== 12
        })
      }
  }

}
</script>

<style scoped lang="scss">
.required-field-label {
  width: 100px;
}
</style>
