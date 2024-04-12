<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
        </v-toolbar>
        <v-container>
          <v-list v-for="(f, index) in filteredFunctions"
                  :key="index"  class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content>
                <router-link :to="`/settings/function/${f.id}`" class="router-link-td">
                  {{f.companyFunctionName}}
                </router-link>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <a-btn :to="`/settings/function/${f.id}`" variant="text" prepend-icon="edit">
                </a-btn>
              </v-list-item-action>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
  import { handleHidingGlobalLoader, getRequest } from '@/helpers/helpers'


  import {computed, getCurrentInstance, onMounted, ref} from "vue";
  import { useUserStore } from '@/stores/UserStore.js'
  import { useAppStore } from '@/stores/AppStore.js'
  const vueInstance = getCurrentInstance().proxy

  const store = vueInstance.$store
  const userStore = useUserStore()
  const appStore = useAppStore()

  const companyId = ref(userStore.details.companyId)
  const userId = ref(userStore.details.id)
  const functions = ref([])

  const filteredFunctions = computed(() => {
    return functions.value.filter(f => !f.archives)
  })

  const getFunctions = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/function`)
      functions.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }

  onMounted(() => {
    getFunctions()
  })

</script>

<style scoped lang="scss">


</style>
