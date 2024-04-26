<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="header-bar">
          <v-toolbar-title class="title-large text-wrap">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[addNewEventStatusType = !addNewEventStatusType, expanded = [], getCompanyEventStatusTypes()]"
                v-if="userCanAdd"
                :prepend-icon="!addNewEventStatusType ? 'add' : vuetify.breakpoint.mdAndUp ? '' : 'close'"
                :text="vuetify.breakpoint.mdAndUp ? (addNewEventStatusType ? 'Cancel' : 'Add Event Status Type') : ''"
            />
            <a-btn variant="text" color="primary" @click="expandEsst = !expandEsst"
                             :prepend-icon="!expandEsst ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <div class="mb-4">
          <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewEventStatusType">
            <h3>Assign a Status Type</h3>
            <a-autocomplete label="Event Status Type"
                            :items="availableCompanyEventStatusTypes"
                            v-model="newEventStatusTypeId"
                            item-title="eventStatusType"
                            item-value="id"
                            hide-details
                            :loading="companyStatusesLoading"
                            autocomplete="off"
            >
              <template #item="{ item }">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ item.eventStatusType }} ({{ item.rootEventStatusType }})
              </template>
            </a-autocomplete>
            <v-checkbox v-model="newEventStatusEditableInSchedule" label="Editable in Schedule"/>
            <AlbatrossButton @click="assignStatusTypeToEvent">Save</AlbatrossButton>
          </v-card>
          <v-data-table
            v-if="expandEsst"
            :headers="eventHeaders"
            :items="filterAssignedEventStatusTypes"
            hide-default-footer
            :items-per-page="-1"
            disable-sort
            class="elevation-1 square-card mb-2 table-striped"
          >
            <template #no-data>
              <span class="default-text-color">No available event status types</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available event status types</span>
            </template>


            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left"><a href="/settings/eventStatuses">{{ item.eventStatusType }}</a></td>
                <td class="text-left">{{ item.rootEventStatusType }}</td>
                <td class="text-left"><v-checkbox v-model="item.editableInSchedule" @change="saveEditableInSchedule(item)"/></td>
                <td>
                  <div class="flex-display align-center">
                    <a-btn
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanEdit"
                        @click="eventStatusTypeToDelete=item"
                        prepend-icon="delete"
                    ></a-btn>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>
        <ConfirmationDialog :open-dialog="!!eventStatusTypeToDelete" @confirm="deleteStatusTypeFromEvent" @close-dialog="eventStatusTypeToDelete=null">
          Are you sure you want to delete {{ eventStatusTypeToDeleteName }}?
        </ConfirmationDialog>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="header-bar">
          <v-toolbar-title class="title-large">Event Access Control</v-toolbar-title>
        </v-toolbar>
        <v-card flat color="rowShadeCustom" class="square-card mt-2 d-flex">
          <v-card-text class="d-flex flex-column">
            <multi-select-group
              v-if="!eventLoading"
              :userCanEdit="userCanEdit"
              :returnObject="event"
              :content="positions"
              :dropdownEnabled="event.hidden"
              :selectedContent="event.hiddenWhiteListedPositions"
              :title="'Hidden'"
              :label="'Allowed Positions'"
              :alternateLabel = "'Denied Positions'"
              :allow="event.hiddenAllow"
              :contentLoading="positionsLoading"
              :full-size="vuetify.breakpoint.smAndDown"
              :save-button="userCanEdit"
              @selected-changed="hiddenSelectedEventListener"
              @allow-changed="hiddenAllowEventListener"
              @checkbox-changed="hiddenCheckboxEventListener"
              @save-multi-select="saveHiddenAndWhiteList"
            ></multi-select-group>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {getAvailableForEvent} from '@/services/eventStatusTypeService'
import { getRequest, postRequest, deleteRequest, putRequest, handleHidingGlobalLoader} from "@/helpers/helpers";
import orderBy from "lodash.orderby"
import MultiSelectGroup from "@/components/MultiSelectGroup.vue"
import {ref, computed, onMounted, getCurrentInstance} from "vue"
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify

const expandEsst = ref(true)
const event = ref({})
const eventId = ref(route.params.id)
const availableCompanyEventStatusTypes = ref([])
const companyStatusesLoading = ref(false)
const addNewEventStatusType = ref(false)
const newType = ref({})
const newEventStatusTypeId = ref(null)
const newEventStatusEditableInSchedule = ref(false)

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})

const eventHeaders = ref([
  {text: 'Status Type', value: 'statusType', show: true},
  {text: 'Category', value: 'category', show: true},
  {text: 'Editable in Schedule', value: 'scheduleEditable', show: true},
  {text: '', value: 'icons', show: false, width: '100px'},

])
const eventStatusTypeToDelete = ref(null)
const positions = ref([])
const positionsLoading = ref(false)
const hiddenPositionsChanged = ref(false)
const eventLoading = ref(false)

onMounted (() => {
  getEvent()
  getPositions()
})
const getEvent = async  () => {
	appStore.loading = true
      try {
        eventLoading.value = true;
        const {data} = await getRequest(`/event/${eventId.value}`)
        event.value = data
        appStore.loading = false
        eventLoading.value = false;
      } catch (e) {
        console.error('*** ERROR ***', e)
		  appStore.showSnack('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      }
    }

const eventStatusTypeToDeleteName = computed(() => {
  return eventStatusTypeToDelete.value?.eventStatusType
})

const filterAssignedEventStatusTypes = computed(() => {
  return orderBy(event.value?.companyEventStatusTypes?.filter(u => {
    return !u.archived
  }), [f => f.eventStatusType])
})
const assignStatusTypeToEvent = async  () => {
  appStore.loading = true
  try {
    newType.value.eventId = route.params.id
    newType.value.editableInSchedule
    const {data} = await postRequest(`/event/status/assignCompanyStatus/${newEventStatusTypeId.value}/toEvent/${eventId.value}?editableInSchedule=${newEventStatusEditableInSchedule.value}`)
    event.value.companyEventStatusTypes.push(data)
    // reset fields
    addNewEventStatusType.value = false
    newEventStatusTypeId.value = null
	  appStore.showSnack('SUCCESS', 'Status Type Added')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
	  appStore.showSnack('ERROR', 'Error Adding Status Type')

    appStore.loading = false
  }
}

const deleteStatusTypeFromEvent = async() => {
  const item = eventStatusTypeToDelete.value
  appStore.loading = true
  try {
    item.archived = true
    await deleteRequest(`/event/${eventId.value}/companyStatus/${item.id}`)
    appStore.showSnack('SUCCESS', 'Event Status Type Deleted')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Event Status Type')
    appStore.loading = false
  } finally {
    eventStatusTypeToDelete.value = null
  }
}

const saveEditableInSchedule = async (item) => {
      appStore.loading = true
      try {
       await postRequest(`/event/status/updateEditableInSchedule/${item.companyEventStatusTypeId}/forEvent/${parseInt(eventId.value)}?editableInSchedule=${item.editableInSchedule}`)
        appStore.showSnack('SUCCESS', 'Editable in Schedule Updated')
        appStore.loading = false
      }catch (e){
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Updating Editable in Schedule')
        appStore.loading = false
      }
    }
const getCompanyEventStatusTypes = async () => {
  if(addNewEventStatusType.value) {
    companyStatusesLoading.value = true
    try {
      const {data} = await getAvailableForEvent(eventId.value)
      availableCompanyEventStatusTypes.value = data
      companyStatusesLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
		appStore.showSnack('ERROR', 'Error Retrieving Event Status Types')

      companyStatusesLoading.value = false
    }
  }

}

const selectAllHidden = () => {
  return event.value.hiddenWhiteListedPositions?.length === positions.value?.length
}
const selectSomeHidden = (f) => {
  return event.value.hiddenWhiteListedPositions?.length > 0 && !selectAllHidden(f)
}
const icon = () => {
  if (selectAllHidden()) {
    return 'check_box'
  }
  if (selectSomeHidden()) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const getPositions = async () => {
  if(positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
       handleHidingGlobalLoader( status)
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
		appStore.showSnack('ERROR', 'Error Retrieving Positions')
      appStore.loading = false
    }
  }
}
const saveHiddenAndWhiteList = async () => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/event/saveHiddenAndWhiteList?positionsChanged=${event.value.hiddenPositionsChanged ?? false}`, event.value)
    hiddenPositionsChanged.value = false
    if(!event.value.hidden) {
      event.value.hiddenWhiteListedPositions = []
    }
    appStore.showSnack('SUCCESS', 'Saved Successfully')
     handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
	  appStore.showSnack('ERROR', 'Error Saving Event Access Control')
    appStore.loading = false
  }
}
const hiddenSelectedEventListener = (e) => {
  event.value.hiddenWhiteListedPositions = e;
  event.value.hiddenPositionsChanged = true;
}
const hiddenAllowEventListener = (e) => {
  event.value.hiddenAllow = (e === 0);
}
const hiddenCheckboxEventListener = (e) => {
  event.value.hidden = e;
}

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.header-bar {
  border-bottom: 1px solid #E6E6E6;

}

</style>
