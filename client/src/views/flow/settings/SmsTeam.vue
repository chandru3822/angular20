<template>
  <v-container id="hierarchy-container">
    <ConfirmDeleteDialogImproved
        :open-confirm-delete-dialog="showDeleteDialog"
        hide-title
        @closeConfirmDeleteDialog="clearDeleteItem"
        @confirm-delete="deleteItem"
    >
      <template v-slot:title class="albatross-body-1">
        <span>Are you sure you want to remove <b>{{itemToDelete.name || itemToDelete.teamName}}</b>?</span>
      </template>
      <template v-slot:default>Make sure this team has resolved associated conversations</template>
    </ConfirmDeleteDialogImproved>
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">SMS Teams</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addTeam = !addTeam, newType = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addTeam ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addTeam" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Team</h3>
          <v-text-field text v-model="newTeam.teamName"
                        label="Team Name" />

          <v-btn :disabled="!newTeam.teamName"
                 color="primaryCustom" class="white--text mr-2"
                 @click="saveTeam(newTeam, true)">
            Save
          </v-btn>
          <v-btn @click="[addTeam = !addTeam, newTeam = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterTeams"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterTeams.indexOf(item) % 2}">
              <v-text-field text v-model="item.teamName" label="Team Name" class="px-4"/>
              <v-checkbox dense v-model="item.checked" :value="item.isDefault" :disabled="item.isDefault" class="albatross-body-2 mt-0 px-4" label="Make Default for incoming unprompted customer messages" />
              <div class="mb-2">
                <v-toolbar flat dense color="transparent" class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Positions</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-btn text @click="addPosition = !addPosition">
                    <v-icon>add</v-icon>
                  </v-btn>
                </v-toolbar>
                <v-card flat v-if="addPosition" color="transparent">
                  <v-select
                    v-model="positionId"
                    :items="positions"
                    label="Positions"
                    item-text="position"
                    item-value="id"
                    class="px-4"
                  ></v-select>

                  <v-btn text :disabled="!positionId"
                         @click="addPositionToTeam"
                  class="mb-6">
                    Save
                  </v-btn>
                  <v-btn text @click="[addPosition = !addPosition, positionId = null]" class="mb-6">
                    Cancel
                  </v-btn>
                </v-card>

                <v-data-table
                  :headers="positionHeaders"
                  :items="filterPositions()"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-footer
                  :mobile-breakpoint="0"
                  class="elevation-1 org-type-table"
                  disable-sort
                  height="15%"
                >
                  <template #no-data>
                    No positions assigned
                  </template>

                  <template #no-results>
                    No positions assigned
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.positions.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <v-btn small text @click="startDelete(DeleteTypeEnum.POSITION, item)">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>

              <div id="team-container">
                <v-toolbar dense flat color="transparent" class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Users</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-btn text @click="addUser = !addUser">
                    <v-icon>add</v-icon>
                  </v-btn>
                </v-toolbar>
                <v-card flat v-if="addUser" color="transparent">
                  <v-autocomplete
                    v-model="userId"
                    :items="users"
                    label="Users"
                    item-text="fullName"
                    item-value="id"
                    attach
                    class="px-4"
                  ></v-autocomplete>

                  <v-btn text :disabled="!userId"
                         @click="addUserToTeam">
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
                  hide-default-footer
                  :mobile-breakpoint="0"
                  disable-sort
                  class="elevation-1 org-type-table"
                >
                  <template #no-data>
                    No users assigned
                  </template>

                  <template #no-results>
                    No users assigned
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.users.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <v-btn small text @click="startDelete(DeleteTypeEnum.USER, item)">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>

              <div id="org-container">
                <v-toolbar color="transparent" dense flat class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Organizations</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-btn text @click="addOrg = !addOrg">
                    <v-icon>add</v-icon>
                  </v-btn>
                </v-toolbar>
                <v-card flat v-if="addOrg" color="transparent">
                  <v-autocomplete
                    v-model="orgId"
                    :items="orgs"
                    label="Organizations"
                    item-text="orgName"
                    item-value="id"
                    attach
                    class="px-4"
                  ></v-autocomplete>

                  <v-btn text :disabled="!orgId"
                         @click="addOrgToTeam">
                    Save
                  </v-btn>
                  <v-btn text @click="[addOrg = !addOrg, orgId = null]">
                    Cancel
                  </v-btn>
                </v-card>
                <v-data-table
                  :headers="orgHeaders"
                  :items="filterOrgs()"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-footer
                  :mobile-breakpoint="0"
                  disable-sort
                  class="elevation-1 org-type-table"
                >
                  <template #no-data>
                    No organizations assigned
                  </template>

                  <template #no-results>
                    No organizations assigned
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.orgs.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <v-btn small text @click="startDelete(DeleteTypeEnum.ORG, item)">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>
              <v-row class="justify-start pl-7">
              <v-btn color="primaryCustom" class="white--text mr-2 mb-6" :disabled="!item.teamName" @click="saveTeam(item, false)">Save</v-btn>
              </v-row>
            </td>
          </template>

          <template #item="{ item }">
            <tr :class="{'shaded-row': filterTeams.indexOf(item) % 2}">
              <td class="text-left align-baseline">
                <span>{{ item.teamName }}</span>
                <span v-if="item.positions.length === 0 && item.users.length === 0 && item.orgs.length === 0" class="pl-4 error-red"><v-icon color="error" class="pr-1">error</v-icon>This team has no members</span>
              </td>
              <td class="pl-6"><v-icon v-if="item.isDefault">mdi-check</v-icon></td>
              <td class="text-right">
                <v-btn small text v-if="!expanded.includes(item) && $store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')" @click="expanded = [item]; expandedItem = item;">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn v-if="!expanded.includes(item) && $store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'DELETE')"
                       :disabled="item.isDefault" small text @click="startDelete(DeleteTypeEnum.TEAM, item)">
                  <v-icon>delete</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
              </td>

            </tr>
          </template>

        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  putRequest,
  getSnackbar,
  getRequest,
  postRequest,
  deleteRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmDeleteDialogImproved from "@/ConfirmDeleteDialogImproved";

export default {
  name: 'smsTeam',
  components: {ConfirmDeleteDialogImproved, ConfirmDeleteDialog},
  data () {
    return {
      DeleteTypeEnum: Object.freeze({
        TEAM: 'deleteTeam',
        POSITION:'deletePosition',
        USER:'deleteUser',
        ORG: 'deleteOrg'
      }),
      snackbar: {},
      constants,
      teams: [],
      newTeam: {},
      addTeam: false,
      userSearch: '',
      orgSearch: '',
      levels: [],
      parentId: this.$store.state.user.details.parentCompanyId,
      headers: [
        { text: 'Team Name', value: 'teamName', show: true },
        {text: 'Default', value: 'isDefault', show: true },
        { text: null, value: 'icons', show: true, sortable: false }
      ],
      expanded: [],
      expandedItem: [],
      showDeleteDialog: false,
      showDeleteUserDialog: false,
      positionHeaders: [
        {text: 'Current Positions', value: 'name', show: true},
        {text: null, value: 'icons', show: true}
      ],
      userHeaders: [
        {text: 'Current Users', value: 'fullName', show: true},
        {text: null, value: 'icons', show: true}
      ],
      orgHeaders: [
        {text: 'Current Organizations', value: 'orgName', show: true},
        {text: null, value: 'icons', show: true}
      ],
      addUser: false,
      addPosition: false,
      addOrg: false,
      users: [],
      positions: [],
      orgs: [],
      positionId: '',
      userId: '',
      orgId: '',
      itemToDelete: '',
      deleteType: ''
    }
  },
  computed: {
    filterTeams () {
      return this.teams.filter(tmp => !tmp.archived)
    }
  },
  methods: {
    async getTeams () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/smsTeam/`)
        this.teams = data
        this.teams.map(team => team.checked = team.isDefault)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveTeam(team, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const confirmChangeDefault = (team.checked !== team.isDefault)
        if(confirmChangeDefault) {
          //if the edited team has been set as default, remove the isDefault state from the old default team
          const oldDefaultTeam = this.teams.filter(team => team.isDefault)[0]
          if (oldDefaultTeam) {
            oldDefaultTeam.isDefault = false
            const {removeData, removeStatus} = await putRequest(`/smsTeam/`, oldDefaultTeam) //removes the default state from
          }
          team.isDefault = team.checked
        }
        const {data, status} = await putRequest(`/smsTeam/`, team)
        if(isNew){
          this.teams.push(data)
          this.addTeam = false
          this.newTeam = {}
          this.snackbar = getSnackbar('SUCCESS', 'Team Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.expanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Team Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        handleHidingGlobalLoader(this, status)
        await this.getTeams();
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Team' : 'Error Updating Team')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTeam(team) {
      try {
        const {data, status} = await putRequest(`/smsTeam/${team.id}/delete`)
        team.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Team Deleted')
        this.showDeleteDialog = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Team')
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
    filterPositions () {
      return this.expandedItem?.positions?.filter(p => { return !p.archived})
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
    async getOrgs() {
      try {
        const {data, status} = await getRequest(`/org`)
        this.orgs = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Organizations')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterOrgs () {
      return this.expandedItem?.orgs?.filter(o => { return !o.archived})
    },
    async addPositionToTeam() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/smsTeam/${this.expandedItem.id}/position/${this.positionId}`, {})
        this.expandedItem.positions.push(data)
        this.positionId = null
        this.addPosition = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error adding Position')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addUserToTeam() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/smsTeam/${this.expandedItem.id}/user/${this.userId}`, {})
        this.expandedItem.users.push(data)
        this.userId = null
        this.addUser = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error adding User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteUserFromTeam(user) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await deleteRequest(`/smsTeam/${this.expandedItem.id}/user/` + user.id)
        this.snackbar = getSnackbar('SUCCESS', 'User removed')
        user.archived = true
        const userIndex = this.expandedItem.users.findIndex(u => u.id === user.id);
        this.expandedItem.users.splice(userIndex, 1)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Unable to remove User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deletePositionFromTeam(position) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await deleteRequest(`/smsTeam/${this.expandedItem.id}/position/` + position.positionId)
        position.archived = true
        const positionIndex = this.expandedItem.positions.findIndex(p => p.id === position.id);
        this.expandedItem.positions.splice(positionIndex, 1)
        this.snackbar = getSnackbar('SUCCESS', 'Position removed')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Unable to removing Position')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addOrgToTeam() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/smsTeam/${this.expandedItem.id}/org/${this.orgId}`, {})
        this.expandedItem.orgs.push(data)
        this.orgId = null
        this.addOrg = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error adding Organization')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteOrgFromTeam(org) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await deleteRequest(`/smsTeam/${this.expandedItem.id}/org/` + org.orgId)
        this.snackbar = getSnackbar('SUCCESS', 'Organization removed')
        org.archived = true
        const orgIndex = this.expandedItem.orgs.findIndex(o => o.id === org.id);
        this.expandedItem.orgs.splice(orgIndex, 1)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error removing Organization')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    startDelete(type, item){
      this.itemToDelete = item
      this.deleteType = type
      this.showDeleteDialog = true
    },
    clearDeleteItem() {
      this.itemToDelete = ''
      this.deleteType = ''
      this.showDeleteDialog = false
    },
    deleteItem() {
      switch (this.deleteType) {
        case this.DeleteTypeEnum.POSITION:
          this.deletePositionFromTeam(this.itemToDelete)
          break;
        case this.DeleteTypeEnum.USER:
          this.deleteUserFromTeam(this.itemToDelete)
          break;
        case this.DeleteTypeEnum.ORG:
          this.deleteOrgFromTeam(this.itemToDelete)
          break;
        case this.DeleteTypeEnum.TEAM:
          this.deleteTeam(this.itemToDelete)
          break;
      }
      this.clearDeleteItem()
    },
    filterUsers () {
      return this.expandedItem?.users?.filter(p => { return !p.archived})
    },
  },
  async created () {
    this.getTeams()
    this.getPositions()
    this.getUsers()
    this.getOrgs()
  }
}
</script>

<style lang="scss">
#team-container .v-data-table__wrapper {
  max-height: calc(100vh - 650px);
}

#hierarchy-container .v-data-table__wrapper {
  max-height: calc(100vh - 200px);
}
</style>

<style lang="scss" scoped>
.team-select {
  width: 450px;
}
.org-type-table {
  margin: 0 16px 30px 16px;

}

.edit-card {
  height: 113px;
}

.error-red {
  color: var(--v-error-base);
}
</style>
