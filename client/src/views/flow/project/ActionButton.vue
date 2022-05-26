<template>
  <v-btn
    :disabled="!proceed"
    color="primary"
    class="action-button"
    @click="completeAction"
  >
  {{ actionResult.actionName }}
    <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
    <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
</v-btn>
</template>

<script>

import {handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
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
        const {data, status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/action/${this.actionResult.id}`)
        if (status === 204 || status === 200) {
          this.handleOnComplete(data)
        } else {
          this.handleOnCompleteError(this.actionResult.id)
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.handleOnCompleteError(this.actionResult.id, e.data.message)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss">
.action-button > .v-btn__content {
  color: white !important;
  text-transform: none;
}
</style>
