<template>
  <v-dialog
      v-model="showJoinConversationDialog"
      @click:outside="exitDialogue"
      width="303">
  <v-card class="pa-6">
    <v-card-title
        class="albatross-header-4-new pa-0"
        primary-title
    >
      Confirm assignment
    </v-card-title>

    <v-card-text class="albatross-caption pt-4 pb-0 px-0 default-text-color">
      We assign users to conversations when they wish to send SMS to the customer. You are a part of more than 1 team, which team do you want to be added to this conversation?
    </v-card-text>

    <v-select v-model="selectedSmsTeam"
              :items="teamsAssociatedToUser"
              item-text="teamName"
              label="Team"
              class="team-select pa-0 mt-4"
              return-object
    ><template #item="{item}">
                  <span>
                    {{item.teamName}}
                  </span>
    </template>
    </v-select>
    <v-card-actions class="pt-1 pb-0 px-0">
      <v-spacer/>
      <v-btn
          class="text-capitalize"
          @click="exitDialogue"
          text color="primary"
      >
        Cancel
      </v-btn>

      <v-btn
          color="primary"
          class="text-capitalize white--text"
          :disabled="!selectedSmsTeam"
          @click="joinConversation">
        Join
      </v-btn>
    </v-card-actions>
  </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "ConfirmAssignmentDialog",
  props: {
    showJoinConversationDialog: Boolean,
    teamsAssociatedToUser: Array,
  },
  data () {
    return {
      selectedSmsTeam:''
    }
  },
  methods: {
    joinConversation(){
      this.$emit('joinConversation', this.selectedSmsTeam)
      this.selectedSmsTeam = ''
      this.exitDialogue()

    },

    exitDialogue(){
      this.$emit('update:showJoinConversationDialog', false)
    }
  }
}
</script>

<style lang="scss" scoped>
.team-select {
  max-width: 100%;
}
</style>
