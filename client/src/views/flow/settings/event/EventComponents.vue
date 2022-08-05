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

</style>
