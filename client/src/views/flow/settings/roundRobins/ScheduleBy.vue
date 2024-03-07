<template>
  <v-container class="pa-0" id="schedule-by-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule By
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanAdd" @click="[addScheduler = !addScheduler, selectedScheduler = {}, getSchedulers()]">
              <v-icon v-if="addScheduler">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addScheduler" class="square-card text-left pa-5">
          <v-autocomplete v-model="selectedScheduler"
                    :items="schedulers"
                    label="Select a User..."
                    :loading="schedulersLoading"
                    item-text="fullName"
                    item-value="userId"
                    return-object
                          autocomplete="off"
                          attach>
          </v-autocomplete>
          <v-btn color="primary" class="mr-3 white--text" @click="addUserToRoundRobin(selectedScheduler)"
                 :disabled="!selectedScheduler.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addScheduler"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="schedulerSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table id="round-robin-schedule-by-table"
          :headers="schedulerHeaders"
          :items="filterSchedulers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="schedulerSearch"
          :loading="schedulersLoading"
          class="elevation-0 table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left name-col">{{item.fullName}}</td>
              <td :class="{'text-right': $vuetify.breakpoint.smAndDown}">
                <v-btn v-if="userCanEdit" icon color="primary" :large="$vuetify.breakpoint.smAndDown" @click="userToDelete = item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromRoundRobin" @close-dialog="userToDelete = null">
      Are you sure you want to remove this user: <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { mapStores } from 'pinia'
  import { useUserStore } from '@/stores/UserStorePinia.js'

  export default {
    name: 'ScheduleBy',
    components: {ConfirmationDialog},
    data() {
      return {
        snackbar: {},
        scheduleByUsers: [],
        roundRobinId: this.$route.params.id,
        dataLoading: true,
        selectedScheduler: {},
        schedulers: [],
        schedulersLoading: false,
        addScheduler: false,
        schedulerSearch: '',
        schedulerHeaders: [
          {text: 'Name', value: 'fullName', show: true },
          {text: '', value: 'icons', show: true},
        ],
        userToDelete: null
      }
    },
    computed: {
      ...mapStores(useUserStore),
      userCanAdd() {
        return this.userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
      },
      userCanEdit() {
        return this.userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
      },
      userCanDelete() {
        return this.userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE')
      },
      userToDeleteName(){
        return this.userToDelete ? this.userToDelete.fullName : ''
      }
    },
    created () {
      this.getScheduleByUsers()
    },
    methods: {
      filterSchedulers () {
        return this.scheduleByUsers?.filter(pczu => { return !pczu.archived})
      },
      async getScheduleByUsers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/roundRobin/${this.roundRobinId}/scheduleBy`)
          this.scheduleByUsers = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUserFromRoundRobin () {
        const user = this.userToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/roundRobin/user/${user.id}`)
          user.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addUserToRoundRobin (selected) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            roundRobinId: this.roundRobinId,
            userId: selected.id,
          }
          const {data, status} = await postRequest(`/roundRobin/saveScheduleByUser`, params)
          this.scheduleByUsers.push(data)
          this.addScheduler = false
          this.selectedScheduler = {}
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedulers() {
        if (this.addScheduler) {
          this.schedulersLoading = true
          try {
            const {data} = await getRequest(`/roundRobin/${this.roundRobinId}/schedulers`)
            this.schedulers = data
            this.schedulersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
    }
  }
</script>
<style scoped lang="scss">
@media (max-width: 770px) {
  .name-col {
    width: 100%;
  }
}
</style>
<style lang="scss">
  #schedule-by-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
  @media (max-width: 770px) {
    #round-robin-schedule-by-table {
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
