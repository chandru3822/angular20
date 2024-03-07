<template>
  <v-container id="custom-field-container">
    <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
    <CustomFields v-else :api-path="apiPath"></CustomFields>
  </v-container>
</template>

<script setup>
  import CustomFields from "@/views/flow/settings/customFields/CustomFields.vue"
  import { ref, getCurrentInstance} from 'vue'
  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance()
  const userStore = useUserStore()
  const snackbar = vueInstance.$snackbar

  const apiPath = ref(userStore.details.apiPath)

</script>
