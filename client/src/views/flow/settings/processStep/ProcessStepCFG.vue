<template>
  <v-container class="custom-field-group-container py-0">
    <v-row>
      <v-col cols="12" class="py-0">
            <ProcessStepCustomFieldGroups v-if="!loading" :customFieldGroups="processStep.customFieldGroups"></ProcessStepCustomFieldGroups>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>


  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStorePinia.js'

  const appStore = useAppStore()
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

        const loading = ref( true)
        const processStep = ref( {})
        const breadcrumbs = ref( [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/processSteps`
          }
        ])

  const processStepId = computed(() => {
    return route.params.id
  })

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const companyId = computed(() => {
    return userStore.details.companyId
  })

  onMounted(async () => {
      await getProcessStepDetails()
    
  })
    
      const getProcessStepDetails = async () => {
        appStore.loading = true
        loading.value = true
        try {
          appStore.loading = true
          const {data, status} = await getRequest(`/processStep/${processStepId.value}`)
          processStep.value = data
          loading.value = false
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>
