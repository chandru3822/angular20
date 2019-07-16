<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" flat>
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-spacer></v-spacer>
        <div v-if="changesMade">
          <v-btn class="mr-2" :to="{ path: `/settings/processSteps`}">cancel</v-btn>
          <v-btn color="primary white--text" @click="saveProcessStep">Save Changes</v-btn>
        </div>
      </v-toolbar>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          {{ processStepId ? processStep.processStepName : 'New Process Step'}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          UI Components
        </v-toolbar-items>
      </v-toolbar>
      <v-container class="mt-2 name-container">
        <v-text-field
            label="Process Step Name"
            tabindex=1
            @input="changesMade = true"
            v-model="processStep.processStepName"
        ></v-text-field>
        <v-btn v-if="!processStepId" :disabled="!processStep.processStepName" @click="addProcessStep">Save</v-btn>
      </v-container>
      <v-flex v-if="processStepId">
        <h3>Custom Fields</h3>
        <v-btn v-if="!addNewCustomFieldGroup" @click="addNewCustomFieldGroup = !addNewCustomFieldGroup">
          <v-icon>add</v-icon>
          Create Group
        </v-btn>
        <!--Add new custom value: {{ addNewCustomFieldGroup }}-->
        <ProcessStepCustomFieldGroups :customFieldGroups="processStep.customFieldGroupTypes" :createNew="addNewCustomFieldGroup"
                                      @update="onStep1Update"></ProcessStepCustomFieldGroups>
      </v-flex>
      <v-divider></v-divider>
      <v-flex v-if="processStepId">
        <h3>Links</h3>
        <v-btn @click="getLinksForProcessStep">
          <v-icon v-if="!addNewLink">add</v-icon>
          {{ addNewLink ? 'Cancel' : 'Add Type'}}
        </v-btn>
        <v-select v-if="addNewLink"
                  v-model="newLink.linkId"
                  :items="availableLinks"
                  label="Select Link"
                  item-text="link"
                  item-value="id"
                  @input="assignNewLink"
        ></v-select>
        <v-container>
          <v-list v-for="(a, index) in filterBy(processStep.links, false, 'archived')"
                  :key="index">
            <v-list-item>
              <v-list-item-content>
                {{a.link}} | {{ a.url }}
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
                    Are you sure you want to delete this link: <strong>{{ a.link }}</strong>?
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
                        @click="a.archived = true; deleteLinkFromStep(a.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-flex>
      <v-divider></v-divider>
      <v-flex v-if="processStepId">
        <h3>Attachments</h3>
        <v-btn @click="getAttachmentTypesForProcessStep">
          <v-icon v-if="!addNewType">add</v-icon>
          {{ addNewType ? 'Cancel' : 'Add Type'}}
        </v-btn>
        <v-select v-if="addNewType"
                  v-model="newType.attachmentTypeId"
                  :items="availableAttachmentTypes"
                  label="Select Attachment Type"
                  item-text="attachmentType"
                  item-value="id"
                  @input="assignNewType"
        ></v-select>
        <v-container>
          <v-list v-for="(a, index) in filterBy(processStep.attachmentTypes, false, 'archived')"
                  :key="index">
            <v-list-item>
              <v-list-item-content>
                {{a.attachmentType}}
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
                    Are you sure you want to delete this attachment type: <strong>{{ a.attachmentType }}</strong>?
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
                        @click="a.archived = true; deleteTypeFromStep(a.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-flex>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepCustomFieldGroups
    },
    data () {
      return {
        addNewCustomFieldGroup: false,
        changesMade: false,
        addNewType: false,
        newType: {},
        addNewLink: false,
        newLink: {},
        availableLinks: [],
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        availableAttachmentTypes: [],
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/processSteps`
          },
        ]
      }
    },
    computed: {
    },
    async created () {
      if(this.processStepId) {
        this.getProcessStepDetails()
      }
    },
    methods: {
      onStep1Update (newData) {
        console.log('someting happen', newData)
        this.addNewCustomFieldGroup = newData
      },
      async addProcessStep () {
        console.log('ADD HERE', this.processStep)
      },
      async getProcessStepDetails () {
        console.log('will load details here', this.processStep)
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        this.processStep = data
      },
      // async getOrgs () {
      //   console.log('will load orgs here')
      //   const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/org`)
      //   this.orgs = data
      // },
      async saveProcessStep () {
        const {data} = await putRequest(`/api/v1/flow/companies/${this.companyId}/processStep`, this.processStep)
        this.changesMade = false
      },
      async getAttachmentTypesForProcessStep () {
        this.addNewType = !this.addNewType
        if(this.addNewType){
          const { data } = await getRequest(`/api/v1/flow/companies/${this.companyId}/attachment/typesForStep/${this.$route.params.id}`)
          this.availableAttachmentTypes = data
        }
      },
      async assignNewType () {
        this.newType.processStepId = this.$route.params.id
        const { data } = await postRequest(`/api/v1/flow/companies/${this.companyId}/attachment/processStepType`, this.newType)
        console.log('randaLogger', data)
        this.processStep.attachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
      },
      async deleteTypeFromStep (id) {
        this.addNewType = false
        console.log('deleting')
        await deleteRequest(`/api/v1/flow/companies/${this.companyId}/attachment/processStepType/${id}`)
        // this.availableAttachmentTypes = data
      },
      async getLinksForProcessStep () {
        this.addNewLink = !this.addNewLink
        if(this.addNewLink){
          const { data } = await getRequest(`/api/v1/flow/companies/${this.companyId}/links/processStep/${this.$route.params.id}`)
          this.availableLinks = data
        }
      },
      async assignNewLink () {
        this.newLink.processStepId = this.$route.params.id
        const { data } = await postRequest(`/api/v1/flow/companies/${this.companyId}/links/processStep`, this.newLink)
        console.log('randaLogger', data)
        this.processStep.links.push(data)
        // reset fields
        this.addNewLink = false
        this.newLink = {}
      },
      async deleteLinkFromStep (id) {
        this.addNewLink = false
        console.log('deleting')
        await deleteRequest(`/api/v1/flow/companies/${this.companyId}/links/processStep/${id}`)
        // this.availableAttachmentTypes = data
      }
    }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>
