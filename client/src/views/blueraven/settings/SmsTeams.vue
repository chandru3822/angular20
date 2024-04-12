<template>
  <v-container id="hierarchy-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Message Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[addTemplate = !addTemplate, newType = {}]"
                v-if="userStore.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')"
                prepend-icon="add"
                :text="addTemplate ? 'Cancel' : 'Add New'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addTemplate" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Template</h3>
          <a-text-field v-model="newTemplate.title"
                        label="Title" />
          <a-textarea v-model="newTemplate.message"
                      label="Message" />
          <a-autocomplete v-model="newTemplate.teamIds"
                          :items="selectableTeams"
                          item-title="fullName"
                          item-value="positionId"
                          multiple
                          placeholder="Select Team(s)"
                          height="35px"
                          outlined
                          class="team-select"
          >
            <template  v-slot:selection="{item, index}">
              <v-chip small v-if="index === 0 && newTemplate.teamIds && newTemplate.teamIds.length < 2">
                <span>{{ item.fullName }}</span>
              </v-chip>
              <span
                  v-if="index === 1 && newTemplate.teamIds && newTemplate.teamIds.length >= 2"
                  class="primary--text caption"
              >{{ newTemplate.teamIds.length }} selected</span>
            </template>
          </a-autocomplete>

          <a-btn
              :disabled="!newTemplate.title || !newTemplate.message || newTemplate.teamIds.length < 1"
              color="primary"
              class="mr-2"
              @click="saveTemplate(newTemplate, true)"
              text="Save"
          ></a-btn>
          <a-btn
              @click="[addTemplate = !addTemplate, newTemplate = {}]"
              color="unset"
              text="Cancel"
          ></a-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filteredTemplates"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filteredTemplates.indexOf(item) % 2}">
              <h3>Edit Template</h3>
              <a-text-field v-model="item.title" label="Title" />
              <a-textarea v-model="item.message"
                          label="Message"
                          auto-grow
              ></a-textarea>

              <a-autocomplete v-model="item.teamIds"
                              :items="selectableTeams"
                              item-title="fullName"
                              item-value="positionId"
                              multiple
                              placeholder="Select Team(s)"
                              height="35px"
                              outlined
                              class="team-select"
              >
                <template  v-slot:selection="{item, index}">
                  <v-chip small v-if="index === 0 && expandedItem.teamIds && expandedItem.teamIds.length < 2">
                    <span>{{ item.fullName }}</span>
                  </v-chip>
                  <span
                      v-if="index === 1 && expandedItem.teamIds && expandedItem.teamIds.length >= 2"
                      class="primary--text caption"
                  >{{ expandedItem.teamIds.length }} selected</span>
                </template>
              </a-autocomplete>

              <a-btn
                  color="primary"
                  class="mr-2"
                  :disabled="!item.title || !item.message || item.teamIds.length < 1"
                  @click="saveTemplate(item, false)"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': filteredTemplates.indexOf(item) % 2}">
              <td class="text-left">{{ item.title }}</td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    v-if="!expanded.includes(item) && userStore.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')"
                    @click="expanded = [item]; expandedItem = item"
                    color="unset"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    v-if="expanded.includes(item)"
                    @click="expanded = []"
                    color="unset"
                    text="cancel"
                ></a-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, putRequest,  getRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const templates = ref([])
const newTemplate = ref({})
const addTemplate = ref(false)
const levels = ref([])
const headers = ref([
  { text: 'Title', value: 'title', show: true },
  { text: null, value: 'icons', show: true, sortable: false }
])
const expanded = ref([])
const expandedItem = ref([])
const showDeleteDialog = ref(false)
const teams = ref([])
const selectableTeams = ref([])

onMounted(() => {
  getTemplates()
  getTeams()
})

const filteredTemplates = computed(() => {
  return templates.value.filter(tmp => !tmp.archived)
})

const getTemplates = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/messaging/templates`)
    templates.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Templates')

    appStore.loading = false
  }
}
const saveTemplate = async(template, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/messaging/template`, template)
    if(isNew){
      templates.value.push(data)
      addTemplate.value = false
      newTemplate.value = {}
      snackbar('SUCCESS', 'Template Added')

    } else {
      expanded.value = []
      snackbar('SUCCESS', 'Template Updated')

    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Template' : 'Error Updating Template')

    appStore.loading = false
  }
}
const deleteTemplate = async(template) => {
  try {
    const {status} = await putRequest(`/messaging/template/delete/${template.id}`)
    showDeleteDialog.value = false
    template.archived = true
    snackbar('SUCCESS', 'Template Deleted')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Template')

    appStore.loading = false
  }
}
const getTeams = async() => {
  try {
    const {data} = await getRequest(`/smsTeam`)
    selectableTeams.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving teams')

  }
}

</script>

<style lang="scss">
#hierarchy-container .v-data-table__wrapper {
  height: calc(100vh - 200px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.team-select {
  width: 450px;
}
</style>
