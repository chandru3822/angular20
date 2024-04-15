<template>
  <v-row>
    <v-col cols="12">
      <v-card class="square-card">
        <v-data-table
            id="all-process-steps-table"
            :headers="headers"
            :items="steps"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            disable-sort
            class="elevation-0"
            :item-class="isPrimaryStep"
        >
          <template #no-data>
            <span class="default-text-color">No active process steps</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No active process steps</span>
          </template>

          <template #item.id="{item}" class="text-left">
            <router-link :to="`/project/${projectId}/processStep/${item.projectProcessStepId}`">{{ item.projectProcessStepId }}</router-link>
          </template>
          <template #item.processStepName="{item}" class="text-left" >{{item.processStepName}}</template>
          <template #item.dateCreated="{item}" class="text-left" >{{ item.dateCreated | formatDate('timestamp') }}</template>
          <template #item.owner="{item}" class="text-left" >{{ item.owner && item.owner.fullName }}</template>
          <template #item.processStepStatusType="{item}" class="text-left" >{{ item.processStepStatusType }}</template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup>
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const props = defineProps({
  projectId: Number,
  steps: Array,
  contactId: Number
})
const { projectId, steps, contactId } = toRefs(props)

const headers = ref([
  {text: 'ID', value: 'id', show: true, width: 80},
  {text: 'Type', value: 'processStepName', show: true},
  {text: 'Created', value: 'dateCreated', show: true},
  {text: 'Owner', value: 'owner', show: true},
  {text: 'Status', value: 'processStepStatusType', show: true},
])

const isPrimaryStep = (item) => {
  if(item.main){
    return "primary-row"
  }
}
</script>

<style scoped lang="scss">

.header {
  background-color: #E6E6E9;
  color: #1F3C73;
  border-bottom: 1px solid #C7C7CC;
}


</style>
