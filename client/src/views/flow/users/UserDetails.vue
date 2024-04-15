<template>
  <div id="user-detail-container">
    <!--    modal for editing user fields -->
    <ConfirmationDialog :open-dialog="showEditModal" @confirm="validateForm" @close-dialog="showEditModal = false" parent-close>
      <template v-slot:title>User Overview</template>
      <v-form ref="userEditForm">
        <a-select attach v-model="tempUser.userStatusTypeId"
                  :items="userStatusTypes"
                  label="User Status"
                  :rules="requiredRules"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  placeholder="Select a status..."
                  item-title="userStatusType"
                  item-value="id"
                  autocomplete="off">
        </a-select>
        <a-text-field
                      label="User First Name"
                      placeholder=" "
                      :rules="requiredRules"
                      :readonly="!userCanEdit"
                      v-model="tempUser.firstName"
        ></a-text-field>
        <a-text-field
                      label="User Last Name"
                      :rules="requiredRules"
                      :readonly="!userCanEdit"
                      v-model="tempUser.lastName"
        ></a-text-field>
        <a-text-field
                      label="Phone"
                      placeholder=" "
                      :rules="userPhoneRule"
                      :readonly="!userCanEdit"
                      v-model="tempUser.phoneNumber"></a-text-field>
        <a-text-field
                      label="Phone Extension"
                      placeholder=" "
                      :readonly="!userCanEdit"
                      v-model="tempUser.phoneExtension"></a-text-field>
        <a-text-field
                      label="E-Mail"
                      placeholder=" "
                      :rules="emailRule"
                      :readonly="!userCanEdit"
                      v-model="tempUser.email"></a-text-field>
        <a-text-field
                      label="Username"
                      placeholder=" "
                      :rules="usernameRule"
                      :readonly="!userCanEdit"
                      v-model="tempUser.username"></a-text-field>
        <a-text-field  class="mt-4"
                      v-if="userIsAdmin"
                      :rules="passwordRule"
                      label="Password"
                      placeholder=" "
                      v-model="tempUser.newPassword"></a-text-field>
      </v-form>
      <template v-slot:yes>Save</template>
    </ConfirmationDialog>
    <!-- Delete Company Access dialog  -->
    <ConfirmationDialog :open-dialog="!!companyToDelete" @confirm="removeUserCompany" @close-dialog="[companyToDelete.deleteConfirm = false, companyToDelete = null]">
      Are you sure you want to delete {{ companyToDeleteName }} from this user?
      <template v-slot:yes>Delete</template>
    </ConfirmationDialog>
    <!--    end dialogs -->
    <ThreeColumnLayout :header-hidden="true"
                       :auto-overflow-left="false">
      <template v-slot:left-column>
        <div v-if="!projectStore.leftSideSplit && user && user.id"
             class="height-one-hunned overflow-y-auto">
          <PageOverview
              page-name="User"
              :show-edit-btn="userCanEdit"
              @clickEdit="[getUserStatusTypes(), tempUser = cloneDeep(user), showEditModal = true]"
              :details="overviewDetails"
              :dense="true"
          ></PageOverview>
          <v-divider class="mt-4" v-if="user.loginAttempts >= 9"></v-divider>
          <v-card color="#ffcac7" class="pa-4 mx-2 mt-2" v-if="user.loginAttempts >= 9">
            <label>Too Many Attempts, User Account Locked</label><br/>
            <a-btn
                v-if="userIsAdmin"
                @click="unlockUserAccount"
                color="primary"
                class="mt-2"
                text="Unlock"
            ></a-btn>
          </v-card>
          <v-divider></v-divider>
          <SidePanelExpansionPanel header="Company Access" :section-expanded="sectionExpanded">
            <template v-slot:tool-btn>
              <v-menu
                  v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
                  bottom
                  offset-y
                  :close-on-content-click="false"
              >
                <template v-slot:activator="{ on: menu }">
                  <a-btn
                      variant="text"
                      color="primary"
                      :activation-handler="{ ...menu }"
                      x-small
                      v-if="userIsAdmin"
                      @click="addUserCompany = !addUserCompany"
                      prepend-icon="add"
                  ></a-btn>
                </template>
                <v-card class="pa-5">
                  <a-select
                      v-model="newCompany.id"
                      :items="filterUserCompanies()"
                      label="Company"
                      item-title="companyName"
                      item-value="id"
                      @input="getUserStatusTypes(newCompany.id)"
                  ></a-select>
                  <a-select
                      v-model="newCompany.companyUserStatusTypeId"
                      :items="companyUserStatusTypes"
                      label="User Status"
                      item-title="userStatusType"
                      item-value="id"
                  ></a-select>
                  <a-btn
                      v-if="userIsAdmin"
                      color="primary"
                      class="mb-2"
                      :disabled="!newCompany.id || !newCompany.companyUserStatusTypeId"
                      variant="text"
                      @click="saveUserCompany"
                      text="Add User to Company"
                  ></a-btn>
                </v-card>
              </v-menu>
            </template>
            <template v-slot:expanded-content>
              <v-card flat v-for="uc in user.companies"
                      class="user-company-button albatross-body-1">
                {{ uc.companyName }}
                <a-btn
                    icon
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="userIsAdmin && user.companies.length > 1"
                    @click="companyToDelete = uc"
                    prepend-icon="delete"
                ></a-btn>
              </v-card>
            </template>
          </SidePanelExpansionPanel>
          <v-divider></v-divider>
        </div>
      </template>
      <template v-slot:main-column>
        <div>
          <!-- this cannot be inside the v-if display or else the fixed toolbar doesn't work -->
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="albatross-header-3">
              User Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                  variant="text"
                  color="primary"
                  @click="setSplitColumnValue()"
                  class="px-0"
                  :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
              ></a-btn>
              <div>
                <a-btn
                    color="primary"
                    class="mt-3"
                    v-if="userCanEdit"
                    :loading="fieldsLoading"
                    :disabled="fieldsSaving"
                    @click="saveUser()"
                    text="Save Fields"
                ></a-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div class="user-fields-container" v-if="user && user.id && !fieldsLoading">
            <v-row class="px-5">
              <v-col cols="12" class="text-left py-0 px-0">
                <!--    process field groups-->
                <v-form ref="userForm">
                  <v-col
                      class="pt-0"
                      v-for="(cfg, index) in customFieldGroups"
                      :key="index"
                  >
                    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
                      <v-toolbar-title>
                        {{ cfg.groupName }}
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                      </v-toolbar-items>
                    </v-toolbar>

                    <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                      <v-row>
                        <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                        <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                      </v-row>

                    </v-card>
                  </v-col>

                </v-form>
              </v-col>
            </v-row>
          </div>
          <div v-else>
            <SpinnerInline centered :size="50" color="primary"/>
          </div>
        </div>
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="user && user.id"
                         :user-id-in="userId"
                         :force-show-upload-btn="true"
                         :show-sms-tab="true"></ProjectActivity>
      </template>
    </ThreeColumnLayout>

  </div>
</template>

<script setup>

import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  formatPhoneNumber, logError
} from '@/helpers/helpers'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import cloneDeep from 'lodash.clonedeep'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import constants from '@/helpers/constants'
import SpinnerInline from '@/components/SpinnerInline'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import PageOverview from '../PageOverview'
import SidePanelExpansionPanel from '@/components/SidePanelExpansionPanel.vue'
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store



const breadcrumbs = ref([
  {text: 'Back to Users',disabled: false,exact: true,to: `/users`},
])
const userPhoneRule = ref([v => !!v || 'Field is required',v => (!v || (v && v.length !== 0)) || 'Field is required',v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number"])
const usernameRule = ref(constants.USERNAME_RULES)
const passwordRule = ref(constants.PASSWORD_RULES)
const emailRule = ref(constants.EMAIL_RULES)
const companies = ref([])
const dirtyCfvs = ref([])
const tempUser = ref({})
const userEditForm = ref(null)
const userForm = ref(null)
const user = ref({})
const showEditModal = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const fieldsSaving = ref(false)
const fieldsLoading = ref(true)
const customFieldGroups = ref([])
const notes = ref([])
const owners = ref([])
const changeOwner = ref(false)
const userStatusTypes = ref([])
const addUserCompany = ref(false)
const newCompany = ref({})
const sectionExpanded = ref(true)
const companyUserStatusTypes = ref([])
const companyToDelete = ref(null)

const userId = computed(() => {
  return parseInt(route.params.id)
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'EDIT')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('USERS', 'ADMIN')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const overviewDetails = computed(() => {
  return [
    {
      label: 'User Status',
      type: constants.OVERVIEW_FIELD_TYPES.STATUS,
      value: user.value.userStatusType,
      active: user.value.hasAccess
    },
    {
      label: 'Username',
      type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
      value: user.value.username
    },
    {
      label: 'Phone number',
      type: constants.OVERVIEW_FIELD_TYPES.PHONE,
      value: user.value.phoneNumber
    },
    {
      label: 'Phone Extension',
      type: constants.OVERVIEW_FIELD_TYPES.EXTENSION,
      value: user.value.phoneExtension
    },
    {
      label: 'Email address',
      type: constants.OVERVIEW_FIELD_TYPES.EMAIL,
      value: user.value.email
    },
  ]
})
const companyToDeleteName = computed(() => {
  return companyToDelete.value ? companyToDelete.value.companyName : ''
})
onMounted(async() => {
  fieldsLoading.value = true
  let requests = [getUser(), getCompanies(), getCustomFieldGroups()]
  await Promise.all(requests).then(async () => {
    appStore.loading = false
    fieldsLoading.value = false
  })
})

const setSplitColumnValue = () => {
  //flip the flag
  projectStore.manualColumnSplit = !projectStore.manualColumnSplit
}
const getCustomFieldValuesToDisplay = (values, columnNum) => {
  if (projectStore.manualColumnSplit) {
    return values.filter(function (element, index, values) {
      return (index % 2 === (columnNum === 1 ? 0 : 1));
    });
  } else {
    return values
  }
}
const validateForm = async() => {
  if (userEditForm.value.validate()) {
    saveUserSystemFields()
  }
}
const saveUserSystemFields = async () => {
  appStore.loading = true
  try {
    //temp user holds all the changes in case they cancel. use those values
    const {data, status} = await putRequest(`/user`, tempUser.value)
    user.value = cloneDeep(tempUser.value)
    user.value.userStatusType = data.userStatusType
    user.value.hasAccess = data.hasAccess
    showEditModal.value = false
    appStore.showSnack('SUCCESS', 'User Updated')

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Saving Fields')

    appStore.loading = false
  }
  showEditModal.value = false
}
const saveUser = async() => {
  if (userForm.value.validate()) {
    //validation moved to vue form validation with rules
    appStore.loading = true
    // user.value.customFieldGroups = customFieldGroups.value
    fieldsSaving.value = true
    try {
      // save dirty custom field values
      const {data, status} = await postRequest(`/customFieldValues/user/${user.value.id}`, dirtyCfvs.value)
      dirtyCfvs.value = []
      customFieldGroups.value = data
      fieldsSaving.value = false
      appStore.showSnack('SUCCESS', 'User Saved')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let errorMsg = e?.message ? 'Error Saving User: ' + e.message : 'Error Saving User'
      appStore.showSnack('ERROR', errorMsg)

      fieldsSaving.value = false
      appStore.loading = false
    }
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')

  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getCustomFieldGroups = async() => {
  try {
    const {data, status} = await getRequestWithParams(`/customFieldValues/user/${userId.value}`)
    customFieldGroups.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Custom Fields')

    appStore.loading = false
  }
}
const getUser = async() => {
  try {
    const {data, status} = await getRequest(`/user/${userId.value}`)
    user.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving User')

    appStore.loading = false
  }
}
const getCompanies = async() => {
  try {
    const {data, status} = await getRequestWithParams(`/companies/availableForUser`)
    companies.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Companies')

    appStore.loading = false
  }
}
const getUserStatusTypes = async(companyId) => {
  try {
    let params = {
      companyId: companyId
    }
    const {data, status} = await getRequestWithParams(`/user/statuses`, {params})
    if (companyId) {
      //the user status types for adding a user to a user_company
      companyUserStatusTypes.value = cloneDeep(data)
    } else {
      // the user statuses for saving the current user
      userStatusTypes.value = cloneDeep(data)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving User Statuses')

    appStore.loading = false
  }
}
const removeUserCompany = async() => {
  const uc = companyToDelete.value
  appStore.loading = true
  try {
    let params = {
      companyId: uc.id,
      userId: userId.value
    }
    const {data, status} = await postRequest(`/user/removeFromCompany`, params)
    user.value.companies = data
    if (companyId.value === uc.id) {
      router.push({name: 'users'})
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Removing User Company')

    appStore.loading = false
  }
}
const saveUserCompany = async() => {
  appStore.loading = true
  try {
    let params = {
      companyId: newCompany.value.id,
      companyUserStatusTypeId: newCompany.value.companyUserStatusTypeId,
      userId: userId.value
    }
    const {data, status} = await postRequest(`/user/addToCompany`, params)
    user.value.companies = data
    newCompany.value = {}
    addUserCompany.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving User Company')

    appStore.loading = false
  }
}
const saveUserStatus = async() => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/user/${userId.value}/status/${user.value.userStatusTypeId}`)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving User Status')

    appStore.loading = false
  }
}
const unlockUserAccount = async() => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/user/${userId.value}/unlock`)
    user.value.loginAttempts = 0
    appStore.showSnack('SUCCESS', 'User Unlocked')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Unlocking User')

    appStore.loading = false
  }
}
const getReadOnly = (field) => {
  return !userCanEdit.value || getCustomFieldReadOnly(field)
}
const filterUserCompanies = () => {
  let companiesInUse = user.value.companies.map(c => c.id)
  return companies.value.filter(c => !companiesInUse.includes(c.id))
}
</script>

<style lang="scss">
#company-access-toolbar .v-toolbar__content {
  padding-left: 0;
  padding-top: 0;
}

.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}

</style>

<style lang="scss" scoped>
#user-detail-container {
  width: calc(100vw);
  height: calc(100% - 81px);
  max-height: calc(100% - 81px);
  padding: 0 !important;
  overflow: hidden;
  margin-left: -15px;
}

#three-column-container {
  div.user-fields-container {
    overflow: auto ;
    overflow-x: hidden;
    height: calc(100vh - 200px);
    padding-bottom: 0;
  }
}

.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.user-header {
  background-color: white;
}



.user-title {
  font-size: 30px;
}

.user-subtitle {
  font-size: 20px;
}

.user-status {
  font-size: 20px;
  display: flex;
  align-items: flex-end;
  text-align: left;
}

.user-owner {
  font-size: 18px;
  /*display: flex;*/
  /*align-items: flex-end;*/
  text-align: right;
}

.change-owner-button {
  text-decoration: underline;
  text-transform: lowercase;
}

.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}

.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken1);
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

.user-company-button {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

</style>

