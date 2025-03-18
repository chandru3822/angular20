<template>
  <div>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Orgs Assigned to Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addOrg = !addOrg, newOrg = {}, orgHistory = []]"
              v-if="canAdd"
              :prepend-icon="addOrg ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addOrg" class="square-card text-left px-5 pb-5">
          <v-row>
            <v-col cols="12" md="6">
              <a-autocomplete v-model="newOrg.orgId"
                              :items="orgsToAdd"
                              :loading="orgsLoading"
                              prepend-icon="search"
                              cache-items
                              :search-input.sync="orgSearch"
                              label="Search for an org..."
                              item-title="orgName"
                              item-value="orgId"
                              autocomplete="off"
                              @input="getOrgHistory(newOrg.orgId)"
                              attach
              >
              </a-autocomplete>
              <DatetimePickerInput
                v-model="newOrg.startDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Start Date"
                :readonly="!newOrg.orgId || errorLoadingOrgHistory"
                @input="checkDates(newOrg.startDate, newOrg.endDate, orgHistory, newOrg, null)"
              />
              <DatetimePickerInput
                v-model="newOrg.endDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="End Date"
                :readonly="!newOrg.orgId || errorLoadingOrgHistory"
                @input="checkDates(newOrg.startDate, newOrg.endDate, orgHistory, newOrg, null)"
              />
            </v-col>
            <v-col cols="12" md="6">
              <v-data-table
                :headers="historyHeaders"
                :items="orgHistory"
                :fixed-header="true"
                :items-per-page="-1"
                disable-sort
                hide-default-footer
                class="elevation-1"
                v-if="orgHistory.length > 0"
              >
              </v-data-table>
              <div v-if="errorLoadingOrgHistory" class="error--text">
                We had a problem loading this orgs's plan history. Cannot add this org until their history can be
                checked.
              </div>
            </v-col>
          </v-row>

          <div v-if="newOrg.dateError" class="error--text mb-2">
            * Error: {{ newOrg.dateErrorMsg }}
          </div>
          <div class="mb-2" v-else-if="newOrg.showNote">
            {{ newOrg.noteMsg }}
          </div>
          <a-btn
            color="primary"
            class="mr-3"
            @click="addOrgToPlan()"
            :disabled="newOrg.dateError || !newOrg.orgId || !newOrg.startDate || errorLoadingOrgHistory"
            text="Add"
          ></a-btn>
        </v-card>
        <v-divider v-if="addOrg"></v-divider>
        <v-data-table
          :headers="headers"
          :items="filteredCommissionOrgs"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          single-expand
          :expanded.sync="assignedOrgExpanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available orgs
          </template>

          <template #no-results>
            No available orgs
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-row>
                <v-col cols="12" md="6">
                  <DatetimePickerInput
                    v-model="item.endDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="End Date"
                    :readonly="errorLoadingOrgHistory"
                    @input="checkDates(item.startDate, item.endDate, orgHistory, item, commission.id)"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-data-table
                    :headers="historyHeaders"
                    :items="orgHistory"
                    item-key="orgPlanId"
                    :fixed-header="true"
                    :items-per-page="-1"
                    hide-default-footer
                    class="elevation-1"
                    v-if="orgHistory.length > 0"
                  >
                  </v-data-table>
                  <div v-if="errorLoadingOrgHistory" class="error--text">
                    We had a problem loading this org's plan history. Cannot add this org until their history can be
                    checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{ item.dateErrorMsg }}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{ item.noteMsg }}
              </div>
              <a-btn
                color="primary"
                class="mr-3"
                @click="updateAssignedOrg(item)"
                :disabled="item.dateError || !item.orgId || !item.startDate || errorLoadingOrgHistory"
                text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.orgName }}</td>
              <td class="text-left">{{ item.startDate }}</td>
              <td class="text-left">{{ item.endDate }}</td>
              <td>
                <a-btn
                  v-if="commission.statusType === 'PENDING' && !assignedOrgExpanded.includes(item) && canEdit"
                  size="small"
                  variant="text"
                  color="primary"
                  prepend-icon="edit"
                  @click="[assignedOrgExpanded = [item], getOrgHistory(item.orgId)]"
                ></a-btn>
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="assignedOrgExpanded = []"
                  v-if="assignedOrgExpanded.includes(item) && canEdit"
                  text="Cancel"
                ></a-btn>
                <a-btn
                  v-if="commission.statusType === 'PENDING' && canDelete"
                  size="small"
                  variant="text"
                  color="primary"
                  @click="orgToDelete=item"
                  prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!orgToDelete" @confirm="deleteOrgFromPlan" @close-dialog="orgToDelete=null">
      Are you sure you want to delete <strong>{{ orgToDeleteName }}</strong>?
    </ConfirmationDialog>
  </div>
</template>

<script setup>
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  import {
    handleHidingGlobalLoader,
    getRequest,
    deleteRequest,
    putRequest,
    postRequestWithRequestParams,
    postRequest,
    getSnackbar,
    getRequestWithParams
  } from '@/helpers/helpers.js';
  import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
  import { useBrsStore } from '@/stores/BrsStore.js'
  import {getCurrentInstance, computed, ref, onMounted, watch, toRefs} from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useAppStore} from '@/stores/AppStore.js'
  import {useRoute, useRouter} from "vue-router/composables"
  import debounce from "lodash.debounce"
  import { storeToRefs } from 'pinia'

  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const appStore = useAppStore()
  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const props = defineProps({
    commission: Object,
    planId: Number,
    dataLoading: Boolean,
    canEdit: Boolean,
    canAdd: Boolean,
    canDelete: Boolean,
    isAdmin: Boolean
  })
  const { commission, planId } = toRefs(props)

  const addOrg = ref(false)
  const newOrg = ref({})
  const orgsToAdd = ref([])
  const orgSearch = ref('')
  const orgHistory = ref([])
  const orgsLoading = ref(false)
  const orgToDelete = ref(null)
  const errorLoadingOrgHistory = ref(false)
  const assignedOrgExpanded = ref([])

  const historyHeaders = ref([
    {text: 'Name', value: 'name', show: true},
    {text: 'Start Date', value: 'startDate', show: true},
    {text: 'End Date', value: 'endDate', show: true},
  ])

  const headers = ref([
    {text: 'Org Name', value: 'orgName', show: true},
    {text: 'Start Date', value: 'startDate', show: true},
    {text: 'End Date', value: 'endDate', show: true},
    {text: '', value: 'icons', show: true},
  ])

  const orgToDeleteName = computed(() => {
    return orgToDelete.value ? orgToDelete.value.orgName : ''
  })
  const filteredCommissionOrgs = computed(() => {
    return commission.value?.orgs?.filter(cu => {
      return !cu.archived
    })
  })
  const timezone = computed(() => {
    return userStore.timezone.value
  })


  watch(orgSearch, (val) => {
    if (!val) {
      orgsToAdd.value = []
      newOrg.value.orgId = null
      return
    }
    orgsToAdd.value = []
    getOrgsToAddDebounced(val)
  })

  onMounted(() => {

  })

  const updateAssignedOrg = async (item) => {
    appStore.loading = true
    try {
      const {status} = await postRequest(`/commissionManagement/${planId.value}/updateOrg`, item, 'blueraven')
      assignedOrgExpanded.value = []
      orgHistory.value = []
      appStore.showSnack('SUCCESS', 'Assigned Org Updated')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Updating Assigned Org')
      appStore.loading = false
    }
  }
  const getOrgsToAddDebounced = debounce((val) => {
    getOrgsToAdd(val)
  }, 500)
  const getOrgsToAdd = async (query) => {
    if (addOrg.value) {
      orgsLoading.value = true
      try {
        let params = {
          query,
          planId: planId.value
        }
        const {data} = await getRequestWithParams(`/commissionManagement/dealerOrgs/_search`, {params}, 'blueraven')
        orgsToAdd.value = data
        orgsLoading.value = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Commission Plan Orgs')
        appStore.loading = false
      }
    }
  }
  const addOrgToPlan = async () => {
    appStore.loading = true
    try {
      let params = {
        orgId: newOrg.value.orgId,
        startDate: newOrg.value.startDate,
        endDate: newOrg.value.endDate,
        approvalCreds: null
      }
      const {
        data,
        status
      } = await postRequestWithRequestParams(`/commissionManagement/${planId.value}/orgs`, params, {addOrgToPlan: true}, 'blueraven')
      commission.value.orgs = data
      appStore.showSnack('SUCCESS', 'Commission Plan Org Added')
      addOrg.value = false
      newOrg.value = {}
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Commission Plan Org')
      appStore.loading = false
    }
  }
  const deleteOrgFromPlan = async () => {
    const commissionPlanOrg = orgToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/commissionManagement/${planId.value}/commissionOrg/${commissionPlanOrg.id}`, 'blueraven')
      appStore.showSnack('SUCCESS', 'Commission Plan Org Deleted')
      commissionPlanOrg.archived = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Commission Plan Org')
      appStore.loading = false
    }
  }
  const getOrgHistory = async (orgId) => {
    //reset the rest of the new org fields if they change orgs
    delete newOrg.value.startDate
    delete newOrg.value.endDate
    newOrg.value.dateError = false
    newOrg.value.dateErrorMsg = ''
    newOrg.value.showNote = false
    newOrg.value.noteMsg = ''
    errorLoadingOrgHistory.value = false
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/commissionManagement/commissionOrg/${orgId}/history`, 'blueraven')
      orgHistory.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      errorLoadingOrgHistory.value = true
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Org History')
      appStore.loading = false
    }
  }
  const checkDates = (startDate, endDate, plans, item, existingId) => {
    //item = where to track the error
    item.dateError = false

    if (startDate > endDate) {
      item.dateError = true
      item.dateErrorMsg = 'End Date cannot be before Start Date'
    } else {
      let overlap = []
      let hasActivePlan = false
      plans.forEach(p => {
        if (dateRangeOverlap(startDate, endDate, p, existingId)) {
          overlap.push(p)
        }
        // if any plan doesn't have an end date, then there is an active plan
        if (!p.endDate) {
          hasActivePlan = true
        }
      })
      if (overlap.length > 0) {
        item.dateError = true
        item.dateErrorMsg = 'Plans Cannot Overlap'
      } else if (!existingId && startDate && hasActivePlan) {
        item.showNote = true
        item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
      }
    }
  }
  const dateRangeOverlap = (start, end, plan, existingId) => {
    //this will not allow them to go back in time to add plans before existing plans which seems to be ok
    if (plan.id === existingId) {
      // ignore overlap check for self on existing record
      return false
    } else {
      //this is used when adding a new plan
      return start <= plan.startDate || start <= plan.endDate
    }
  }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
