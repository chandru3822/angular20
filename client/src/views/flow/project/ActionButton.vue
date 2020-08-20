<template>
<v-btn
  :disabled="!proceed"
  :loading="isResultLoading"
  color="primary"
  class="action-button"
  @click="completeAction"
>{{ label }}</v-btn>
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
      proceed: false
    }
  },
  methods: {
    getActionResult: async function() {
      try {
        this.isResultLoading = true
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/actionResult/${this.actionId}`)
        this.proceed = data.canPerform
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
  }
}
</script>

<style lang="scss">

.action-button > .v-btn__content {
  color: white !important;
}
</style>
