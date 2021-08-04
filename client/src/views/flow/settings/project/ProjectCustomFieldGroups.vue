<template>
  <v-container class="custom-field-group-container pa-0">
    <CustomFieldGroup :is-project="true"></CustomFieldGroup>
  </v-container>
</template>

<script>
import CustomFieldGroup from '../objectType/CustomFieldGroup'

export default {
  name: 'ProjectCustomFieldGroup',
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

