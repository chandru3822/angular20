<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/tournaments'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">{{tournament.tournamentName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text @click="edit = !edit">
            <v-icon>edit</v-icon>
          </v-btn>
        </v-toolbar>
        <v-card flat class="mt-2">
          <div>
            <v-text-field
              v-if="edit"
              label="Tournament Name"
              tabindex=1
              v-model="tournament.tournamentName"
            ></v-text-field>
            <v-autocomplete
              :readonly="!edit"
              :disabled="!edit"
              v-model="tournament.tournamentOwnerTypeId"
              :items="ownerTypes"
              label="Owner Type"
              item-text="ownerType"
              item-value="id"
            ></v-autocomplete>
            <DatetimePickerInput
              v-model="tournament.startDate"
              :readonly="!edit"
              :disabled="!edit"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="tournament.endDate"
              :readonly="!edit"
              :disabled="!edit"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
<!--            tournament image -->
            <label>Tournament Background Image</label>
            <div v-if="userCanEdit">
              <v-btn text v-if="!savingImage && !tournament.backgroundAttachmentPresignedUrl"  @click="addImage = !addImage">
                <v-icon v-if="addImage">remove</v-icon>
                <v-icon v-else>add</v-icon>
              </v-btn>
              <v-btn v-else text class="mr-2" @click="deleteAttachment(tournament.backgroundAttachmentId)">
                <v-icon>delete</v-icon>
              </v-btn>
            </div>
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
          <div v-if="edit">
            <v-btn
              :disabled="!tournament.tournamentName || !tournament.startDate || !tournament.endDate || !tournament.tournamentOwnerTypeId"
              @click="updateTournament">Save
            </v-btn>
            <v-btn class="ml-2" @click="edit = false">Cancel</v-btn>
          </div>
        </v-card>
        <v-tabs class="tabs-bar">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>

        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { Actions } from '@/store'
  import constants from '@/helpers/constants'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    getRequest,
    getRequestWithParams,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'TournamentAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
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
        tournamentId: parseInt(this.$route.params.id),
        userId: this.$store.state.user.details.id,
        tabs: [
          {
            label: 'Brackets',
            path: `/settings/tournaments/${this.$route.params.id}/brackets`,
          },
          {
            label: 'Qualifying',
            path: `/settings/tournaments/${this.$route.params.id}/pool/1`,
          },
          {
            label: 'Last Chance',
            path: `/settings/tournaments/${this.$route.params.id}/pool/2`,
          },
          {
            label: 'Winner',
            path: `/settings/tournaments/${this.$route.params.id}/pool/3`,
          }
        ]
      }
    },
    computed: {},
    methods: {
      async getTournamentOwnerTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await putRequest(`/tournament`, this.tournament, 'blueraven')
          this.tournament = data
          this.edit = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async uploadFile (files, attachmentTypeId, sourceId, sizeLimit) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_UPLOAD, {
            file: files[0],
            sizeLimit,
            attachmentTypeId,
            sourceId,
            callback: async (img, error) => {
              if(error?.error) {
                this.snackbar = getSnackbar('ERROR', error.errorMsg)
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              } else {
                console.log('randaLogger',img)
                this.tournament.backgroundAttachmentPresignedUrl = img.presignedUrl
                this.addImage = false
                this.snackbar = getSnackbar('SUCCESS', 'Image Uploaded')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                this.$store.commit(AppMutations.SET_LOADING, false)
              }
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAttachment (id) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await this.$store.dispatch(Actions.FILE_DELETE, {
            id,
            callback: async (status) => {
              this.tournament.backgroundAttachmentId = null
              this.tournament.backgroundAttachmentPresignedUrl = null
              // this.$store.commit(UserMutations.SET_USER_IMAGE, {})
              this.snackbar = getSnackbar('SUCCESS', 'Image Deleted')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting File')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    async created() {
      this.getTournamentOwnerTypes()
      this.getTournament()
    }
  }
</script>

<style lang="scss">
</style>

<style scoped lang="scss">
  .tabs-bar {
    top: -12px;
    border-top: 1px solid #E6E6E6;
    border-bottom: 1px solid #E6E6E6;
    .v-tab:hover {
      color: var(--v-primaryCustom-base);
    }
  }

  .tournament-logo {
    margin-top: 15px;
    max-width: 200px;
    height: auto;
  }

</style>
