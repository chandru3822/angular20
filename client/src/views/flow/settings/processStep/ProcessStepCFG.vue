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
  import {AppMutations} from '@/stores/AppStore'

  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables";
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

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
        store.commit(AppMutations.SET_LOADING, true)
        loading.value = true
        try {
          store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest(`/processStep/${processStepId.value}`)
          processStep.value = data
          loading.value = false
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Retrieving Data')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>
