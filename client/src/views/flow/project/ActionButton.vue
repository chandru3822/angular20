<template>
  <v-btn
    :disabled="!proceed"
    color="primaryCustom"
    class="action-button"
    @click="completeAction"
  >
  {{ actionResult.actionName }}
    <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
    <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
</v-btn>
</template>

<script>

import {postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'ActionButton',
  props: {
    actionResult: Object,
    projectProcessStepId: Number,
    handleOnComplete: Function,
    handleOnCompleteError: Function
  },
  data () {
    return {
      proceed: this.actionResult.canPerform && this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT')
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
