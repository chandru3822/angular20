<template>
  <div>
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="title-large">
        SMS Messages
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <AlbatrossButton
            variant="text"
            color="primary"
            v-if="!addChildSms && userCanAdd"
            @click="[addChildSms = true, loadChildTemplates()]"
            prepend-icon="add"
        ></AlbatrossButton>
      </v-toolbar-items>
    </v-toolbar>
    <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
            v-if="addChildSms">
      <h3>Add Child Sms</h3>
      <v-autocomplete v-model="selectedTemplate"
                      :items="childSmsTemplates"
                      label="SMS Template"
                      item-text="title"
                      item-value="id"
                      return-object
                      @input="selectedTeams=[]"
                      attach
      ></v-autocomplete>
      <v-autocomplete v-if="selectedTemplate.id"
                      v-model="selectedTeams"
                      :items="selectedTemplate.teams"
                      label="Select SMS Team(s)"
                      item-text="teamName"
                      item-value="id"
                      multiple
                      return-object
                      attach
      ></v-autocomplete>
      <div class="mt-3">
        <AlbatrossButton
            :disabled="!selectedTemplate || selectedTemplate.id == null"
            color="primary"
            @click="saveSmsToAction()"
            prepend-icon="save"
            text="Save"
        ></AlbatrossButton>

        <AlbatrossButton
            class="ml-3"
            @click="addChildSms = false"
            variant="text"
            color="primary"
            prepend-icon="remove"
            text="Cancel"
        ></AlbatrossButton>

      </div>
    </v-card>
    <v-row justify="center" class="pl-3 pr-3"
           v-if="action.processStepEventActionChildSmsTemplates && action.processStepEventActionChildSmsTemplates.length > 0">
      <v-col cols="12" class="pt-0">
        <v-list v-for="(cp, index) in action.processStepEventActionChildSmsTemplates.filter(a => !a.archived)"
                :key="index"
                :class="{ 'shaded-row': index % 2 }">
          <v-list-item>
            <v-list-item-content class="text-left pb-0">
              <v-list-item-title>
                {{ cp.title }}
              </v-list-item-title>
              <v-list-item-content class="pb-0">
                <div class="d-flex">
                  Teams:
                  <p class="d-flex ml-2">
                    <span v-for="(team, idx) in cp.teams">
                    <span v-if="idx !== 0">,</span>
                      {{ team.teamName }}
                    </span>
                  </p>
                </div>
              </v-list-item-content>
            </v-list-item-content>

            <v-dialog
                v-if="userCanEdit"
                v-model="cp.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-list-item-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-item-action>
              </template>
              <v-card>
                <v-card-title
                    class="text-h5 grey lighten-2"
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete <strong>{{ cp.title }}</strong> from <strong>{{
                    action.actionName
                  }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <AlbatrossButton @click="cp.deleteConfirm = false" text="No"></AlbatrossButton>

                  <AlbatrossButton
                      color="primary"
                      variant="text"
                      @click="[cp.archived = true, deleteSmsFromAction(cp.id)]"
                      text="Yes"
                  ></AlbatrossButton>

                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  postRequest
} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  selectedActionIndex: Number,
  action: Object,
  processStepId: Number,
  addSmsCallback: Function,
  deleteSmsCallback: Function
})

const {selectedActionIndex, action, processStepId, addSmsCallback, deleteSmsCallback} = props

const addChildSms = ref(false)
const selectedTemplate = ref({})
const selectedTeams = ref([])
const childSmsTemplates = ref([])

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

const loadChildTemplates = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/messaging/templatesWithTeams`)
    childSmsTemplates.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Templates')
    appStore.loading = false
  }
}
const saveSmsToAction = async () => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/processStep/${processStepId}/event/${action.id}/addSmsToAction`, {
      messageTemplateId: selectedTemplate.value.id,
      teamIds: selectedTeams.value.map(m => m.id)
    })
    addSmsCallback(action.id, data)
    selectedTemplate.value = {}
    selectedTeams.value = []
    snackbar('SUCCESS', 'SMS Template Added To Event Action')
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding SMS Template to Event Action')
    appStore.loading = false
  }
}
const deleteSmsFromAction = async (id) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processStep/${processStepId}/event/${action.id}/deleteSms/${id}`)
    deleteSmsCallback(action.id, id)
    snackbar('SUCCESS', 'SMS Template Deleted From Event Action')
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting SMS Template From Event Action')
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">

</style>
