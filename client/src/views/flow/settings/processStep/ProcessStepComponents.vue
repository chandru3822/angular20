<template>
  <v-container class="custom-field-group-container py-0">
    <v-row>
      <v-col cols="12">
        <v-row class="mb-2">
          <v-col cols="12">
            <v-text-field color="primary"
                          v-model="processStep.processStepName"
                          label="Process Step Name"></v-text-field>
            <div>
              <label class="mt-4">Allow Non-Admin to Add to Project:</label>
              <input class="ml-3" type="checkbox" v-model="processStep.nonAdminAdd">
            </div>
            <v-btn color="primaryCustom" dark class="white--text mt-3"
                   @click="saveProcessStep">
              Save Process Step
            </v-btn>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row>
          <v-col cols="12"  class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Work Queue Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getWorkQueueTypesForStep">
                  <v-icon v-if="!addNewWorkQueueType">add</v-icon>
                  {{ addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type'}}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-autocomplete v-if="addNewWorkQueueType"
                        v-model="newWorkQueueType.workQueueTypeId"
                        :items="workQueueTypes"
                        label="Select Work Queue Type"
                        item-text="workQueueType"
                        item-value="id"
                        @input="assignNewWorkQueueType"
              ></v-autocomplete>
              <v-card flat v-if="processStep.workQueueTypes && processStep.workQueueTypes.length > 0">
                <v-list v-for="(a, index) in filterBy(processStep.workQueueTypes, false, 'archived')"
                        :key="index">
                  <v-list-item :class="{'shaded-row': index % 2}">
                    <v-list-item-content>
                      {{a.workQueueType}}
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
                          Are you sure you want to delete this Work Queue Type: <strong>{{ a.workQueueType }}</strong>?
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
                            @click="[a.archived = true, deleteWorkQueueTypeFromStep(a.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </v-card>
            </div>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row>
          <v-col cols="12"  class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Links</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getLinksForProcessStep">
                  <v-icon v-if="!addNewLink">add</v-icon>
                  {{ addNewLink ? 'Cancel' : 'Add Link'}}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-select v-if="addNewLink"
                        v-model="newLink.linkId"
                        :items="availableLinks"
                        label="Select Link"
                        item-text="link"
                        item-value="id"
                        @input="assignNewLink"
              ></v-select>
              <v-card flat v-if="processStep.links && processStep.links.length > 0">
                <v-list v-for="(a, index) in filterBy(processStep.links, false, 'archived')"
                        :key="index">
                  <v-list-item :class="{'shaded-row': index % 2}">
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
                              @click="[a.archived = true, deleteLinkFromStep(a.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </v-card>
            </div>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row v-if="processStepId">
          <v-col cols="12" class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getAttachmentTypesForProcessStep">
                  <v-icon v-if="!addNewType">add</v-icon>
                  {{ addNewType ? 'Cancel' : 'Add Type'}}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-select v-if="addNewType"
                        v-model="newType.attachmentTypeId"
                        :items="availableAttachmentTypes"
                        label="Select Attachment Type"
                        item-text="attachmentType"
                        item-value="id"
                        @input="assignNewType"
              ></v-select>
              <v-card flat v-if="processStep.attachmentTypes && processStep.attachmentTypes.length > 0">
                <v-list v-for="(a, index) in filterBy(processStep.attachmentTypes, false, 'archived')"
                        :key="index">
                  <v-list-item :class="{'shaded-row': index % 2}">
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
                              @click="[a.archived = true, deleteTypeFromStep(a.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </v-card>
            </div>
          </v-col>
        </v-row>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'ProcessStepComponents',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepCustomFieldGroups,
      Snackbar
    },
    data () {
      return {
        snackbar: {},
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
        workQueueTypes: [],
        newWorkQueueType: {},
        addNewWorkQueueType: false,
        checkedIds: [],
        selectedOptions: [],
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
      await this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequest(`/processStep/${this.processStepId}`)
          this.processStep = data
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveProcessStep () {
        //handle everything that can happen in save
        // this.saveWorkQueueTypes()
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/processStep`, this.processStep)
          this.changesMade = false
          this.snackbar = getSnackbar('SUCCESS', 'Process Step Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Process Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAttachmentTypesForProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewType = !this.addNewType
          if(this.addNewType){
            const { data } = await getRequest(`/attachmentType/typesForStep/${this.$route.params.id}`)
            this.availableAttachmentTypes = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignNewType () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
        this.newType.processStepId = this.$route.params.id
          const { data } = await postRequest(`/attachmentType/processStepType`, this.newType)
          this.processStep.attachmentTypes.push(data)
          // reset fields
          this.addNewType = false
          this.newType = {}
          this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteTypeFromStep (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewType = false
          await deleteRequest(`/attachmentType/processStepType/${id}`)
          // this.availableAttachmentTypes = data
          this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getLinksForProcessStep () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewLink = !this.addNewLink
          if(this.addNewLink){
            const { data } = await getRequest(`/links/processStep/${this.$route.params.id}`)
            this.availableLinks = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignNewLink () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newLink.processStepId = this.$route.params.id
          const { data } = await postRequest(`/links/processStep`, this.newLink)
          this.processStep.links.push(data)
          // reset fields
          this.addNewLink = false
          this.newLink = {}
          this.snackbar = getSnackbar('SUCCESS', 'Link Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Link')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteLinkFromStep (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewLink = false
          await deleteRequest(`/links/processStep/${id}`)
          // this.availableAttachmentTypes = data
          this.snackbar = getSnackbar('SUCCESS', 'Link Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWorkQueueTypesForStep() {
        try {
          this.addNewWorkQueueType = !this.addNewWorkQueueType
          if(this.addNewWorkQueueType) {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await getRequest(`/workQueueType/processStep/${this.$route.params.id}`)
            this.workQueueTypes = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignNewWorkQueueType () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newWorkQueueType.processStepId = this.$route.params.id
          const { data } = await postRequest(`/workQueueType/processStep`, this.newWorkQueueType)
          this.processStep.workQueueTypes.push(data)
          // reset fields
          this.addNewWorkQueueType = false
          this.newWorkQueueType = {}
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Type')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteWorkQueueTypeFromStep (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewWorkQueueType = false
          await deleteRequest(`/workQueueType/processStep/${id}`)
          // this.availableAttachmentTypes = data
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>
