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
                    <v-toolbar-title class="headline-medium albatross-header-1 align-center">
                      <router-link :to="`/project/${projectId}/children`" @click="$emit('click')">
                        {{parentProject?.projectName}}
                      </router-link>
                      <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
                      <span class="title-medium">All Child Projects</span>
                    </v-toolbar-title>
                    <v-toolbar-items>
                      <a-btn variant="text" text="Export" prepend-icon="mdi-tray-arrow-down" @click="exportToCsv" />
                    </v-toolbar-items>
                    <v-spacer/>
                    <v-toolbar-items>
                      <a-btn variant="text" text="Discard Changes"
                             @click="discardModal = true"
                             :disabled="disabledSave" />
                    </v-toolbar-items>
                    <a-btn prepend-icon="mdi-content-save" text="Save"
                           :disabled="disabledSave"
                           @click="saveChanges"/>
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
                  :items="filteredChildProjects"
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
                    <td
                      class="text-left pl-6"
                      :style="{background: index % 2 ? 'var(--v-primary-lighten9) !important' : 'white'}"
                    >
                      <router-link :to="`/project/${item.id}/status`" target="_blank">
                        {{ item.projectName }}
                      </router-link>
                    </td>
                    <td
                      class="text-left pl-6"
                      :class="{
                        'shrink': focusedInput === `${index}-${h.customFieldGroupAssignmentId}` && filteredChildProjects.length > 1,
                        'normal': focusedInput !== `${index}-${h.customFieldGroupAssignmentId}` || filteredChildProjects.length <= 1,
                        'custom-column-width': h.dataTypeId !== DATA_FIELD_TYPES.DATE && h.dataTypeId !== DATA_FIELD_TYPES.TIMESTAMP && h.dataTypeId !== DATA_FIELD_TYPES.SYSTEM_LIST && h.dataTypeId !== DATA_FIELD_TYPES.BOOLEAN,
                        'custom-column-selector-width': h.dataTypeId === DATA_FIELD_TYPES.SYSTEM_LIST,
                        'custom-column-date-width': h.dataTypeId === DATA_FIELD_TYPES.DATE || h.dataTypeId === DATA_FIELD_TYPES.TIMESTAMP,
                        'custom-column-checkbox-width': h.dataTypeId === DATA_FIELD_TYPES.BOOLEAN,
                      }"
                      v-for="h in headers.filter(h => h.showInLoop)"
                      @focusin="handleFocusin(index, h.customFieldGroupAssignmentId)"
                      @focusout="handleFocusout"
                      tabindex="0"
                    >
                      <div class="input-container">
                        <a-btn class="pl-0"
                              v-if="h.dataTypeId === DATA_FIELD_TYPES.DATE || h.dataTypeId === DATA_FIELD_TYPES.TIMESTAMP"
                              icon
                              color="unset"
                              prepend-icon="mdi-calendar"
                              @click="populateField(h.customFieldGroupAssignmentId, item, getTodayDate(h.dataTypeId))"
                        />
                        <a-btn class="pl-0"
                               v-if="h.dataTypeId === DATA_FIELD_TYPES.SYSTEM_LIST && constantSystemListValues.includes(h.companySystemListId)"
                               icon
                               color="unset"
                               prepend-icon="mdi-account-arrow-right-outline"
                               @click="() => populateListOptionField(h, item)"
                        />
                        <DatetimePickerInput
                          v-if="h.dataTypeId === DATA_FIELD_TYPES.DATE"
                          v-model="item[h.customFieldGroupAssignmentId]"
                          tabindex="0"
                          :timezone="timezone"
                          :type="'date'"
                          dense="compact"
                          :format="'MMMM DD, YYYY'"
                          hide-details
                          hide-prepend-icon
                          :change-callback="() => {
                            debouncePopulateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])
                            delayFocusin(index, h.customFieldGroupAssignmentId)
                          }"
                        />
                        <DatetimePickerInput
                          v-else-if="h.dataTypeId === DATA_FIELD_TYPES.TIMESTAMP"
                          v-model="item[h.customFieldGroupAssignmentId]"
                          tabindex="0"
                          :timezone="timezone"
                          :type="'timestamp'"
                          :format="'MMMM DD, YYYY, h:mm A'"
                          hide-prepend-icon
                          hide-details
                          dense="compact"
                          :change-callback="() => { debouncePopulateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId]) }"
                        />
                        <v-checkbox v-else-if="h.dataTypeId === DATA_FIELD_TYPES.BOOLEAN"
                                    @input="debouncePopulateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"
                                    v-model="item[h.customFieldGroupAssignmentId]"></v-checkbox>
                        <v-text-field v-else-if="h.dataTypeId === DATA_FIELD_TYPES.TEXT"
                                      v-model="item[h.customFieldGroupAssignmentId]"
                                      @input="debouncePopulateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"/>
                        <a-autocomplete attach
                                        v-model="item[h.customFieldGroupAssignmentId]"
                                        v-else-if="h.dataTypeId === DATA_FIELD_TYPES.SYSTEM_LIST"
                                        :items="h.listOfValues"
                                        no-data-text="No Values Available"
                                        clearable
                                        density="compact"
                                        hide-details
                                        @input="debouncePopulateDirtyFields(h.customFieldGroupAssignmentId, item.id, item[h.customFieldGroupAssignmentId])"
                                        item-title="name"
                                        item-value="id"
                        />
                        <v-btn
                          small
                          v-show="focusedInput === `${index}-${h.customFieldGroupAssignmentId}` &&
                            filteredChildProjects.length > 1"
                          :disabled="!item[h.customFieldGroupAssignmentId] && h.dataTypeId !== DATA_FIELD_TYPES.BOOLEAN"
                          color="secondary"
                          class="ml-2 apply-to-btn"
                          @click="() => populateAllCfgaIdValues(h.customFieldGroupAssignmentId, item[h.customFieldGroupAssignmentId], item)"
                        >
                          {{ filteredChildProjects.length === childProjects.length ? 'Apply to All' : 'Apply to Filtered' }}
                        </v-btn>
                      </div>
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
    <ConfirmationDialog :open-dialog="discardModal" @confirm="[discardChanges()]"
                        @close-dialog="discardModal = false">
      <template v-slot:title>Discard Changes</template>
      Are you sure you want to discard any unsaved changes?
      <template v-slot:yes>Discard Changes</template>
      <template v-slot:no>Cancel</template>
    </ConfirmationDialog>
  </v-row>
</template>

<script setup>

import {getRequest, logError, getProjectPath, putRequest} from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch, nextTick } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {onBeforeRouteLeave, onBeforeRouteUpdate, useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import constants from "@/helpers/constants.js";
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { saveAs } from 'file-saver'
import debounce from "lodash.debounce";
import Vue from 'vue'

const { DATA_FIELD_TYPES, COMPANY_SYSTEM_LISTS } = constants
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const filters = vueInstance.$filters

const constantSystemListValues = Object.values(COMPANY_SYSTEM_LISTS)

const defaultProjectPage = ref(getProjectPath().pathSuffix)
let count = ref(0)
const props = defineProps({
  project: Object
})
const { project } = toRefs(props)
const parentProject = ref()

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const timezone = computed(() => {
  return userStore.timezone.value
})
const focusedInput = ref(null);
const currentFocusedInput = ref(null);
const childProjects = ref([])
const projectSearch = ref('')
const debouncedProjectSearch = ref('');
const phaseSearch = ref('')
const debouncedPhaseSearch = ref('');
const dirtyFields = ref({})
const menuOpen = ref(false)
const isChildProjectsLoading = ref(false)
const options = ref({itemsPerPage: 25})
const unsavedModal = ref(false);
const discardModal = ref(false);
const override = ref(false);
const preSaveSnapshot = ref([])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})

const filteredChildProjects = computed(() => {
  return childProjects.value.filter(p => {
    const projectNameMatch = !debouncedProjectSearch.value || p.projectName?.toLowerCase().includes(debouncedProjectSearch.value.toLowerCase());
    const phaseMatch = !debouncedPhaseSearch.value || (p[28136] && p[28136]?.toLowerCase().includes(debouncedPhaseSearch.value.toLowerCase()));
    return projectNameMatch && phaseMatch;
  });
});

const filterFunction = computed(() => {
  const searchTerm = debouncedProjectSearch.value;

  if (!searchTerm) return () => true;

  return (value) => {
    if (!value) return false;
    return value.toLowerCase().includes(searchTerm);
  };
});

watch(
  projectSearch,
  debounce((newVal) => {
    debouncedProjectSearch.value = newVal?.toLowerCase() || '';
  }, 500)
);

watch(
  phaseSearch,
  debounce((newVal) => {
    debouncedPhaseSearch.value = newVal?.toLowerCase() || '';
  }, 500)
);

const delayFocusin = (index, cfgaId) => setTimeout(() => handleFocusin(index, cfgaId), 100);

const handleFocusin = (index, cfgaId) => {
  const focusedInputKey = `${index}-${cfgaId}`;
  focusedInput.value = focusedInputKey;
  setTimeout(() => {
    currentFocusedInput.value = focusedInputKey;
  }, 100);
}

const handleFocusout = () => {
  setTimeout(() => {
    if (focusedInput.value === currentFocusedInput.value)
      focusedInput.value = null;
  }, 100);
}

const headers = ref([
  {
    text: 'Project Name',
    value: 'projectName',
    showInLoop: false,
    width: 200,
    filter: filterFunction.value,
  },
]);

onMounted(async () => {
  isChildProjectsLoading.value = true
  let requests = [getChildProjectHeaders(), getChildProjects(), getProject()]
  await Promise.all(requests).then(async () => {
    isChildProjectsLoading.value = false
  })
})

onBeforeRouteUpdate(async (to, from, next) => {
  if (!override.value && Object.keys(dirtyFields.value || {}).length > 0) {
    unsavedModal.value = true
  } else {
    next()
  }
})

onBeforeRouteLeave(async (to, from, next) => {
  if (!override.value && Object.keys(dirtyFields.value || {}).length > 0) {
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

const getTodayDate = (dataTypeId) => {
  const today = new Date();

  if (dataTypeId === DATA_FIELD_TYPES.DATE) {
    return today.toISOString().split('T')[0];
  } else if (dataTypeId === DATA_FIELD_TYPES.TIMESTAMP) {
    return today.toISOString();
  }

  return null;
}

const getCurrentUserPositionId = () => {
  return userStore.details?.userPositions.find(up => up.primaryFlag)?.id
}

const debouncePopulateDirtyFields = debounce((cfgaId, projectId, value) => {
  populateDirtyFields(cfgaId, projectId, value)
}, 500)

const updateDirtyFields = (cfgaId, projectId, key, value) => {
  Vue.set(dirtyFields.value, key, { customFieldGroupAssignmentId: cfgaId, projectId, value });
}

const populateDirtyFields = (cfgaId, projectId, value) => {
  const key = `${cfgaId}_${projectId}`

  if (projectId && cfgaId && key) {
    updateDirtyFields(cfgaId, projectId, key, value)
  }
}

const populateField = (cfgaId, item, value) => {
  item[cfgaId] = value

  populateDirtyFields(cfgaId, item.id, value);
}

const populateAllCfgaIdValues = (cfgaId, value, item) => {
  if (!childProjects.value || !Array.isArray(childProjects.value)) return

  item[cfgaId] = value

  filteredChildProjects.value.forEach((child) => {
    const projectId = child.id

    child[cfgaId] = value

    populateDirtyFields(cfgaId, projectId, value)
  })
}

const populateListOptionField = (header, item) => {
  const userPositionId = getCurrentUserPositionId()
  const isValidHeaderListOption = header.listOfValues.some(lov => lov.id === userPositionId)

  populateField(header.customFieldGroupAssignmentId, item, isValidHeaderListOption ? userPositionId : null)
}

const goToProject = () => {
  override.value = true
  router.push({path: `/project/${projectId.value}/children`})
}

const getDeepCopy = (obj) => {
  return JSON.parse(JSON.stringify(obj))
}

const saveChanges = async () => {
  appStore.loading = true
  try {
    await putRequest(`/project/${projectId.value}/children/details`, Object.values(dirtyFields.value));
    preSaveSnapshot.value = getDeepCopy(childProjects.value)
    dirtyFields.value = {}
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Saving Changes')
  } finally {
    appStore.loading = false
  }
}

const discardChanges = async () => {
  dirtyFields.value = {};
  childProjects.value = getDeepCopy(preSaveSnapshot.value)
  await nextTick();
}

const getChildProjectHeaders = async () => {
  try {
    const {data} = await getRequest(`/project/childrenHeaders`)
    data.forEach(d => {
      let determinedFilter =
        d.customFieldGroupAssignmentId === 28136
          ? (value) => filteredChildProjects.value
          : null;
      let header = { ...d,
        text: d.fieldName,
        key: d.customFieldGroupAssignmentId,
        value: d.customFieldGroupAssignmentId.toString(),
        showInLoop: true,
        width: getColumnWidth(d.dataTypeId),
        filter: determinedFilter
      }
      headers.value.push(header)
    })
  } catch (e) {
    logError(e)
  }
}

const disabledSave = computed(() => Object.keys(dirtyFields.value || {}).length === 0);

const getProject = async () => {
  try {
    const { data } = await getRequest(`/project/${projectId.value}`)
    parentProject.value = data
  } catch (e) {
    logError(e)
  }
}

const getColumnWidth = (dataTypeId) => {
  switch (dataTypeId) {
    case DATA_FIELD_TYPES.DATE: return 210
    case DATA_FIELD_TYPES.TIMESTAMP: return 250
    case DATA_FIELD_TYPES.TEXT:
    case DATA_FIELD_TYPES.SYSTEM:
    case DATA_FIELD_TYPES.SYSTEM_LIST:
    case DATA_FIELD_TYPES.SYSTEM_MULTISELECT:
      return 200
    default: return 100
  }
}

const getChildProjects = async () => {
  try {
    isChildProjectsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/children/details`)
    childProjects.value = getDeepCopy(data)
    preSaveSnapshot.value = getDeepCopy(data)
  } catch (e) {
    logError(e)
  }
}

const exportToCsv = () => {
  appStore.loading = true
  try {
    let csv = ''

    headers.value.forEach((h) => {
      return (csv += `${h.text},`)
    })
    csv += `\n`

    childProjects.value.filter(
        p => {
          const projectNameMatch = !debouncedProjectSearch.value || p.projectName?.toLowerCase().includes(debouncedProjectSearch.value);
          const phaseMatch = !debouncedPhaseSearch.value || (p[28136] && p[28136]?.toLowerCase().includes(debouncedPhaseSearch.value));
          return projectNameMatch && phaseMatch;
        }).forEach((p) => {
      headers.value.forEach((h) => {
        if (h.dataTypeId === DATA_FIELD_TYPES.DATE) {
          //if it is a date it needs to be formatted here
          csv +=
              '"' +
              `${p[h.value] === null || p[h.value] === undefined ? '' : filters.formatDate(p[h.value], "date")}` +
              '",'
        } else if (h.dataTypeId === DATA_FIELD_TYPES.SYSTEM_LIST) {
          // if they add other system lists besides the one being used at this time, we will need to specify by id
          csv +=
            '"' +
            `${p[h.value] === null || p[h.value] === undefined ? '' :
              h.listOfValues.find(lv => lv.id === p[h.value])?.name ?? p[h.value]}` +
            '",'
        } else if (h.dataTypeId === DATA_FIELD_TYPES.BOOLEAN) {
          csv +=
            '"' +
            `${p[h.value] === true ? 'true' : 'false'}` +
            '",'
        } else {
          csv +=
              '"' +
              `${p[h.value] === null || p[h.value] === undefined ? '' : p[h.value]}` +
              '",'
        }
      })
      csv += `\n`
    })
    const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
    saveAs(blob, `${parentProject.value?.projectName.replace(' ', '_')}_ChildProjects.csv`)
    appStore.loading = false
  }catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Exporting to Excel')
    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>

.albatross-header-1,
td {
  a {
    text-decoration-line: none;
  }
}

.custom-column-checkbox-width.normal {
  .v-input--checkbox {
    width: 230px !important;
  }
}

.custom-column-width.normal > div:not(:has(.v-input--checkbox)) {
  width: 260px !important;
}

.custom-column-selector-width.normal > div:not(:has(.v-input--checkbox)) {
  width: 360px !important;
}

.custom-column-date-width.normal > div:not(:has(.v-input--checkbox)) {
  width: 340px !important;
}

.custom-column-checkbox-width.shrink,
.custom-column-width.shrink,
 .custom-column-width.shrink > div:not(:has(button)) {
   flex: 1;
 }

.v-input.datetime-picker-input .v-input__control {
  width: 100%;
}

.apply-to-btn {
  color: var(--v-primary-base) !important;
  white-space: nowrap;
}

.input-container {
  display: flex;
  align-items: center;
  gap: 8px;
}

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

.v-data-table-header > tr {
  height: 48px;

  .project-children-filter-header {
    border-bottom: thin solid rgba(0, 0, 0, 0.12);
    padding-bottom: 8px;
  }
}


#project-children-container table > tr > th:nth-child(1),
#project-children-container table > tbody > tr > td:nth-child(1),
#project-children-container table > thead > tr > th:nth-child(1) {
   position: sticky !important;
   position: -webkit-sticky !important;
   left: 0;
   z-index: 2;
   background: white;
 }
#project-children-container table > thead > tr > th:nth-child(1) {
  z-index: 3 !important;
}
</style>
