<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="[addNewEvent = !addNewEvent, getAvailableEvents()]" text color="primary" v-if="userCanAdd">
              <v-icon v-if="!addNewEvent">add</v-icon>
              {{ addNewEvent ? 'Cancel' : 'Add Event'}}
            </v-btn>
            <v-btn text color="primary" @click="expandEvents = !expandEvents">
              <v-icon v-if="!expandEvents">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewEvent">
          <v-col cols="12">
            <v-autocomplete v-model="newEvent"
                            :items="availableEvents"
                            label="Select Event"
                            item-value="id"
                            item-text="eventName"
                            return-object
            ></v-autocomplete>
            <v-select v-if="newEvent.id"
                      v-model="newEvent.initialCompanyEventStatusTypeId"
                      :items="newEvent.companyEventStatusTypes"
                      label="Select Initial Status"
                      item-value="id"
                      item-text="eventStatusType"
            ></v-select>
            <v-btn color="primary"
                   :disabled="!newEvent.id || !newEvent.initialCompanyEventStatusTypeId"
                   @click="addEventToProcessStep">
              Save
            </v-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandEvents">
          <v-col cols="12" class="pt-0">
            <v-data-table
              :headers="headers"
              :items="filterEvents()"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              :mobile-breakpoint="0"
              hide-default-footer
              disable-sort
              class="event-table elevation-1 fix-column-width-bug square-card"
            >
              <template #no-data>
                <span class="default-text-color">No events for this process step</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No events for this process step</span>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td style="width: 50px">
                    <v-btn text color="primary" v-if="userCanEdit" icon small class="handle">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">{{item.eventName}} <v-icon color="primary" @click="goToPath(`/settings/event/${item.eventId}/components`)">mdi-link</v-icon></td>
                  <td class="text-left">{{item.initialEventStatusType}}</td>
                  <td>
                    <div style="display: flex; justify-content: flex-end">
                      <router-link v-if="userCanEdit" class="no-text-decoration pr-3"
                                   :to="`/settings/processStep/${processStepId}/event/${item.id}`">
                        <v-btn :disabled="!userCanEdit" small text color="primary">
                          <v-icon>edit</v-icon>
                        </v-btn>
                      </router-link>
                      <v-btn v-else :disabled="!userCanEdit" small text color="primary">
                        <v-icon>edit</v-icon>
                      </v-btn>
                      <v-btn :disabled="!userCanDelete" small text color="primary" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
                    </div>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteEventFromStep"
                                 @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this event?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ProcessStepEvents',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],
  mounted() {
    let table = document.querySelector('.event-table tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({newIndex, oldIndex}) {
        const rowSelected = _self.events.splice(oldIndex, 1)[0]
        _self.events.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(_self.events)

        let rowsToSave = []
        rowsClone.forEach((r, idx) => {
          //check if the row needs to be saved before updating display order
          //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
          let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
          //update display order
          r.displayOrder = idx
          //save only rows that changed
          if (save) {
            _self.events[idx].newDisplayOrder = idx
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
      expandEvents: true,
      companyEventStatuses: [],
      processStepStatuses: [],
      newEventStatuses: [],
      processStepId: this.$route.params.id,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Event', value: 'eventName', show: true},
        {text: 'Initial Status', value: 'initialEventStatusType', show: true},
        {text: null, value: 'icons', show: true}
      ],
      addNewEvent: false,
      newEvent: {},
      events: [],
      availableEvents: [],
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  computed: {},
  async created() {
    await this.getEvents()
  },
  methods: {
    async getEvents() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
        this.events = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableEvents() {
      if(this.addNewEvent) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event/available`)
          this.availableEvents = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    filterEvents() {
      // return this.events.filter(e => {
      //   return !e.archived
      // })
      return orderBy(this.events.filter(e => { return !e.archived}), [e => e.displayOrder])
    },
    async addEventToProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          eventId: this.newEvent.id,
          initialCompanyEventStatusTypeId: this.newEvent.initialCompanyEventStatusTypeId
        }
        const {data} = await postRequest(`/processStep/${this.processStepId}/event`, params)
        this.events.push(data)
        this.newEvent = {}
        this.addNewEvent = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteEventFromStep() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/processStep/${this.processStepId}/event/${item.id}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Event Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/event/order`, rows)
          this.snackbar = getSnackbar('SUCCESS', 'Event Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Event Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    closeDeleteDialog(){
      this.showDeleteDialog = false
      this.itemToDelete = null
    },
    goToPath(path) {
      this.$router.push({ path: `${path}` })
    }
  }

}
</script>

<style scoped lang="scss">
.required-field-label {
  width: 100px;
}
</style>
