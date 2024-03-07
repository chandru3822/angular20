<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-card flat class="mt-2">
          <div>
            <v-text-field
                :readonly="!edit"
                :disabled="!edit"
                label="Tournament Name"
                tabindex=1
                v-model="tournament.tournamentName"
            ></v-text-field>
            <v-autocomplete
                readonly
                disabled
                v-model="tournament.tournamentOwnerTypeId"
                :items="ownerTypes"
                label="Owner Type"
                item-text="ownerType"
                item-value="id"
                attach
            ></v-autocomplete>
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
            <v-autocomplete
                readonly
                disabled
                v-model="tournament.tournamentFormulaId"
                :items="formulas"
                label="Scoring Formula"
                item-text="formulaTitle"
                item-value="id"
                attach
            ></v-autocomplete>
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
            <v-btn color="primary"
                   class="white--text mb-4"
                   v-if="!edit"
                   @click="edit = !edit">
              Edit Details
            </v-btn>
            <div v-if="edit" class="mb-4">
              <v-btn
                  color="primary"
                  :disabled="!tournament.tournamentName || !tournament.startDate || !tournament.endDate || (tournament.startDate >= tournament.endDate) || !tournament.tournamentOwnerTypeId || !tournament.tournamentFormulaId
                          || validateCustomFields()"
                  @click="updateTournament">Save
              </v-btn>
              <v-btn text color="primary" class="ml-2" @click="edit = false">Cancel</v-btn>
            </div>

            <!--            tournament image -->
            <v-divider></v-divider>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="title-large text-wrap">Tournament Background Image</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                       v-if="userCanEdit && !savingImage && !tournament.backgroundAttachmentPresignedUrl"
                       @click="addImage = !addImage">
                  <v-icon v-if="addImage">remove</v-icon>
                  <v-icon v-else>add</v-icon>
                </v-btn>
                <v-btn v-else-if="userCanEdit" icon :large="$vuetify.breakpoint.smAndDown" color="primary" class="mr-2"
                       @click="deleteAttachment(tournament.backgroundAttachmentId)">
                  <v-icon>delete</v-icon>
                </v-btn>
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
import {AppMutations} from '@/stores/AppStore'
import {Actions} from '@/store'
import constants from '@/helpers/constants'
import TournamentCustomField from '@/views/flow/settings/tournaments/TournamentCustomField.vue'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  getSnackbar
} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
const userStore = useUserStore()
import {useRoute} from "vue-router/composables";
const route = useRoute()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const timezone = computed(() => {
  return userStore.details.timezone.value
})
const tournamentId = computed(() => {
  return route.params.id
})

const addImage = ref(false)
const savingImage = ref(false)
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const attachmentTypeId = ref(914)
const snackbar = ref({})
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
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
    ownerTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTournamentFormulas = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {
      data,
      status
    } = await getRequest(`/tournament/formulas/${tournament.value.tournamentOwnerTypeId}`, 'blueraven')
    formulas.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTournament = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    tournament.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Loading Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const updateTournament = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    //they cannot archive a field from here so when we send these up we will only update/insert those that changed
    tournament.value.tournamentFormulaFields = dirtyCfvs.value
    const {data, status} = await putRequest(`/tournament`, tournament.value, 'blueraven')
    tournament.value = data
    dirtyCfvs.value = []
    edit.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Saving Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const uploadFile = async (files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    let file = files[0]
    await store.dispatch(Actions.FILE_UPLOAD, {
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
          tournament.value.backgroundAttachmentPresignedUrl = img.presignedUrl
          tournament.value.backgroundAttachmentId = img.id
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
    await store.dispatch(Actions.FILE_DELETE, {
      id,
      callback: async () => {
        tournament.value.backgroundAttachmentId = null
        tournament.value.backgroundAttachmentPresignedUrl = null
        getSnackbar('SUCCESS', 'Image Deleted')
        store.commit(AppMutations.SET_LOADING, false)
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Deleting File')
    store.commit(AppMutations.SET_LOADING, false)
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
