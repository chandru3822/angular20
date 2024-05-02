<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newCategory = { color: '#ffffff'}]" v-if="userCanAdd"
              :hide-text-on-mobile="vuetify.breakpoint.smAndDown"
              :prepend-icon="vuetify.breakpoint.smAndDown ? addNew ? 'close' : 'add' : ''"
              :text="addNew ? 'Cancel' : 'Add New'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew">
            <a-text-field v-model="newCategory.workQueueCategory"
                          placeholder="Enter a category"
                          label="Work Queue Category">
            </a-text-field>
            <div class="theme-label">
              Select a Color: {{newCategory.color}}
              <v-avatar
                  :tile="false"
                  :size="30"
                  :color="newCategory.color"
                  @click="showColor = !showColor"
                  class="account-img clickable bordered"
              >
              </v-avatar>
            </div>
            <v-color-picker v-if="showColor" class="my-3" v-model="newCategory.color" :canvas-height="colorOptions.height" :width="colorOptions.width" :mode="colorOptions.mode" :hide-mode-switch="colorOptions.hideModeSwitch"></v-color-picker>
            <a-btn
              color="primary"
              :disabled="!newCategory.workQueueCategory"
              @click="addNewCategory"
              text="Save"
              class="mb-3"
            />
          </div>
          <v-data-table
              :headers="headers"
              :items="filterCategories"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              hide-default-footer
              fixed-header
              single-expand
              :expanded.sync="expanded"
              class="elevation-1 table-striped"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item.draggable="{ item }">
                  <a-btn variant="text"
                                   color="primary"
                                   icon
                                   size="small"
                                   class="handle"
                                   v-if="userCanEdit"
                                   prepend-icon="drag_handle"
                  />
            </template>
                <template #item.workQueueCategory="{ item }" class="text-left">
                  <a-text-field class="one-hunned" v-if="selectedWorkQueueCategoryId === item.id" v-model="item.workQueueCategory"></a-text-field>
                  <div v-else>{{item.workQueueCategory}}</div>
                </template>
                <template #item.color="{ item }" class="text-left">
                  <v-avatar
                      :tile="false"
                      :size="30"
                      :color="item.color"
                      @click="updateItemValue(item)"
                      class="account-img clickable bordered"
                  >
                  </v-avatar>
                  <v-color-picker v-if="item.showColor" class="my-3" v-model="item.color" :canvas-height="colorOptions.height" :width="colorOptions.width" :mode="colorOptions.mode" :hide-mode-switch="colorOptions.hideModeSwitch"></v-color-picker>
                </template>
                <template #item.hidden="{ item }" class="text-left">
                  <v-card flat color="transparent" class="square-card my-2" v-if="selectedWorkQueueCategoryId === item.id">
                    <multi-select-group v-if="!workQueueLoading"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="item"
                                        :content="positions"
                                        :dropdownEnabled="item.hidden"
                                        :selectedContent="item.hiddenWhiteListedPositions"
                                        :title="'Hidden'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel = "'Denied Positions'"
                                        :allow="item.hiddenAllow"
                                        :contentLoading="positionsLoading"
                                        backgroundColor="transparent"
                                        @selected-changed="workQueueCategoriesHiddenSelectedEventListener"
                                        @allow-changed="workQueueCategoriesHiddenAllowEventListener"
                                        @checkbox-changed="workQueueCategoriesHiddenCheckboxEventListener"
                                        :full-size="vuetify.breakpoint.smAndDown"
                    />
                                      <br v-if="!item.hidden">
                                      <a-btn color="primary" dark class="d-inline-block white--text"
                                             @click="saveHiddenAndWhiteList(item)" prepend-icon="save" text="SAVE HIDDEN"/>
                                    </v-card>
                </template>
                <template #item.icons="{ item }" class="text-right">
                  <div v-if="userCanEdit" class="item-icons">
                    <a-btn v-if="selectedWorkQueueCategoryId  === item.id"
                                     class="clickable"
                                     size="small" variant="text"
                                     color="primary"
                                     prepend-icon="save"
                                     @click="saveCategory(item)"
                    />
                    <a-btn v-else
                                     class="clickable"
                                     size="small" variant="text"
                                     color="primary"
                                     prepend-icon="edit"
                                     @click="selectedWorkQueueCategoryId = item.id; selectedWorkQueueCategoryDisplayOrder = item.displayOrder"
                    />
                    <a-btn
                      :disabled="!userCanDelete"
                      size="small" variant="text"
                      color="primary"
                      class="clickable" @click="categoryToDelete=item"
                      prepend-icon="delete"
                    />
                  </div>
                </template>
          </v-data-table>
          <ConfirmationDialog :open-dialog="!!categoryToDelete" @confirm="[deleteCategory, categoryToDelete.archived = true]" @close-dialog="categoryToDelete=null">
            Are you sure you want to delete this work queue category: <strong>{{ categoryToDeleteName }}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script setup>

  import orderBy from 'lodash.orderby'
  import {getWorkQueueCategories} from '@/services/workQueueService'

  import {
    handleHidingGlobalLoader,
    deleteRequest,
    putRequest,
    postRequest,
    defineSortableTable,
    getRequest
  } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import cloneDeep from "lodash.clonedeep";
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

  import { useUserStore } from '@/stores/UserStore.js'
  import { useAppStore } from '@/stores/AppStore.js'
  import MultiSelectGroup from "@/components/MultiSelectGroup.vue";
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()

  const colorOptions = ref({
    canvasHeight: 75,
    width: 200,
    mode: 'hexa',
    hideModeSwitch: true
  })
  const workQueueCategories = ref([])
  const workQueueLoading = ref(false)
  const positions = ref([])
  const positionsLoading = ref(false)
  const hiddenPositionsChanged = ref(false)
  const addNew = ref(false)
  const showColor = ref(false)
  const newCategory = ref({ color: '#ffffff'})
  const selectedWorkQueueCategoryId = ref(null)
  const selectedWorkQueueCategoryDisplayOrder = ref(null)
  const expanded = ref([])
  const categoryToDelete = ref(null)
  const headers = ref([
    { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
    { text: 'Category', value: 'workQueueCategory', show: true },
    { text: 'Color', value: 'color', show: true },
    { text: null, value: 'hidden', show: true },
    { text: null, value: 'icons', show: true }
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
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })

  const categoryToDeleteName = computed(() => {
    return categoryToDelete.value ? categoryToDelete.value.workQueueCategory : ''
  })
  const workQueueCategoriesHiddenSelectedEventListener = (e) => {
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenWhiteListedPositions = e;
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenPositionsChanged = true;
  }
  const workQueueCategoriesHiddenAllowEventListener = (e) => {
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenAllow = (e === 0);
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenPositionsChanged = true;
  }
  const workQueueCategoriesHiddenCheckboxEventListener = (e) => {
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hidden = e;
    workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenPositionsChanged = true;
  }
  const selectAllHidden = (wqc) => {
    return wqc.hiddenWhiteListedPositions?.length === positions.value?.length
  }
  const selectSomeHidden = (wqc) => {
    return wqc.hiddenWhiteListedPositions?.length > 0 && !selectAllHidden(wqc)
  }
  const iconOwner = (wqc) => {
    if (selectAllHidden(wqc)) {
      return 'check_box'
    }
    if (selectSomeHidden(wqc)) {
      return 'indeterminate_check_box'
    }
    return 'check_box_outline_blank'
  }
  const toggleSelectAllPositions = (wqc) => {
    vueInstance.$nextTick(() => {
      if (selectAllHidden(wqc)) {
        wqc.hiddenWhiteListedPositions = []
        wqc.hiddenPositionsChanged = true
      } else {
        wqc.hiddenWhiteListedPositions = cloneDeep(positions.value)
        wqc.hiddenPositionsChanged = true
      }
    })
  }
  const getPositions = async () => {
    if (positions.value?.length === 0) {
      try {
        positionsLoading.value = true
        const {data, status} = await getRequest(`/position/withParent`)
        positions.value = data
        positionsLoading.value = false
        handleHidingGlobalLoader(status)
      } catch (e) {
        positionsLoading.value = false
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Positions')

        appStore.loading = false
      }
    }
  }
  const saveHiddenAndWhiteList = async (item) => {
    appStore.loading = true
    try {
      const {status} = await putRequest(`/workQueueCategory/saveHiddenAndWhiteList?savePositions=${workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenPositionsChanged ?? false}`, workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value])
      hiddenPositionsChanged.value = false
      if (!workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hidden) {
        workQueueCategories.value[selectedWorkQueueCategoryDisplayOrder.value].hiddenWhiteListedPositions = []
      }
      appStore.showSnack('SUCCESS', 'Saved Successfully')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.loading = false
    }
  }
  const updateItemValue = (item) => {
    if (selectedWorkQueueCategoryId.value === item.id) {
      vueInstance.$set(item, 'showColor', !item.showColor)
    }
  }
  const getAllWorkQueueCategories = async () => {
    appStore.loading = true
    try {
      workQueueLoading.value = true;
      const {data, status} = await getWorkQueueCategories(true)
      workQueueCategories.value = data
      handleHidingGlobalLoader(status)
      workQueueLoading.value = false;
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Work Queue Categories')

      appStore.loading = false
    }
  }
  const deleteCategory = async () => {
    const typeId = categoryToDelete.value.id
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/workQueueCategory/${typeId}`)
      appStore.showSnack('SUCCESS', 'Successfully Deleted Work Queue Category')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Work Queue Category')

      appStore.loading = false
    }
    categoryToDelete.value = null
  }
  const addNewCategory = async () => {
    appStore.loading = true
    try {
      const {data, status} = await postRequest(`/workQueueCategory`, newCategory.value)

      appStore.showSnack('SUCCESS', 'Work Queue Category Added')


      // add it to the records already on the screen
      workQueueCategories.value.push(data)
      workQueueCategories.value = orderBy(workQueueCategories.value, [wqc => wqc.workQueueCategory.toLowerCase()])

      // reset the new process fields
      addNew.value = false
      newCategory.value = {color: null}

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Work Queue Category')

      appStore.loading = false
    }
  }
  const saveCategory = async (wqc) => {
    appStore.loading = true
    try {
      selectedWorkQueueCategoryId.value = null
      const {status} = await putRequest(`/workQueueCategory`, wqc)
      wqc.showColor = false
      appStore.showSnack('SUCCESS', 'Work Queue Category Saved')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Work Queue Category')

      appStore.loading = false
    }
  }
  const saveRowChanges = async (rows) => {
    if (rows?.length > 0) {
      appStore.loading = true
      try {
        const {status} = await putRequest(`/workQueueCategory/order`, rows)
        appStore.showSnack('SUCCESS', 'Work Queue Category Order Saved')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Saving Work Queue Order')

        appStore.loading = false
      }
    }
  }
  const filterCategories = computed(() => {
    return workQueueCategories.value.filter(wqc => {
      return !wqc.archived
    })
  })

  onMounted(() => {
    defineSortableTable('tbody', workQueueCategories, 'displayOrder', saveRowChanges)

    getAllWorkQueueCategories()
    getPositions()
  })
</script>
