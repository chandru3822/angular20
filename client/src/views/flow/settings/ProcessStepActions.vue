<template>
  <v-layout row wrap>
    <v-flex xs-12>
      <h3>Requirements</h3>
      <v-btn @click="getRequirementTypes">
        <v-icon v-if="!addNewRequirement">add</v-icon>
        {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}
      </v-btn>
      <v-container v-if="addNewRequirement">
        <v-select v-model="newRequirement.processStepRequirementTypeId"
                  :items="availableRequirementTypes"
                  label="Select Requirement Type"
                  item-value="id"
                  item-text="processStepRequirementType"
                  @input="selectRequirementType"
        ></v-select>
        <v-select v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 1"
                  v-model="parent"
                  :items="parentObjects"
                  label="Parent Object"
                  item-text="processStepName"
                  return-object
                  @input="loadFieldsByParent"
        ></v-select>
        <v-select v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"
                  v-model="newRequirement.companyFunctionId"
                  :items="availableFunctions"
                  label="Function"
                  item-text="functionName"
                  item-value="id"
        ></v-select>
        <v-select v-if="parent.id"
                  v-model="newRequirement.customFieldGroupId"
                  :items="customFields"
                  label="Custom Field"
                  item-text="fieldName"
                  item-value="customFieldGroupId"
        ></v-select>
        <v-select v-if="(newRequirement.processStepRequirementTypeId === 1 && newRequirement.customFieldGroupId) || (newRequirement.processStepRequirementTypeId === 2 && newRequirement.companyFunctionId)"
                  v-model="newRequirement.operatorTypeId"
                  :items="operatorTypes"
                  label="Operator"
                  item-text="operatorType"
                  item-value="id"
        ></v-select>
        <v-text-field v-if="newRequirement.operatorTypeId"
                      v-model="newRequirement.processRequirementValue"
                      placeholder="Enter a value"
                      label="Value">
        </v-text-field>
        <v-btn v-if="newRequirement.processRequirementValue"
               @click="saveNewRequirement">
          <v-icon>save</v-icon>
          Save
        </v-btn>
      </v-container>
      <v-container>
<!--        todo: put this back in after archived is added-->
<!--        <v-list v-for="(r, index) in filterBy(requirements, false, 'archived')"-->
        <v-data-table
            :headers="headers"
            :items="requirements"
            :items-per-page="-1"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1"
        >
          <template v-slot:no-data>
            NO DATA HERE!
          </template>

          <template v-slot:no-results>
            No requirements for this process step
          </template>

<!--          <template v-slot:expanded-item="{ headers, item }">-->
<!--            <td :colspan="headers.length">Peek-a-boo!</td>-->
<!--          </template>-->

          <template v-slot:expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4">
                <v-select v-model="item.operatorTypeId"
                          :items="operatorTypes"
                          class="one-hunned"
                          label="Operator"
                          item-text="operatorType"
                          item-value="id"
                ></v-select>
                <v-text-field v-model="item.processRequirementValue"
                              placeholder="Enter a value"
                              label="Value">
                </v-text-field>
                <v-btn>
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
              {{ item.companyFunction }}
            </span>

          </template>
          <template #item.icons="{ item }">
            <v-btn text @click="expanded = [item]" v-if="!expanded.includes(item)">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text @click="expanded = []" v-if="expanded.includes(item)">cancel</v-btn>
            <v-dialog
                v-model="item.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-btn text v-on="on">
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
          </template>
        </v-data-table>
<!--        <v-list v-for="(r, index) in requirements"-->
<!--                :key="index">-->
<!--          <v-list-item>-->
<!--            <v-list-item-content>-->
<!--              {{r.processStepRequirementType}}| {{r.parentName}} | {{r.fieldName}}| {{r.operatorType}} | {{r.processRequirementValue}}-->
<!--            </v-list-item-content>-->
<!--            <v-dialog-->
<!--                v-model="r.deleteConfirm"-->
<!--                width="500">-->
<!--              <template v-slot:activator="{ on }">-->
<!--                <v-list-item-action class="clickable" v-on="on">-->
<!--                  <v-icon>delete</v-icon>-->
<!--                </v-list-item-action>-->
<!--              </template>-->
<!--              <v-card>-->
<!--                <v-card-title-->
<!--                    class="headline grey lighten-2"-->
<!--                    primary-title-->
<!--                >-->
<!--                  Confirm-->
<!--                </v-card-title>-->

<!--                <v-card-text>-->
<!--                  Are you sure you want to delete this requirement?-->
<!--                </v-card-text>-->

<!--                <v-divider></v-divider>-->

<!--                <v-card-actions>-->
<!--                  <v-spacer></v-spacer>-->
<!--                  <v-btn-->
<!--                      @click="r.deleteConfirm = false">-->
<!--                    No-->
<!--                  </v-btn>-->
<!--                  <v-btn-->
<!--                      color="primary"-->
<!--                      text-->
<!--                      @click="r.archived = true; deleteRequirement(r.id)">-->
<!--                    Yes-->
<!--                  </v-btn>-->
<!--                </v-card-actions>-->
<!--              </v-card>-->
<!--            </v-dialog>-->
<!--          </v-list-item>-->
<!--        </v-list>-->
      </v-container>
    </v-flex>
    <v-divider></v-divider>
    <v-flex xs-12>
      <h3>Actions</h3>
      <v-btn @click="addNewAction = !addNewAction">
        <v-icon v-if="!addNewAction">add</v-icon>
        {{ addNewAction ? 'Cancel' : 'Add Action'}}
      </v-btn>
      <v-container v-if="addNewAction">
        <v-text-field v-model="newAction.actionName"
                      placeholder="Enter a name"
                      label="Action Name">
        </v-text-field>
        <v-select v-model="newAction.processStepStatusId"
                  :items="statusTypes"
                  label="Action changes status of parent process step to"
                  item-text="statusType"
                  item-value="id"
                  @input=""
        ></v-select>
        <v-text-field v-model="newAction.logicStuff"
                      placeholder="Example '1 AND 2'"
                      label="Logic to enable action">
         </v-text-field>

      </v-container>
      <v-container>
        <v-list v-for="(a, index) in filterBy(actions, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              {{a.action}}
            </v-list-item-content>
            <v-dialog
                v-model="a.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-list-item-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-item-action>
              </template>
              <v-card>
                <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete this action: <strong>{{ a.action }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="a.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="a.archived = true; deleteAction(a.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'

  export default {
    name: 'ProcessStepActions',
    mixins: [Vue2Filters.mixin],
    components: {},
    data () {
      return {
        headers: [
          { text: 'Type', value: 'processStepRequirementType', show: true },
          { text: 'Details', value: 'custom', show: true},
          { text: 'Operator', value: 'operatorType', show: true },
          { text: 'Value', value: 'processRequirementValue', show: true },
          { text: null, value: 'icons', show: true }
        ],
        addNewRequirement: false,
        newRequirement: {},
        availableRequirementTypes: [],
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        parentObjects: [],
        parent: {},
        customFields: [],
        operatorTypes: [],

        requirements: [],
        availableFunctions: [],


        addNewAction: false,
        newAction: {},
        actions: [],
        statusTypes: [],
        expanded: [],
      }
    },
    computed: {},
    async created () {
      this.getRequirements()
      this.getActions()
      this.loadOperatorTypes()
    },
    methods: {
      //requirements
      async getRequirements() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/requirement`)
        this.requirements = data
      },
      async getRequirementTypes () {
        this.addNewRequirement = !this.addNewRequirement
        if (this.addNewRequirement){
          const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/requirement/types`)
          this.availableRequirementTypes = data
        }
      },
      async selectRequirementType() {
        //1 == custom field, 2 == function
        if(this.newRequirement.processStepRequirementTypeId === 1){
          const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/getParentObjects`)
          this.parentObjects = data
        } else {
          console.log('WILL BE A FUNCTION')
          this.availableFunctions = [
            { id: 1, functionName: 'Your Mom'},
            { id: 2, functionName: 'Your Dad'},
          ]
        }
      },
      async loadFieldsByParent() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/customField/getByParentProcessStep/${this.parent.id}`)
        this.customFields = data
      },
      async loadOperatorTypes() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/operator`)
        this.operatorTypes = data
      },
      async saveNewRequirement() {
        console.log('SAVE WILL BE HERE', this.newRequirement)
        //todo: i dont know what this is
        this.newRequirement.requirementNbr = 1
        this.newRequirement.processStepId = this.processStepId
        const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/requirement`, this.newRequirement)
        this.requirements.push(data)
        this.addNewRequirement = false
        this.newRequirement = {}
        this.parent = {}
        this.availableFunctions = []
      },
      async updateRequirementType(requirement) {
        putRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/requirement`, requirement)
      },
      async deleteRequirement(id) {
        await deleteRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}/requirement/${id}`)
      },
      //ACTIONS
      async getActions () {
        console.log('LOAD ACTIONS HERE')
        // const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        // this.actions = data
      },
      async getStatusTypes () {
        this.addNewAction = !this.addNewAction
        if (this.addNewAction){
          const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/status`)
          this.statusTypes = orderBy(data, [s => s.processStepStatusType.toLowerCase()])
        }
      },
      async assignNewAction() {
        console.log('ASSIGN ACTION HERE')
      },
      async deleteAction(id) {
        console.log('DELETE ACTION HERE', id)
      },
    }

  }
</script>

<style scoped lang="scss">
</style>
