<template>
  <v-row no-gutters id="project-status-tracker-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
      <!--      <div v-if="fieldsLoading" class="section-spinner">-->
      <!--        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
      <!--      </div>-->
      <div>

        <div class="headline-small stage-header">
          Current Stage:
          <span :class="{'cancelled-text': cancelled}">{{currentStatus.projectStatusType}}
          </span>
        </div>
        <div class="relative">
          <div id="vertical-line"></div>
          <div v-for="(milestone, idx) in milestones" class="mb-3 stage-section">
            <div class="flex-display flex-align-items-center">
              <StatusTrackerIcon :clickable="false"
                                 :milestone="milestone"
                                 :current-status-id="currentStatus.companyProjectStatusTypeId"
              ></StatusTrackerIcon>
              <span class="ml-2 label-large" :class="{'active-status': milestone.id === currentStatus.companyProjectStatusTypeId}">{{milestone.projectStatusType}}</span>

              <v-tooltip left>
                <template v-slot:activator="{ on, attrs }">
                  <a-btn
                      icon
                      class="information-icon"
                      color="var(--v-grey-base)"
                      v-bind="attrs"
                      :activation-handler="on"
                      prepend-icon="mdi-information"
                  ></a-btn>
                </template>
                <span>{{ milestone.description }}</span>
              </v-tooltip>
            </div>
            <!--        <v-card class="px-3 mt-2 ml-10 pb-3" v-if="milestone.assignedFields?.length > 0">-->
            <div v-for="field in milestone.assignedFields">
              <v-card class="px-3 mt-2 ml-10 pb-3 milestone-card" :elevation="0" v-if="milestone.assignedFields?.length > 0">
                <StatusTrackerItem :field="field" :cancelled="cancelled"
                ></StatusTrackerItem>
              </v-card>
            </div>
          </div>
        </div>
      </div>
    </v-col>
  </v-row>
</template>

<script setup>

import {getRequest,  handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import StatusTrackerIcon from '@/views/flow/project/StatusTrackerIcon'
import StatusTrackerItem from '@/views/flow/project/StatusTrackerItem'


import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  milestones: Array,
})
const { milestones } = toRefs(props)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const currentStatus = ref({})
const cancelled = ref(false)

onMounted(() => {
  getCurrentStatus()
})

const getCurrentStatus = async() => {
  try {
    const {data, status} = await getRequest(`/project/${projectId.value}/status`)
    currentStatus.value = data
    if(currentStatus.value.projectStatusTypeId == 2){
      cancelled.value = true;
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Current Project Status')

  }
}
</script>

<style lang="scss" scoped>
.active-status {
  color: #000000;
}

.cancelled-text{
  color: var(--v-error-base);
}

.information-icon{
  width: 36px;
}

.stage-header{
  padding-top: 12px;
  padding-bottom: 16px;
}

.stage-section{
  margin-bottom: 24px !important;
}

#vertical-line {
  height: calc(100% - 9px);
  border-left: solid 1px #9E9E9E;
  position: absolute;
  top: 5px;
  left: 13px;
}

.milestone-card{
  margin-top: 12px !important;
  box-shadow: none;
  border: 1px solid var(--v-grey-lighten1);
}
</style>

<style lang="scss">

</style>
