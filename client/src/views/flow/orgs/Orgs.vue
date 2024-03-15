<template>
  <v-container id="orgs-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Organizations</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-switch
                v-model="search.inactive"
                @change="setLocalStorage"
                class="fix-switch-color mt-5 mr-3"
                label="Include Inactive"
            />
            <a-btn
                variant="text"
                color="primary"
                @click="exportCsv"
                prepend-icon="mdi-cloud-download"
                :text="!constants.IS_MOBILE ? 'Export' : ''"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filteredOrgs"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug org-table square-card"
        >
          <template #no-data>
            <span class="default-text-color">No available organizations</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available organizations</span>
          </template>

          <template v-slot:body.prepend>
            <tr>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.org"
                              @blur="setLocalStorage"
                              placeholder="Organization"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.type"
                              @blur="setLocalStorage"
                              placeholder="Type"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.parent"
                              @blur="setLocalStorage"
                              placeholder="Parent"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.stateAbbreviation"
                              @blur="setLocalStorage"
                              placeholder="State"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              @blur="setLocalStorage"
                              v-model="search.active" placeholder="Active"></v-text-field>
              </td>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.orgName}}</td>
              <td class="text-left">{{item.orgType}}</td>
              <td class="text-left">{{item.parentOrgName}}</td>
              <td class="text-left">{{item.stateAbbreviation}}</td>
              <td class="text-left">{{item.activeFlag ? 'Yes' : 'No'}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import {  handleHidingGlobalLoader, getRequestWithParams,  } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { saveAs } from 'file-saver'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
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

const initialLoad = ref(true)
const delay = ref(500)
const dialog = ref(false)
const orgs = ref([])
const orgFilter = ref(route.params.orgFilter ? route.params.orgFilter : '')
const headers = ref([
  { text: 'Organization', value: 'orgName', show: true,filter: value => {if (!search.value.org) {return true} else {return value.toLowerCase().includes(search.value.org.toLowerCase())}}},
  { text: 'Type', value: 'orgType', show: true,filter: value => {if (!search.value.type) {return true} else {return value.toLowerCase().includes(search.value.type.toLowerCase())}}},
  { text: 'Parent', value: 'parentOrgName', show: true,filter: value => {if (!search.value.parent) {return true} else {return value && value.toLowerCase().includes(search.value.parent.toLowerCase())}}},
  { text: 'State', value: 'stateAbbreviation', show: true,filter: value => {if (!search.value.stateAbbreviation) {return true} else {return value && value.toLowerCase().includes(search.value.stateAbbreviation.toLowerCase())}}},
  { text: 'Active', value: 'activeFlag', show: true,filter: value => {if (!search.value.active) {return true} else {let stringValue = value ? 'Yes' : 'No'; return stringValue.toLowerCase().includes(search.value.active.toLowerCase())}}}
])
const descending = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const totalOrgs = ref(0)
const dataLoading = ref(true)
const search = ref({org: '',type: '',parent: '',active: '',inactive: false})


const hasOrgAddAccess = computed(() => {
  return userStore.userHasFeatureAccessLevel('ORGS', 'ADD')
})
const filteredOrgs = computed(() => {
  return orgs.value.filter(o => { return search.value?.inactive ? true : o.activeFlag})
})
const useSavedFilters = computed(() => {
  return route.params.useSavedFilters
})

watch(
    () => options,
    (newValue, oldValue) => {
      if (!initialLoad.value) {
        getOrgs();
      }
    },
    { deep: true }
)

onMounted(() => {
  if (orgFilter.value) {
    search.value = orgFilter.value
  }
  if(useSavedFilters.value === 'true') {
    let localOrgSearch = localStorage.getItem('orgSearch')
    if(localOrgSearch !== null) {
      search.value = JSON.parse(localStorage.getItem('orgSearch'))
    }
  } else {
    localStorage.removeItem('orgSearch')
  }
  getOrgs()
})

const setLocalStorage =  () => {
  localStorage.setItem('orgSearch', JSON.stringify(search.value))
}
const clickRow = (id)=> {
  router.push({name: 'org', params: {id}})
}
const getOrgs = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/org`)
    orgs.value = data
    initialLoad.value = false
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Organizations')

    appStore.loading = false
  }
}
const exportCsv = () => {
  let csv = ''

  headers.value.forEach(h => csv += `${h.text},`)
  csv = `${csv.slice(0, -1)}\n`

  filteredOrgs.value.forEach(o => {

    let addRow = true
    headers.value.forEach(h => {
      if (!h.filter(o[h.value])) {
        addRow = false
      }
    })

    if (addRow) {
      headers.value.forEach(h => csv += '"'+`${o[h.value] === null ? '' : o[h.value]}`+'",')
      csv = `${csv.slice(0, -1)}\n`
    }
  })

  const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
  saveAs(blob, 'Orgs.csv')
}


</script>

<style lang="scss">
#orgs-container .v-data-table__wrapper {
  height: calc(100vh - 190px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#orgs-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.org-table {
  margin-top: 2px;
}
</style>
