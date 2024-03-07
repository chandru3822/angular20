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

          <AlbatrossButton
            color="primary"
            class="white--text"
            @click="deleteError = false"
            text="OK"
          />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pa-0">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newStep = {}, getResourceFields()]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :text="addNew ? 'Cancel' : 'Add New'"
            />
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

            <AlbatrossButton
              color="primary"
              :disabled="!newEvent.eventName || !newEvent.resourceCustomFieldId"
              @click="addEvent"
              text="save"
            />
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
                id="events-settings-table"
              :headers="headers"
              :items="filterEvents"
              :fixed-header="true"
              :items-per-page="100"
              :search="search"
              :footer-props="footerProps"
              hide-default-header
              class="elevation-1 square-card table-striped"
            >
              <template #item.eventName="{ item }" class="clickable" @click="goToEvent(item.id)">{{item.eventName}}</template>
              <template #item.icons="{item}" class="text-end">
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      @click="goToEvent(item.id)"
                      prepend-icon="edit"
                    />
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                      @click="eventToDelete=item"
                      prepend-icon="delete"
                    />
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

<script setup>
import {AppMutations} from '@/stores/AppStore'

import {getRequest, putRequest, postRequest, getSnackbar, handleHidingGlobalLoader} from '@/helpers/helpers'
import debounce from "lodash.debounce";
import { getEventResourceFields } from "@/services/eventService"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {computed, getCurrentInstance, ref, onMounted} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const router = vueInstance.$router
const userStore = useUserStore()

const addNew = ref(false)
const deleteError = ref(false)
const cannotDeleteReasons = ref({})
const search = ref('')
const newEvent = ref({})
const selectedEventId = ref(null)

const companyId = ref(userStore.details.companyId)
const userId = ref(userStore.details.id)
const events = ref([])
const eventResourceFields = ref([])
const headers = ref([
  {text: 'Event Name', value: 'eventName', show: true},
  {text: '', value: 'icons', show: true},
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': 'Rows per page:'
})
const eventToDelete = ref(null)


onMounted(() => {
  getEvents()
})
// watch(options, () => {
//   const handler = () => {
//     getEvents()
//   }
// })

const eventToDeleteName = computed(() => {
  return eventToDelete.value ? eventToDelete.value.eventName : ''
})

const filterEvents = computed(() => {
  return events.value.filter(e => {
    return !e.archived
  })
})

const debounceGetSteps = () => {
  debounce(function () {
    getEvents()
  }, 500)
}

const getResourceFields = async () => {
  if(addNew.value) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data} = await getEventResourceFields()
      eventResourceFields.value = data
      store.commit(AppMutations.SET_LOADING, false)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}

const getEvents = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data} = await getRequest(`/event`)
    events.value = data
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const deleteEvent =  async () => {
  const event = eventToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/event/delete/${event.id}`)
    event.archived = true
    snackbar('SUCCESS', 'Event Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    if (e.status === 400) {
      event.deleteConfirm = false
      deleteError.value = true
      cannotDeleteReasons.value = e.data
    }
    snackbar('ERROR', 'Error Deleting Event')
    store.commit(AppMutations.SET_LOADING, false)
  }
  eventToDelete.value = null
}

const addEvent = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data} = await postRequest(`/event`, newEvent.value)
    router.push({path: `/settings/event/${data.id}/customFieldGroups`})
    snackbar('SUCCESS', 'Event Added')
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Event')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const goToEvent = (eventId) => {
  router.push({path: `/settings/event/${eventId}/components`})
}

</script>

<style lang="scss">
#event-step-container .v-data-table__wrapper {
  height: calc(100vh - 310px);
  min-height: 300px;
}
#events-settings-table > div.v-data-table__wrapper > table > tbody > tr {
  td {
    justify-content: center;
  }
  td:last-child {
    text-align: end !important;
  }
}
@media (max-width: 770px) {
  #events-settings-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__pagination {

      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);


      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}


</style>
