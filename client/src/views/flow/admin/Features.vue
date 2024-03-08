<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Features</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton :hide-text-on-mobile="true" prepend-icon="add"
                             variant="text"
                             text="Blah"
                             @click="[addNew = !addNew, selectedFeature = {}]">
            </AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>{{ isCompanyRoot ? 'Add New Feature' : 'Add Feature to Company' }}</h3>
          <div class="mb-3">
            <div v-if="isCompanyRoot">
              <v-text-field text label="Enter the name of a new feature"
                            v-model="selectedFeature.featureName"></v-text-field>
              <v-text-field text label="Enter Feature Code"
                            v-model="selectedFeature.featureCode"></v-text-field>
              <label>Is System:</label>
              <input class="ml-3" type="checkbox" v-model="selectedFeature.isSystem">
            </div>
            <v-select
                v-else
                v-model="selectedFeature"
                :items="features"
                label="Select a feature to use"
                item-text="featureName"
                item-value="id"
                return-object
            ></v-select>
          </div>
          <AlbatrossButton variant="text" text="Cancel" @click="[addNew = !addNew, selectedFeature = {}]"></AlbatrossButton>
          <AlbatrossButton :disabled="!selectedFeature || !selectedFeature.featureName || !selectedFeature.featureCode"
                 class="mr-2"
                 @click="saveFeature(true)">
            Save
          </AlbatrossButton>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="filteredFeatures"
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
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <h3>Edit Feature</h3>
              <div class="mb-3">
                <v-text-field text v-model="item.featureName"
                              label="Feature Name"/>
                <div v-if="isCompanyRoot">
                  <v-text-field text v-model="item.featureCode"
                                label="Feature Name"/>
                  <label>Is System:</label>
                  <input class="ml-3" type="checkbox" v-model="item.isSystem">
                </div>
              </div>
              <AlbatrossButton :disabled="!item.featureName"
                     class="mr-2"
                     @click="saveFeature(false, item)">
                Save
              </AlbatrossButton>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': companyFeatures.indexOf(item) % 2}">
              <td class="text-left">{{ item.featureName }}</td>
              <td class="text-left">{{ item.featureCode }}</td>
              <td class="text-right">
                <AlbatrossButton variant="text" size="small" prepend-icon="edit" v-if="!expanded.includes(item)" @click="expanded = [item]">
                </AlbatrossButton>
                <AlbatrossButton size="small" text="cancel" v-if="expanded.includes(item)" @click="expanded = []"></AlbatrossButton>
                <AlbatrossButton variant="text" size="small" prepend-icon="delete" @click="featureToDelete=item" />
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!featureToDelete" @confirm="deleteFeature"
                        @close-dialog="featureToDelete = null">
      <div v-if="isCompanyRoot">
        <span class="error--text">WARNING:</span> This will delete this feature system-wide!
      </div>
      <div v-else>
        <span class="error--text">WARNING:</span> Feature access control will be completely reset for this feature even
        if you add the same one back in.
      </div>
      Are you sure you want to delete this feature: <b>{{ featureToDeleteName }}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import orderBy from 'lodash.orderby'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {getCurrentInstance, onMounted, computed, ref} from 'vue'
import AlbatrossButton from '@/components/customVuetify/AlbatrossButton'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appstore = useAppStore()
const snackbar = vueInstance.$snackbar

const isCompanyRoot = ref(userStore.isCompanyRoot)
const addNew = ref(false)
const levels = ref([])
const companyFeatures = ref([])
const selectedFeature = ref({})
const features = ref([])
const apiUrl = ref(userStore.isCompanyRoot ? `/feature` : `/feature/company`)
const selectedFeatureId = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const expanded = ref([])
const featureToDelete = ref(null)
const headers = ref([
  {text: 'Feature', value: 'feature', show: true},
  {text: 'Feature Code', value: 'featureCode', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])
const featureToDeleteName = computed(() => {
  return featureToDelete.value ? featureToDelete.value.featureName : ''
})

const filteredFeatures = computed(() => {
  return orderBy(companyFeatures.value.filter(cf => {
    return !cf.archived
  }), [cf => cf.featureName.toLowerCase()])
})

onMounted(() => {
  getCompanyFeatures()
  getFeatures()
})
const saveFeature = async (isNew, feature) => {
  appStore.loading = true
  try {
    feature = isNew && isCompanyRoot.value ? selectedFeature.value :
        isNew && !isCompanyRoot.value ?
            {
              featureId: selectedFeature.value.id,
              featureName: selectedFeature.value.featureName,
            } : feature
    const {data, status} = await putRequest(`${apiUrl.value}`, feature)
    if (isNew) {
      companyFeatures.value.push(data)
      addNew.value = false
      selectedFeature.value = {}
      snackbar('SUCCESS', 'Feature Added')
    } else {
      expanded.value = []
      snackbar('SUCCESS', 'Feature Updated')
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Feature' : 'Error Updating Feature')
    appStore.loading = false
  }
}
const getCompanyFeatures = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`${apiUrl.value}`)
    companyFeatures.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Features')
    appStore.loading = false
  }
}
const getFeatures = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/feature`)
    features.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Features')
    appStore.loading = false
  }
}
const deleteFeature = async () => {
  const feature = featureToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`${apiUrl.value}/${feature.id}`)
    feature.archived = true
    snackbar('SUCCESS', 'Feature Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Feature')
    appStore.loading = false
  }
}
</script>
