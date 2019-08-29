<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-flex>
        <ProcessStepCustomFieldGroups :customFieldGroups="processStep.customFieldGroupTypes"></ProcessStepCustomFieldGroups>
      </v-flex>
      <v-divider></v-divider>
      <v-flex>
        <h3>Links</h3>
        <v-btn @click="getLinksForProcessStep">
          <v-icon v-if="!addNewLink">add</v-icon>
          {{ addNewLink ? 'Cancel' : 'Add Link'}}
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
    name: 'ProcessStepComponents',
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
      this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processStep/${this.processStepId}`)
        this.processStep = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async saveProcessStep () {
        const {data} = await putRequest(`/api/v1/flow/${this.companyId}/processStep`, this.processStep)
        this.changesMade = false
      },
      async getAttachmentTypesForProcessStep () {
        this.addNewType = !this.addNewType
        if(this.addNewType){
          const { data } = await getRequest(`/api/v1/flow/${this.companyId}/attachmentType/typesForStep/${this.$route.params.id}`)
          this.availableAttachmentTypes = data
        }
      },
      async assignNewType () {
        this.newType.processStepId = this.$route.params.id
        const { data } = await postRequest(`/api/v1/flow/${this.companyId}/attachmentType/processStepType`, this.newType)
        console.log('randaLogger', data)
        this.processStep.attachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
      },
      async deleteTypeFromStep (id) {
        this.addNewType = false
        console.log('deleting')
        await deleteRequest(`/api/v1/flow/${this.companyId}/attachmentType/processStepType/${id}`)
        // this.availableAttachmentTypes = data
      },
      async getLinksForProcessStep () {
        this.addNewLink = !this.addNewLink
        if(this.addNewLink){
          const { data } = await getRequest(`/api/v1/flow/${this.companyId}/links/processStep/${this.$route.params.id}`)
          this.availableLinks = data
        }
      },
      async assignNewLink () {
        this.newLink.processStepId = this.$route.params.id
        const { data } = await postRequest(`/api/v1/flow/${this.companyId}/links/processStep`, this.newLink)
        console.log('randaLogger', data)
        this.processStep.links.push(data)
        // reset fields
        this.addNewLink = false
        this.newLink = {}
      },
      async deleteLinkFromStep (id) {
        this.addNewLink = false
        console.log('deleting')
        await deleteRequest(`/api/v1/flow/${this.companyId}/links/processStep/${id}`)
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
