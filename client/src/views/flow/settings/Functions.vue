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
                {{f.companyFunctionName}}
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <AlbatrossButton :to="`/settings/function/${f.id}`" variant="text" prepend-icon="edit">
                </AlbatrossButton>
              </v-list-item-action>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import { handleHidingGlobalLoader, getRequest } from '@/helpers/helpers'
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

  import {computed, getCurrentInstance, onMounted, ref} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()

  const companyId = ref(userStore.details.companyId)
  const userId = ref(userStore.details.id)
  const functions = ref([])

  const filteredFunctions = computed(() => {
    return functions.value.filter(f => !f.archives)
  })

  const getFunctions = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/function`)
      functions.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }

  onMounted(() => {
    getFunctions()
  })

</script>

<style scoped lang="scss">


</style>
