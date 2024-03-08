<template>
  <v-container id="custom-field-container">
    <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
    <CustomFields v-else :api-path="apiPath"></CustomFields>
  </v-container>
</template>

<script setup>
  import CustomFields from "@/views/flow/settings/customFields/CustomFields.vue"
  import { ref, getCurrentInstance} from 'vue'

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  const apiPath = ref(store.state.user.details.apiPath)

</script>
