<template>
<v-btn
  :disabled="!proceed"
  :loading="isResultLoading"
>{{ label }}</v-btn>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'

export default {
  name: 'ActionButton',
  props: {
    actionId: Number,
    projectProcessStep: Number,
    label: String
  },
  data () {
    return {
      isResultLoading: true,
      proceed: false
    }
  },
  methods: {
    getActionResult: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStep}/actionResult/${this.actionId}`)
        this.proceed = data.canComplete
      } catch (e) {
        logError(e)
      } finally {
        this.isResultLoading = false
      }
    }
  },
  created () {
    this.getActionResult()
  }
}
</script>

<style lang="scss" scoped>

</style>
