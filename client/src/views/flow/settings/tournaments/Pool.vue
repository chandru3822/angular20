<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="pt-0" v-if="!poolLoading">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">{{pool.customName || pool.poolType + ' Pool'}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text @click="editPool = !editPool">
            <v-icon v-if="!editPool">edit</v-icon>
            <v-icon v-else>close</v-icon>
          </v-btn>
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
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="pool.endDate"
              :readonly="!editPool"
              :disabled="!editPool"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
          </div>
          <v-btn color="primary"
                 v-if="editPool"
                 class="white--text"
                 :disabled="!pool.startDate || !pool.endDate || pool.startDate > pool.endDate"
                 @click="savePoolDates()">
            Save
          </v-btn>
        </div>
        <div v-if="poolTypeId === 3">
          <v-divider class="mt-2"></v-divider>

          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title class="app-title">Winner Background Image</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text v-if="userCanEdit && !savingImage && !pool.backgroundAttachmentPresignedUrl"
                     @click="addImage = !addImage">
                <v-icon v-if="addImage">remove</v-icon>
                <v-icon v-else>add</v-icon>
              </v-btn>
              <v-btn v-else-if="userCanEdit" text class="mr-2"
                     @click="deleteAttachment(pool.backgroundAttachmentId)">
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
            <v-toolbar-title class="app-title">Positions</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn text @click="addPosition = !addPosition">
              <v-icon>add</v-icon>
            </v-btn>
          </v-toolbar>
          <v-card flat v-if="addPosition">
            <v-select
              v-model="positionId"
              :items="positions"
              label="Positions"
              item-text="position"
              item-value="id"
            ></v-select>

            <v-btn text :disabled="!positionId"
                   @click="addPositionToPool">
              Save
            </v-btn>
            <v-btn text @click="[addPosition = !addPosition, positionId = null]">
              Cancel
            </v-btn>
          </v-card>

          <v-data-table
            :headers="positionHeaders"
            :items="filterPositions()"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 org-type-table"
          >
            <template #no-data>
              No positions assigned
            </template>

            <template #no-results>
              No positions assigned
            </template>

            <template #item="{ item }">
              <tr class="text-left" :class="{'shaded-row': pool.positions.indexOf(item) % 2}">
                <td class="text-left">{{ item.position }}</td>
                <td class="text-right">
                  <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this position: {{ item.position }}?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deletePositionFromPool(item)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>

        <div id="pool-container">
          <v-toolbar flat class="wqt-header-bar">
            <v-toolbar-title class="app-title">Users</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn text @click="addUser = !addUser">
              <v-icon>add</v-icon>
            </v-btn>
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

            <v-btn text :disabled="!userId"
                   @click="addUserToPool">
              Save
            </v-btn>
            <v-btn text @click="[addUser = !addUser, userId = null]">
              Cancel
            </v-btn>
          </v-card>
          <v-text-field
            v-model="userSearch"
            prepend-inner-icon="search"
            label="Search"
            class="mb-2"
            single-line
            hide-details
          ></v-text-field>
          <v-data-table
            :headers="userHeaders"
            :items="filterUsers()"
            :fixed-header="true"
            :search="userSearch"
            :items-per-page="100"
            :mobile-breakpoint="0"
            class="elevation-1 org-type-table"
          >
            <template #no-data>
              No users assigned
            </template>

            <template #no-results>
              No users assigned
            </template>

            <template #item="{ item }">
              <tr class="text-left" :class="{'shaded-row': pool.users.indexOf(item) % 2}">
                <td class="text-left">{{ item.fullName }}</td>
                <td class="text-right">
                  <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this user: {{ item.user }}?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteUserFromPool(item)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
              </tr>
            </template>

          </v-data-table>
        </div>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { Actions } from '@/store'
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

  export default {
    name: 'PoolAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
    },
    data() {
      return {
        constants,
        snackbar: {},
        edit: false,
        pool: {},
        userSearch: '',
        addImage: false,
        savingImage: false,
        acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
        //todo: 915 = tournament pool image
        attachmentTypeId: 915,
        editPool: false,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        poolLoading: true,
        addPosition: false,
        positionId: null,
        positions: [],
        addUser: false,
        userId: null,
        users: [],
        timezone: this.$store.state.user.details.timezone.value,
        tournamentId: this.$route.params.id,
        poolTypeId: parseInt(this.$route.params.poolTypeId),
        positionHeaders: [
          {text: 'Position', value: 'position', show: true},
          {text: null, value: 'icons', show: true}
        ],
        userHeaders: [
          {text: 'User', value: 'fullName', show: true},
          {text: null, value: 'icons', show: true}
        ]
      }
    },
    async created() {
      this.getTournamentPool()
      this.getPositions()
      this.getUsers()
    },
    watch: {
      // whenever pool type id changes, this function will run
      '$route.params.poolTypeId': function () {
        // reset the selected group when the object type changes
        this.poolTypeId = parseInt(this.$route.params.poolTypeId)
        this.pool = {}
        this.getTournamentPool()
      }
    },
    computed: {},
    methods: {
      async savePoolDates() {
        try {
          const {status} = await putRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}`, this.pool, 'blueraven')
          this.editPool = false
          this.snackbar = getSnackbar('SUCCESS', 'Pool Changes Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Pool')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions() {
        try {
          const {data, status} = await getRequest(`/position`)
          this.positions = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUsers() {
        try {
          const {data, status} = await getRequest(`/user/active`)
          this.users = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournamentPool() {
        this.poolLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.pool = data
          this.poolLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addPositionToPool() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/addPosition/${this.positionId}`, {}, 'blueraven')
          this.pool.positions.push(data)
          this.positionId = null
          this.addPosition = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePositionFromPool(position) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/deletePosition/${position.id}`, 'blueraven')
          position.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterPositions () {
        return this.pool?.positions?.filter(p => { return !p.archived})
      },
      async addUserToPool() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/addUser/${this.userId}`, {}, 'blueraven')
          this.pool.users.push(data)
          this.userId = null
          this.addUser = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUserFromPool(user) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/deleteUser/${user.id}`, 'blueraven')
          user.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterUsers () {
        return this.pool?.users?.filter(p => { return !p.archived})
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
                this.pool.backgroundAttachmentPresignedUrl = img.presignedUrl
                this.pool.backgroundAttachmentId = img.id
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
            callback: async () => {
              this.pool.backgroundAttachmentId = null
              this.pool.backgroundAttachmentPresignedUrl = null
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

  }
</script>

<style lang="scss">
  #pool-container .v-data-table__wrapper {
    max-height: calc(100vh - 650px);
    min-height: 300px;
  }
</style>

<style scoped lang="scss">

  .tournament-logo {
    margin-top: 15px;
    max-width: 400px;
    height: auto;
  }
</style>
