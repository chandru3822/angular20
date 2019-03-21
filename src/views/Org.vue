<template>
<div v-if="$route.name === 'org'">
  <v-btn
    @click="$router.push({name: 'orgs'})"
  >Back</v-btn>
  Org Form
</div>
</template>

<script>
export default {
  name: 'NewOrg'
}
</script>

<style scoped lang="scss">

</style>
