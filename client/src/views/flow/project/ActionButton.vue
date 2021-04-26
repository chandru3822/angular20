<template>
  <v-btn
    :disabled="!proceed"
    color="primaryCustom"
    class="action-button"
    v-if="!dirtyCfvCount || dirtyCfvCount === 0"
    @click="completeAction"
  >
  {{ actionResult.actionName }}
    <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
    <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
</v-btn>
<v-dialog v-else width="500"
            v-model="unsavedFieldsModal">
    <template v-slot:activator="{ on }">
      <v-btn
        :disabled="!proceed"
        color="primaryCustom"
        class="action-button"
        v-on="on"
      >
        {{ actionResult.actionName }}
        <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
        <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
      </v-btn>
    </template>
    <v-card>
      <v-card-title
        class="headline grey lighten-2"
        primary-title
      >
        Confirm
      </v-card-title>

      <v-card-text  class="pt-4">
        You have unsaved fields.  Are you sure you want to continue without saving?
      </v-card-text>

      <v-divider></v-divider>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click="unsavedFieldsModal = false">
          No
        </v-btn>
        <v-btn
          color="primaryCustom"
          text
          @click="completeAction">
          Yes
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>

import {postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'ActionButton',
  props: {
    actionResult: Object,
    dirtyCfvCount: Number,
    projectProcessStepId: Number,
    handleOnComplete: Function,
    handleOnCompleteError: Function
  },
  data () {
    return {
      unsavedFieldsModal: false,
      proceed: !this.actionResult.triggerAutomatically && this.actionResult.canPerform && this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT')
    }
  },
  methods: {
    getColor () {
      return this.proceed ? 'white' : null
    },
    completeAction: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/action/${this.actionResult.id}`)
        if (status === 204) {
          this.handleOnComplete()
        } else {
          this.handleOnCompleteError(this.actionResult.id)
        }
      } catch (e) {
        this.handleOnCompleteError(this.actionResult.id)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss">

.action-button > .v-btn__content {
  color: white !important;
}
</style>
