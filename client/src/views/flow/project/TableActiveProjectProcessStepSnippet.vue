<template>
  <v-row>
    <v-col cols="12" class="pt-0">
      <v-card class="square-card">
        <v-data-table
            :headers="headers"
            :items="sortedSteps"
            :fixed-header="true"
            :items-per-page="-1"
            id="qa-process-step-table"
            hide-default-footer
            disable-sort
            class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No active process steps</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No active process steps</span>
          </template>

          <template #item.id="{item}" class="text-left" id="qa-process-link">
            <router-link :to="getProjectProcessStepPath(item)">
              {{ item.projectProcessStepId }}
            </router-link>
          </template>
          <template #item.processStepName="{item}" class="text-left" id="qa-process-step-name">{{item.processStepName}}
          </template>
          <template #item.dateCreated="{item}" class="text-left" id="qa-process-date-created">{{ item.dateCreated | formatDate('timestamp') }}
          </template>
          <template #item.owner="{item}" class="text-left" id="qa-process-owner-name">{{ item.owner && item.owner.fullName }}
          </template>
          <template #item.processStepStatusType="{item}" class="text-left" id="qa-process-status">{{item.processStepStatusType}}
          </template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup>
import orderBy from 'lodash.orderby'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  projectId: Number,
  steps: Array,
  contactId: Number
})
const { projectId, steps, contactId } = toRefs(props)

const sortedSteps = computed(() => {
  return orderBy(steps.value, 'projectProcessStepId', 'desc')
})

const headers = ref([
  {text: 'ID', value: 'id', show: true},
  {text: 'Name', value: 'processStepName', show: true},
  {text: 'Created', value: 'dateCreated', show: true},
  {text: 'Owner', value: 'owner', show: true},
  {text: 'Status', value: 'processStepStatusType', show: true},
])

const getProjectProcessStepPath= (processStep) => {
  return `/project/${projectId.value}/processStep/${processStep.projectProcessStepId}`
}
</script>


<style scoped lang="scss">
.header {
  background-color: #E6E6E9;
  color: #1F3C73;
  border-bottom: 1px solid #C7C7CC;
}
</style>
