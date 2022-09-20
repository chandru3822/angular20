<template>
  <v-container id="event-step-container" class="custom-field-group-container">
    <v-dialog width="700"
              v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 grey lighten-2 error--text">
          Error Deleting Event
        </v-card-title>

        <v-card-text class="pt-5">
          <div v-if="cannotDeleteReasons && cannotDeleteReasons.length > 0" class="mb-5">
            <div class="mb-3">* This event is being used by Process Steps Events.  You must remove from the following locations before deleting this event.</div>
            <div v-for="a in cannotDeleteReasons" :key="a.id" class="ml-5">
              <strong>{{ a.processStepName }}</strong>
            </div>
          </div>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primary"
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newStep = {}, getEventResourceFields()]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              {{ addNew ? 'Cancel' : 'Add New'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container class="pa-0">
          <v-card color="transparent" flat v-if="addNew" class="mb-3 pa-2">
            <v-text-field
              label="Event Name"
              tabindex=1
              v-model="newEvent.eventName"
            ></v-text-field>

            <v-autocomplete
              v-model="newEvent.resourceCustomFieldId"
              :items="eventResourceFields"
              label="Resource"
              item-text="fieldName"
              item-value="id"
            ></v-autocomplete>

            <v-btn color="primary" :disabled="!newEvent.eventName || !newEvent.resourceCustomFieldId"
                   @click="addEvent">
              Save
            </v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
              ></v-text-field>
            </v-card-title>
            <v-data-table
              :headers="headers"
              :items="filterEvents()"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              hide-default-header
              class="elevation-1 square-card"
            >
              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left clickable" @click="goToEvent(item.id)">{{item.eventName}}</td>
                  <td class="text-right">
                    <v-btn small text color="primary" @click="goToEvent(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn small text color="primary"
                           v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                           @click="eventToDelete=item">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
          <ConfirmationDialog :open-dialog="!!eventToDelete" @confirm="deleteEvent" @close-dialog="eventToDelete=null">
            Are you sure you want to delete this event: <b>{{eventToDeleteName}}</b>?
          </ConfirmationDialog>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'

import {getRequest, putRequest, postRequest, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
import debounce from "lodash.debounce";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'Events',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      addNew: false,
      deleteError: false,
      cannotDeleteReasons: {},
      search: '',
      newEvent: {},
      selectedEventId: null,
      companyId: this.$store.state.user.details.companyId,
      userId: this.$store.state.user.details.id,
      events: [],
      eventResourceFields: [],
      headers: [
        {text: 'Event Name', value: 'eventName', show: true},
        {text: '', value: 'icons', show: true},
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': 'Rows per page:'
      },
      eventToDelete: null
    }
  },
  watch: {
    options: {
      handler () {
        this.getEvents()
      },
      deep: true,
    },
  },
  computed: {
    eventToDeleteName(){
      return this.eventToDelete ? this.eventToDelete.eventName : ''
    }
  },
  methods: {
    debounceGetSteps: debounce( function () {
      this.getEvents()
    }, 500),
    goToEvent(eventId) {
      this.$router.push({path: `/settings/event/${eventId}/components`})
    },
    async getEventResourceFields() {
      if(this.addNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldGroup/getEventResourceFields`)
          this.eventResourceFields = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getEvents () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/event`)
        this.events = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteEvent () {
      const event = this.eventToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/event/delete/${event.id}`)
        event.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Event Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        if (e.status === 400) {
          event.deleteConfirm = false
          this.deleteError = true
          this.cannotDeleteReasons = e.data
        }
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.eventToDelete = null
    },
    async addEvent () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/event`, this.newEvent)
        this.$router.push({path: `/settings/event/${data.id}/customFieldGroups`})
        this.snackbar = getSnackbar('SUCCESS', 'Event Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterEvents () {
      return this.events.filter(e => { return !e.archived})
    },
  },
  async created () {
    await this.getEvents()
  }
}
</script>

<style lang="scss">
#event-step-container .v-data-table__wrapper {
  height: calc(100vh - 310px);
  min-height: 300px;
}

</style>
