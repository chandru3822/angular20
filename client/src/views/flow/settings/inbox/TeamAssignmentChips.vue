<template>
  <v-chip-group column class="team-chips">
      <span v-for="(team, index) in smsTeamOwners" class="d-flex flex-wrap">
        <v-chip v-if="team.users.length === 0"
                label
                :close="teamNamesAssociatedToUser.includes(team.teamName) && userCanView"
                close-icon="mdi-close"
                @click:close="closeTeam(team)"
                class="chip"
                :class="{
                  'unassigned-team-chip': teamNamesAssociatedToUser.includes(team.teamName),
                  'other-team-chip': !teamNamesAssociatedToUser.includes(team.teamName),  'selected': selectedProjectId === projectId && showSelectedStyles}"
        >
          <span >{{team.teamName}} - Unassigned</span>
        </v-chip>
        <v-chip v-else v-for="(user, index) in team.users"
                label
                :close="(user.userId === userId && userCanView) || (teamNamesAssociatedToUser.includes(team.teamName) && userCanManage)"
                close-icon="mdi-close"
                @click:close="close(user)"
                :ripple="false"
                class="chip"
                :class="{'assigned-team-chip': teamNamesAssociatedToUser.includes(team.teamName),
                 'other-team-chip': !teamNamesAssociatedToUser.includes(team.teamName), 'selected': selectedProjectId === projectId && showSelectedStyles}">
          <span>{{team.teamName}} - {{user.name}}</span>
        </v-chip>
      </span>
    <v-chip v-if="(project && project.showAssignToMeButton) || showAssignToMeButton && !reloading"
            label
            class="white--text text-capitalize clickable"
            :ripple="false"
            :class="unassignedTeamExits ? 'unassigned-join-button' : 'assigned-join-button'"
            @click.stop="$emit('joinConversation')">
      <span>Join</span>
    </v-chip>
    <v-dialog v-model="showRemoveDialog" max-width="709px">
      <v-card class="pt-6 pl-6">
        <v-card-title class="albatross-header-4-new pa-0">What would you like to do?</v-card-title>
        <v-radio-group v-model="removeOption">
          <v-radio :key="0" :value="0" class="albatross-body-1 remove-dialog-option mb-4">
            <template v-slot:label><div class="default-text-color"> Remove <strong>&nbsp;{{userToRemove.name}}&nbsp;</strong> from the conversation</div></template></v-radio>
          <v-radio :key="1" :value="1" class="albatross-body-1 remove-dialog-option mb-0" color="grey darken-4" :mesaages="[`This will also remove other ${teamToRemove.teamName} team members on the conversation`]">
            <template v-slot:label><div class="default-text-color">Remove <strong>&nbsp;{{userToRemove.name}}&nbsp;</strong> and <strong>&nbsp;{{teamToRemove.teamName}}&nbsp;</strong> team from the conversation</div></template>
          </v-radio>
          <span class="albatross-body-3 remove-dialog-option-info px-8 pt-n4">This will also remove other {{teamToRemove.teamName}} team members on the conversation</span>
        </v-radio-group>
        <v-card-actions class="pb-4">
          <v-spacer/>
          <v-btn class="text-capitalize" text color="primary" @click="showRemoveDialog=false">Cancel</v-btn>
          <v-btn class="text-capitalize white--text" depressed color="primary" @click="confirmChoice">Confirm</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showRemoveLastTeamDialog" max-width="600px">
      <v-card class="pt-6">
        <v-card-title
            class="albatross-header-4-new pt-0"
            primary-title>
          Remove Team
        </v-card-title>
        <v-card-text class="default-text-color albatross-body-1 px-6">
         <div>Because no other team is on the conversation, this action will remove the team and close the conversation.</div>
          <div>Are you sure you want to remove {{teamToRemove.teamName}} team and close conversation?</div>
        </v-card-text>
        <v-card-actions class="pb-4">
          <v-spacer/>
          <v-btn class="text-capitalize" text color="primary" @click="showRemoveLastTeamDialog=false">Cancel</v-btn>
          <v-btn class="text-capitalize white--text" color="primary" @click="removeTeam(teamToRemove.id)">Remove and Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showRemoveTeamDialog" max-width="509px">
      <v-card>
        <v-card-title
            class="albatross-header-4-new"
            primary-title>
          Remove Team
        </v-card-title>
        <v-card-text class="albatross-body-1 pb-2 default-text-color">
          <div>This action will remove the team from the conversation. </div>
          <div>Are you sure you want to remove <b>{{teamToRemove.teamName}}</b> team?</div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
              text color="primary"
              @click="showRemoveTeamDialog=false"
              class="text-capitalize mr-2 mb-2"
          >
            Cancel
          </v-btn>
          <v-btn
              color="primary"
              class="white--text elevation-2 text-capitalize mb-2"
              @click="removeTeam(teamToRemove.id)">
            Remove
          </v-btn>
        </v-card-actions>
      </v-card>

    </v-dialog>
    <v-menu offset-y :close-on-content-click="false" v-model="teamsMenuOpen" v-if="userCanView">
      <template v-slot:activator="{on, attrs}">
        <v-btn icon v-bind="attrs" v-on="on" large class="align-self-baseline">
          <v-tooltip top small><template v-slot:activator="{on, attrs}">
            <v-icon color="primary" @click="" v-bind="attrs" v-on="on">
              mdi-plus
            </v-icon>
          </template>
            <span class="albatross-body-3">Add Member</span>
          </v-tooltip>
        </v-btn>
      </template>
      <AddTeamDropdown :sms-team-owners="smsTeamOwners" :project-id="projectId" @closeTeamAdded="teamAdded()"></AddTeamDropdown>
    </v-menu>

  </v-chip-group>
</template>

<script>
import {getSnackbar, putRequest} from "@/helpers/helpers";
import AddTeamDropdown from "@/views/flow/settings/inbox/AddTeamDropdown";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: "TeamAssignmentChips",
  components: {
    AddTeamDropdown
  },
  props: {
    smsTeamOwners: Array,
    teamNamesAssociatedToUser: Array,
    projectId: Number,
    project: Object,
    showSelectedStyles: Boolean,
    showAssignToMeButton: Boolean,
    reloading: Boolean
  },
  data (){
    return {
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE'),
      userCanView: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
      userId: this.$store.state.user.details.id,
      showRemoveDialog: false,
      showRemoveLastTeamDialog: false,
      showRemoveTeamDialog: false,
      userToRemove:'',
      teamToRemove:{},
      removeOption:0,
      teamsMenuOpen: false,
      unassignedTeamMenuOpen: false,
      selectedProjectId: null
    }
  },
  watch: {
    '$route.params.projectId': function () {
      this.selectedProjectId = parseInt(this.$route.params.projectId) | null
    }
  },
  created() {
    this.selectedProjectId = parseInt(this.$route.params.projectId) | null
  },
  methods: {
    teamAdded() {
      this.teamsMenuOpen = false
      this.unassignedTeamMenuOpen = false
      this.$emit('updateOwner')
    },
    close (user) {
      this.userToRemove=user
      this.teamToRemove = this.getTeamToRemoveBySmsTeamId(user.smsTeamId)
      this.showRemoveDialog = true
    },
    closeTeam (team) {
      this.teamToRemove = team
      if(this.smsTeamOwners.length === 1){
        this.showRemoveLastTeamDialog = true
      } else {
        this.showRemoveTeamDialog = true
      }
      },
    getTeamToRemoveBySmsTeamId(smsTeamId){
     return this.smsTeamOwners.find(team => team.id === smsTeamId)
    },
    confirmChoice(){
      switch (this.removeOption){
        case 0: this.removeUser()
             break
        case 1: this.removeTeam(this.teamToRemove.id)
            break
      }
      this.removeOption = 0
      this.showRemoveDialog = false
    },
    async removeTeam(teamId) {
      this.showRemoveTeamDialog=false
      this.showRemoveLastTeamDialog = false
      try {
        await putRequest(`/messaging/removeTeam/`+ this.projectId + '/' + teamId)
        // If the project is currently opened on the right panel, navigate back to main inbox to close it
        if (this.$route.path.includes('inboxConversation') && this.$route.path.includes(this.projectId)) {
          await this.$router.push({path: `/inbox`})
        }

        this.snackbar = getSnackbar('SUCCESS', 'Team removed')
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error removing team')
      }
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      this.$emit('updateOwner')
    },
    async removeUser() {
      try {
        const bodyData = {
          projectId: this.projectId,
          smsTeamId: this.userToRemove.smsTeamId,
          userId: this.userToRemove.userId,
          name: this.userToRemove.name,
          archived: this.userToRemove.archived
        }
        await putRequest(`/messaging/removeOwner/`+ this.projectId, bodyData)
        this.snackbar = getSnackbar('SUCCESS', 'Unassigned')
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error removing team')
      }
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      this.$emit('updateOwner')
    },
    unassignedTeamExits() {
      let unassignedExists = false;
      this.smsTeamOwners.forEach(team => {
        if (team.users.length === 0 && this.teamNamesAssociatedToUser.includes(team.teamName)) {
          unassignedExists = true;
        }
      });

      return unassignedExists;
    },
  }

}
</script>

<style lang="scss" scoped>

.unassigned-join-button {
  background-color: #1F3C73 !important;
}
.assigned-join-button {
  background-color: #C0C0C0;
  color: #1F3C73 !important;
}

.chip:hover {
  cursor: default;
}
.chip::before {
  color: transparent;
  cursor: default;
}

.unassigned-team-chip {
  background-color: var(--v-error-lighten4) !important;
  color: #BD2828 !important;
  cursor: default;

  &.selected {
    border: solid 0.5px;
  }
}

.other-team-chip {
  background: var(--v-grey-lighten3) !important;
  cursor: default;

  &.selected {
    border: solid 0.5px;
  }
}

.assigned-team-chip {
  background: var(--v-primary-lighten9) !important;
  //color: white !important;
  cursor: default;
  &.selected {
    background: white !important;
    border: solid 0.5px;
  }
}

.remove-dialog-option-info {
  color: #949494;
}
</style>
