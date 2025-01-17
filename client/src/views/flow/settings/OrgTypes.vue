<template>
  <v-container id="hierarchy-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            Organization Types
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click=";[(addType = !addType), (newType = {})]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="true"
              :prepend-icon="addType ? 'close' : 'add'"
              :text="addType ? 'Cancel' : 'Add New'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addType" class="pa-5 mb-2">
          <h3>Add Org Type</h3>
          <a-text-field v-model="newOrgType.orgType" label="Org Type Name" />
          <a-select
            attach
            v-model="newOrgType.orgLevelId"
            :items="levels"
            label="Level"
            item-title="level"
            item-value="id"
          ></a-select>
          <a-select
            attach
            v-if="newOrgType.orgLevelId"
            v-model="newOrgType.orgParentTypeId"
            :items="filteredOrgTypes(newOrgType.orgLevelId)"
            label="Parent"
            item-title="orgType"
            item-value="id"
          ></a-select>
          <div class="mb-3" v-if="userStore.isParent">
            <label>Make available in children:</label>
            <input
              type="checkbox"
              class="ml-3"
              v-model="newOrgType.availableToChildren"
            />
          </div>

          <a-btn
            :disabled="!newOrgType.orgType || !newOrgType.orgLevelId"
            color="primary"
            class="white--text mr-2"
            @click="saveOrgType(newOrgType, true)"
            text="Save"
          />
          <a-btn
            variant="text"
            color="primary"
            @click=";[(addType = !addType), (newOrgType = {})]"
            text="Cancel"
          />
        </v-card>
        <v-data-table
          :headers="headers"
          :items="orgTypes"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 org-type-table"
          :item-class="rowClass"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">
              No parameters exist for this function
            </span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td
              :colspan="headers.length"
              class="pa-4"
              :class="{ 'shaded-row': orgTypes.indexOf(item) % 2 === 1 }"
            >
              <h3>Edit Org Type {{ orgTypes.indexOf(item) % 2 }}</h3>
              <a-text-field v-model="item.orgType" label="Org Type Name" />
              <a-select
                attach
                v-model="item.orgLevelId"
                :items="levels"
                label="Level"
                item-title="level"
                item-value="id"
              ></a-select>
              <a-select
                attach
                v-if="item.orgLevelId && item.orgLevelId"
                v-model="item.orgParentTypeId"
                :items="filteredOrgTypes(item.orgLevelId)"
                label="Parent"
                item-title="orgType"
                item-value="id"
              ></a-select>
              <div class="mb-3" v-if="userStore.isParent">
                <label>Make available in children:</label>
                <input
                  type="checkbox"
                  class="ml-3"
                  v-model="item.availableToChildren"
                />
              </div>
              <a-btn
                :disabled="!item.orgType || !item.orgLevelId"
                color="primary"
                class="white--text mr-2"
                @click="saveOrgType(item, false)"
                text="Save"
              />
            </td>
          </template>

          <template #item.level="{ item }" class="text-end"
            ><span class="ml-2">{{ item?.level || 'n/a' }}</span></template
          >
          <template #item.orgParentType="{ item }" class="text-left">{{
            item.orgParentType || 'n/a'
          }}</template>
          <template #item.icons="{ item, index }">
            <a-btn
              size="small"
              variant="text"
              color="primary"
              v-if="
                !expanded.includes(item) &&
                userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
              "
              @click="expanded = [item]"
              prepend-icon="edit"
            />
            <a-btn
              size="small"
              variant="text"
              color="primary"
              v-if="expanded.includes(item)"
              @click="expanded = []"
              text="Cancel"
            />
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {
  handleHidingGlobalLoader,
  putRequest,
  getSnackbar,
  getRowClass
} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import { getOrgTypes, getOrgLevels } from '@/services/orgService'

import { computed, getCurrentInstance, onMounted, ref } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const vueInstance = getCurrentInstance().proxy

const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()

const orgTypes = ref([])
const newOrgType = ref({})
const addType = ref(false)
const levels = ref([])
const expanded = ref([])
const headers = ref([
  { text: 'Org Type', value: 'orgType', show: true },
  { text: 'Level', value: 'level', width: 84, show: true },
  { text: 'Parent', value: 'orgParentType', show: true },
  { text: null, value: 'icons', show: true, sortable: false }
])

const getAllOrgTypes = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getOrgTypes()
    orgTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Org Types')
    appStore.loading = false
  }
}
const getAllOrgLevels = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getOrgLevels()
    levels.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Org Levels')
    appStore.loading = false
  }
}
const saveOrgType = async (ot, isNew) => {
  appStore.loading = true
  try {
    ot.level = ot.level === 'n/a' ? null : ot.level
    const { data, status } = await putRequest(`/orgType`, ot)
    if (isNew) {
      orgTypes.value.push(data)
      addType.value = false
      newOrgType.value = {}
      appStore.showSnack('SUCCESS', 'Org Type Added')
    } else {
      ot.level = data.level
      ot.orgParentType = data.orgParentType
      expanded.value = []
      appStore.showSnack('SUCCESS', 'Org Type Updated')
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack(
      'ERROR',
      isNew ? 'Error Adding Org Type' : 'Error Updating Org Type'
    )
    appStore.loading = false
  }
}
const filteredOrgTypes = (orgLevelId) => {
  // filter list so they cannot select a parent that is further down in the hierarchy than self
  const orgLevel = levels?.value.find((l) => l.id === orgLevelId)
  return orgTypes.value.filter((ot) => {
    return ot.level < orgLevel?.level
  })
}
const rowClass = (item) => {
  return getRowClass(item, orgTypes.value)
}

onMounted(async () => {
  await getAllOrgTypes()
  await getAllOrgLevels()
})
</script>

<style lang="scss">
#hierarchy-container .v-data-table__wrapper {
  height: calc(100vh - 200px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.org-type-table {
  margin-top: 2px;
}
</style>
