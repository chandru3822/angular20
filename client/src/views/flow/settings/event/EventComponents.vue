<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNewEventStatusType = !addNewEventStatusType, expanded = [], getCompanyEventStatusTypes()]" v-if="userCanAdd">
              <v-icon v-if="!addNewEventStatusType">add</v-icon>
              {{ addNewEventStatusType ? 'Cancel' : 'Add Event Status Type' }}
            </v-btn>
            <v-btn text color="primary" @click="expandEsst = !expandEsst">
              <v-icon v-if="!expandEsst">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="mb-4">
          <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewEventStatusType">
            <h3>Assign a Status Type</h3>
            <v-autocomplete label="Event Status Type"
                            :items="availableCompanyEventStatusTypes"
                            v-model="newEventStatusTypeId"
                            item-text="eventStatusType"
                            item-value="id"
                            :loading="companyStatusesLoading"
                            autocomplete="off"
                            @input="assignStatusTypeToEvent"
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.eventStatusType }} ({{ data.item.rootEventStatusType }})
              </template>
            </v-autocomplete>
          </v-card>
          <v-data-table
            v-if="expandEsst"
            :headers="eventHeaders"
            :items="filterAssignedEventStatusTypes()"
            hide-default-footer
            :items-per-page="-1"
            disable-sort
            class="elevation-1 square-card mb-2"
          >
            <template #no-data>
              No available event status types
            </template>

            <template #no-results>
              No available event status types
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">{{ item.eventStatusType }}</td>
                <td class="text-left">{{ item.rootEventStatusType }}</td>
                <td class="text-right">
                  <div class="flex-display align-center">
                    <v-btn small text color="primary" v-if="userCanEdit" @click="eventStatusTypeToDelete=item"><v-icon>delete</v-icon></v-btn>
                  </div>
                </td>
              </tr>
            </template>
          </v-data-table>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="getAttachmentTypesForEvents" v-if="userCanAdd">
              <v-icon v-if="!addNewType">add</v-icon>
              {{ addNewType ? 'Cancel' : 'Add Type'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-autocomplete v-if="addNewType"
                        v-model="newType.attachmentTypeId"
                        :items="availableAttachmentTypes"
                        label="Select Attachment Type"
                        item-text="attachmentType"
                        item-value="id"
                        @input="assignNewType"
        ></v-autocomplete>
        <v-card flat >
          <draggable v-model="eventAttachmentTypes" group="projectAttachmentTypes"
                     :disabled="!userCanEdit"
                     id="proj-attachment-draggable"
                     @change="saveAttachmentTypeOrder(eventAttachmentTypes)"
                     @start="drag=true" @end="drag=false">
            <v-list v-for="(a, index) in filterBy(eventAttachmentTypes, false, 'archived')"
                    :key="index">
              <v-list-item class="grab" dense :class="{'shaded-row': index % 2}">
                <v-list-item-action>
                  <v-icon>drag_handle</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  {{a.attachmentType}}
                </v-list-item-content>
                <v-btn text color="primary" @click="attachmentTypeToDelete = a"><v-icon>delete</v-icon></v-btn>
              </v-list-item>
            </v-list>
          </draggable>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!eventStatusTypeToDelete" @confirm="deleteStatusTypeFromEvent" @close-dialog="eventStatusTypeToDelete=null">
      Are you sure you want to delete this event status type: <strong>{{ eventStatusTypeToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!attachmentTypeToDelete" @confirm="deleteAttachmentType" @close-dialog="attachmentTypeToDelete=null">
      Are you sure you want to delete this attachment type: <strong>{{ attachmentTypeToDeleteType }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {getAvailableForEvent} from '@/services/eventStatusTypeService'
import {deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters"
import orderBy from "lodash.orderby"
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'EventComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ConfirmDeleteDialog,
    draggable
  },
  data () {
    return {
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      addNewType: false,
      expandEsst: true,
      event: {},
      eventId: this.$route.params.id,
      availableCompanyEventStatusTypes: [],
      companyStatusesLoading: false,
      addNewEventStatusType: false,
      newType: {},
      newEventStatusTypeId: null,
      combinedStatuses: [ {header: 'Category'} ],
      companyEventStatusTypes: [],
      eventStatusTypes: [],
      availableAttachmentTypes: [],
      eventAttachmentTypes: [],
      eventHeaders: [
        {text: 'Status Type', value: 'statusType', show: true},
        {text: 'Category', value: 'category', show: true},
        {text: '', value: 'icons', show: false, width: '100px'},
      ],
      eventStatusTypeToDelete: null,
      attachmentTypeToDelete: null
    }
  },
  computed: {
    eventStatusTypeToDeleteName(){
      return this.eventStatusTypeToDelete ? this.eventStatusTypeToDelete.eventStatusType : ''
    },
    attachmentTypeToDeleteType(){
      return this.attachmentTypeToDelete ? this.attachmentTypeToDelete.attachmentType : ''
    }
  },
  watch: {},
  created () {
    this.getEventAttachmentTypes()
    this.getEvent()
  },
  methods: {
    async getEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/event/${this.eventId}`)
        this.event = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getEventAttachmentTypes () {
      //this one loads attachment types already assigned to an event
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data } = await getRequest(`/attachmentType/eventTypes/${this.$route.params.id}`)
        this.eventAttachmentTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAttachmentTypesForEvents () {
      //this one loads attachment types AVAILABLE TO BE assigned to an event ...idk maybe this should be one function
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if(this.addNewType){
          const { data } = await getRequest(`/attachmentType/typesForEvent/${this.$route.params.id}`)
          this.availableAttachmentTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewType () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.eventId = this.$route.params.id
        const { data } = await postRequest(`/attachmentType/eventType`, this.newType)
        this.eventAttachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachmentType () {
      const attachmentType = this.attachmentTypeToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        await deleteRequest(`/attachmentType/eventType/${attachmentType.id}`)
        // this.availableAttachmentTypes = data
        attachmentType.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.attachmentTypeToDelete = null
    },
    async saveAttachmentTypeOrder (attachmentTypes) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let typesToSave = []
        attachmentTypes.forEach((f, idx) => {
          let order = idx + 1
          if(f.displayOrder !== order){
            f.displayOrder = order
            typesToSave.push(f)
          }
        })
        // save them here
        if(typesToSave.length > 0) {
          await putRequest(`/attachmentType/updateOrderInProject`, typesToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Types Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterAssignedEventStatusTypes() {
      return orderBy(this.event?.companyEventStatusTypes?.filter(u => {
        return !u.archived
      }), [f => f.eventStatusType])
    },
    async assignStatusTypeToEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.eventId = this.$route.params.id
        const {data} = await postRequest(`/event/status/assignCompanyStatus/${this.newEventStatusTypeId}/toEvent/${this.eventId}`)
        this.event.companyEventStatusTypes.push(data)
        // reset fields
        this.addNewEventStatusType = false
        this.newEventStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyEventStatusTypes() {
      if(this.addNewEventStatusType) {
        this.companyStatusesLoading = true
        try {
          const {data} = await getAvailableForEvent(this.eventId)
          this.availableCompanyEventStatusTypes = data
          this.companyStatusesLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.companyStatusesLoading = false
        }
      }

    },
    async deleteStatusTypeFromEvent () {
      const item = this.eventStatusTypeToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.archived = true
        await deleteRequest(`/event/${this.eventId}/companyStatus/${item.id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Event Status Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.eventStatusTypeToDelete = null
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#proj-attachment-draggable .v-list {
  padding-top: 0;
  padding-bottom: 0;
}
</style>
