<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col>
        <v-app-bar flat class="elevation-1 call-group-bar">
          <v-toolbar-title class="pt-2 title-large">Call Groups

          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text" icon :large="vuetify.breakpoint.smAndDown"
                             color="primary" v-if="userCanEdit" @click="editGroup = !editGroup"
                             :prepend-icon="editGroup ? 'mid-close' : 'edit'"
            />
            <AlbatrossButton variant="text" color="primary"
                             @click="[addNew = !addNew, newCallGroup = {}]" v-if="userCanAdd"
                             text="ADD NEW"
            />
          </v-toolbar-items>
          <template v-slot:extension>
            <div v-if="editGroup">
              <v-text-field text class="d-inline-block mt-4 edit-text"
                            label="Contacts per Phone Number"
                            type="text"
                            tabindex=1
                            v-model="maxCallCount">
              </v-text-field>
              <v-text-field text class="d-inline-block mt-4 edit-text"
                            type="text"
                            label="Days Per Period"
                            tabindex=1
                            v-model="daysPerPeriod">
              </v-text-field>
              <AlbatrossButton
                :disabled="!maxCallCount || !daysPerPeriod"
                variant="text" icon :large="vuetify.breakpoint.smAndDown"
                color="primary"
                @click="saveGroupInfo()"
                prepend-icon="save"
              />
            </div>
            <div v-else class="title-medium">
              <b>Contacts per Phone Number:</b> {{maxCallCount}}
              <br/>
              <b>Time Period:</b> {{daysPerPeriod}} days
            </div>
          </template>
        </v-app-bar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Call Group Name"
                tabindex=1
                v-model="newCallGroup.callGroupName"
            ></v-text-field>
            <AlbatrossButton
              color="primary"
              :disabled="!newCallGroup.callGroupName"
              @click="addCallGroup"
              text="SAVE"
            />
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                v-model="search"
                prepend-inner-icon="search"
                label="Search"
                single-line
                hide-details
                @input="debounceSearch"
              ></v-text-field>
            </v-card-title>
            <v-data-table
                :headers="headers"
                :items="filterCallGroups"
                :fixed-header="true"
                :items-per-page="-1"
                disable-sort
                :loading="dataLoading"
                hide-default-footer
                class="elevation-1"
            >
              <template #item.callGroupName="{ item }" class="text-left clickable" @click="goToCallGroup(item.id)">
                <img v-if="item.maxCallCountHit"
                     name="userImg" src="../../../../assets/blueraven/alert_icon.jpg" class="icon-height"
                     title="All active phone numbers exceed max call count">
                {{item.callGroupName}}
              </template>
              <template #item.activePostalCodes="{item}">{{item.postalCodesCount}}</template>
              <template #item.activePhoneNumbers="{item}">{{item.activePhoneNumbersCount}}</template>
              <template #item.active="{item}">
                <v-select attach style="width: 100px" v-model="item.active" :disabled="!userCanEdit" :items="items" @change="updateCallGroup(item)"></v-select>
              </template>
              <template #item.icons="{item}" class="text-right">
                <AlbatrossButton size="small" variant="text"
                                 icon
                                 :large="vuetify.breakpoint.smAndDown"
                                 color="primary" @click="goToCallGroup(item.id)"
                                 prepend-icon="edit"
                />
                <AlbatrossButton
                  v-if="userCanDelete"
                  size="small"
                  variant="text"
                  icon
                  :large="vuetify.breakpoint.smAndDown"
                  color="primary"
                  @click="callGroupToDelete=item"
                  prepend-icon="delete"
                />
              </template>
            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!callGroupToDelete" @confirm="[callGroupToDelete.archived = true, deleteCallGroup()]" @close-dialog="callGroupToDelete = null">
      Are you sure you want to delete this call group: <strong>{{callGroupToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import debounce from 'lodash.debounce'
  import { handleHidingGlobalLoader, getRequestWithParams, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, computed} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import {useRouter} from "vue-router/composables"
  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const router = useRouter()

  const addNew = ref(false)
  const search = ref(null)
  const showError = ref(null)
  const errorMsg = ref(null)
  const newCallGroup = ref({})
  const dataLoading = ref(true)
  const editGroup = ref(false)
  const CallGroups = ref([])
  const maxCallCount = ref(20)
  const daysPerPeriod = ref(30)
  const headers = ref([
    {text: 'Call Group Name', value: 'callGroupName', show: true},
    {text: 'No. Postal Codes', value: 'activePostalCodes', show: true},
    {text: 'Active Phone Numbers', value: 'activePhoneNumbers', show: true},
    {text: 'Status', value: 'active', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const items =ref([
    {text: 'Active', value: true},
    {text: 'Disabled', value: false}
  ])
  const callGroupToDelete = ref(null)

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'DELETE')
  })
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })
  const callGroupToDeleteName = computed(() => {
    return callGroupToDelete.value ? callGroupToDelete.value.callGroupName : ''
  })

  const debounceSearch = debounce(() => {
    //don't allow search to be null - causes issues
    // search.value = search.value || ''
    getCallGroups()
    }, 500)

  const filterCallGroups = computed(() => {
    return CallGroups.value.filter(cg => { return !cg.archived})
  })
  const goToCallGroup = (groupId) => {
    router.push({path: `/settings/callGroup/${groupId}/numbers`})
  }
  const getCallGroups = async () => {
    dataLoading.value = true
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequestWithParams(`/callGroup`, { params: { searchQuery: search.value}}, 'blueraven')
      CallGroups.value = data
      daysPerPeriod.value = data[0].daysPerPeriod
      maxCallCount.value = data[0].maxCallCount
      dataLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      dataLoading.value = false
      snackbar('ERROR', 'Error Retrieving Data')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const deleteCallGroup = async () => {
    const groupId = callGroupToDelete.value.id
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await deleteRequest(`/callGroup/${groupId}`, 'blueraven')
      snackbar('SUCCESS', 'Call Group Deleted')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Call Group')

      store.commit(AppMutations.SET_LOADING, false)
    }
    callGroupToDelete.value = null
  }
  const addCallGroup = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      newCallGroup.value.maxCallCount = maxCallCount.value
      newCallGroup.value.daysPerPeriod = daysPerPeriod.value
      const {data, status} = await postRequest(`/callGroup`, newCallGroup.value, 'blueraven')
      router.push({path: `/settings/callGroup/${data.id}/codes`})
      snackbar('SUCCESS', 'Call Group Added')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Call Group')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const updateCallGroup = async (item) => {
    showError.value = false
    errorMsg.value = ''
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await postRequest(`/callGroup`, item, 'blueraven')
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = 'Error updating Call Group'
      snackbar('ERROR', msg)

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const saveGroupInfo = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const params = {
        maxCallCount: maxCallCount.value,
        daysPerPeriod: daysPerPeriod.value
      }
      const {status} = await postRequest(`/callGroup/config`, params, 'blueraven')
      editGroup.value = false
      snackbar('SUCCESS', 'Call Group settings saved')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Call Group')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  onMounted(async () => {
    getCallGroups()
  })
</script>

<style lang="scss">
  #postal-codes .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
    border-top: solid 1px #E0E0E0;
  }
  .icon-height {
    height: 18px;
    width: 18px;
    margin-right: 5px;
  }
  .call-group-bar {
    min-height: 125px !important;
  }
  .edit-text {
    margin-left: 25px;
  }
</style>
