<template>
  <v-card class="px-6 pt-4 square-card">
    <v-card-title
        class="albatross-header-3 text-capitalize pa-0"
        primary-title>
      Assign Project to {{planName}}
      <v-spacer/>

    </v-card-title>
    <v-card-text class="">
      <a-text-field
                    label="Enter Project ID to Add"
                    placeholder=" "
                    v-model.number="projectId"></a-text-field>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <a-btn
          variant="text"
          color="primary"
          class="elevation-0 text-capitalize"
          @click="$emit('cancel')"
          text="Close"
      ></a-btn>
      <a-btn
          class="ml-2 text-capitalize"
          :disabled="!projectId"
          color="primary"
          @click="saveProjectToPlan()"
          text="Save"
      ></a-btn>
    </v-card-actions>
  </v-card>
</template>

<script setup>
import { getSnackbar, postRequestWithRequestParams } from '@/helpers/helpers'

import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'

const brsStore = useBrsStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  override: Boolean,
  planId: Number,
  planName: String
})

const { override, planId, planName } = toRefs(props)

const projectId = ref(null)
const dataSaving = ref(false)

const saveProjectToPlan = async() => {
  dataSaving.value = true
  try {
    let url = override.value ? `/commissionManagement/overrides/plan/${planId.value}/assignToPlan` : `/commissionManagement/${planId.value}/assignToPlan`
    await postRequestWithRequestParams(url, null, { projectId: projectId.value }, 'blueraven')
    appStore.showSnack('SUCCESS', 'Project Assigned')

    projectId.value = null
    dataSaving.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataSaving.value = false
    let msg = e?.data?.message || 'Error Assigning Project to Plan'
    appStore.showSnack('ERROR', msg)

    appStore.loading = false
  }
}
</script>
