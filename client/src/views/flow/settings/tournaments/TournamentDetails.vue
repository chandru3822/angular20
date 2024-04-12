<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-card flat class="mt-2">
          <div>
            <a-text-field
                :readonly="!edit"
                :disabled="!edit"
                label="Tournament Name"
                tabindex=1
                v-model="tournament.tournamentName"
            ></a-text-field>
            <a-autocomplete
                readonly
                disabled
                v-model="tournament.tournamentOwnerTypeId"
                :items="ownerTypes"
                label="Owner Type"
                item-title="ownerType"
                item-value="id"
                attach
            ></a-autocomplete>
            <DatetimePickerInput
                v-model="tournament.startDate"
                :readonly="!edit"
                :disabled="!edit"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Tournament Start Date"
            />
            <DatetimePickerInput
                v-model="tournament.endDate"
                :readonly="!edit"
                :disabled="!edit"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Tournament End Date"
            />
            <a-autocomplete
                readonly
                disabled
                v-model="tournament.tournamentFormulaId"
                :items="formulas"
                label="Scoring Formula"
                item-title="formulaTitle"
                item-value="id"
                attach
            ></a-autocomplete>
            <div v-if="tournament.tournamentFormulaFields && tournament.tournamentFormulaFields.length > 0"
                 v-for="tff in tournament.tournamentFormulaFields">
              <TournamentCustomField
                  :callback="(item) => populateDirtyCfvs(item)"
                  :readonly="!edit"
                  :field="tff">
              </TournamentCustomField>

            </div>
            <div class="mb-4">
              <label>Tournament Is Live: </label>
              <input type="checkbox"
                     class="d-inline-block ml-3"
                     :readonly="!edit"
                     :disabled="!edit"
                     v-model="tournament.active"
              />
            </div>
            <a-btn
                class="mb-4"
                color="primary"
                text="Edit Details"
                v-if="!edit"
                @click="edit = !edit">
            </a-btn>

            <div v-if="edit" class="mb-4">
              <a-btn
                  color="primary"
                  text="Save"
                  :disabled="!tournament.tournamentName || !tournament.startDate || !tournament.endDate || (tournament.startDate >= tournament.endDate) || !tournament.tournamentOwnerTypeId || !tournament.tournamentFormulaId
                          || validateCustomFields()"
                  @click="updateTournament">
              </a-btn>
              <a-btn
                  variant="text"
                  color="primary"
                  class="ml-2"
                  text="Cancel"
                  @click="edit = false">
              </a-btn>
            </div>

            <!--            tournament image -->
            <v-divider></v-divider>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="title-large text-wrap">Tournament Background Image</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <a-btn
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                    v-if="userCanEdit && !savingImage && !tournament.backgroundAttachmentPresignedUrl"
                    icon
                    color="primary"
                    :prepend-icon="addImage ? 'remove' : 'add'"
                    @click="addImage = !addImage">
                </a-btn>

                <a-btn
                    v-else-if="userCanEdit"
                    :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                    icon
                    class="mr-2"
                    color="primary"
                    prepend-icon="delete"
                    @click="deleteAttachment(tournament.backgroundAttachmentId)">
                </a-btn>
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
                    @change="uploadFile($event.target.files, attachmentTypeId, tournament.id, 1048576)"
                    name="avatar"
                >
                <br/><span>* Due to render times associated with this file it cannot exceed 1MB</span>
              </form>
            </div>
            <div v-else-if="tournament.backgroundAttachmentPresignedUrl">
              <img class="tournament-logo" :src="tournament.backgroundAttachmentPresignedUrl">
            </div>
            <div class="mt-2 mb-4" v-else>
              No Tournament Image Uploaded
            </div>
          </div>
        </v-card>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import TournamentCustomField from '@/views/flow/settings/tournaments/TournamentCustomField.vue'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest
} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from 'vue-router/composables'
import { useFileStore } from '@/stores/FileStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const userStore = useUserStore()
const route = useRoute()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const fileStore = useFileStore()

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const timezone = computed(() => {
  return userStore.timezone.value
})
const tournamentId = computed(() => {
  return route.params.id
})

const addImage = ref(false)
const savingImage = ref(false)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const attachmentTypeId = ref(914)
const edit = ref(false)
const tournament = ref({})
const ownerTypes = ref([])
const dirtyCfvs = ref([])
const formulas = ref([])

onMounted(async () => {
  getTournamentOwnerTypes()
  await getTournament()
  getTournamentFormulas()
})

const validateCustomFields = () => {
  let invalid = false
  if (tournament.value.tournamentFormulaFields?.length > 0) {
    //if the tournament has custom fields then none of them can be null
    tournament.value.tournamentFormulaFields.forEach(tff => {
      //datatype 3 = booleans can be null if they dont have a value
      if ((tff.fieldValue === null || tff.fieldValue === '') && tff.dataTypeId !== 3) {
        invalid = true
      }
    })
  }
  return invalid
}
const getTournamentOwnerTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
    ownerTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getTournamentFormulas = async () => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await getRequest(`/tournament/formulas/${tournament.value.tournamentOwnerTypeId}`, 'blueraven')
    formulas.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getTournament = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    tournament.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')
    appStore.loading = false
  }
}
const updateTournament = async () => {
  appStore.loading = true
  try {
    //they cannot archive a field from here so when we send these up we will only update/insert those that changed
    tournament.value.tournamentFormulaFields = dirtyCfvs.value
    const {data, status} = await putRequest(`/tournament`, tournament.value, 'blueraven')
    tournament.value = data
    dirtyCfvs.value = []
    edit.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Tournament')
    appStore.loading = false
  }
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
          tournament.value.backgroundAttachmentPresignedUrl = img.presignedUrl
          tournament.value.backgroundAttachmentId = img.id
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
        tournament.value.backgroundAttachmentId = null
        tournament.value.backgroundAttachmentPresignedUrl = null
        snackbar('SUCCESS', 'Image Deleted')
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    appStore.loading = false
  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id))
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
</script>

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
