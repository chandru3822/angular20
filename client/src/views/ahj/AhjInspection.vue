<template>
  <div>
    <h1>This is the AHJ Inspection component</h1>
  </div>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { getRequest } from '@/helpers/helpers'

  export default {
    name: 'ahjInspection',
    data: () => ({
      ahjInspection: {}
    }),
    async created () {
      this.ahjId = parseInt(this.$route.params.ahjId)
      const {data} = await getRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/inspection`)
      this.ahjInspection = cloneDeep(data)
      console.log("AHJ Inspection:", this.ahjInspection)
    }
  }
</script>