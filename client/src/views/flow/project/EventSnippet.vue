<template>
  <v-row>
    <v-col cols="12">
      <v-card class="square-card">
        <v-data-table
          :headers="headers"
          :items="events"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          disable-sort
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No active events</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No active events</span>
          </template>

          <template #item.id="{item}" class="text-left">
            <router-link :to="`/project/${projectId}/processStep/${item.projectProcessStepId}/event/${item.id}`">{{ item.id }}</router-link>
          </template>
          <template #item.eventName="{item}" class="text-left">{{item.eventName}}</template>
          <template #item.start="{item}" class="text-left">{{ item.startTime | formatDate('timestamp') }}</template>
          <template #item.resourceName="{item}" class="text-left">{{item.resource}}</template>
          <template #item.eventStatusType="{item}" class="text-left">{{ item.eventStatusType }}</template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup>

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

const headers = ref([
  {text: 'ID', value: 'id', show: true, width: 80},
  {text: 'Type', value: 'eventName', show: true},
  {text: 'Start', value: 'start', show: true},
  {text: 'Resource', value: 'resourceName', show: true},
  {text: 'Status', value: 'eventStatusType', show: true},
])

const props = defineProps({
  projectId: Number,
  events: Array
})
const { projectId, events } = toRefs(props)

</script>

<style scoped lang="scss">

.header {
  background-color: #E6E6E9;
  color: #1F3C73;
  border-bottom: 1px solid #C7C7CC;
}

</style>
