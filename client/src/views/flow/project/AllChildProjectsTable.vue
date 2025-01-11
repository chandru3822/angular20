<template>
  <v-row no-gutters id="project-children-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-expand-transition>
        <v-col>
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <v-toolbar color="white" class="elevation-1">
                    <v-toolbar-title class="app-title">All Child Projects</v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                      <a-btn variant="text" text="Cancel" :to="`/project/${projectId}/children`"></a-btn>
                      <a-btn variant="text" color="primary" text="Save Changes"
                             :disabled="dirtyFields?.length === 0"
                             @click="saveChanges()"></a-btn>
                    </v-toolbar-items>
                  </v-toolbar>
                </v-col>
              </v-row>
            </v-col>

            <v-col cols="12" v-if="isChildProjectsLoading">
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <v-data-table
                  :headers="headers"
                  :items="childProjects"
                  item-key="id"
                  :fixed-header="true"
                  :options.sync="options"
                  :footer-props="footerProps"
                  :items-per-page="-1"
                  :loading="isChildProjectsLoading"
                  dense
                  class="elevation-1"
              >

                <template #no-data>
                  No child projects found
                </template>

                <template #no-results>
                  No child projects found
                </template>

                <template #header="{ props: { headers } }">
                  <tr>
                    <th v-for="header in headers" :key="header.text" class="project-children-filter-header">
                      <div v-if="header.value === 'projectName'" class="pt-2 table-filter">
                        <a-text-field v-model="projectSearch"
                                      class="mx-2"
                                      :placeholder="'Search ' + header.text"
                                      clearable
                                      density="compact"
                                      variant="outlined"
                                      hide-details
                        ></a-text-field>
                      </div>
                      <div v-if="header.key === 28136" class="pt-2 table-filter">
                        <a-text-field v-model="phaseSearch"
                                      class="mx-2"
                                      :placeholder="'Search ' + header.text"
                                      clearable
                                      density="compact"
                                      variant="outlined"
                                      hide-details
                        ></a-text-field>
                      </div>
                    </th>
                  </tr>
                </template>

                <template #item="{ item, index }">
                  <tr :class="{'shaded-row': index % 2}">
                    <td class="text-left pl-4" :style="{background: index % 2 ? 'var(--v-primary-lighten9) !important' : 'white'}">{{item.projectName}}</td>
                    <td class="text-left pl-4" v-for="h in headers.filter(h => h.showInLoop)">
                      <DatetimePickerInput
                          v-if="h.dataTypeId === 1"
                          v-model="item[h.customFieldGroupAssignmentId]"
                          :timezone="timezone"
                          :type="'date'"
                          dense="compact"
                          :format="'MMMM DD, YYYY'"
                          hide-details
                          hide-prepend-icon
                          :change-callback="() => { populateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId]) }"
                      />
                      <DatetimePickerInput
                          v-else-if="h.dataTypeId === 2"
                          v-model="item[h.customFieldGroupAssignmentId]"
                          :timezone="timezone"
                          :type="'timestamp'"
                          :format="'MMMM DD, YYYY, h:mm A'"
                          hide-prepend-icon
                          hide-details
                          dense="compact"
                          :change-callback="() => { populateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId]) }"
                      />
                      <v-checkbox v-else-if="h.dataTypeId === 3"
                                  @change="populateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"
                                  v-model="item[h.customFieldGroupAssignmentId]"></v-checkbox>
                      <v-text-field v-else-if="h.dataTypeId === 5"
                                    v-model="item[h.customFieldGroupAssignmentId]"
                                    @change="populateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"/>
                      <a-autocomplete attach
                                      v-model="item[h.customFieldGroupAssignmentId]"
                                      v-else-if="h.dataTypeId === 9"
                                      :items="h.listOfValues"
                                      no-data-text="No Values Available"
                                      clearable
                                      density="compact"
                                      hide-details
                                      @input="populateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"
                                      item-title="name"
                                      item-value="id"
                      ></a-autocomplete>
                    </td>
                  </tr>
                </template>
              </v-data-table>

            </v-col>

          </v-row>
        </v-col>
      </v-expand-transition>
    </v-col>

    <ConfirmationDialog :open-dialog="unsavedModal" @confirm="[goToProject()]"
                        @close-dialog="unsavedModal = false">
      <template v-slot:title>Unsaved Changes</template>
      You have unsaved changes. Are you sure you want to continue without saving?
      <template v-slot:yes>Exit Without Saving</template>
      <template v-slot:no>Stay and Keep Editing</template>
    </ConfirmationDialog>
  </v-row>
</template>

<script setup>

import {getRequest, logError, getProjectPath, putRequest} from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {onBeforeRouteLeave, onBeforeRouteUpdate, useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import constants from "@/helpers/constants.js";
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const defaultProjectPage = ref(getProjectPath().pathSuffix)
let count = ref(0)
const props = defineProps({
  project: Object
})
const { project } = toRefs(props)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const timezone = computed(() => {
  return userStore.timezone.value
})

const childProjects = ref([])
const projectSearch = ref('')
const phaseSearch = ref('')
const dirtyFields = ref([])
const menuOpen = ref(false)
const isChildProjectsLoading = ref(false)
const options = ref({itemsPerPage: 25})
const unsavedModal = ref(false);
const override = ref(false);
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  // { text: '', value: 'selectBox', selectFilter:true, showInLoop: false, width: '50px' },
  {text: 'Project Name', value: 'projectName', showInLoop: false, width: 200, filter: value => {if (!projectSearch.value) {return true} else {return value.toLowerCase().includes(projectSearch.value.toLowerCase())}}},
])

onMounted(async () => {
  isChildProjectsLoading.value = true
  let requests = [getChildProjectHeaders(), getChildProjects()]
  await Promise.all(requests).then(async () => {
    isChildProjectsLoading.value = false
  })
})

onBeforeRouteUpdate(async (to, from, next) => {
  if (!override.value && dirtyFields.value?.length > 0) {
    unsavedModal.value = true
  } else {
    next()
  }
})

onBeforeRouteLeave(async (to, from, next) => {
  if (!override.value && dirtyFields.value?.length > 0) {
    unsavedModal.value = true
  } else {
    next()
  }
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})

const companyId = computed(() => {
  return userStore.details.companyId
})

const populateDirtyFields = (cfgaId, projectId, value) => {
  let matchingIndex = dirtyFields.value.findIndex((field) => field.customFieldGroupAssignmentId === cfgaId && field.projectId === projectId)

  if(matchingIndex !== -1) {
    dirtyFields.value[matchingIndex].value = value
  } else {
    dirtyFields.value.push({
      customFieldGroupAssignmentId: cfgaId,
      projectId,
      value
    })
  }

}

const goToProject = () => {
  override.value = true
  router.push({path: `/project/${projectId.value}/children`})
}

const saveChanges = async () => {
  appStore.loading = true
  try {
    await putRequest(`/project/${projectId.value}/children/details`, dirtyFields.value)
    dirtyFields.value = []
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Saving Changes')
  } finally {
    appStore.loading = false
  }
}

const getChildProjectHeaders = async () => {
  try {
    const {data} = await getRequest(`/project/childrenHeaders`)
    data.forEach(d => {
      let header = { ...d,
        text: d.fieldName,
        key: d.customFieldGroupAssignmentId,
        value: d.customFieldGroupAssignmentId.toString(),
        showInLoop: true,
        width: getColumnWidth(d.dataTypeId),
        filter: d.customFieldGroupAssignmentId === 28136 ? value => {if (!phaseSearch.value) {return true} else {return value?.toLowerCase().includes(phaseSearch.value?.toLowerCase())}} : null
      }
      headers.value.push(header)
    })
  } catch (e) {
    logError(e)
  }
}

const getColumnWidth = (dataTypeId) => {
  switch (dataTypeId) {
    case 1: return 210
    case 2: return 250
    case 5: return 200
    case 8:
    case 9:
    case 10:
      return 200
    default: return 100
  }
}

const getChildProjects = async () => {
  try {
    isChildProjectsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/children/details`)
    childProjects.value = data
  } catch (e) {
    logError(e)
  }
}
</script>

<style lang="scss" scoped>
#project-details-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}

.project-title {
  font-size: 20px;
}
.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 20px;
  }
}
</style>

<style lang="scss">
#project-children-container .v-data-table__wrapper {
  height: calc(100vh - 230px);
  min-height: 300px;
}

.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}
.manage-btn {
  margin-left: 12px;
}

.project-children-filter-header {
  border-bottom: thin solid rgba(0, 0, 0, 0.12);
  padding-bottom: 8px;
}

#project-children-container table > tr > th:nth-child(1),
#project-children-container table > tbody > tr > td:nth-child(1),
#project-children-container table > thead > tr > th:nth-child(1) {
   position: sticky !important;
   position: -webkit-sticky !important;
   left: 0;
   z-index: 9998;
   background: white;
 }
#project-children-container table > thead > tr > th:nth-child(1) {
  z-index: 9999 !important;
}
</style>
