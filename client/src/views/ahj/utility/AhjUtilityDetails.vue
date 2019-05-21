<template>
  <div>
    <h1>This is the AHJ Utility Detail component for AHJ Utility {{ ahjUtilityId }}</h1>
  </div>
</template>

<script>
  export default {
    name: 'ahjUtilityDetails',
    data: () => ({
      testDataItem: ''
    }),
    created () {
      this.ahjUtilityId = this.$route.params.ahjUtilityId
    }
  }
</script>