<template>
  <v-container class="custom-field-group-container pa-0">
    <CustomFieldGroup :is-project="false"></CustomFieldGroup>
  </v-container>
</template>

<script>
import CustomFieldGroup from '../CustomFieldGroup'

export default {
  name: 'EventCustomFieldGroup',
  components: {
    CustomFieldGroup
  },
  data () {
    return {
    }
  },
  watch: {},
  created () {},
  methods: {}
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
