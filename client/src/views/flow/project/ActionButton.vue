<template>
  <v-btn
    :disabled="!proceed"
    :loading="isResultLoading"
    color="primaryCustom"
    class="action-button"
    @click="completeAction"
  >
  {{ label }}
    <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
    <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
</v-btn>
</template>

<script>

import {getRequest, logError, postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'ActionButton',
  props: {
    actionId: Number,
    projectProcessStepId: Number,
    label: String,
    handleOnComplete: Function,
    handleOnCompleteError: Function
  },
  data () {
    return {
      isResultLoading: false,
      proceed: false,
      actionResult: {}
    }
  },
  methods: {
    getColor () {
      return this.proceed ? 'white' : null
    },
    getActionResult: async function() {
      try {
        this.isResultLoading = true
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/actionResult/${this.actionId}`)
        //verifying that a user has edit permissions to process steps to be able to click a button, might have to add an Actions permission eventually
        this.actionResult = data
        this.proceed = data.canPerform && this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT')
      } catch (e) {
        logError(e)
      } finally {
        this.isResultLoading = false
      }
    },
    completeAction: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/action/${this.actionId}`, {})
        if (status === 204) {
          this.handleOnComplete()
        } else {
          this.handleOnCompleteError(this.$props.actionId)
        }
      } catch (e) {
        this.handleOnCompleteError(this.$props.actionId)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  created () {
    this.getActionResult()
  },
  mounted () {
    this.$root.$on('projectProcessStep:checkAction', this.getActionResult)
  },
  beforeDestroy() {
    this.$root.$off('projectProcessStep:checkAction');
  }
}
</script>

<style lang="scss">

.action-button > .v-btn__content {
  color: white !important;
}
</style>
