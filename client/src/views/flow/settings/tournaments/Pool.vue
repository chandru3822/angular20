<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="pt-0" v-if="!poolLoading">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="title-large">{{ pool.customName || pool.poolType + ' Pool' }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <AlbatrossButton
              :round="true"
              color="primary"
              @click="editPool = !editPool"
              :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
              :prepend-icon="editPool ? 'close' : 'edit'"
          />

        </v-toolbar>
        <div>
          <v-text-field
              v-if="editPool"
              label="Custom Pool Name"
              hint="(optional)"
              persistent-hint
              v-model="pool.customName"
          ></v-text-field>
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

          <AlbatrossButton
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
              <AlbatrossButton
                  v-if="userCanEdit && !savingImage && !pool.backgroundAttachmentPresignedUrl"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                  :round="true"
                  color="primary"
                  :prepend-icon="addImage ? 'remove' : 'add'"
                  @click="addImage = !addImage">
              </AlbatrossButton>

              <AlbatrossButton
                  v-else-if="userCanEdit"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                  :round="true"
                  color="primary"
                  prepend-icon="delete"
                  @click="deleteWinnerBackgroundDialog = true">
              </AlbatrossButton>

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
            <AlbatrossButton
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                :round="true"
                color="primary"
                prepend-icon="add"
                @click="addPosition = !addPosition">
            </AlbatrossButton>

          </v-toolbar>
          <v-card flat v-if="addPosition">
            <v-autocomplete
                v-model="positionId"
                :items="positions"
                label="Positions"
                item-text="position"
                item-value="id"
            ></v-autocomplete>

            <AlbatrossButton
                color="primary"
                text="Save"
                :disabled="!positionId"
                @click="addPositionToPool">
            </AlbatrossButton>

            <AlbatrossButton
                color="primary"
                variant="text"
                text="Cancel"
                @click="[addPosition = !addPosition, positionId = null]">
            </AlbatrossButton>
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
                  <AlbatrossButton
                      :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                      :round="true"
                      color="primary"
                      prepend-icon="delete"
                      @click="positionToDelete=item">
                  </AlbatrossButton>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>

        <div id="pool-container">
          <v-toolbar flat class="wqt-header-bar">
            <v-toolbar-title class="title-large">Users</v-toolbar-title>
            <v-spacer></v-spacer>
            <AlbatrossButton
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                :round="true"
                color="primary"
                prepend-icon="add"
                @click="addUser = !addUser">
            </AlbatrossButton>
          </v-toolbar>
          <v-card flat v-if="addUser">
            <v-autocomplete
                v-model="userId"
                :items="users"
                label="Users"
                item-text="fullName"
                item-value="id"
                attach
            ></v-autocomplete>

            <AlbatrossButton
                color="primary"
                text="Save"
                :disabled="!userId"
                @click="addUserToPool">
            </AlbatrossButton>

            <AlbatrossButton
                color="primary"
                text="Cancel"
                variant="text"
                @click="[addUser = !addUser, userId = null]">
            </AlbatrossButton>
          </v-card>
          <v-text-field
              v-model="userSearch"
              prepend-inner-icon="search"
              label="Search"
              class="mb-2"
              single-line
              hide-details
          ></v-text-field>
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
                  <AlbatrossButton
                      :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                      :round="true"
                      color="primary"
                      prepend-icon="delete"
                      @click="userToDelete=item">
                  </AlbatrossButton>
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
import {AppMutations} from '@/stores/AppStore'
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
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import { useFileStore } from '@/stores/FileStore.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const fileStore = useFileStore()
const route = useRoute()
const userStore = useUserStore()

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
const addUser = ref(false)
const userId = ref(null)
const users = ref([])
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
  getPositions()
  getUsers()
})

const tournamentId = computed(() => {
  return route.params.id
})

const poolTypeId = computed(() => {
  return parseInt(route.params.poolTypeId)
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const timezone = computed(() => {
  return userStore.details.timezone.value
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
    getSnackbar('SUCCESS', 'Pool Changes Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Updating Pool')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getPositions = async () => {
  try {
    const {data, status} = await getRequest(`/position`)
    positions.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Positions')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getUsers = async () => {
  try {
    const {data, status} = await getRequest(`/user/active`)
    users.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Users')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTournamentPool = async () => {
  poolLoading.value = true
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {
      data,
      status
    } = await getRequest(`/tournament/${tournamentId.value}/pool/byType/${poolTypeId.value}`, 'blueraven')
    pool.value = data
    poolLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Loading Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const addPositionToPool = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {
      data,
      status
    } = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/addPosition/${positionId.value}`, {}, 'blueraven')
    pool.value.positions.push(data)
    positionId.value = null
    addPosition.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Adding Position')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deletePositionFromPool = async () => {
  const position = positionToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/deletePosition/${position.id}`, 'blueraven')
    position.archived = true
    handleHidingGlobalLoader(vueInstance, status)
    positionToDelete.value = null
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Deleting Position')
    store.commit(AppMutations.SET_LOADING, false)
    positionToDelete.value = null
  }
}

const addUserToPool = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {
      data,
      status
    } = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/addUser/${userId.value}`, {}, 'blueraven')
    pool.value.users.push(data)
    userId.value = null
    addUser.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Adding User')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteUserFromPool = async () => {
  const user = userToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/deleteUser/${user.id}`, 'blueraven')
    user.archived = true
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Deleting User')
    store.commit(AppMutations.SET_LOADING, false)
  }
  userToDelete.value = null
}

const uploadFile = async (files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      sizeLimit,
      attachmentTypeId,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if (error?.error) {
          getSnackbar('ERROR', error.errorMsg)
          store.commit(AppMutations.SET_LOADING, false)
        } else {
          pool.value.backgroundAttachmentPresignedUrl = img.presignedUrl
          pool.value.backgroundAttachmentId = img.id
          addImage.value = false
          getSnackbar('SUCCESS', 'Image Uploaded')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Uploading File')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteAttachment = async (id) => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await fileStore.deleteFile({
      id,
      callback: async () => {
        pool.value.backgroundAttachmentId = null
        pool.value.backgroundAttachmentPresignedUrl = null
        // store.commit(UserMutations.SET_USER_IMAGE, {})
        getSnackbar('SUCCESS', 'Image Deleted')
        store.commit(AppMutations.SET_LOADING, false)
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Deleting File')
    store.commit(AppMutations.SET_LOADING, false)
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
