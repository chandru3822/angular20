<template>
  <v-container class="bracket-container">
    <div :style="{'min-width': minWidth}" class="bracket-div">
      <v-row v-for="row in rowCount" class="bracket-row pt-0" :style="{'min-width': minWidth}" >
        <BracketComponent class="d-inline-block"
                          v-for="(b, idx) in getBracketsInRows(row)"
                          :bracket-count="bracketCount"
                          :row-number="row"
                          :bracket="b" :reverse="idx % 2 !== 0"/>
      </v-row>
    </div>
  </v-container>
</template>

<script setup>

import BracketComponent from "./component/BracketComponent";
import {handleHidingGlobalLoader, getRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useRoute} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const bracketCount = ref(0)
const brackets = ref([])
const rowCount = ref(1)

const tournamentId = computed(() => {
  return route.params.id
})

const minWidth = computed(() => {
  if(brackets.value?.length > 0) {
    let roundCount = brackets.value[0].rounds?.length
    if(bracketCount.value === 0) {
      return roundCount * 175 + 'px'
    } else {
      return (roundCount * 175 * 2) + 'px'
    }
  }
})

onMounted(() => {
  getBrackets()
})

const getBracketsInRows = (rowNum) => {
  // bracketCount 1, 0
  // bracketCount 2, 0,1  row 1
  // bracketCount 4, 2,3  row 2
  // bracketCount 6, 4,5  row 3
  let results = []
  let validIdx = []
  if (bracketCount.value === 1) {
    results = brackets.value
  } else {
    if (rowNum === 1) {
      validIdx = [0, 1]
    } else if (rowNum === 2) {
      validIdx = [2, 3]
    } else if (rowNum === 3) {
      validIdx = [4, 5]
    } else if (rowNum === 4) {
      validIdx = [6, 7]
    }
    results = brackets.value?.filter((b, idx) => {
      return validIdx.includes(idx)
    })
  }
  return results
}
const getBrackets = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}/brackets`, 'blueraven')
    brackets.value = data
    bracketCount.value = brackets.value.length
    rowCount.value = Math.ceil(bracketCount.value / 2)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Brackets')

    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>
.bracket-container {
  overflow: auto;
  width: 100%;
  height: calc(100vh - 104px);
  /*overflow-y: hidden;*/
  /*padding: 0;*/
}
.bracket-div {
  /*max-height: calc(100vh - 175px);*/

}
.bracket-row {
  padding-right: 50px;
  display: flex;
  justify-content: space-between;
}
</style>

