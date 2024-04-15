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
              v-if="userCanEdit"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="constants.IS_MOBILE ? 'add' : ''"
              :text="addTemplate ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addTemplate" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Template</h3>
          <a-text-field  v-model="newTemplate.title"
                        label="Title" />
          <a-textarea v-model="newTemplate.message"
                      label="Message" />
          <a-autocomplete v-model="newTemplate.teamIds"
                          :items="selectableTeams"
                          item-title="teamName"
                          item-value="id"
                          multiple
                          placeholder="Select Team(s)"
                          height="35px"
                          variant="outlined"
                          class="team-select"
          >
            <template  v-slot:selection="{item, index}">
              <v-chip small v-if="index === 0 && newTemplate.teamIds && newTemplate.teamIds.length < 2">
                <span>{{ item.teamName }}</span>
              </v-chip>
              <span
                v-if="index === 1 && newTemplate.teamIds && newTemplate.teamIds.length >= 2"
                class="primary--text caption"
              >{{ newTemplate.teamIds.length }} selected</span>
            </template>
          </a-autocomplete>
          <a-btn
            variant="text"
            color="primary"
            @click="[addTemplate = !addTemplate, newTemplate = {}]"
            text="CANCEL"
          />
          <a-btn
            :disabled="!newTemplate.title || !newTemplate.message"
            color="primary"
            class="white--text mr-2"
            @click="saveTemplate(newTemplate, true)"
            text="SAVE"
          />
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterTemplates"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 org-type-table"
        >
          <template v-slot:header.teamIds="{ header }">
            <div class="d-flex align-baseline filter-dropdown"> <div>{{ header.text }}<v-icon small @click="showFilter = !showFilter">mdi-filter</v-icon></div>
            <a-autocomplete v-if="showFilter"
                            v-model="teamFilter"
                            :items="selectableTeams"
                            item-title="teamName"
                            item-value="id"
                            clearable
                            autofocus
                            placeholder="Enter Team Name"
                            class="pl-3 font-weight-regular albatross-body-2"
            ></a-autocomplete>
           </div>
          </template>
          <template #no-data>
            <span class="default-text-color">No templates available</span>
          </template>
          <template #no-results>
            <span class="default-text-color">No templates match your selection</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-6" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <a-text-field  v-model="item.title" label="Template Name" class="pb-4"/>
              <a-textarea v-model="item.message"
                          label="Template Message"
                          auto-grow
                          variant="outlined"
              ></a-textarea>


              <a-autocomplete v-model="item.teamIds"
                              :items="selectableTeams"
                              item-title="teamName"
                              item-value="id"
                              multiple
                              label="Teams"
                              class="team-select mt-0 pb-3"
              >

              </a-autocomplete>

              <a-btn
                color="primary"
                class="white--text mr-2"
                :disabled="!item.title || !item.message" @click="saveTemplate(item, false)"
                text="SAVE"
              />
            </td>
          </template>

          <template #item="{ item }">
            <tr  class="text-left" :class="{'shaded-row': filterTemplates.indexOf(item) % 2}">
              <td class="text-left">{{ item.title }}</td>
              <td class="">{{getTeamsForTemplate(item)}}</td>
              <td class="text-right flex-display align-center">
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="!expanded.includes(item) && userCanEdit"
                  @click="expanded = [item]; expandedItem = item;"
                  prepend-icon="edit"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="!expanded.includes(item) && userCanEdit" @click="templateToDelete=item"
                  prepend-icon="delete"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="expanded.includes(item)"
                  @click="expanded = []"
                  text="CANCEL"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!templateToDelete" @confirm="deleteTemplate" @close-dialog="templateToDelete=null">
      Are you sure you want to delete this template?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {
  handleHidingGlobalLoader,
  putRequest,
  getRequest,
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'


import {computed, getCurrentInstance, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const vueInstance = getCurrentInstance().proxy

const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()

const templates = ref([])
const newTemplate = ref({})
const addTemplate = ref(false)
const addTeam = ref(false)
const teamFilter = ref(null)
const showFilter = ref(false)
const levels = ref([])
const expanded = ref([])
const expandedItem = ref([])
const showDeleteDialog = ref(false)
const teams = ref([])
const selectableTeams = ref([])
const templateToDelete = ref(null)
const headers = ref([
  {text: 'Template Title', value: 'title', show: true },
  {text: 'Teams', value: 'teamIds', show: true, sortable: false, filter: value => {
      if(!value || !teamFilter.value) {
        return true
      }
      return value.includes(teamFilter.value)
    }
  },
  { text: null, value: 'icons', show: true, sortable: false }
])

const filterTemplates = computed(() => {
  return templates.value.filter(tmp => !tmp.archived)
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE')
})

const getTemplates = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/messaging/templates`)
    templates.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Templates')
    appStore.loading = false
  }
}
const saveTemplate = async (template, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/messaging/template`, template)
    if(isNew){
      templates.value.push(data)
      addTemplate.value = false
      newTemplate.value = {}
      appStore.showSnack('SUCCESS', 'Template Added')
    } else {
      expanded.value = []
      appStore.showSnack('SUCCESS', 'Template Updated')
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', isNew ? 'Error Adding Template' : 'Error Updating Template')

    appStore.loading = false
  }
}
const deleteTemplate = async () => {
  const template = templateToDelete.value
  try {
    const {status} = await putRequest(`/messaging/template/delete/${template.id}`)
    showDeleteDialog.value = false
    template.archived = true
    appStore.showSnack('SUCCESS', 'Template Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Template')
    appStore.loading = false
  }
}
const getTeams = async () => {
  try {
    const {data} = await getRequest(`/smsTeam`)
    selectableTeams.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving teams')
  }
}

const getTeamsForTemplate = (template) => {
  const teamNames = selectableTeams.value.filter(team => template.teamIds.includes(team.id)).map(team => {
    return team.teamName
  })
  return teamNames.join(", ")
}
onMounted(async () => {
  await getTemplates()
  await getTeams()
})

</script>

<style lang="scss">
#hierarchy-container .v-data-table__wrapper {
  height: calc(100vh - 200px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>

.filter-dropdown {
  width: 50%;
}

.team-select {
  width: 450px;
}

.wqt-header-bar {
  border-bottom: 1px solid #E6E6E6;
  border-top: 1px solid #E6E6E6;
}
</style>
