<template>
<v-btn
  :disabled="!proceed"
  :loading="isResultLoading"
  @click="completeAction"
>{{ label }}</v-btn>
</template>

<script>

import {getRequest, logError, postRequest} from '@/helpers/helpers'

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
        const {status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/action/${this.actionId}`, {})
        if (status === 204) {
          this.handleOnComplete()
        } else {
          this.handleOnCompleteError()
        }
      } catch (e) {
        this.handleOnCompleteError()
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

<style lang="scss" scoped>

</style>
