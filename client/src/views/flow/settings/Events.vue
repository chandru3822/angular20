<template>
  <v-container id="event-step-container" class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newStep = {}, getSchedulingFields()]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
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
              v-if="schedulingFields && schedulingFields[0]"
              v-model="newEvent.resourceCustomFieldId"
              :items="schedulingFields[0].availableCustomFields"
              label="Resource"
              item-text="fieldName"
              item-value="id"
            ></v-autocomplete>

            <v-btn :disabled="!newEvent.eventName || !newEvent.resourceCustomFieldId"
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
                    <v-btn small text @click="goToEvent(item.id)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                              v-model="item.deleteConfirm" width="500">

                      <template v-slot:activator="{ on }">
                        <v-btn small text v-on="on">
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
                          Are you sure you want to delete this event: <strong>{{ item.eventName }}</strong>?
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
                            @click="deleteEvent(item)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </td>

                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'

import { getRequest, getRequestWithParams, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import debounce from "lodash.debounce";

export default {
  name: 'Events',
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      addNew: false,
      deleteError: false,
      fieldsInUse: [],
      search: '',
      newEvent: {},
      selectedEventId: null,
      companyId: this.$store.state.user.details.companyId,
      userId: this.$store.state.user.details.id,
      events: [],
      schedulingFields: [],
      headers: [
        {text: 'Event Name', value: 'eventName', show: true},
        {text: '', value: 'icons', show: true},
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': 'Rows per page:'
      },
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
  },
  methods: {
    debounceGetSteps: debounce( function () {
      this.getEvents()
    }, 500),
    goToEvent(eventId) {
      this.$router.push({path: `/settings/event/${eventId}/components`})
    },
    async getSchedulingFields() {
      if(this.addNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldGroup/getEventTypesAndFields/4`)
          this.schedulingFields = data
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
    async deleteEvent (event) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/event/delete/${event.id}`)
        if (data?.length > 0) {
          this.deleteError = true
          event.deleteConfirm = false
          this.fieldsInUse = data
          this.snackbar = getSnackbar('ERROR', 'Event Cannot Be Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.fieldsInUse = []
          event.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Event Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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
