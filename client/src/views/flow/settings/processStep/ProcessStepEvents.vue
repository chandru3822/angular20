<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="title-large">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                @click="[addNewEvent = !addNewEvent, getAvailableEvents()]"
                variant="text"
                color="primary"
                v-if="userCanAdd"
                :prepend-icon="!addNewEvent ? 'add' : 'close'"
                :text="$vuetify.breakpoint.smAndDown ? '' : addNewEvent ? 'Cancel' : 'Add Event'"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="expandEvents = !expandEvents"
                :prepend-icon="!expandEvents ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            ></a-btn>
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
            <a-btn
                color="primary"
                :disabled="!newEvent.id || !newEvent.initialCompanyEventStatusTypeId"
                @click="addEventToProcessStep"
                text="Save"
            ></a-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandEvents">
          <v-col cols="12" class="pt-0">
            <v-data-table
                :headers="headers"
                :items="filteredEvents"
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
                    <a-btn
                        variant="text"
                        color="primary"
                        v-if="userCanEdit"
                        icon
                        size="small"
                        class="handle"
                        prepend-icon="drag_handle"
                    ></a-btn>
                  </td>
                  <td class="text-left">{{ item.eventName }}</td>
                  <td class="text-left">{{ item.initialEventStatusType }}</td>
                  <td>
                    <div class="d-flex justify-end" :class="{'flex-column' : $vuetify.breakpoint.smAndDown}">
                      <a-btn
                          size="small"
                          variant="text"
                          :to="`/settings/event/${item.eventId}/components`"
                          target="_blank"
                          :html-html-style="{'text-decoration': 'none'}"
                          prepend-icon="mdi-cogs"
                          color="primary"
                      ></a-btn>
                      <a-btn
                          :disabled="!userCanEdit"
                          size="small"
                          variant="text"
                          color="primary"
                          @click="router.push({ path: `/settings/processStep/${processStepId}/event/${item.id}` })"
                          prepend-icon="edit"
                      ></a-btn>
                      <a-btn
                          :disabled="!userCanDelete"
                          size="small"
                          variant="text"
                          color="primary"
                          @click="[itemToDelete=item, showDeleteDialog=true]"
                          prepend-icon="delete"
                      ></a-btn>
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

<script setup>


import orderBy from 'lodash.orderby'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  defineSortableTable
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

onMounted(async () => {
  defineSortableTable('.event-table tbody', events, 'displayOrder', saveRowChanges)

  await getEvents()
})

const expandEvents = ref(true)
const companyEventStatuses = ref([])
const processStepStatuses = ref([])
const newEventStatuses = ref([])
const addNewEvent = ref(false)
const newEvent = ref({})
const events = ref([])
const availableEvents = ref([])
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const headers = ([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Event', value: 'eventName', show: true},
  {text: 'Initial Status', value: 'initialEventStatusType', show: true},
  {text: null, value: 'icons', show: true}
])

const processStepId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')
})
const filteredEvents = computed(() => {
  return orderBy(events.value.filter(e => {
    return !e.archived
  }), [e => e.displayOrder])
})

const getEvents = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/processStep/${processStepId.value}/event/admin`)
    events.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getAvailableEvents = async () => {
  if (addNewEvent.value) {
    appStore.loading = true
    try {
      const {data} = await getRequest(`/processStep/${processStepId.value}/event/available`)
      availableEvents.value = data
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
}

const addEventToProcessStep = async () => {
  appStore.loading = true
  try {
    let params = {
      eventId: newEvent.value.id,
      initialCompanyEventStatusTypeId: newEvent.value.initialCompanyEventStatusTypeId
    }
    const {data} = await postRequest(`/processStep/${processStepId.value}/event`, params)
    events.value.push(data)
    newEvent.value = {}
    addNewEvent.value = false
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Event')
    appStore.loading = false
  }
}
const deleteEventFromStep = async () => {
  const item = itemToDelete.value
  appStore.loading = true
  try {
    await deleteRequest(`/processStep/${processStepId.value}/event/${item.id}`)
    item.archived = true
    snackbar('SUCCESS', 'Event Deleted')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Event')
    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    appStore.loading = true
    try {
      await putRequest(`/processStep/${processStepId.value}/event/order`, rows)
      snackbar('SUCCESS', 'Event Order Saved')
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Event Order')
      appStore.loading = false
    }
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
const goToPath = (path) => {
  router.push({path: `${path}`})
}
</script>

<style scoped lang="scss">
.required-field-label {
  width: 100px;
}
</style>
