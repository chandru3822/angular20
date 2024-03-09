<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="header-bar">
          <v-toolbar-title class="title-large text-wrap">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNewEventStatusType = !addNewEventStatusType, expanded = [], getCompanyEventStatusTypes()]"
              v-if="userCanAdd"
              :prepend-icon="!addNewEventStatusType ? 'add' : ''"
              :text="vuetify.breakpoint.mdAndUp ? (addNewEventStatusType ? 'Cancel' : 'Add Event Status Type') : ''"
            />
            <AlbatrossButton variant="text" color="primary" @click="expandEsst = !expandEsst"
               :prepend-icon="!expandEsst ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            />
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


                <template #item.statusType="{item}" class="text-left"><a href="/settings/eventStatuses">{{ item.eventStatusType }}</a></template>
                <template #item.category="{item}" class="text-left">{{ item.rootEventStatusType }}</template>
                <td class="text-right">
                  <div class="flex-display align-center">
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="userCanEdit"
                      @click="eventStatusTypeToDelete=item"
                      prepend-icon="delete"
                    />
                  </div>
                </td>

          </v-data-table>
        </div>
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
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {getAvailableForEvent} from '@/services/eventStatusTypeService'
import {deleteRequest, getRequest, getSnackbar, postRequest, putRequest, handleHidingGlobalLoader} from "@/helpers/helpers";
import orderBy from "lodash.orderby"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import cloneDeep from "lodash.clonedeep";
import MultiSelectGroup from "@/components/MultiSelectGroup.vue";

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {ref, computed, onMounted, getCurrentInstance} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const route = vueInstance.$route
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const addNewType = ref(false)
const expandEsst = ref(true)
const event = ref({})
const availableCompanyEventStatusTypes = ref([])
const companyStatusesLoading = ref(false)
const addNewEventStatusType = ref(false)
const newType = ref({})
const newEventStatusTypeId = ref(null)
const combinedStatuses = ref([ {header: 'Category'} ])
const companyEventStatusTypes = ref([])
const eventStatusTypes = ref([])
const eventHeaders = ref([
  {text: 'Status Type', value: 'statusType', show: true},
  {text: 'Category', value: 'category', show: true},
  {text: '', value: 'icons', show: false, width: '100px'},
])
const eventStatusTypeToDelete = ref(null)
const attachmentTypeToDelete = ref(null)
const positions = ref([])
const positionsLoading = ref(false)
const hiddenPositionsChanged = ref(false)
const eventLoading = ref(false)

const eventId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

const eventStatusTypeToDeleteName = computed(() => {
  return eventStatusTypeToDelete.value ? eventStatusTypeToDelete.value.eventStatusType : ''
})
const attachmentTypeToDeleteType = computed(() => {
  return attachmentTypeToDelete.value ? attachmentTypeToDelete.value.attachmentType : ''
})

onMounted (() => {
  getEvent()
  getPositions()
})
const getEvent = async  () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    eventLoading.value = true;
    const {data} = await getRequest(`/event/${eventId.value}`)
    event.value = data
    store.commit(AppMutations.SET_LOADING, false)
    eventLoading.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const filterAssignedEventStatusTypes = computed(() => {
  return orderBy(event.value?.companyEventStatusTypes?.filter(u => {
    return !u.archived
  }), [f => f.eventStatusType])
})
const assignStatusTypeToEvent = async  () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    newType.value.eventId = route.params.id
    const {data} = await postRequest(`/event/status/assignCompanyStatus/${newEventStatusTypeId.value}/toEvent/${eventId.value}`)
    event.value.companyEventStatusTypes.push(data)
    // reset fields
    addNewEventStatusType.value = false
    newEventStatusTypeId.value = null
    snackbar('SUCCESS', 'Status Type Added')

    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Status Type')

    store.commit(AppMutations.SET_LOADING, false)
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
      snackbar('ERROR', 'Error Retrieving Event Status Types')

      companyStatusesLoading.value = false
    }
  }

}
const deleteStatusTypeFromEvent = async  () => {
  const item = eventStatusTypeToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    item.archived = true
    await deleteRequest(`/event/${eventId.value}/companyStatus/${item.id}`)
    snackbar('SUCCESS', 'Event Status Type Deleted')

    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Event Status Type')

    store.commit(AppMutations.SET_LOADING, false)
  }
  eventStatusTypeToDelete.value = null
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
const toggleSelectAllPositionsOwner = () => {
  vueInstance.$nextTick(() => {
    if (selectAllHidden()) {
      event.value.hiddenWhiteListedPositions = []
      hiddenPositionsChanged.value = true
    } else {
      event.value.hiddenWhiteListedPositions = cloneDeep(positions.value)
      hiddenPositionsChanged.value = true
    }
  })
}
const getPositions = async () => {
  if(positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const saveHiddenAndWhiteList = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/event/saveHiddenAndWhiteList?positionsChanged=${event.value.hiddenPositionsChanged ?? false}`, event.value)
    hiddenPositionsChanged.value = false
    if(!event.value.hidden) {
      event.value.hiddenWhiteListedPositions = []
    }
    snackbar('SUCCESS', 'Saved Successfully')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Event Access Control')
    store.commit(AppMutations.SET_LOADING, false)
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
