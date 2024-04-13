<template>
  <v-container class="pa-0">
    <v-checkbox
        class="pt-5 ml-3"
        dense
        v-model="showCancelled"
        label="Show Cancelled"
        v-show="userCanManage"
        @change="fetchProjects(searchQuery)"
    />
    <RequestTable :headers="headers" :projects="projects" :total-items="totalItems" :feature-code="'ELECTRONIC_DOCUMENTS'" :is-loading="dataLoading"
                  @openRequest="openRequest($event)" @searchInput="fetchProjects($event)" @submitRequest="submitRequest">
      <template v-slot:dialogContent>
        <v-card-title>
          <span class="text-h5">Document generator</span>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <a-text-field label="Customer Name"
                            v-model="customer_name"
                            disabled
                            class="customer-name-width"
              ></a-text-field>
            </v-col>
            <v-col>
              <a-select label="Template type"
                        v-model="selectedTempType"
                        :items="templateTypes"
                        @change="fetchTemplates"
                        item-title="text"
                        item-value="text"
                        class="template-type-width"
              ></a-select>

              <a-autocomplete label="Documents"
                              v-model="selectedDocIds"
                              :items="documents"
                              multiple
                              autocomplete="off"
                              no-data-text="No documents found"
                              item-title="name"
                              item-value="id"
                              @change="populateDocName"
              ></a-autocomplete>
              <a-text-field
                  v-show="selectedDocIds.length === 1"
                  label="Document Name"
                  v-model="document_name"
              ></a-text-field>
            </v-col>
          </v-row>
        </v-card-text>
      </template>
    </RequestTable>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script setup>
import Snackbar from '@/components/Snackbar.vue'
import {
  handleHidingGlobalLoader,
  getRequest,

  getRequestWithParams
} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import RequestTable from "@/components/RequestTable";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const dataLoading = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const projects = ref([])
const headers = ref([
  {text: 'Customer Name', value: 'customer_name', show: true},
  {text: 'Project ID', value: 'project_id', show: true},
  {text: 'Address', value: 'address', show: true}
])
const pagination = ref({})
const projectsSearch = ref('')
const searchQuery = ref('')
const showCancelled = ref(false)
const totalItems = ref(0)
const documents = ref([])
const selectedDocIds = ref('')
const project_id = ref('')
const customer_name = ref('')
const document_name = ref(null)
const requestDialog = ref(false)
const templateTypes = ref([
  {text: 'Permitting'},
  {text: 'Utility'},
  {text: 'Change Order'}
])
const selectedTempType = ref('Permitting')

const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('ELECTRONIC_DOCUMENTS', 'MANAGE')
})

watch(() => options.value,
    () => {
      fetchProjects();
    },
    { deep: true }
)

onMounted(() => {
  appStore.loading = true
  dataLoading.value = true
  Promise.all([
    fetchProjects()
  ]).then(() => {
    appStore.loading = false;
    dataLoading.value = false;
  })
})

const fetchProjects = async(searchQuery) => {
  if(searchQuery !== undefined){
    searchQuery.value = searchQuery
  }
  try {
    dataLoading.value = true
    const {page, itemsPerPage} = options.value
    const params = {
      query: searchQuery.value,
      showCancelled: showCancelled.value,
      page: page - 1,
      size: itemsPerPage
    }
    const {data} = await getRequestWithParams(`/electronicDocument/projects`, {
      params
    })

    projects.value = data.content;
    totalItems.value = data.totalElements
    dataLoading.value = false;
  } catch (e) {
    dataLoading.value = false;
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving projects')

  }
}
const openRequest = async(it) => {
  project_id.value = it.project_id
  customer_name.value = it.customer_name
  await fetchTemplates();
  requestDialog.value = true;
}
const fetchTemplates = async() => {
  try {
    selectedDocIds.value = ''
    if (selectedTempType.value === 'Permitting') {
      const {data, status} = await getRequest('/electronicDocument/getPermittingDocuments/' + project_id.value)
      if (data != null) {
        documents.value = data
      }
      handleHidingGlobalLoader( status)
    } else if (selectedTempType.value === 'Utility') {
      const {data, status} = await getRequest('/electronicDocument/getUtilityDocuments/' + project_id.value)
      if (data != null) {
        documents.value = data
      }
      handleHidingGlobalLoader( status)
    } else {
      const {data, status} = await getRequest('/electronicDocument/getChangeOrderDocuments/' + project_id.value)
      if (data != null) {
        documents.value = data
      }
      handleHidingGlobalLoader( status)
    }

  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving documents')

  }
}
const submitRequest = async() => {
  try {
    appStore.loading = true
    if (selectedDocIds.value.length === 0) {
      console.error('*** ERROR ***', 'Error generating document: No document selected')
      appStore.showSnack('ERROR', 'Error generating document: No document selected')

      appStore.loading = false
      return
    }

    const {data, status} = await getRequestWithParams('/electronicDocument/generate/' + project_id.value + '/' + selectedDocIds.value, {
      params: {
        documentName: document_name.value
      }
    })

    if (data != null && data.length > 0) {
      for (let i = 0; i < data.length; i++) {
        window.open(data[i]);
      }
      appStore.showSnack('SUCCESS', 'Electronic document generated')
    } else {
      appStore.showSnack('ERROR', 'Error generating document')
    }

    requestDialog.value = false;
    appStore.loading = false

  } catch (e) {
    appStore.loading = false
    appStore.showSnack('ERROR', 'Error generating document')

    console.error('*** ERROR ***', e)
  }
}
const populateDocName = () => {
  try {
    if (selectedDocIds.value.length === 1) {
      let name = documents.value.filter(doc => doc.id === selectedDocIds.value[0])[0].name
      if (name.lastIndexOf('-') > -1) {
        document_name.value = name.substr(name.lastIndexOf('-') + 2)
      }
      else {
        document_name.value = name;
      }
    }
    else {
      document_name.value = null;
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    document_name.value = null;
  }

}
</script>

<style lang="scss" scoped>
.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 240px);
}

.name-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primaryText-base);
  }
}

.customer-name-width {
  width: 300px;
}

.template-type-width {
  width: 150px;
}
</style>
