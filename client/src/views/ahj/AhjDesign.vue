<template>
  <div>
    <h1>This is the AHJ Design component</h1>
  </div>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { getRequest } from '@/helpers/helpers'

  export default {
    name: 'ahjDesign',
    data: () => ({
      ahjDesign: {}
    }),
    async created () {
      this.ahjId = parseInt(this.$route.params.ahjId)
      const {data} = await getRequest(`/api/v1/company/blueraven/ahj/${this.ahjId}/design`)
      this.ahjDesign = cloneDeep(data)
      console.log("AHJ Design:", this.ahjDesign)
    }
  }
</script>