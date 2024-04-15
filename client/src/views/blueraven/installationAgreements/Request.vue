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
    <RequestTable :headers="headers" :projects="projects" :total-items="totalItems" :feature-code="'INSTALLATION_AGREEMENT'" :is-loading="dataLoading"
                  @openRequest="openRequest($event)" @searchInput="fetchProjects($event)" @submitRequest="submitRequest">
      <template v-slot:dialogContent>
        <v-card-title>
          <span class="text-h5">Request for Installation Agreement</span>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <a-text-field label="Customer Name"
                            v-model="requestItem.customer_name"
                            disabled
              ></a-text-field>

              <div style="display: flex;">
                <a-text-field label="Email Address"
                              v-model="requestItem.email"
                              :disabled="!editEmail"
                ></a-text-field>
                <v-icon v-if="!editEmail" small color="primary" class="mr-3" @click="editEmail = !editEmail">
                  edit
                </v-icon>
                <v-icon v-if="editEmail" small text color="primary" class="mr-3" @click="resetEmail">
                  cancel
                </v-icon>
                <v-icon v-if="editEmail" small color="primary" class="mr-3" @click="updateEmail">
                  save
                </v-icon>
              </div>


              <a-btn
                  color="primary"
                  raised
                  @click="openLoanApp()"
                  text="Finance Application"
              ></a-btn>
              <a-btn
                  :disabled="!requestItem.proposalNbr"
                  v-if="requestItem.sunpowerProposal"
                  color="primary"
                  raised
                  @click="updateSunpowerApp()"
                  class="mt-5"
                  text="Update / Renew Spwr Quote"
              ></a-btn>
            </v-col>
            <v-col>
              <a-select attach label="Proposal Number"
                        v-model="selectedProposal"
                        return-object
                        :items="requestItem.proposalNbrs"
                        item-title="proposalNbr"
                        @change="handleProposalSelection"
              />
              <v-checkbox label="Send English Installation Agreement"
                          class="default-text-color"
                          v-model="requestItem.sendInstallationAgreement"
              />
              <v-checkbox label="Send Spanish Installation Agreement"
                          class="default-text-color"
                          v-model="requestItem.isSpanish"
              />
              <v-checkbox label="Send Finance Docs (Finance Products Only)"
                          class="default-text-color"
                          v-model="requestItem.sendLoanDocs"
              />
            </v-col>
          </v-row>
        </v-card-text>
      </template>
    </RequestTable>
  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,

  getRequestWithParams
} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import RequestTable from "@/components/RequestTable";

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
const requestItem = ref({customer_name: '',email: '',proposalNbr: '',proposalNbrs: [],sendLoanDocs: true,sendInstallationAgreement: false,isSpanish: false,projectId: ''
})
const selectedProposal = ref(null)
const currentEmail = ref('')
const editEmail = ref(false)

const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('INSTALLATION_AGREEMENT', 'MANAGE')
})
watch(
    () => options,
    (newValue, oldValue) => {
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

const fetchProjects = async(search) => {
  if(search !== undefined){
    searchQuery.value = search
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

    const {data} = await getRequestWithParams(`/install-agreement/projects`, {
      params
    }, 'blueraven')

    projects.value = data.content;
    totalItems.value = data.totalElements
    dataLoading.value = false;
  } catch (e) {
    dataLoading.value = false;
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving installation agreements')

  }
}
const setSearchQuery = (query)=> {
  searchQuery.value=query
}
const handleProposalSelection = () => {
  requestItem.value.proposalNbr = selectedProposal.value.proposalNbr
  if (selectedProposal.value.loanType) {
    requestItem.value.sunpowerProposal = selectedProposal.value.loanType.includes('SunPower')
  }
}
const openRequest = async(it) => {
  requestItem.value.customer_name = it.customer_name
  requestItem.value.email = it.email
  currentEmail.value = it.email
  requestItem.value.projectId = it.project_id
  requestItem.value.sunpowerProposal = false

  // get proposal numbers
  try {
    const {data, status} = await getRequest('/install-agreement/getProposalNumbers/' + it.project_id, 'blueraven')
    if (data == null) {
      requestItem.value.proposalNbrs = ['No Logs Found For Project']
      requestItem.value.proposalNbr = 'No Logs Found For Project'
    } else {
      requestItem.value.proposalNbrs = data;
    }

    handleHidingGlobalLoader( status)
  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving proposal numbers')

  }
}
const submitRequest = async() => {
  try {
    appStore.loading = true
    if (!requestItem.value.proposalNbr) {
      console.error('*** ERROR ***', 'Error saving installation agreement request: No Proposal Number selected')
      appStore.showSnack('ERROR', 'Unable to save installation agreement request without Proposal Number')

      appStore.loading = false
      return
    }

    const {status} = await postRequest('/install-agreement/create', requestItem.value, 'blueraven')
    handleHidingGlobalLoader( status)
    appStore.showSnack('SUCCESS', 'Installation agreement request submitted')

  } catch (e) {
    appStore.loading = false
    if (e?.data?.message.includes('locate')) {
      appStore.showSnack('ERROR', 'Error: Unable to locate a finance application for this project')
    } else if (e?.data?.message) {
      appStore.showSnack('ERROR', e.data.message)
    } else {
      appStore.showSnack('ERROR', 'Error submitting installation agreement request ')
    }

    console.error('*** ERROR ***', e)
  }
}
const updateSunpowerApp = async() => {
  try {
    appStore.loading = true
    const {status} = await postRequest('/install-agreement/updateSunpowerApp/' + requestItem.value.projectId + '/' + requestItem.value.proposalNbr, {}, 'blueraven')
    requestDialog.value = false;
    handleHidingGlobalLoader( status)
    appStore.showSnack('SUCCESS', 'SunPower loan application updated')

    appStore.loading = false
  } catch (e) {
    appStore.loading = false
    if (e?.data?.message) {
      appStore.showSnack('ERROR', e.data.message)
    } else {
      appStore.showSnack('ERROR', 'Error updating SunPower loan application')
    }

    console.error('*** ERROR ***', e)
  }
}
const openLoanApp = async() => {
  try {
    appStore.loading = true
    if (!requestItem.value.proposalNbr) {
      console.error('*** ERROR ***', 'Error: Unable to generate Finance application without Proposal Number')
      appStore.showSnack('ERROR', 'Unable to generate Finance application without Proposal Number')

      appStore.loading = false
      return
    }

    if (!requestItem.value.email) {
      console.error('*** ERROR ***', 'Error: Unable to generate Finance application without Email Address')
      appStore.showSnack('ERROR', 'Unable to generate Finance application without Email Address')

      appStore.loading = false
      return
    }

    const {
      data,
      status
    } = await getRequest('/install-agreement/generate/' + requestItem.value.projectId + '/' + requestItem.value.proposalNbr, 'blueraven')

    // Handle case for Sunpower update
    if (data === 'Quote Updated') {
      appStore.showSnack('SUCCESS', 'Quote Updated')

    }
    else {
      window.open(data);
    }

    handleHidingGlobalLoader( status)
  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    if (e.data.message != null) {
      appStore.showSnack('ERROR', e.data.message)
    } else if (e.data.detail != null) {
      appStore.showSnack('ERROR', e.data.detail)
    } else {
      appStore.showSnack('ERROR', 'Error generating Finance Application')
    }
  }
}
const updateEmail = async() => {
  try {
    appStore.loading = true
    const {status} = await putRequest('/install-agreement/updateEmailAddress/' + requestItem.value.projectId, {
      email: requestItem.value.email
    }, 'blueraven')

    currentEmail.value = requestItem.value.email;
    editEmail.value = false;
    appStore.showSnack('SUCCESS', 'Email address updated')

    handleHidingGlobalLoader( status)
    await fetchProjects(searchQuery.value);
  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error updating email address')

  }
}
const resetEmail = () => {
  editEmail.value = false;
  requestItem.value.email = currentEmail.value;
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

.default-text-color .theme--light.v-label{
  color: rgba(0,0,0,0.87)
}
</style>
