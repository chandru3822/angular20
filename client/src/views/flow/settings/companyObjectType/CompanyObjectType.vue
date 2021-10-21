<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <CompanyCustomFieldGroup></CompanyCustomFieldGroup>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import constants from '@/helpers/constants'
import CompanyCustomFieldGroup from './CompanyCustomFieldGroup'

export default {
  name: 'CompanyObjectType',
  components: {
    CompanyCustomFieldGroup
  },
  data () {
    return {
      snackbar: {},
      constants,
      companyObjectTypeId: this.$route.params.id,
    }
  },

  created () {},
  methods: {}
}
</script>
