<template>
  <v-card :key="idx"
          width="355" height="558" class="pa-4 proposal-card d-flex flex-column">
    <v-carousel v-if="d.attachments.length > 0" hide>
      <v-carousel-item v-for="(image, i) in d.attachments" style="position: relative;" class="design-image">
        <img-proxy
            name="designImg"
            class="design-image"
            :quality="80"
            :uuid="d.attachments[d.imageIndex].uuid" />
      </v-carousel-item>
    </v-carousel>
    <div v-else class="design-image no-image-placeholder">
      <v-icon size="50">mdi-home</v-icon>
    </div>
    <div class="mt-3 albatross-caption grey--text">
      System size: ??kW, Created: {{ d.dateCreated | formatDate('date', 'MMM D, YYYY') }}
    </div>
    <div><a class="albatross-caption" target="_blank" :href="`/project/${projectId}/processStep/${d.projectProcessStepId}`">Open Process Step</a><v-icon class="anchor-icon" x-small>mdi-launch</v-icon></div>
    <a-btn
        color="primary"
        class="mt-4 one-hunned text-capitalize font-weight-bold"
        @click="addProposal(d)"
        text="Create new proposal"
    ></a-btn>
    <v-list v-if="d.proposals.length > 0">
      <v-list-item
          v-for="(proposal, index) in d.proposals.slice((offset * numberToDisplay),(numberToDisplay + (offset * numberToDisplay)))"
          :key="index" two-line
          class="proposal-container"
          @click="router.push({name: 'proposal', params: {proposalId: proposal.id}})">
        <v-list-item-content>
          <v-list-item-title class="proposal-title">Proposal {{ proposal.id }}</v-list-item-title>
          <v-list-item-subtitle>
            <v-container class="design-small-gray subtitle-container">
              <v-row>
                <v-col class="pt-2 pb-0">more info</v-col> <!--todo: use actual info here-->
                <v-col class="pt-2 pb-0 text-right">{{ proposal.dateCreated | formatDate('date', 'MMM D, YYYY') }}</v-col>
              </v-row>
            </v-container>
          </v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <div class="mt-6 ml-4" v-else>No Proposals Available</div>
    <div class="slice-selectors" v-if="d.proposals.length > numberToDisplay">
      <v-icon dense
              color="primary"
              class="pr-1 pb-3"
              :disabled="offset === 0"
              @click="offset--">mdi-chevron-left</v-icon>
      <v-icon dense
              color="primary"
              class="pl-1 pb-3"
              :disabled="disableAddSlice"
              @click="offset++">mdi-chevron-right</v-icon>
    </div>
  </v-card>
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

const props = defineProps({
  d: Object,
  idx: Number,
  projectId: Number
})
const { d, idx, projectId } = toRefs(props)

const numberToDisplay = ref(3)
const offset = ref(0)

const disableAddSlice = computed(() => {
  const proposalCount = d.value?.proposals.length
  let pageCount = (Math.floor(proposalCount / numberToDisplay.value))
  let dividesEqually = proposalCount % numberToDisplay.value === 0
  if (dividesEqually && pageCount !== 0) {
    pageCount--
  }
  return pageCount === offset.value
})
</script>

<style lang="scss" scoped>
.proposal-card {
  display: inline-block;
  margin-left: 10px;
  margin-right: 10px;
  position: relative;
  margin-bottom: 20px;
}
.design-image {
  height: 170px;
  width: 323px;
  border-radius: 0 !important;
}

.image-selection-icon {
  opacity: .6;
}

.image-selection-container {
  position: absolute;
  top: 0;
  left: 0;
  padding: 5px;
  display: flex;
  align-items: center;
}

.no-image-placeholder {
  text-align: center;
  display: flex;
  background-color: #dddddd;
  justify-content: center;
}

.anchor-icon {
  color: var(--v-anchor-base) !important;
  text-decoration: none !important;
}

.design-small-gray {
  color: #808588;
  font-size: 12px;
}

.proposal-title {
  font-size: 14px;
  color: var(--v-blackText-base);
}

.subtitle-container {
  padding: 0;
}

.proposal-container {
  height: 71px;
}

.slice-selectors {
  position: absolute;
  bottom: 0;
  width: calc(100% - 40px);
  text-align: center;
}
</style>
