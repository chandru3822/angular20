<template>
  <v-container id="custom-field-container">
    <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
    <CustomFields v-else :api-path="apiPath"></CustomFields>
  </v-container>
</template>

<script>
  import CustomFields from "@/views/flow/settings/customFields/CustomFields.vue"
  export default {
    name: 'CompanyCustomFields',
    components: {
      CustomFields,
    },
    data() {
      return {
        snackbar: {},
        apiPath: this.$store.state.user.details.apiPath,
      }
    }
  }
</script>
