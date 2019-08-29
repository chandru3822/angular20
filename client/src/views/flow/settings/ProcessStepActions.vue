<template>
  <v-layout row wrap>
    <v-flex xs-12>
      <v-toolbar flat>
        <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn @click="getRequirementTypes" text>
            <v-icon v-if="!addNewRequirement">add</v-icon>
            {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container v-if="addNewRequirement">
        <!--  TODO: need to protect against bad data when they go back and change the requirement type but have already selected other values lower in the form      -->
        <v-select v-model="newRequirement.processStepRequirementTypeId"
                  :items="availableRequirementTypes"
                  label="Select Requirement Type"
                  item-value="id"
                  item-text="processStepRequirementType"
                  @input="selectRequirementType"
        ></v-select>
        <!-- if it is a custom field -->
        <v-select v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 1"
                  v-model="parent"
                  :items="parentObjects"
                  label="Parent Object"
                  item-text="processStepName"
                  return-object
                  @input="loadFieldsByParent"
        ></v-select>
        <v-select v-if="parent.id"
                  v-model="newRequirement.customFieldGroupId"
                  :items="customFields"
                  label="Custom Field"
                  item-text="fieldName"
                  item-value="customFieldGroupId"
        ></v-select>
        <!-- if it is a function -->
        <v-select v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"
                  v-model="newRequirement.companyFunctionId"
                  :items="availableFunctions"
                  label="Function"
                  item-text="companyFunctionName"
                  item-value="id"
                  @input="loadFunctionParams"
        ></v-select>
        <div v-if="newRequirement.companyFunctionId && newRequirement.functionParams.length > 0">
          <h5 class="text-left">Default Function Parameters</h5>
          <v-container>
            <v-text-field
                v-for="fp in newRequirement.functionParams"
                placeholder="Enter a default value"
                v-model="fp.defaultValue"
                :label="fp.parameterName"></v-text-field>
          </v-container>
        </div>
        <v-select v-if="(newRequirement.processStepRequirementTypeId === 1 && newRequirement.customFieldGroupId) || (newRequirement.processStepRequirementTypeId === 2 && newRequirement.companyFunctionId)"
                  v-model="newRequirement.operatorTypeId"
                  :items="operatorTypes"
                  label="Operator"
                  item-text="operatorType"
                  item-value="id"
        ></v-select>
        <v-text-field v-if="newRequirement.operatorTypeId"
                      v-model="newRequirement.requirementValue"
                      placeholder="Enter a value"
                      label="Value">
        </v-text-field>
        <v-btn :disabled="validateRequirementForm()"
               @click="saveNewRequirement">
          <v-icon>save</v-icon>
          Save
        </v-btn>
      </v-container>
      <v-container>
        <v-data-table
            :headers="headers"
            :items="filterRequirements()"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug"
        >
          <template #no-data>
            No requirements for this process step
          </template>

          <template #no-results>
            No requirements for this process step
          </template>

<!--          <template v-slot:expanded-item="{ headers, item }">-->
<!--            <td :colspan="headers.length">Peek-a-boo!</td>-->
<!--          </template>-->

          <template #expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4">
                <v-select v-model="item.operatorTypeId"
                          :items="operatorTypes"
                          class="one-hunned"
                          label="Operator"
                          item-text="operatorType"
                          item-value="id"
                ></v-select>
                <v-text-field v-model="item.requirementValue"
                              placeholder="Enter a value"
                              label="Value">
                </v-text-field>
                <v-btn @click="updateRequirement(item)">
                  <v-icon>save</v-icon>
                  Save
                </v-btn>
              </td>
          </template>

          <template #item.custom="{ item }">
            <span v-if="item.processStepRequirementTypeId === 1">
              {{ item.parentName }} | {{ item.fieldName }}
            </span>
            <span>
              {{ item.companyFunctionName }}
            </span>

          </template>
          <template #item.icons="{ item }">
            <div style="display: flex;">
              <v-btn small text @click="expanded = [item]" v-if="!expanded.includes(item)">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn small text @click="expanded = []" v-if="expanded.includes(item)">cancel</v-btn>
              <v-dialog
                  v-model="item.deleteConfirm"
                  width="500">
                <template #activator="{ on }">
                  <v-btn small text v-on="on">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this requirement?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="item.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="item.archived = true; deleteRequirement(item.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </div>
          </template>
        </v-data-table>
      </v-container>
    </v-flex>
    <v-divider></v-divider>
    <v-flex xs-12>
      <v-toolbar flat>
        <v-toolbar-title class="app-title">Actions</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn @click="addNewAction = !addNewAction" text>
            <v-icon v-if="!addNewAction">add</v-icon>
            {{ addNewAction ? 'Cancel' : 'Add Action'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container v-if="addNewAction">
        <v-text-field v-model="newAction.actionName"
                      placeholder="Enter a name"
                      label="Action Name">
        </v-text-field>
        <v-select v-model="newAction.actionTypeId"
                  :items="actionTypes"
                  label="Action Type"
                  item-text="actionType"
                  item-value="id"
                  @input=""
        ></v-select>
        <v-select v-model="newAction.processStepStatusTypeId"
                  :items="statusTypes"
                  label="Action changes status of parent process step to"
                  item-text="processStepStatusType"
                  item-value="id"
                  @input=""
        ></v-select>
        <v-btn v-if="newAction.actionName && newAction.processStepStatusTypeId && newAction.actionTypeId"
               @click="saveNewAction">
          <v-icon>save</v-icon>
          Save
        </v-btn>
      </v-container>
      <v-container>
        <v-data-table
            :headers="actionHeaders"
            :items="filterActions()"
            :items-per-page="-1"
            single-expand
            :expanded.sync="actionExpanded"
            hide-default-footer
            class="elevation-1 fix-column-width-bug"
        >
          <template #no-data>
            No actions for this process step
          </template>

          <template #no-results>
            No actions for this process step
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="actionHeaders.length" class="pb-4">
              <v-container>
                <v-text-field v-model="item.actionName"
                              placeholder="Enter a name"
                              label="Action Name">
                </v-text-field>
                <v-select v-model="item.actionTypeId"
                          :items="actionTypes"
                          label="Action Type"
                          item-text="actionType"
                          item-value="id"
                          @input=""
                ></v-select>
                <v-select v-model="item.processStepStatusTypeId"
                          :items="statusTypes"
                          label="Action changes status of parent process step to"
                          item-text="processStepStatusType"
                          item-value="id"
                          @input=""
                ></v-select>
              </v-container>
              <v-divider></v-divider>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Current Logic</v-toolbar-title>
                <v-spacer></v-spacer>
                <v-toolbar-items>
                  <v-btn text @click="item.processStepLogicList = []">
                    <v-icon>clear</v-icon>
                    Clear All
                  </v-btn>
                </v-toolbar-items>
              </v-toolbar>
              <v-container class="text-left">
                <v-btn small class="ml-1 mr-1 mt-1" v-for="(l, index) in filterBy(item.processStepLogicList, false, 'archived')" :key="index"
                       @click="l.archived = true">
                  {{l.processStepRequirementId ? l.processStepRequirementId : l.operationType}}
                </v-btn>
              </v-container>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Available Operations</v-toolbar-title>
              </v-toolbar>
              <v-container class="text-left">
                <v-btn small class="ml-1 mr-1 mt-1" v-for="ot in operationTypes"
                    @click="item.processStepLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})">
                  {{ot.operationType}}
                </v-btn>
              </v-container>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
              </v-toolbar>
              <v-container class="text-left mb-4">
                <v-btn small class="ml-1 mr-1 mt-1" v-for="r in requirements"
                    @click="item.processStepLogicList.push({ processStepRequirementId: r.id, archived: false })">
                  {{r.requirementNbr}}
                </v-btn>
              </v-container>
              <v-divider></v-divider>
              <v-btn @click="updateAction(item)" class="mt-4">
                <v-icon class="mr-2">save</v-icon>
                Save Changes
              </v-btn>
            </td>
          </template>

          <template #item.icons="{ item }">
            <div style="display: flex;">
              <v-btn small text @click="actionExpanded = [item]" v-if="!actionExpanded.includes(item)">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn small text @click="actionExpanded = []" v-if="actionExpanded.includes(item)">cancel</v-btn>
              <v-dialog
                  v-model="item.deleteConfirm"
                  width="500">
                <template #activator="{ on }">
                  <v-btn small text v-on="on">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this action?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="item.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="item.archived = true; deleteAction(item)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </div>
          </template>

        </v-data-table>
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import {AppMutations} from '@/stores/AppStore'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'

  export default {
    name: 'ProcessStepActions',
    mixins: [Vue2Filters.mixin],
    components: {},
    data () {
      return {
        headers: [
          { text: 'ID', value: 'requirementNbr', width: '65px', show: true },
          { text: 'Type', value: 'processStepRequirementType', show: true },
          { text: 'Details', value: 'custom', show: true},
          { text: 'Operator', value: 'operatorType', show: true },
          { text: 'Value', value: 'requirementValue', show: true },
          { text: null, value: 'icons', show: true }
        ],
        actionHeaders: [
          { text: 'Name', value: 'actionName', show: true },
          { text: 'Type', value: 'actionType', show: true },
          { text: 'Parent Status Change', value: 'processStepStatusType', show: true },
          { text: null, value: 'icons', show: true }
        ],
        addNewRequirement: false,
        newRequirement: {
          functionParams: []
        },
        availableRequirementTypes: [],
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        parentObjects: [],
        parent: {},
        customFields: [],
        operatorTypes: [],
        operationTypes: [],

        requirements: [],
        availableFunctions: [],


        addNewAction: false,
        newAction: {},
        actions: [],
        statusTypes: [],
        expanded: [],
        actionExpanded: [],
        //todo: get these from endpoint but i am lazy right now
        actionTypes: [
          {id: 1, actionType: 'Link'},
          {id: 2, actionType: 'Button'}
        ]
      }
    },
    computed: {},
    async created () {
      this.getRequirements()
      this.getActions()
      this.getStatusTypes()
      this.getOperationTypes()
      this.loadOperatorTypes()
    },
    methods: {
      //requirements
      async getRequirements() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/requirement`)
        this.requirements = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      filterRequirements () {
        return this.requirements.filter(r => { return !r.archived})
      },
      async getRequirementTypes () {
        this.addNewRequirement = !this.addNewRequirement
        if (this.addNewRequirement){
          const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/requirement/types`)
          this.availableRequirementTypes = data
        }
      },
      async selectRequirementType() {
        //1 == custom field, 2 == function
        if(this.newRequirement.processStepRequirementTypeId === 1){
          const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/getParentObjects`, { params: { id: this.processStepId}})
          this.parentObjects = data
        } else {
          const {data} = await getRequest(`/api/v1/flow/${this.companyId}/function`)
          this.availableFunctions = data
        }
      },
      async loadFieldsByParent() {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customField/getByParentProcessStep/${this.parent.id}`)
        this.customFields = data
      },
      async loadFunctionParams() {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/function/${this.newRequirement.companyFunctionId}/defaultParams`)
        console.log('randaLoggerDDD', data)
        this.newRequirement.functionParams = data
      },
      async loadOperatorTypes() {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/operator`)
        this.operatorTypes = data
      },
      validateRequirementForm() {
        let invalidParams = false
        if(this.newRequirement.functionParams.length > 0){
          this.newRequirement.functionParams.forEach(fp => {
            if(!fp.defaultValue) {
              invalidParams = true
            }
          })
        }
        return invalidParams || !this.newRequirement.requirementValue
      },
      async saveNewRequirement() {
        this.newRequirement.processStepId = this.processStepId
        const {data} = await postRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/requirement`, this.newRequirement)
        this.requirements.push(data)
        this.addNewRequirement = false
        this.newRequirement = {
          functionParams: []
        }
        this.parent = {}
        this.availableFunctions = []
      },
      async updateRequirement(requirement) {
        const {data} = await putRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/requirement`, requirement)
        this.expanded = []
        // this forces the list to update the operator displayed ... using requirement = data did not work
        requirement.operatorType = data.operatorType
      },
      async deleteRequirement(id) {
        await deleteRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/requirement/${id}`)
      },
      //ACTIONS
      async getActions () {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/action`)
        this.actions = data
      },
      filterActions () {
        return this.actions.filter(a => { return !a.archived})
      },
      async saveNewAction() {
        this.newAction.processStepId = this.processStepId
        const {data} = await postRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/action`, this.newAction)
        this.actions.push(data)
        this.addNewAction = false
        this.newAction = {}
      },
      async updateAction(action) {
        action.processStepLogicList = action.processStepLogicList.filter(l => {return !l.archived})

        const {data} = await putRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/action`, action)
        // this forces the list to update the values displayed ... using action = data did not work
        action.actionType = data.actionType
        action.processStepStatusType = data.processStepStatusType
        this.actionExpanded = []
      },
      async getStatusTypes () {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/status`)
        this.statusTypes = orderBy(data, [s => s.processStepStatusType.toLowerCase()])
      },
      async getOperationTypes () {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/operation`)
        this.operationTypes = orderBy(data, [o => o.operationType.toLowerCase()])
      },
      async assignNewAction() {
        console.log('ASSIGN ACTION HERE')
        //i dont know what i was writing this for
      },
      async deleteAction(item) {
        console.log('DELETE ACTION HERE', item)
        await deleteRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}/action/${item.id}`)
        item.archived = true
      },
    }

  }
</script>

<style scoped lang="scss">
.params {
  width: 100%;
}
</style>
