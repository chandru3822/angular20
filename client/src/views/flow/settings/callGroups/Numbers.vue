<template>
  <v-container class="pa-0" id="numbers-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Phone Numbers
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                             icon
                             :large="vuetify.breakpoint.smAndDown"
                             color="primary" v-if="userCanAdd" @click="[addNumber = !addNumber, newNumber = '']"
                             :prepend-icon="addNumber ? 'remove' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNumber" class="square-card text-left pa-5">
          <a-text-field
                        label="Phone Number"
                        counter
                        type="number"
                        :maxlength="20"
                        v-model="newNumber">
          </a-text-field>
          <div class="error-text mb-3" v-if="showError">{{errorMsg}}</div>
          <a-btn color="primary" class="mr-3 white--text" @click="addNumberToGroup()"
                           :disabled="!newNumber"
                           text="Add"
          />
        </v-card>
        <v-divider v-if="addNumber"></v-divider>
        <v-card-title class="pt-0">
          <a-text-field
            v-model="numberSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></a-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table id="call-group-phone-number-table"
          :headers="numberHeaders"
          :items="filterPhoneNumbers"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="numberSearch"
          :loading="dataLoading"
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No available phone numbers</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available phone numbers</span>
          </template>
              <template #item.phoneNumber="{item}" class="text-left">
                <img v-if="item.maxCallCountHit"
                  name="userImg" src="../../../../assets/blueraven/alert_icon.jpg" class="icon-height"
                title="Max call count exceeded">
                {{item.phoneNumber}}
              </template>
              <template #item.dateCreated="{item}" class="text-left">{{item.dateCreated  | formatDate('date', 'M/D/YYYY')}}</template>
              <template #item.callCount="{item}" class="text-left">{{item.callCount}}</template>
              <template #item.active="{item}" class="text-left">
                <v-select attach style="width: 120px" v-model="item.active" :disabled="!userCanEdit" :items="items" @change="updatePhoneNumber(item)"></v-select>
              </template>
              <template #item.icons="{item}">
                <a-btn size="small"
                                 variant="text"
                                 icon
                                 :large="vuetify.breakpoint.smAndDown" color="primary" v-if="userCanDelete"
                                 @click="phoneNumberToDelete=item"
                                 prepend-icon="delete"
                />
              </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!phoneNumberToDelete" @confirm="deleteNumber" @close-dialog="phoneNumberToDelete = null">
      Are you sure you want to delete this call group: <strong>{{phoneNumberToDeleteNumber}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";


  import {getCurrentInstance, onMounted, ref, computed} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const vuetify = vueInstance.$vuetify
  const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()

  const phoneNumbers = ref([])
  const showError = ref(false)
  const errorMsg = ref('')
  const dataLoading = ref(true)
  const addNumber = ref(false)
  const newNumber = ref('')
  const numberSearch = ref('')
  const numberHeaders = ref([
    {text: 'Phone Number', value: 'phoneNumber', show: true},
    {text: 'Date Added', value: 'dateCreated', show: true},
    {text: 'Contacts Assigned', value: 'callCount', show: true},
    {text: 'Status', value: 'active', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const items = ref([
    {text: 'Active', value: true},
    {text: 'Disabled', value: false}
  ])
  const phoneNumberToDelete = ref(null)

  const phoneNumberToDeleteNumber = computed(() => {
    return phoneNumberToDelete.value ? phoneNumberToDelete.value.phoneNumber : ''
  })
  const callGroupId = computed(() => {
    return route.params.id
  })
  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'EDIT')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel('CALL_GROUPS', 'DELETE')
  })


  onMounted (() => {
    getNumbersForGroup()
  })

  const filterPhoneNumbers = computed(() => {
    return phoneNumbers.value?.length ? phoneNumbers.value.filter(pc => { return !pc.archived}) : []
  })
  const getNumbersForGroup = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/callGroup/${callGroupId.value}/numbers`, 'blueraven')
      phoneNumbers.value = data
      dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
  const deleteNumber = async () => {
    const number = phoneNumberToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/callGroup/number/${number.id}`, 'blueraven')
      number.archived = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Removing Phone Number')

      appStore.loading = false
    }
  }
  const addNumberToGroup = async () => {
    showError.value = false
    errorMsg.value = ''
    appStore.loading = true
    try {
      let phoneRegex = '^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$'
      if (!newNumber.value.match(phoneRegex) || newNumber.value.length > 20) {
        snackbar('ERROR', 'Error Adding Phone Number: Please reformat the Phone field with a valid phone number')

        appStore.loading = false
        return;
      }

      let params = {
        callGroupId: callGroupId.value,
        phoneNumber: newNumber.value
      }
      const {data, status} = await postRequest(`/callGroup/addNumber`, params, 'blueraven')
      phoneNumbers.value.push(data)
      addNumber.value = false
      newNumber.value = {}
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = e.data?.message?.includes('Phone Number Already In Use') ? e.data.message : 'Error Adding Phone Number'
      snackbar('ERROR', msg)

      appStore.loading = false
    }
  }
  const updatePhoneNumber = async (item) => {
    showError.value = false
    errorMsg.value = ''
    appStore.loading = true
    try {
      let params = {
        id: item.id,
        active: item.active
      }
      const {status} = await postRequest(`/callGroup/updateNumber`, params, 'blueraven')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = 'Error updating Phone Number'
      snackbar('ERROR', msg)
      appStore.loading = false
    }
  }
</script>

<style lang="scss">
  #numbers-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
  .icon-height {
    height: 25px;
    width: 25px;
    margin-right: 15px;
  }

  @media (max-width: 770px) {
    #call-group-phone-number-table {
      padding-bottom: 12px;
      div.v-data-footer {
        display: inline-block;
        width: 100%;
        padding-bottom: 12px;

        div.v-data-footer__select {
          justify-content: center;
        }

        div.v-data-footer__pagination {

        }

        div.v-data-footer__icons-before {
          display: inline;
          margin-left: calc(50% - 36px);
        }

        div.v-data-footer__icons-after {
          display: inline;
        }

      }
    }
  }

</style>

