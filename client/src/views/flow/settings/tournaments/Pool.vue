<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">{{pool.poolType}} Pool</v-toolbar-title>
        </v-toolbar>

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
                        class="headline grey lighten-2"
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

        <div>
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
            ></v-autocomplete>

            <v-btn text :disabled="!userId"
                   @click="addUserToPool">
              Save
            </v-btn>
            <v-btn text @click="[addUser = !addUser, userId = null]">
              Cancel
            </v-btn>
          </v-card>

          <v-data-table
            :headers="userHeaders"
            :items="filterUsers()"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
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
                <td class="text-left">{{ item.user }}</td>
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
                        class="headline grey lighten-2"
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
    name: 'PoolAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        edit: false,
        pool: {},
        addPosition: false,
        positionId: null,
        positions: [],
        addUser: false,
        userId: null,
        users: [],
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
      '$route.params.poolTypeId': function (oldObjectTypeId, newObjectTypeId) {
        // reset the selected group when the object type changes
        this.poolTypeId = parseInt(this.$route.params.poolTypeId)
        this.pool = {}
        this.getTournamentPool()
      }
    },
    computed: {},
    methods: {
      async getPositions() {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUsers() {
        try {
          const {data} = await getRequest(`/user/active`)
          this.users = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournamentPool() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.pool = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/addPosition/${this.positionId}`, {}, 'blueraven')
          this.pool.positions.push(data)
          this.positionId = null
          this.addPosition = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          await deleteRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/deletePosition/${position.id}`, 'blueraven')
          position.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/addUser/${this.userId}`, {}, 'blueraven')
          this.pool.users.push(data)
          this.userId = null
          this.addUser = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          await deleteRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/deleteUser/${user.id}`, 'blueraven')
          user.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
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
    },

  }
</script>

<style lang="scss">
</style>

<style scoped lang="scss">


</style>
