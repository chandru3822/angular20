<template>
  <div v-if="!apiPath">Cannot load custom fields for this user or company.</div>
  <CustomField v-else :api-path="apiPath"></CustomField>
</template>

<script setup>
  import CustomField from "@/views/flow/settings/customFields/CustomField.vue"
  import { ref, getCurrentInstance} from 'vue'
  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance()
  const userStore = useUserStore()

  const apiPath = ref(userStore.details.apiPath)

</script>

<style lang="scss">
</style>

<style scoped lang="scss">

</style>
