<template>
  <v-container id="work-queue-types-container">
    <ConfirmationDialog :openDialog="deleteError" @cancel="deleteError = false" hideConfirm>
      <template v-slot:title><span class="error-text">Error Deleting Work Queue Type</span></template>
      <div v-if="cannotDeleteReasons && cannotDeleteReasons.length > 0" class="mb-5">
        <div class="mb-3">* This work queue type is being used by Process Steps or Process Step Events. You must remove
          those before deleting this work queue type.
        </div>
        <div v-for="a in cannotDeleteReasons" :key="a.id" class="ml-5">
          <strong>{{ a.processStepName }}</strong>
        </div>
      </div>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar toolbar-z-index-override">
          <v-autocomplete
              v-model="selectedWorkQueueCategoryId"
              :items="filteredCategories"
              label="Work Queue Category"
              item-text="workQueueCategory"
              item-value="id"
              @input="filterCategories()"
              attach
          ></v-autocomplete>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text" :hide-text-on-mobile="true" :text="addNew ? 'Cancel' : 'Add New'"
                             class="mx-2"
                             custom-classes=""
                             :prepend-icon="addNew ? 'close' : 'add'"
                             @click="[addNew = !addNew, newType = {}]" v-if="userCanAdd">
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew">
            <v-text-field v-model="newType.workQueueType"
                          placeholder="Enter a type"
                          label="Work Queue Type">
            </v-text-field>
            <v-autocomplete
                v-model="newType.workQueueCategoryId"
                :items="workQueueCategories"
                label="Work Queue Category"
                item-text="workQueueCategory"
                item-value="id"
                attach
            ></v-autocomplete>
            <div>
              <label>Use Event Data:</label>
              <input type="checkbox" class="ml-3" v-model="newType.useEventData">
              <span class="no-change-text">* This value cannot be changed after creation.</span>
            </div>
            <AlbatrossButton
                color="primary"
                class="mt-2"
                :disabled="!newType.workQueueType || !newType.workQueueCategoryId"
                @click="addNewType"
                text="Save"
            ></AlbatrossButton>
          </div>
          <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
          ></v-text-field>
          <v-data-table
              :headers="headers"
              :items="filteredWorkQueueTypes"
              :fixed-header="true"
              :items-per-page="50"
              :search="search"
              :sort-desc="[false]"
              :sort-by="['workQueueCategoryDisplayOrder','displayOrder']"
              class="elevation-1 mt-1"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item="{ item, index }">

              <tr class="clickable" :class="{'shaded-row': workQueueTypes.indexOf(item) % 2}">
                <td style="width: 50px" @click="goToDetails(item)">
                  <AlbatrossButton
                      v-if="(userCanEdit || userIsAdmin) && selectedWorkQueueCategoryId !== -1"
                      variant="text"
                      color="primary"
                      icon
                      size="small"
                      class="handle"
                      prepend-icon="drag_handle"
                  ></AlbatrossButton>
                </td>
                <td class="text-left" @click="goToDetails(item)">
                  {{ item.workQueueType }}
                </td>
                <td class="text-left" @click="goToDetails(item)">
                  {{ item.workQueueCategory }}
                </td>
                <td class="text-left" @click="goToDetails(item)">
                  <input type="checkbox" disabled v-model="item.useEventData">
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <AlbatrossButton
                        @click="goToDetails(item)"
                        class="clickable"
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanEdit || userIsAdmin"
                        prepend-icon="edit"
                    ></AlbatrossButton>
                    <AlbatrossButton
                        class="clickable"
                        @click="workQueueToDelete=item"
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanDelete"
                        prepend-icon="delete"
                    ></AlbatrossButton>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!workQueueToDelete" @confirm="deleteType(workQueueToDelete)"
                        @close-dialog="workQueueToDelete=null">
      Are you sure you want to delete this work queue type: <strong>{{ workQueueToDeleteType }}</strong>

    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'
import {getWorkQueueTypes, getWorkQueueCategories} from '@/services/workQueueService'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"

import {handleHidingGlobalLoader, putRequest, postRequest, defineSortableTable} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, onMounted, computed, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRouter} from "vue-router/composables"
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const deleteError = ref(false)
const cannotDeleteReasons = ref({})
const search = ref('')
const masterWorkQueueTypes = ref([])
const workQueueTypes = ref([])
const workQueueCategories = ref([])
const filteredCategories = ref([])
const addNew = ref(false)
const newType = ref({})
const selectedWorkQueueTypeId = ref(null)
const selectedWorkQueueCategoryId = ref(-1)
const expanded = ref([])
const workQueueToDelete = ref(null)
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Type', value: 'workQueueType', show: true},
  {text: 'Category', value: 'workQueueCategory', show: true},
  {text: 'Uses Event Data', value: 'useEventData', show: true},
  {text: null, value: 'icons', show: true, width: 150}
])

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})

const workQueueToDeleteType = computed(() => {
  return workQueueToDelete.value ? workQueueToDelete.value.workQueueType : ''
})

const filteredWorkQueueTypes = computed(() => {
  return workQueueTypes.value.filter(wqt => {
    return !wqt.archived
  })
})

onMounted(async () => {
  getAllWorkQueueCategories()
  await getAllWorkQueueTypes()

  defineSortableTable('tbody', workQueueTypes, 'displayOrder', saveRowChanges)
})


const getAllWorkQueueTypes = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getWorkQueueTypes()
    workQueueTypes.value = data
    //make copy so filtering works later
    masterWorkQueueTypes.value = cloneDeep(workQueueTypes.value)

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Work Queue Types')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getAllWorkQueueCategories = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getWorkQueueCategories()
    workQueueCategories.value = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
    filteredCategories.value = cloneDeep(workQueueCategories.value)
    filteredCategories.value.unshift({id: -1, workQueueCategory: 'All'})
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Work Queue Types')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const filterCategories = () => {
  workQueueTypes.value = selectedWorkQueueCategoryId.value === -1 ? masterWorkQueueTypes.value : masterWorkQueueTypes.value.filter(wqt => wqt.workQueueCategoryId === selectedWorkQueueCategoryId.value)
}
const deleteType = async (item) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/workQueueType/delete/${item.id}`)
    snackbar('SUCCESS', 'Successfully Deleted Work Queue Type')
    item.archived = true
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)

    if (e.status === 400) {
      item.deleteConfirm = false
      deleteError.value = true
      cannotDeleteReasons.value = e.data
    }
    snackbar('ERROR', 'Error Deleting Work Queue Type')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const addNewType = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await postRequest(`/workQueueType/type`, newType.value)

    snackbar('SUCCESS', 'Work Queue Type Added')

    // add it to the master list too
    masterWorkQueueTypes.value.push(data)
    workQueueTypes.value.push(data)

    // reset the new process fields
    addNew.value = false
    newType.value = {}

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Work Queue Type')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await putRequest(`/workQueueType/order`, rows)
      snackbar('SUCCESS', 'Order Updated')
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Order Changes')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const goToDetails = (item) => {
  router.push({name: 'workQueueType', params: {id: item.id}})
}
</script>

<style lang="scss">
#work-queue-types-container .v-data-table__wrapper {
  max-height: calc(100vh - 350px);
  min-height: 300px;
}

#work-queue-types-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.no-change-text {
  margin-left: 10px;
  color: #BDBDBD;
}
</style>
