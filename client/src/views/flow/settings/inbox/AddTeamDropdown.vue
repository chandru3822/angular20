<template>
  <v-card width="300px" min-height="270px" class="pa-6 d-flex flex-column">
    <div class="albatross-header-4-new">Add Member</div>
    <v-select v-model="teamToSave"
              :items="selectableTeams"
              item-text="teamName"
              label="Team"
              class="user-filter-select"
              @change="getSelectableUsers"
              menu-props="offset-y"
              return-object
    > <template #item="{item}">
                  <span>
                    {{item.teamName}}
                  </span>
    </template>
    </v-select>
    <v-autocomplete v-model="ownersToSave"
                    :disabled="!teamToSave || selectableUsers.length == 0"
                    :items="selectableUsers"
                    multiple
                    item-text="name"
                    label="Select Owners"
                    height="35px"
                    class="user-filter-select"
                    return-object
                    menu-props="offset-y"
    >
      <template
        slot="selection"
        slot-scope="{ item, index }"
      >
        <v-chip small v-if="index === 0 && ownersToSave && ownersToSave.length < 2">
          <span>{{ item.name }}</span>
        </v-chip>
        <span
          v-if="index === 1 && ownersToSave && ownersToSave.length >= 2"
          class="primary--text caption"
        >{{ ownersToSave.length }} selected</span>
      </template>
    </v-autocomplete>


    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn color="secondary" class="text-capitalize" @click="cancel()">Cancel</v-btn>
      <v-btn :disabled="!teamToSave || !ownersToSave"
             color="primary" class="text-capitalize white--text" @click="addTeamDetails()">Save</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, postRequest} from "@/helpers/helpers";

export default {
  name: "AddTeamDropdown",
  props: {
    smsTeamOwners:[],
    defaultTeamId: Number,
    projectId:Number
  },
  data () {
    return {
      teamToSave: '',
      selectableTeams: [],
      existingTeams: {},
      ownersToSave: [],
      selectableUsers: [],
      userCanView: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE'),
      userId: this.$store.state.user.details.id,
    }
  },
  async created() {
    await(this.getTeams())
    if(this.defaultTeamId) {
      this.teamToSave = this.selectableTeams.find(team => this.defaultTeamId === team.id)
      this.getSelectableUsers()
    }
  },
  methods: {
    async getTeams() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/smsTeam/users`)
        this.selectableTeams = data.sort((a,b)=>{
          if(a.teamName < b.teamName) {
            return -1
          }
          if(a.teamName > b.teamName) {
            return 1
          }
          return 0
        })
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async addTeamDetails() {
      let params = {
        id: this.teamToSave.id,
        users: this.ownersToSave
      }
      try {
        const {data, status} = await postRequest(`/messaging/addTeam/${this.projectId}`, params)
        const snackbarText = (!this.ownersToSave || this.ownersToSave.length === 0 ) ? 'Team added':
            (this.isTeamAlreadyAdded(this.teamToSave) ? 'Conversation assigned' : `Conversation assigned and ${this.teamToSave.teamName} team added`)
        this.snackbar = getSnackbar('SUCCESS', snackbarText)
        this.teamToSave = '';
        this.selectableUsers = []
        this.ownersToSave = []
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error adding team')
      }
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      this.$emit('closeTeamAdded')
    },
    cancel() {
      this.teamToSave = ''
      this.ownersToSave = []
      this.$emit('closeTeamAdded')
    },
    isTeamAlreadyAdded(team) {
      let teamAlreadyAdded = false
         this.smsTeamOwners.forEach(owner => {
           if (owner.id === team.id) {
             teamAlreadyAdded = true
             return true
           }
         })
       return teamAlreadyAdded
    },
    getSelectableUsers() {
      let teamAlreadyAdded = false;
      this.selectableUsers = [];
      this.ownersToSave = [];
      this.smsTeamOwners.forEach(owner => {
        // If this is the team being added has already been added
        if (owner.id === this.teamToSave.id) {
          teamAlreadyAdded = true;
          this.teamToSave.users.forEach(u => {
            if (!owner.users.filter(u2 => u2.userId === u.userId).length > 0) {
              this.selectableUsers.push(u);
            }
          })
        }
      })
      // If the team hasn't been added, all users can be selected
      if (!teamAlreadyAdded) {
        this.selectableUsers = this.teamToSave.users;
      }

      // If User only has View permission, they can only add themselves
      if (this.userCanView && !this.userCanManage) {
        this.selectableUsers = this.selectableUsers.filter(u => u.userId === this.userId)
      }

      this.selectableUsers.sort((a,b)=>{
        if(a.name < b.name) {
          return -1
        }
        if(a.name > b.name) {
          return 1
        }
        return 0
      })
    }
  }
}
</script>

<style scoped>

</style>
