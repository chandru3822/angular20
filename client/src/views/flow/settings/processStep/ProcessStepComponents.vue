<template>
  <v-container class="custom-field-group-container py-0">
    <v-row>
      <v-col cols="12">
        <v-row class="mb-2">
          <v-col cols="12">
            <v-text-field color="primaryCustom"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="processStep.processStepName"
                          label="Process Step Name"></v-text-field>
            <div>
              <label class="mt-4">Allow Non-Admin to Add to Project:</label>
              <input class="ml-3" type="checkbox" :readonly="!userCanEdit"
                     :disabled="!userCanEdit" v-model="processStep.nonAdminAdd">
            </div>
            <v-btn color="primaryCustom" dark class="white--text mt-3" v-if="userCanEdit"
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
                <v-btn text @click="getWorkQueueTypesForStep" v-if="userCanAdd">
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
                <v-data-table
                  :headers="headers"
                  :items="filterWorkQueueTypes()"
                  single-expand
                  :expanded.sync="expanded"
                  hide-default-footer
                  hide-default-header
                  disable-sort
                  class="elevation-1"
                >
                  <template #no-data>
                    No available work queue types
                  </template>

                  <template #no-results>
                    No available work queue types
                  </template>

                  <template #expanded-item="{ headers, item }">
                    <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': processStep.workQueueTypes.indexOf(item) % 2}">
                      <v-select
                        v-model="item.selectedOptions"
                        :items="projectStatusTypes"
                        multiple
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        persistent-hint
                        hint="Active Status will be used if none selected"
                        label="Project Status Types"
                        item-text="projectStatusType"
                        return-object
                      ></v-select>
                      <v-btn dark class="white--text mt-3" v-if="userCanEdit" color="primaryCustom" @click="saveProjectStatusesToWorkQueueType(item)">
                        Save
                      </v-btn>
                    </td>
                  </template>

                  <template #item="{ item, index }">
                    <tr class="clickable" :class="{'shaded-row': index % 2}">
                      <td class="text-left">{{item.workQueueType}}</td>
                      <td class="text-right">
                        <v-btn small text @click="[expanded = [item], getProjectStatusTypes(item)]"
                               v-if="!expanded.includes(item)">
                          <v-icon>edit</v-icon>
                        </v-btn>
                        <v-btn small text @click="expanded = []"
                               v-else>cancel
                        </v-btn>
                        <v-dialog
                            v-if="userCanEdit"
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
                              primary-title
                            >
                              Confirm
                            </v-card-title>

                            <v-card-text>
                              Are you sure you want to delete <strong>{{ item.workQueueType }}</strong>?
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
                                @click="deleteWorkQueueTypeFromStep(item)">
                                Yes
                              </v-btn>
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                      </td>
                    </tr>
                  </template>
                </v-data-table>
<!--                <v-list v-for="(a, index) in filterBy(processStep.workQueueTypes, false, 'archived')"-->
<!--                        :key="index">-->
<!--                  <v-list-item :class="{'shaded-row': index % 2}">-->
<!--                    <v-list-item-content>-->
<!--                      {{a.workQueueType}}-->
<!--                    </v-list-item-content>-->
<!--                    <v-dialog-->
<!--                      v-model="a.deleteConfirm"-->
<!--                      width="500">-->
<!--                      <template v-slot:activator="{ on }">-->
<!--                        <v-list-item-action class="clickable" v-on="on">-->
<!--                          <v-icon>delete</v-icon>-->
<!--                        </v-list-item-action>-->
<!--                      </template>-->
<!--                      <v-card>-->
<!--                        <v-card-title-->
<!--                          class="headline grey lighten-2"-->
<!--                          primary-title-->
<!--                        >-->
<!--                          Confirm-->
<!--                        </v-card-title>-->

<!--                        <v-card-text>-->
<!--                          Are you sure you want to delete this Work Queue Type: <strong>{{ a.workQueueType }}</strong>?-->
<!--                        </v-card-text>-->

<!--                        <v-divider></v-divider>-->

<!--                        <v-card-actions>-->
<!--                          <v-spacer></v-spacer>-->
<!--                          <v-btn-->
<!--                            @click="a.deleteConfirm = false">-->
<!--                            No-->
<!--                          </v-btn>-->
<!--                          <v-btn-->
<!--                            color="primaryCustom"-->
<!--                            text-->
<!--                            @click="[a.archived = true, deleteWorkQueueTypeFromStep(a.id)]">-->
<!--                            Yes-->
<!--                          </v-btn>-->
<!--                        </v-card-actions>-->
<!--                      </v-card>-->
<!--                    </v-dialog>-->
<!--                  </v-list-item>-->
<!--                </v-list>-->
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
                <v-btn text @click="getLinksForProcessStep" v-if="userCanAdd">
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
                        v-if="userCanEdit"
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
                              color="primaryCustom"
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
                <v-btn text @click="getAttachmentTypesForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewType">add</v-icon>
                  {{ addNewType ? 'Cancel' : 'Add Type'}}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-autocomplete v-if="addNewType"
                        v-model="newType.attachmentTypeId"
                        :items="availableAttachmentTypes"
                        label="Select Attachment Type"
                        item-text="attachmentType"
                        item-value="id"
                        @input="assignNewType"
              ></v-autocomplete>
              <v-card flat v-if="processStep.attachmentTypes && processStep.attachmentTypes.length > 0">
                <v-list v-for="(a, index) in filterBy(processStep.attachmentTypes, false, 'archived')"
                        :key="index">
                  <v-list-item :class="{'shaded-row': index % 2}">
                    <v-list-item-content>
                      {{a.attachmentType}}
                    </v-list-item-content>
                    <v-dialog
                        v-if="userCanEdit"
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
                              color="primaryCustom"
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
        expanded: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        projectStatusTypes: [],
        headers: [
          {text: 'Work Queue Types', value: 'workQueueType', show: true},
          {text: '', value: 'icons', show: false, width: '100px'},
        ],
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
      async getProjectStatusTypes (item) {
        item.selectedOptions = []
        if(this.projectStatusTypes?.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await getRequest(`/project/status`)
            this.projectStatusTypes = data
            // this makes the multi-select work
            this.projectStatusTypes.forEach(d => {
              let match = item.projectStatuses?.find(pst => pst.companyProjectStatusTypeId === d.id)
              if(match) {
                item.selectedOptions.push(d)
              }
            })
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Project Status Types')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.projectStatusTypes.forEach(d => {
            let match = item.projectStatuses.find(pst => pst.companyProjectStatusTypeId === d.id)
            if(match) {
              item.selectedOptions.push(d)
            }
          })
        }

      },
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
      async saveProjectStatusesToWorkQueueType(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //check each projectStatusTypes, if not exists in selectedOptions then it got archived
          item.projectStatuses?.forEach(s => {
            let match = item.selectedOptions.find(o => o.id === s.projectStatusTypeId)
            if (!match) {
              s.archived = true
            }
          })

          //check each selectedOptions, if not exists in item.projectStatuses already then it needs to be added
          item.selectedOptions?.forEach(o => {
            let match = item.projectStatuses.find(pst => pst.projectStatusTypeId === o.id)
            if (!match) {
              let object = {
                id: null,
                companyProjectStatusTypeId: o.id,
                processStepWorkQueueTypeId: item.id,
                archived: false
              }
              item.projectStatuses.push(object)
            }
          })

          const {data} = await putRequest(`/workQueueType/saveProjectStatusTypesToWorkQueueType`, item)
          item.projectStatuses = data
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Project Status Types Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Project Status Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteWorkQueueTypeFromStep (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addNewWorkQueueType = false
          await deleteRequest(`/workQueueType/processStep/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterWorkQueueTypes() {
        return this.processStep?.workQueueTypes.filter(u => {
          return !u.archived
        })
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
