<template>
<v-row>
  <v-col>
    <router-link :to="`/project/${projectId}`">Back</router-link>
  </v-col>
</v-row>
</template>

<script>
export default {
  name: 'ProjectProcessStep',
  data () {
    return {
      projectId: this.$route.params.projectId
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
