<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <a-btn
          variant="text"
          class="pl-1 pr-2 anchor"
          :to="'/settings/projectStatuses'"
          prepend-icon="arrow_left"
          text="BACK"
        ></a-btn>

        <v-row>
          <v-col cols="10" v-if="!edit">
            <div class="headline-small">
              {{ projectStatus.projectStatusType }}
            </div>
            <span>
              {{ projectStatusObjectCategories }}
            </span>
          </v-col>
          <v-col cols="8" v-else>
            <a-text-field
              color="primary"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              v-model="projectStatus.projectStatusType"
              hide-details
              label="Attachment Type Name"
            ></a-text-field>
            <v-select
              v-model="projectStatus.objectCategoryIds"
              multiple
              :items="objectCategories"
              item-text="name"
              item-value="id"
              label="Object Categories"
            >
            </v-select>
          </v-col>
          <v-spacer></v-spacer>
          <div>
            <a-btn
              variant="text"
              v-if="userCanEdit && !edit"
              color="primary"
              @click="edit = !edit"
              prepend-icon="edit"
            />
            <a-btn
              variant="text"
              color="primary"
              class=""
              v-else-if="userCanEdit"
              @click="saveProjectStatus(projectStatus)"
              prepend-icon="save"
            />
            <a-btn
              variant="text"
              color="primary"
              v-if="userCanEdit && edit"
              class=""
              @click="edit = !edit"
              text="Cancel"
              hide-text-on-mobile
              :icon="vuetify.breakpoint.smAndDown"
              :prepend-icon="vuetify.breakpoint.smAndDown ? 'close' : ''"
            />
          </div>
        </v-row>

        <v-tabs class="tabs-bar tabs-border-bottom" v-model="activeTab">
          <v-tab
            v-for="(tab, index) in tabs"
            :key="index"
            :to="tab.path"
            class="text-capitalize ma-0"
            :style="{ 'margin-left': index === 0 ? '12px !important' : '0' }"
          >
            {{ tab.label }}
          </v-tab>
        </v-tabs>
      </v-col>

      <router-view />
    </v-row>
  </v-container>
</template>

<script setup>
import { getCompanyProjectStatusType } from '@/services/projectStatusTypeService'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest
} from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import { useRoute } from 'vue-router/composables'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const userStore = useUserStore()

const route = useRoute()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const statusId = computed(() => {
  return route.params.id
})

const objectCategories = ref([])
const edit = ref(false)
const activeTab = ref('')
const projectStatus = ref({})
const tabs = ref([
  {
    id: 1,
    label: 'Components',
    path: `/settings/projectStatus/${statusId.value}/components`
  },
  {
    id: 2,
    label: 'Fields',
    path: `/settings/projectStatus/${statusId.value}/fields`
  }
])

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

const projectStatusObjectCategories = computed(() => {
  return projectStatus.value?.objectCategoryIds
    ?.map((id) => {
      return objectCategories.value.find((category) => category.id === id)
    })
    ?.filter((oc) => oc.name !== undefined)
    ?.map((oc) => oc?.name)
    ?.join(', ')
})

onMounted(async () => {
  await Promise.allSettled([getStatusInfo(), getObjectCategories()])
})

const getObjectCategories = async () => {
  try {
    const { data } = await getRequest(`/objectCategory?objectTypeId=1`)
    objectCategories.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getStatusInfo = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getCompanyProjectStatusType(statusId.value)
    projectStatus.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}

const saveProjectStatus = async (type) => {
  try {
    appStore.loading = true
    const { data, status } = await putRequest(`/projectStatus/company`, type)

    projectStatus.value = data
    edit.value = false

    appStore.showSnack('SUCCESS', 'Project Status Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Project Status')
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
.tabs-border-bottom {
  border-bottom: 1px solid #e6e6e6;
}
</style>
