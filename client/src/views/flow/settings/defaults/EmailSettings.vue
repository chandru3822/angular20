<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Email Settings</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="addNew"
                @click="addEmail()"
                :disabled="!addFormValid"
                prepend-icon="save"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="[addNew = !addNew, newEmail = {}]"
                :text="addNew ? 'Cancel' : 'Add New'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-col cols="12">
      <v-form v-if="addNew" ref="emailSettingsForm" v-model="addFormValid">
        <v-row>
          <v-col>
            <v-text-field text
                          type="text"
                          placeholder="Sender Name"
                          :rules="senderRequiredRule"
                          v-model="newEmail.senderName"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col>
            <v-text-field text
                          type="text"
                          placeholder="Email Address"
                          :rules="emailRules"
                          v-model="newEmail.emailAddress"
                          required
            >
            </v-text-field>
          </v-col>
          <v-col class="text-center">
            <v-checkbox v-model="newEmail.checked" :value="newEmail.isDefault" label="Default" width="24px"></v-checkbox>
          </v-col>
        </v-row>
      </v-form>
        <v-data-table
            :headers="headers"
            :items="emailValues"
            :items-per-page="-1"
            hide-default-footer
            class="elevation-1 square-card table-striped"
        >
          <template #item.name="{ item, index }">
                <v-text-field text
                              type="text"
                              :ref="`senderName-edit-${item.id}`"
                              :rules="senderRequiredRule"
                              v-if="index === editIndex"
                              v-model="item.senderName">
                </v-text-field>
                <div v-else>
                  {{item.senderName}}
                </div>
          </template>
              <template #item.value="{item, index}" class="text-left">
                <v-text-field text
                              type="text"
                              :ref="`emailAddress-edit-${item.id}`"
                              :rules="emailRules"
                              v-if="index === editIndex"
                              v-model="item.emailAddress">
                </v-text-field>
                <div v-else style="overflow-wrap: anywhere">
                  {{ item.emailAddress }}
                </div>
              </template>
              <template #item.isDefault="{item, index}" class="text-center">
                <v-icon v-show="item.isDefault" v-if="index !== editIndex" class="centered">mdi-check</v-icon>
                <v-checkbox v-if="index == editIndex" v-model="item.checked" :value="item.isDefault" :disabled="item.isDefault" label="Default"></v-checkbox>
              </template>
              <template #item.icons="{item, index}">
                <a-btn
                    icon
                    color="primary"
                    @click="editIndex = index"
                    v-if="index !== editIndex"
                    prepend-icon="edit"
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                ></a-btn>
                <a-btn
                    icon
                    color="primary"
                    @click="updateEmailAddress(item)"
                    :disabled="!isEditValid(item)"
                    v-if="index === editIndex"
                    prepend-icon="save"
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="index === editIndex"
                    @click="clearChanges()"
                    text="cancel"
                ></a-btn>
                <a-btn
                    :disabled="item.isDefault"
                    icon
                    color="primary"
                    @click="emailToDelete=item"
                    prepend-icon="delete"
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                ></a-btn>
              </template>
        </v-data-table>
      </v-col>
    <ConfirmationDialog :open-dialog="!!emailToDelete" @confirm="deleteEmailAddress" @close-dialog="emailToDelete=null">
      Are you sure you want to delete this email address: <strong>{{emailToDeleteAddress}}</strong>?
    </ConfirmationDialog>

    <a-btn
        v-if="is7oaksAdmin"
        class="mt-5"
        :loading="emailQueueProcessing"
        color="primary"
        @click="processEmailQueue()"
        text="Force email queue processing"
    ></a-btn>
  </v-container>
</template>

<script setup>
import {
  getRequest,
  putRequest,
  postRequest,
  putRequestWithRequestParams,
  postRequestWithRequestParams,
  handleHidingGlobalLoader
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import constants from "@/helpers/constants";
import ConfirmationDialog from "@/components/ConfirmationDialog";

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue"
import {useUserStore} from "@/stores/UserStorePinia.js"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const addFormValid = ref(false)
const emailQueueProcessing = ref(false)
const is7oaksAdmin = ref(userStore.isSystemAdmin)
const headers = ref([
  {text: 'Sender Name', value: 'name', show: true},
  {text: 'Email Address', value: 'value', show: true},
  {text: 'Default', value: 'isDefault', show: true, align:'center'},
  {text: null, value: 'icons', show: true, sortable: false}
])
const emailValues = ref([])
const companyId = ref(userStore.details.companyId)
const userId = ref(userStore.details.id)
const editIndex = ref(null)
const newEmail = ref({})
const addNew = ref(false)
const senderRequiredRule = ref([v => !!v || 'Sender name is required'])
const emailRules = ref(constants.EMAIL_RULES)
const emailToDelete = ref(null)

const emailToDeleteAddress = computed(() => {
  return emailToDelete.value ? emailToDelete.value.emailAddress : ''
})

onMounted(async () => {
  getEmailSenders()
})

const getEmailSenders = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/emailAddress/${companyId.value}`, null)
    emailValues.value = data;
    emailValues.value.map( email => email.checked = email.isDefault)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Email Addresses')

    appStore.loading = false
  }
}
const clearChanges = async () => {
  await getEmailSenders()
    editIndex.value = null
}
const isEditValid = (item) => {
  const itemId = item.id
  const senderNameRef = vueInstance.$refs[`senderName-edit-${itemId}`]
  const emailAddressRef = vueInstance.$refs[`emailAddress-edit-${itemId}`]
  if(senderNameRef && emailAddressRef){
    return senderNameRef.valid && emailAddressRef.valid
  } else if (senderNameRef && !emailAddressRef){
    return senderNameRef.valid
  } else if (!senderNameRef && emailAddressRef) {
    return emailAddressRef.valid
  } else return !!(item.senderName && item.emailAddress);
}
const updateEmailAddress = async (item) => {
  appStore.loading = true
  try {
    item.modifiedById = userId.value;
    item.companyId = companyId.value;
    const confirmChangeDefault = (item.checked !== item.isDefault)
    item.isDefault = item.checked;
    const {data, status} = await putRequestWithRequestParams('/emailAddress/updateEmailAddress', item, {updateDefault: confirmChangeDefault})
    emailValues.value = data;
    editIndex.value = null
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Email Address')

    appStore.loading = false
  }
}
const addEmail = async () => {
  appStore.loading = true
  try {
    vueInstance.$refs.emailSettingsForm.validate();
    if(!addFormValid.value) {
      throw {data: false};
    }
    const makeDefault = newEmail.value.checked || false
    newEmail.value.isDefault = makeDefault;
    newEmail.value.createdById = userId.value;
    newEmail.value.companyId=companyId.value;
    const {data, status} = await postRequestWithRequestParams('/emailAddress/saveEmailAddress', newEmail.value, {updateDefault: makeDefault})
    emailValues.value = data;
    newEmail.value = null;
    addNew.value = false;
    handleHidingGlobalLoader(status)
  } catch (e) {
    if(e.data != false) {
      console.error('*** ERROR ***', e)
    }
    snackbar('ERROR', 'Error Adding Email Address')

    appStore.loading = false
  }
}
const deleteEmailAddress = async () => {
  const item = emailToDelete.value
  appStore.loading = true
  try {
    if(item.isDefault){
      throw {data: false}
    }
    item.modifiedById = userId.value;
    const {status} = await putRequest('/emailAddress/archiveEmailAddress', item)
    emailValues.value.splice(emailValues.value.indexOf(item), 1);//remove deleted address from list
    editIndex.value = null
    handleHidingGlobalLoader(status)
  } catch (e) {
    if(e.data != false) {
      console.error('*** ERROR ***', e)
    }
    snackbar('ERROR', 'Error Updating Email Address')
    appStore.loading = false
  }
  emailToDelete.value = null
}
const cancelDelete = (item) => {
  item.deleteConfirm = false
}
const processEmailQueue = async () => {
  emailQueueProcessing.value = true
  try {
    await postRequest(`/emailAddress/processEmailQueue`, null, null)
    emailQueueProcessing.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Processing Email Queue')

    emailQueueProcessing.value = false
  }
}
</script>

<style scoped>

</style>
