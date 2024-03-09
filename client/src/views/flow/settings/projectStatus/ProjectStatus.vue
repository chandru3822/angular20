<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <AlbatrossButton
            variant="text"
            class="pl-1 pr-2 anchor"
            :to="'/settings/projectStatuses'"
            prepend-icon="arrow_left"
            text="BACK"
        ></AlbatrossButton>


        <v-toolbar flat class="app-toolbar">
          <span class="headline-small">{{ projectStatus.projectStatusType }}</span>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>

        <v-tabs class="tabs-bar tabs-border-bottom" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
      </v-col>

      <router-view/>
    </v-row>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {getCompanyProjectStatusType} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useRoute} from "vue-router/composables";

const route = useRoute()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const statusId = computed(() => {
  return route.params.id
})

const activeTab = ref('')
const projectStatus = ref({})
const rootStatusTypes = ref([])
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const savingTypeLogo = ref(false)
const attachmentTypeId = ref(463)
const tabs = ref([
  {
    id: 1,
    label: 'Components',
    path: `/settings/projectStatus/${statusId.value}/components`,
  },
  {
    id: 2,
    label: 'Fields',
    path: `/settings/projectStatus/${statusId.value}/fields`,
  }
])

onMounted(() => {
  getStatusInfo()
})

const getStatusInfo = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getCompanyProjectStatusType(statusId.value)
    projectStatus.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>

<style scoped lang="scss">
.tabs-border-bottom {
  border-bottom: 1px solid #E6E6E6;
}
</style>
