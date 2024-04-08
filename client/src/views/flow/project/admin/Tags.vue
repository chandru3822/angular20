<template>
  <div id="project-tag-admin">
    <v-row v-if="userIsAdmin">

      <v-col cols="12" class="pt-0">

        <v-toolbar flat class="project-header">
          <v-toolbar-title>Assigned Project Tags</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-menu
                v-model="displayDropdown"
                bottom
                offset-y
                min-width="350"
                :close-on-content-click="false"
            >
              <template #activator="{on}">
                <a-btn
                    variant="text"
                    color="primary"
                    size="small"
                    :activation-handler="on"
                    @click="[ getAllTags() ]"
                    prepend-icon="add"
                    :text="!isMobile ? 'Add Project Tag' : ''"
                ></a-btn>
              </template>

              <v-card class="pa-5">
                <a-select
                    v-model="selectedTag"
                    :items="availableTags"
                    @input="addTagToProject"
                    :loading="tagsLoading"
                    return-object
                    label="Select an Available Tag"
                    item-title="tagName"
                    item-value="id"
                ></a-select>
              </v-card>
            </v-menu>
          </v-toolbar-items>
        </v-toolbar>

        <v-divider></v-divider>

        <v-row class="pl-4">
          <v-col cols="12">
            <v-list>
              <v-list-item v-for="(tag, index) in filteredProjectTags"
                           :key="index">
                <v-list-item-title>
                  {{ tag.tagName }}
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="removeTagFromProject(tag)"
                      prepend-icon="delete"
                  ></a-btn>
                </v-list-item-title>
              </v-list-item>
            </v-list>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <v-divider/>
    <div>
      <v-data-table class="pa-5 ma-3"
                    :items="tag_entries"
                    :headers="headers">
      </v-data-table>
    </div>

  </div>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,
  deleteRequest,

  logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import {DateTime} from "luxon";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
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
const vuetify = vueInstance.$vuetify

const projectTags = ref([])
const displayDropdown = ref(false)
const tagsLoading = ref(false)
const allTags = ref([])
const selectedTag = ref({})
const headers = ref([
  { text: 'Tag Name', value: 'tag'},
  { text: 'Date Created', value: 'date_added'},
  { text: 'Created By', value: 'usr_created'},
  { text: 'Date Removed', value: 'date_removed'},
  { text: 'Removed By', value: 'usr_removed'},
])
const tag_entries = ref([])

const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')
})
const filteredProjectTags = computed(() => {
  return projectTags.value.filter(pt => !pt.archived)
})
const availableTags = computed(() => {
  return allTags.value.filter(t => {
    return !filteredProjectTags.value.map(pt => pt.tagId).includes(t.id)
  })
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

onMounted(async() => {
  await getProjectTags()
  await getProjectTagHistory()
})

const getAllTags = async() => {
  if (allTags.value?.length === 0) {
    tagsLoading.value = true
    try {
      //for now this is just hardcoded to show project tags
      const {data, status} = await getRequest(`/tag/byType/1`)
      allTags.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    } finally {
      tagsLoading.value = false
    }
  }
}
const getProjectTags = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/tag/project/${projectId.value}`,
        {skipCancel: true}, null, [])
    projectTags.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error Loading Project Tags')

    appStore.loading = false
  }
}
const addTagToProject = async() => {
  appStore.loading = true
  try {
    displayDropdown.value = false
    const {data, status} = await postRequest(`/tag/project/${projectId.value}`, selectedTag.value)
    projectTags.value.push(data)
    selectedTag.value = {}
    handleHidingGlobalLoader( status)
    await getProjectTagHistory()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Tag to Project')

    appStore.loading = false
  }
}
const removeTagFromProject = async(item) => {
  appStore.loading = true
  try {
    const {data, status} = await deleteRequest(`/tag/project/${projectId.value}/${item.id}`)
    item.archived = true
    handleHidingGlobalLoader( status)
    await getProjectTagHistory()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Removing Tag From Project')

    appStore.loading = false
  }
}
const getProjectTagHistory = async() => {
  appStore.loading = true
  try {
    tag_entries.value = []
    const {data, status} = await getRequest(`/tag/project/${projectId.value}/tags`)
    for (const tg of data) {

      tag_entries.value.push(
          {
            tag: tg?.tagName,
            date_added: DateTime.fromISO(tg?.dateCreated).toFormat('MM-dd-yy H:mm a'),
            usr_created: tg?.fullNameCreatedBy,
            date_removed: tg?.dateCreated < tg?.dateModified ? DateTime.fromISO(tg?.dateModified).toFormat('MM-dd-yy H:mm a') : '',
            usr_removed: tg?.dateCreated < tg?.dateModified ? tg?.fullNameModifiedBy : '',
          }
      )
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tag History From Project')

    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
#project-tag-admin {
  background: #ffffff;
  height: calc(100vh - 250px)
}

.myData {
  color: var(--v-primary-base);
}
</style>
