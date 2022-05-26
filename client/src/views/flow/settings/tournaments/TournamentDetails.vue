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
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Tournament Start Date"
            />
            <DatetimePickerInput
              v-model="tournament.endDate"
              :readonly="!edit"
              :disabled="!edit"
              :timezone="this.timezone"
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
                class="white--text"
                :disabled="!tournament.tournamentName || !tournament.startDate || !tournament.endDate || (tournament.startDate >= tournament.endDate) || !tournament.tournamentOwnerTypeId || !tournament.tournamentFormulaId
                          || validateCustomFields()"
                @click="updateTournament">Save
              </v-btn>
              <v-btn class="ml-2" @click="edit = false">Cancel</v-btn>
            </div>

            <!--            tournament image -->
            <v-divider></v-divider>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="app-title">Tournament Background Image</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text v-if="userCanEdit && !savingImage && !tournament.backgroundAttachmentPresignedUrl"
                       @click="addImage = !addImage">
                  <v-icon v-if="addImage">remove</v-icon>
                  <v-icon v-else>add</v-icon>
                </v-btn>
                <v-btn v-else-if="userCanEdit" text class="mr-2"
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

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {Actions} from '@/store'
  import constants from '@/helpers/constants'
  import Vue2Filters from 'vue2-filters'
  import TournamentCustomField from '@/views/flow/settings/tournaments/TournamentCustomField.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    handleHidingGlobalLoader,
    getRequest,
    putRequest,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'TournamentDetails',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput,
      TournamentCustomField
    },
    data() {
      return {
        constants,
        addImage: false,
        savingImage: false,
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        //todo: 914 = tournament image
        attachmentTypeId: 914,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        snackbar: {},
        edit: false,
        tournament: {},
        timezone: this.$store.state.user.details.timezone.value,
        ownerTypes: [],
        dirtyCfvs: [],
        formulas: [],
        tournamentId: parseInt(this.$route.params.id),
        userId: this.$store.state.user.details.id
      }
    },
    computed: {},
    async created() {
      this.getTournamentOwnerTypes()
      await this.getTournament()
      this.getTournamentFormulas()
    },
    methods: {
      validateCustomFields() {
        let invalid = false
        if(this.tournament.tournamentFormulaFields?.length > 0) {
          //if the tournament has custom fields then none of them can be null
          this.tournament.tournamentFormulaFields.forEach(tff => {
            //datatype 3 = booleans can be null if they dont have a value
            if((tff.fieldValue === null || tff.fieldValue === '') && tff.dataTypeId !== 3) {
              invalid = true
            }
          })
        }
        return invalid
      },
      async getTournamentOwnerTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournamentFormulas() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/formulas/${this.tournament.tournamentOwnerTypeId}`, 'blueraven')
          this.formulas = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //they cannot archive a field from here so when we send these up we will only update/insert those that changed
          this.tournament.tournamentFormulaFields = this.dirtyCfvs
          const {data, status} = await putRequest(`/tournament`, this.tournament, 'blueraven')
          this.tournament = data
          this.dirtyCfvs = []
          this.edit = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async uploadFile(files, attachmentTypeId, sourceId, sizeLimit) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: files[0],
            sizeLimit,
            attachmentTypeId,
            sourceId,
            callback: async (img, error) => {
              if (error?.error) {
                this.snackbar = getSnackbar('ERROR', error.errorMsg)
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              } else {
                this.tournament.backgroundAttachmentPresignedUrl = img.presignedUrl
                this.tournament.backgroundAttachmentId = img.id
                this.addImage = false
                this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              }
            }
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAttachment(id) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_DELETE, {
            id,
            callback: async () => {
              this.tournament.backgroundAttachmentId = null
              this.tournament.backgroundAttachmentPresignedUrl = null
              // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
              this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateDirtyCfvs(field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id))
        if (!match) {
          this.dirtyCfvs.push(field)
        }
      }
    }
  }
</script>

<style scoped lang="scss">

  .tournament-logo {
    margin-top: 15px;
    max-width: 400px;
    height: auto;
  }

</style>
