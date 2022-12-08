<template>
  <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
  <CustomField v-else :api-path="apiPath"></CustomField>
</template>

<script>
  import CustomField from "@/views/flow/settings/customFields/CustomField.vue"
  export default {
    name: 'CompanyCustomField',
    components: {
      CustomField,
    },
    data() {
      return {
        apiPath: this.$store.state.user.details.apiPath,
      }
    },
    async created() {},
    methods: {
    }
  }
</script>

<style lang="scss">
</style>

<style scoped lang="scss">

</style>
