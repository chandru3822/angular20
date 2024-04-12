<template>
  <v-container>
    <v-row>
      <v-col>
        <v-card class="pa-4 text-left" v-if="addNew">
          <v-form ref="newPositionForm">
            <h3>Add User Position</h3>
            <DatetimePickerInput
                v-model="newPosition.startDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Start Date"
            />
            <DatetimePickerInput
                v-model="newPosition.endDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="End Date"
            />
            <label>Make Primary:</label>
            <input type="checkbox" class="ml-3 mb-4" v-model="newPosition.primaryFlag">
            <a-autocomplete v-model="newPosition.positionId"
                            :items="positions"
                            label="Positions"
                            item-title="position"
                            item-value="id"
                            @input="populateHierarchy(newPosition, true)"/>
            <div v-if="newPositionHierarchyPopulated">
              <div v-for="(f, index) in filters" :key="index">
                <a-autocomplete v-if="newPosition.keyedHierarchy && newPosition.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, newPosition)"
                                v-model="newPosition.keyedHierarchy[f.orgLevelId]['orgId']"
                                :items="getOrgsMatchingPositionOrgType(f.orgs, newPosition)"
                                :rules="requiredRules"
                                :label="f.levelName"
                                item-value="id"
                                item-title="orgName"
                >
                  <template  v-slot:selection="{item, index}">
                    {{ item.orgName }} <span v-if="item.showType">&nbsp;- {{ item.orgType }}</span>
                  </template>
                  <template v-slot:item="{ props, item }">
                    {{ item.orgName }} <span v-if="item.showType">&nbsp;- {{ item.orgType }}</span>
                  </template>
                </a-autocomplete>
              </div>
            </div>
            <div v-if="newPosition.startDate >= newPosition.endDate" class="error-text mb-2">
              End date must be null or after the start date
            </div>
            <a-btn
                variant="text"
                color="primary"
                class="mr-2"
                @click="[newPosition = [], addNew = !addNew]"
                text="Cancel"
            ></a-btn>
            <a-btn
                color="primary"
                class="mr-2"
                :disabled="!newPosition.positionId || (newPosition.positionId && newPosition.endDate && !newPosition.startDate ) || (newPosition.positionId && newPosition.endDate <= newPosition.startDate )"
                @click="validate(newPosition)"
                text="Add"
            ></a-btn>
          </v-form>
        </v-card>

        <!--        existing positions -->
        <v-data-table
            v-if="!addNew"
            :headers="headers"
            :items="filteredUserPositions"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            :expanded.sync="expanded"
            single-expand
            disable-sort
            class="elevation-1 mt-1"
        >
          <template #no-data>
            <span class="default-text-color">No available fields</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available fields</span>
          </template>

          <template #header.icons="{}">
            <div class="text-right mr-2">
              <a-btn
                  variant="text"
                  color="primary"
                  size="x-small"
                  @click="addNew = !addNew"
                  v-if="userCanAdd"
                  prepend-icon="add"
              ></a-btn>
            </div>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': userPositions.indexOf(item) % 2}">
              <h3 class="mb-3">Edit Position</h3>
              <DatetimePickerInput
                  v-model="item.startDate"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="Start Date"
              />
              <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="End Date"
              />
              <a-autocomplete v-model="item.positionId"
                              :items="positions"
                              :readonly="true"
                              :disabled="true"
                              label="Positions"
                              @input="populateHierarchy(item, false)"
                              item-title="position"
                              item-value="id"/>
              <label>Primary:</label>
              <input type="checkbox" class="ml-3 mb-4" v-model="item.primaryFlag"
                     :readonly="item.primary || !userCanEdit" :disabled="item.primary || !userCanEdit">
              <div v-for="(f, index) in filters" :key="index">
                <a-autocomplete
                    v-if="item.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, item)"
                    v-model="item.keyedHierarchy[f.orgLevelId]['orgId']"
                    :items="getOrgsMatchingPositionOrgType(f.orgs, item)"
                    :readonly="true"
                    :disabled="true"
                    :rules="requiredRules"
                    :label="f.levelName"
                    item-title="orgName"
                    item-value="id"
                >
                  <template  v-slot:selection="{item, index}">
                    <div style="color: #9E9E9E;">
                      {{ item.orgName }} <span v-if="item.showType">&nbsp;- {{ item.orgType }}</span>
                    </div>
                  </template>
                  <template v-slot:item="{ props, item }">
                  <div style="color: #9E9E9E;">
                      {{ item.orgName }} <span v-if="item.showType">&nbsp;- {{ item.orgType }}</span>
                    </div>
                  </template>
                </a-autocomplete>
              </div>
              <div v-if="item.startDate >= item.endDate" class="error-text mb-2">
                End date must be null or after the start date
              </div>
              <a-btn
                  color="primary"
                  class="mr-2"
                  :disabled="item.startDate >= item.endDate || validatePositionFields(item)"
                  v-if="userCanEdit"
                  @click="savePosition(item)"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': index % 2 }">
              <td class="text-left">{{ item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{ item.endDate | formatDate('date')}}</td>
              <td class="text-left"><a :href="`/settings/position/${item.positionId}`">{{ item.position }}</a></td>
              <td class="text-left">
                <input type="checkbox" v-model="item.primaryFlag" disabled>
              </td>
              <td class="text-left user-column" v-for="(f, index) in filters" :key="index">
                <a v-if="getOrgIdForFilter(item.hierarchy, f.orgLevelId)" :href="`/org/${getOrgIdForFilter(item.hierarchy, f.orgLevelId)}`">{{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}</a>
                <span v-else>{{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}</span>
              </td>
              <td width="150" class="d-flex">
                <a-btn
                    class="align-self-center"
                    variant="text"
                    color="primary"
                    v-if="!expanded.includes(item) && userCanEdit"
                    @click="[handleExpand(item, true), item.primary = item.primaryFlag]"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    class="align-self-center"
                    variant="text"
                    color="primary"
                    v-if="expanded.includes(item)"
                    @click="handleExpand(item, false)"
                    text="cancel"
                ></a-btn>
                <a-btn
                    v-if="userStore.userHasFeatureAccessLevel('USERS', 'DELETE')"
                    class="align-self-center"
                    variant="text"
                    color="primary"
                    @click="positionToDelete = item"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!positionToDelete" @confirm="deleteUserPosition" @close-dialog="positionToDelete = null">
      Are you sure you want to delete this position: <b>{{positionToDeleteName}}</b>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import keyBy from 'lodash.keyby'
import {getOrgFilters} from '@/services/orgService'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const newPositionForm = ref(null)
const newPosition = ref({})
const userPositions = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const positions = ref([])
const addNew = ref(false)
const newPositionHierarchyPopulated = ref(false)
const filters = ref([])
const expanded = ref([])
const userId = ref(route.params.id)
const headers = ref([
  { text: 'Start Date', value: 'startDate', show: true },
  { text: 'End Date', value: 'endDate', show: true },
  { text: 'Position', value: 'position', show: true },
  { text: 'Primary', value: 'primaryFlag', show: true },
])
const positionToDelete = ref(null)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'EDIT')
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const positionToDeleteName = computed(() => {
  return positionToDelete.value ? positionToDelete.value.position : ''
})
const filteredUserPositions = computed(() => {
  return userPositions.value.filter(wqc => { return !wqc.archived})
})

onMounted(() => {
  getUserPositions()
  getFilters()
  getPositions()
})

const validate =  (item) => {
  if (newPositionForm.value.validate()) {
    savePosition(item)
  }
}
const getOrgsMatchingPositionOrgType = (orgs, newPosition) => {
  // get orgs that match the org type selected in the position (admin screen)
  let selectedPosition = positions.value.find(p => p.id === newPosition.positionId)
  return orgs.filter(o => o.orgTypeId === selectedPosition.orgTypeId)
}
const getPositions = async() => {
  try {
    const {data, status} = await getRequest(`/position`)
    positions.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Positions')

    appStore.loading = false
  }
}
const populateHeaders =  () => {
  filters.value.forEach(f => {
    headers.value.push({
      text: f.levelName,
      value: f.levelName,
      show: true,
    })
  })
  headers.value.push({
    text: null,
    name: 'icons',
    value: 'icons',
    show: true,
    sortable: false
  })
}
const getFilters = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgFilters()
    filters.value = data || []
    populateHeaders()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Levels')

    appStore.loading = false
  }
}
const populateHierarchy = (item, isNew) => {
  newPositionHierarchyPopulated.value = false
  let selectedPosition = positions.value.find(p => p.id === item.positionId)
  // level = selectedPosition.level
  item.hierarchy = []
  //push a hierarchy item in for the selected level
  filters.value.forEach(f => {
    if(f.level === selectedPosition.level) {
      let obj = {
        level: f.level,
        orgLevelId: f.orgLevelId,
        positionLevel: null,
        orgName: null,
        orgId: null,
        parentOrgId: null
      }
      item.hierarchy.push(obj)
    }
  })
  item.keyedHierarchy = keyBy(item.hierarchy, 'orgLevelId')
  if(isNew) {
    newPositionHierarchyPopulated.value = true
  }
}
const getUserPositions = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/userPosition/${userId.value}`, null, [])
    userPositions.value = data
    userPositions.value.forEach((p) => {
      p.keyedHierarchy = keyBy(p.hierarchy, 'orgLevelId')
    })
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const getOrgNameForFilter = (hierarchy, filterOrgLevelId) => {
  const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
  return result?.orgName ?? 'N/A'
}
const getOrgIdForFilter = (hierarchy, filterOrgLevelId) => {
  const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
  return result?.orgId ?? null
}
const handleExpand =  (item, expand) => {
  if(expand) {
    expanded.value = [item]
  } else {
    expanded.value = []
  }
}
const savePosition = async (item) => {
  appStore.loading = true
  try {
    addNew.value = false
    let itemIndex = userPositions.value.indexOf(item)

    let lowestHierarchy = item?.hierarchy?.reduce((prev, current) => {
      return (prev.level > current.level) ? prev : current
    })
    let itemId = item.id
    item.orgId = lowestHierarchy.orgId
    let params = {
      ...item,
      primaryFlag: !itemId && userPositions.value.filter(up => !up.archived).length === 0 ? true : item.primaryFlag,
      userId: userId.value
    }

    const {data, status} = await postRequest(`/userPosition`, params)
    item = data
    vueInstance.$set(item, 'hierarchy', data.hierarchy)
    if (item && item.hierarchy) {
      vueInstance.$set(item, 'keyedHierarchy', keyBy(item.hierarchy, 'orgLevelId'))
      if (!itemId) {
        userPositions.value.push(item)
      } else {
        vueInstance.$set(userPositions.value, itemIndex, item)
      }
    }
    if (item.primaryFlag) {
      //clear out any other primary flags in the ui - the db should have already done it
      userPositions.value.forEach(up => {
        if (up.primaryFlag && up.id !== item.id) {
          up.primaryFlag = false
        }
      })
    }
    newPosition.value = {}
    addNew.value = false
    expanded.value = []
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Position')

    appStore.loading = false
  }
}
const isSameLevelAsPosition = (f, item) => {
  // get hierarchy level to show on screen
  let selectedPosition = positions.value.find(p => p.id === item.positionId)
  return selectedPosition && f.level === selectedPosition.level

}
const validatePositionFields = (item) => {
  let lowestHierarchy = item.hierarchy.reduce((prev, current) => {
    return (prev.level > current.level) ? prev : current
  })
  return lowestHierarchy.orgId == null
}
const deleteUserPosition = async() => {
  const item = positionToDelete.value
  try {
    await deleteRequest(`/userPosition/${item.id}`)
    item.archived = true
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting user position')

  }
  positionToDelete.value = null
}
</script>
