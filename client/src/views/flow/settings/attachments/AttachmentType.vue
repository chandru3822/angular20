<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <AlbatrossButton variant="text" color="primary" class="pl-1 pr-2" :to="'/settings/attachments'"
                         prepend-icon="arrow_left"
                         text="BACK"

        />
        <v-toolbar flat class="app-toolbar">
          <span class="headline-small" v-if="!editName">{{ attachment.attachmentType }}</span>
          <v-text-field v-else color="primary"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        v-model="attachment.attachmentType"
                        hide-details
                        label="Event Name"></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text" v-if="userCanEdit && !editName" color="primary" class=""
                             @click="[oldName = attachment.attachmentType, editName = !editName]"
                             prepend-icon="edit"/>
            <AlbatrossButton variant="text" color="primary" class="" v-else-if="userCanEdit"
                             @click="saveAttachmentType()"
                             prepend-icon="save"
            />
            <AlbatrossButton variant="text" color="primary" v-if="userCanEdit && editName" class=""
                             @click="[attachment.attachmentType = oldName, editName = !editName]"
                             text="CANCEL"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-tabs class="tabs-bar">
          <v-tab :to="`/settings/attachment/${attachmentTypeId}/customFieldGroups`">
            Custom Field Groups
          </v-tab>
        </v-tabs>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {getCurrentInstance, onMounted, ref, computed} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const editName = ref(false)
const oldName = ref(null)
const attachment = ref({})

const attachmentTypeId = computed(() => {
  return route.params.id
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})

onMounted(async () => {
  await getAttachmentType()
})
    const getAttachmentType = async () => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/attachmentType/type/${attachmentTypeId.value}`)
        attachment.value = data
        store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const saveAttachmentType = async () => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/attachmentType/type`, attachment.value)
        editName.value = false
        snackbar('SUCCESS', 'Attachment Type Updated')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving Attachment Type')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
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
