<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="pt-0" v-if="!poolLoading">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="title-large">{{ pool.customName || pool.poolType + ' Pool' }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <a-btn
              icon
              color="primary"
              @click="editPool = !editPool"
              :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
              :prepend-icon="editPool ? 'close' : 'edit'"
          />

        </v-toolbar>
        <div>
          <a-text-field
              v-if="editPool"
              label="Custom Pool Name"
              hint="(optional)"
              persistent-hint
              v-model="pool.customName"
          ></a-text-field>
          <div>
            <DatetimePickerInput
                v-model="pool.startDate"
                :readonly="!editPool"
                :disabled="!editPool"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Start Date"
            />
            <DatetimePickerInput
                v-model="pool.endDate"
                :readonly="!editPool"
                :disabled="!editPool"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="End Date"
            />
          </div>

          <a-btn
              v-if="editPool"
              color="primary"
              :disabled="!pool.startDate || !pool.endDate || pool.startDate > pool.endDate"
              @click="savePoolDates()"
              text="Save"/>
        </div>
        <div v-if="poolTypeId === 3">
          <v-divider class="mt-2"></v-divider>

          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title class="title-large text-wrap">Winner Background Image</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                  v-if="userCanEdit && !savingImage && !pool.backgroundAttachmentPresignedUrl"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                  icon
                  color="primary"
                  :prepend-icon="addImage ? 'remove' : 'add'"
                  @click="addImage = !addImage">
              </a-btn>

              <a-btn
                  v-else-if="userCanEdit"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                  icon
                  color="primary"
                  prepend-icon="delete"
                  @click="deleteWinnerBackgroundDialog = true">
              </a-btn>

              <ConfirmationDialog :open-dialog="deleteWinnerBackgroundDialog"
                                  @confirm="deleteAttachment(pool.backgroundAttachmentId)"
                                  @close-dialog="deleteWinnerBackgroundDialog = false">Are you sure you want to delete
                the Winner Background Image?
              </ConfirmationDialog>
            </v-toolbar-items>
          </v-toolbar>
          <label></label>

          <div class="mt-2" v-if="addImage">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingImage"
                  @change="uploadFile($event.target.files, attachmentTypeId, pool.id, 2097152)"
                  name="avatar"
              >
              <br/><span>* Due to render times associated with this file it cannot exceed 2MB</span>
            </form>
          </div>
          <div v-else-if="pool.backgroundAttachmentPresignedUrl">
            <img class="tournament-logo" :src="pool.backgroundAttachmentPresignedUrl">
          </div>
          <div class="mt-2 mb-4 pt-2 pl-5" v-else>
            No Winner Background Image Uploaded
          </div>
        </div>
        <v-divider class="mt-2"></v-divider>

        <div v-if="poolTypeId === 1" class="mb-2">
          <v-toolbar flat class="wqt-header-bar">
            <v-toolbar-title class="title-large">Positions</v-toolbar-title>
            <v-spacer></v-spacer>
            <a-btn
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                icon
                color="primary"
                prepend-icon="add"
                @click="[addPosition = !addPosition, getPositions()]">
            </a-btn>

          </v-toolbar>
          <v-card flat v-if="addPosition">
            <v-autocomplete
                v-model="positionId"
                :items="positions"
                :loading="positionsLoading"
                label="Positions"
                item-text="position"
                item-value="id"
            ></v-autocomplete>

            <a-btn
                color="primary"
                text="Save"
                :disabled="!positionId"
                @click="addPositionToPool">
            </a-btn>

            <a-btn
                color="primary"
                variant="text"
                text="Cancel"
                @click="[addPosition = !addPosition, positionId = null]">
            </a-btn>
          </v-card>

          <v-data-table
              :headers="positionHeaders"
              :items="filteredPositions"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              hide-default-footer
              class="elevation-1 org-type-table"
          >
            <template #no-data>
              <span class="default-text-color">No positions assigned</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No positions assigned</span>
            </template>

            <template #item="{ item }">
              <tr class="text-left" :class="{'shaded-row': pool.positions.indexOf(item) % 2}">
                <td class="text-left">{{ item.position }}</td>
                <td class="text-right">
                  <a-btn
                      :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                      icon
                      color="primary"
                      prepend-icon="delete"
                      @click="positionToDelete=item">
                  </a-btn>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>

        <div id="pool-container">
          <v-toolbar flat class="wqt-header-bar">
            <v-toolbar-title class="title-large">Users</v-toolbar-title>
            <v-spacer></v-spacer>
            <a-btn
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                icon
                color="primary"
                v-if="!pool.liveTournament && filteredUsers?.length > 0"
                prepend-icon="delete"
                @click="deleteUsers = true">
            </a-btn>
            <ConfirmationDialog :open-dialog="deleteUsers" @confirm="deleteUsersFromPool" @close-dialog="deleteUsers=false">
              Are you sure you want to delete all the users from this Tournament Pool?
            </ConfirmationDialog>
            <a-btn
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                icon
                color="primary"
                prepend-icon="mdi-playlist-plus"
                @click="addCustomUsers = !addCustomUsers">
            </a-btn>
            <a-btn
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                icon
                color="primary"
                prepend-icon="add"
                @click="[addUser = !addUser, getUsers()]">
            </a-btn>
          </v-toolbar>
          <v-card class="pa-4" color="secondary" v-if="addCustomUsers && filteredUsers.length > 0">
            This feature is only available when no users have been added to the pool.
          </v-card>
          <v-card class="pa-4" color="secondary" v-else-if="addCustomUsers">
            <h3>Add Custom User Set</h3>
            <ul>
              <li>This is used to add all users that meet a pre-defined set of criteria. </li>
              <li>At least one field in each section is required. </li>
              <li>All fields are inclusive, meaning that any results matching the value you provide will be included. </li>
            </ul>

            <div class="px-3 pt-3">
              <DatetimePickerInput
                  v-model="customStartDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="Position Start Min Date"
              />
              <DatetimePickerInput
                  v-model="customEndDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="Position Start Max Date"
              />

              <a-btn :variant="customInclusive ? 'outlined' : 'text'"
                  color="primary"
                  @click="customInclusive = true">
                AND
              </a-btn>
              <a-btn :variant="customInclusive ? 'text' : 'outlined'"
                     class="ml-3"
                  color="primary"
                  @click="customInclusive = false">
                OR
              </a-btn>

              <a-text-field
                  class="mt-3"
                  type="number"
                  label="Lifetime FDC Count Min"
                  v-model.number="customFdcMin"/>
              <a-text-field
                  type="number"
                  label="Lifetime FDC Count Max"
                  v-model.number="customFdcMax"/>

            <v-card outlined class="pa-3 mt-4" v-if="customStartDate > customEndDate">
              <v-card-text class="error--text">
                Min Date must be before Max Date
              </v-card-text>
            </v-card>
            <v-card outlined class="pa-3 mt-4" v-else-if="(customStartDate || customEndDate) &&
              (customFdcMin || customFdcMin === 0 || customFdcMax)">
              Saving with the current settings will add: <br><br>
              All closers with
              {{ startDatePortion }} <br>
              <strong>{{customInclusive ? 'AND' : 'OR'}}</strong> <br>
              {{ fdcPortion }}

            <div class="mt-6">
              <a-btn variant="outlined"
                  class="mr-2"
                  @click="resetCustom()"
                  text="Cancel"
              />
              <a-btn
                  color="primary white--text"
                  @click="saveCustomUsers()"
                  text="Confirm"
              />
            </div>
            </v-card>

            </div>
          </v-card>
          <v-card flat v-if="addUser">
            <v-autocomplete
                v-model="userId"
                :items="users"
                label="Users"
                :loading="usersLoading"
                item-text="fullName"
                item-value="id"
                attach
            ></v-autocomplete>

            <a-btn
                color="primary"
                text="Save"
                :disabled="!userId"
                @click="addUserToPool">
            </a-btn>

            <a-btn
                color="primary"
                text="Cancel"
                variant="text"
                @click="[addUser = !addUser, userId = null]">
            </a-btn>
          </v-card>
          <a-text-field
              v-model="userSearch"
              prepend-inner-icon="search"
              label="Search"
              class="mb-2"
              single-line
              hide-details
          ></a-text-field>
          <v-data-table id="tournament-pool-table"
                        :headers="userHeaders"
                        :items="filteredUsers"
                        :fixed-header="true"
                        :search="userSearch"
                        :items-per-page="100"
                        :mobile-breakpoint="0"
                        class="elevation-1 org-type-table"
          >
            <template #no-data>
              <span class="default-text-color">No users assigned</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No users assigned</span>
            </template>

            <template #item="{ item }">
              <tr class="text-left" :class="{'shaded-row': pool.users.indexOf(item) % 2}">
                <td class="text-left">{{ item.fullName }}</td>
                <td class="text-right">
                  <a-btn
                      :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                      icon
                      color="primary"
                      prepend-icon="delete"
                      @click="userToDelete=item">
                  </a-btn>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromPool" @close-dialog="userToDelete=null">
      Are you sure you want to delete this user: <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!positionToDelete" @confirm="deletePositionFromPool"
                        @close-dialog="positionToDelete=null">
      Are you sure you want to delete this position?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, watch, computed, ref, onMounted} from 'vue'
import {useRoute} from "vue-router/composables";
import {useUserStore} from '@/stores/UserStorePinia.js'

import { useFileStore } from '@/stores/FileStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const fileStore = useFileStore()
const route = useRoute()
const userStore = useUserStore()
const filters = vueInstance.$filters

const positionToDelete = ref(null)
const edit = ref(false)
const pool = ref({})
const userSearch = ref('')
const addImage = ref(false)
const savingImage = ref(false)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const attachmentTypeId = ref(915)
const editPool = ref(false)
const poolLoading = ref(true)
const addPosition = ref(false)
const positionId = ref(null)
const positions = ref([])
const positionsLoading = ref(true)
const addUser = ref(false)
const addCustomUsers = ref(false)
const deleteUsers = ref(false)
const userId = ref(null)
const users = ref([])
const usersLoading = ref(true)
const customStartDate = ref(null)
const customEndDate = ref(null)
const customFdcMin = ref(null)
const customFdcMax = ref(null)
const customInclusive = ref(true)
const deleteWinnerBackgroundDialog = ref(false)
const userToDelete = ref(null)
const positionHeaders = ref([
  {text: 'Position', value: 'position', show: true},
  {text: null, value: 'icons', show: true}
])
const userHeaders = ref([
  {text: 'User', value: 'fullName', show: true},
  {text: null, value: 'icons', show: true}
])

onMounted(() => {
  getTournamentPool()
})

const tournamentId = computed(() => {
  return route.params.id
})

const startDatePortion = computed(() => {
  let msg = ''
  if (customStartDate.value != null && customEndDate.value != null) {
    msg = `a start date between  ${filters.formatDate(customStartDate.value, 'date', 'MM/DD/YYYY')} and ${filters.formatDate(customEndDate.value, 'date', 'MM/DD/YYYY')}`
  } else if (customStartDate.value != null) {
    msg = `a start date on or after ${filters.formatDate(customStartDate.value, 'date', 'MM/DD/YYYY')}`
  } else if (customEndDate.value != null) {
    msg = `a start date on or before ${filters.formatDate(customEndDate.value, 'date', 'MM/DD/YYYY')}`
  }
  return msg
})

const fdcPortion = computed(() => {
  let msg = ''
  if ((customFdcMin.value || customFdcMin.value === 0) && customFdcMax.value) {
    msg = `A lifetime FDC count between ${customFdcMin.value} and ${customFdcMax.value}`
  } else if (customFdcMin.value || customFdcMin.value === 0) {
    msg = `A lifetime FDC count greater than or equal to ${customFdcMin.value}`
  } else if (customFdcMax.value) {
    msg = `A lifetime FDC count less than or equal to ${customFdcMax.value}`
  }
  return msg
})

const poolTypeId = computed(() => {
  return parseInt(route.params.poolTypeId)
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const timezone = computed(() => {
  return userStore.timezone.value
})

const userToDeleteName = computed(() => {
  return userToDelete.value ? userToDelete.value.fullName : ''
})

const filteredPositions = computed(() => {
  return pool.value?.positions?.filter(p => {
    return !p.archived
  })
})

const filteredUsers = computed(() => {
  return pool.value?.users?.filter(p => {
    return !p.archived
  })
})


watch(() => poolTypeId.value, () => {
  pool.value = {}
  getTournamentPool()
})


const savePoolDates = async () => {
  try {
    const {status} = await putRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}`, pool.value, 'blueraven')
    editPool.value = false
    snackbar('SUCCESS', 'Pool Changes Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Pool')
    appStore.loading = false
  }
}
const getPositions = async () => {
  if(positions.value?.length === 0 && addPosition.value) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position`)
      positions.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')
      appStore.loading = false
    } finally {
      positionsLoading.value = false
    }
  }
}
const deleteUsersFromPool = async () => {
  try {
    appStore.loading = true
    await deleteRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/deleteUsers`, 'blueraven')
    pool.value.users = []
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Users')
  } finally {
    appStore.loading = false
  }
}
const getUsers = async () => {
  if(users.value?.length === 0 && addUser.value) {
    try {
      usersLoading.value = true
      const {data, status} = await getRequest(`/user/active`)
      users.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Users')
      appStore.loading = false
    } finally {
      usersLoading.value = false
    }
  }
}
const getTournamentPool = async () => {
  poolLoading.value = true
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await getRequest(`/tournament/${tournamentId.value}/pool/byType/${poolTypeId.value}`, 'blueraven')
    pool.value = data
    poolLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')
    appStore.loading = false
  }
}
const addPositionToPool = async () => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/addPosition/${positionId.value}`, {}, 'blueraven')
    pool.value.positions.push(data)
    positionId.value = null
    addPosition.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Position')
    appStore.loading = false
  }
}
const deletePositionFromPool = async () => {
  const position = positionToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/deletePosition/${position.id}`, 'blueraven')
    position.archived = true
    handleHidingGlobalLoader(status)
    positionToDelete.value = null
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Position')
    appStore.loading = false
    positionToDelete.value = null
  }
}

const resetCustom = () => {
  customInclusive.value = true
  customStartDate.value = null
  customEndDate.value = null
  customFdcMin.value = null
  customFdcMax.value = null
  addCustomUsers.value = false
}

const saveCustomUsers = async () => {
  appStore.loading = true
  try {
    let params = {
      minFdc: customFdcMin.value,
      maxFdc: customFdcMax.value,
      minDate: customStartDate.value,
      maxDate: customEndDate.value,
      inclusive: customInclusive.value
    }
    const {
      data,
      status
    } = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/addCustomUsers`, params, 'blueraven')
    pool.value.users = data
    resetCustom()
    snackbar('SUCCESS', 'Successfully added matching users.')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.detail || 'Error Adding Users'
    snackbar('ERROR', msg)
    appStore.loading = false
  }
}

const addUserToPool = async () => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/addUser/${userId.value}`, {}, 'blueraven')
    pool.value.users.push(data)
    userId.value = null
    addUser.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.detail || 'Error Adding User'
    snackbar('ERROR', msg)
    appStore.loading = false
  }
}
const deleteUserFromPool = async () => {
  const user = userToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/deleteUser/${user.id}`, 'blueraven')
    user.archived = true
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting User')
    appStore.loading = false
  }
  userToDelete.value = null
}

const uploadFile = async (files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    appStore.loading = true
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      sizeLimit,
      attachmentTypeId,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if (error?.error) {
          snackbar('ERROR', error.errorMsg)
          appStore.loading = false
        } else {
          pool.value.backgroundAttachmentPresignedUrl = img.presignedUrl
          pool.value.backgroundAttachmentId = img.id
          addImage.value = false
          snackbar('SUCCESS', 'Image Uploaded')
          appStore.loading = false
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')
    appStore.loading = false
  }
}
const deleteAttachment = async (id) => {
  try {
    appStore.loading = true
    await fileStore.deleteFile({
      id,
      callback: async () => {
        pool.value.backgroundAttachmentId = null
        pool.value.backgroundAttachmentPresignedUrl = null
        // store.commit(UserMutations.SET_USER_IMAGE, {})
        snackbar('SUCCESS', 'Image Deleted')
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    appStore.loading = false
  }
  deleteWinnerBackgroundDialog.value = false
}
</script>

<style lang="scss">
#pool-container .v-data-table__wrapper {
  max-height: calc(100vh - 650px);
  min-height: 300px;
}

@media (max-width: 770px) {
  #tournament-pool-table {
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

<style scoped lang="scss">

.tournament-logo {
  margin-top: 15px;
  max-width: 400px;
  height: auto;
  @media (max-width: 500px) {
    max-width: 100%;
  }
}
</style>
