<template>
  <v-container id="custom-field-container">
    <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
    <CustomFields v-else :api-path="apiPath"></CustomFields>
  </v-container>
</template>

<script setup>
  import CustomFields from "@/views/flow/settings/customFields/CustomFields.vue"
  import { ref } from 'vue'
  import {useUserStore} from "@/stores/UserStore.js";

  const userStore = useUserStore()
  const apiPath = ref(userStore.details.apiPath)

</script>
