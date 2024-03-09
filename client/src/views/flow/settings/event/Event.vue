<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <AlbatrossButton
            variant="text"
            class="pl-1 pr-2 anchor"
            :to="'/settings/events'"
            color="unset"
            prepend-icon="arrow_left"
            text="Back"
        ></AlbatrossButton>
        <v-toolbar id="event-name-toolbar" flat class="app-toolbar">
          <span class="headline-small" v-if="!editName">{{ event.eventName }}</span>
          <v-text-field v-else color="primary" class=""
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        v-model="event.eventName"
                        hide-details
                        label="Event Name"></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
                variant="text"
                color="primary"
                v-if="userCanEdit && !editName"
                class=""
                @click="[oldName = event.eventName, editName = !editName]"
                prepend-icon="edit"
            ></AlbatrossButton>
            <AlbatrossButton
                variant="text"
                color="primary"
                class=""
                v-else-if="userCanEdit"
                @click="saveEventName()"
                prepend-icon="save"
            ></AlbatrossButton>
            <AlbatrossButton
                variant="text"
                color="primary"
                v-if="userCanEdit && editName"
                class=""
                @click="[event.eventName = oldName, editName = !editName]"
                :prepend-icon="$vuetify.breakpoint.smAndDown ? 'close': ''"
                :text="$vuetify.breakpoint.smAndDown ? '' : 'cancel'"
            ></AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs class="tabs-bar" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>

import {AppMutations} from "@/stores/AppStore";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {getRequest, putRequest} from "@/helpers/helpers";
import {useRoute} from "vue-router/composables"

import {ref, computed, onMounted, getCurrentInstance} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()
const vuetify = vueInstance.$vuetify

const editName = ref(false)
const oldName = ref(null)
const event = ref({})

const eventId = computed(() => {
  return route.params.id
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})


const activeTab = computed({
  get() {
    return route?.path?.includes('/attachmentType') ? `/settings/event/${eventId.value}/attachmentTypes` : null
  },
  set(val) {
    return val
  }
})
const tabs = computed(() => {
  return [
    {
      id: 1,
      label: 'Components',
      path: `/settings/event/${eventId.value}/components`,
    },
    {
      id: 2,
      label: 'Custom Field Groups',
      path: `/settings/event/${eventId.value}/customFieldGroups`,
    },
    {
      id: 3,
      label: 'Attachment Types',
      path: `/settings/event/${eventId.value}/attachmentTypes`,
    }
  ]
})
onMounted(async () => {
  await getEvent()
})
const getEvent = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data} = await getRequest(`/event/${eventId.value}`)
    event.value = data
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveEventName = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    await putRequest(`/event`, event.value)
    editName.value = false
    snackbar('SUCCESS', 'Event Updated')
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Event')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
<style lang="scss">
#event-name-toolbar > div {
  padding: 4px 0;
}

</style>
