<template>
  <v-card class="overflow-y-auto" width="446" id="dbChangeLogScrollRef">
    <v-card-title>Change Log</v-card-title>
    <a-text-field
      class="mx-4 mt-0 pt-0 mb-n5"
      placeholder="Search"
      prepend-inner-icon="search"
      v-model="searchValue"
      clearable
      @click:clear="searchValue=''">
    </a-text-field>
    <DbChangeLogItem
      v-for="item in cardSlices"
      :title=item.title
      :updated-value=item.updatedValue
      :previous-value=item.previousValue
      :modified-by="item.modifiedBy"
      :date-modified="item.dateModified"
      :expand-all="searchValue !== null && searchValue.length > 0"
      :query="searchValue.toLowerCase()"
      :data-type="item.dataType"/>
    <a-btn
      :disabled="btnIsDisabled"
      class="mb-4 load-more-btn"
      variant="text"
      :text="cardSlices.length === 0 ? 'No Available Entries' : (btnIsDisabled ? 'No Additional Entries' :  'Load More')"
      @click="visibleCards+=10"
    ></a-btn>
  </v-card>
</template>

<script setup>
import {ref, computed, defineProps, onMounted, getCurrentInstance, toRefs, watch} from 'vue'
import DbChangeLogItem from "./DbChangeLogItem.vue"
import cloneDeep from "lodash.clonedeep"

const props = defineProps({
  historyList: Array,
  showChangeLog: Boolean,
})
const { historyList, showChangeLog } = toRefs(props)
const visibleCards = ref(5)
const btnIsDisabled = computed(() => {
  if (searchValue.value.length > 0) {
    return true
  }
  return items.value.length <= visibleCards.value;
})

watch(showChangeLog, () => {
  if (showChangeLog.value === false) {
    visibleCards.value = 5
  }
})

watch(historyList, () => {
  if (historyList.value?.length > items.value?.length) {
    items.value = []
    historyList.value.forEach((p) => {
      if (p.dataType === 1) {
        items.value.push({
          'title': p.fieldName,
          'updatedValue': p.updatedValue !== null ? vueInstance.$options.filters.formatDate(p.updatedValue, 'date', 'MMM DD, y') : p.updatedValue,
          'previousValue': p.previousValue!== null ? vueInstance.$options.filters.formatDate(p.previousValue, 'date', 'MMM DD, y') : p.previousValue,
          'modifiedBy': p.modifiedBy,
          'dateModified': p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
          'dataType': p.dataType
        })
      } else if (p.dataType === 2) {
        items.value.push({
          'title': p.fieldName,
          'updatedValue': p.updatedValue !== null ? vueInstance.$options.filters.formatDate(p.updatedValue, 'timestamp', 'MMMM DD, YYYY, hh:mm A') : p.updatedValue,
          'previousValue': p.previousValue!== null ? vueInstance.$options.filters.formatDate(p.previousValue, 'timestamp', 'MMMM DD, YYYY, hh:mm A') : p.previousValue,
          'modifiedBy': p.modifiedBy,
          'dateModified': p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
          'dataType': p.dataType
        })
      } else {
        items.value.push({
          'title': p.fieldName,
          'updatedValue': p.updatedValue,
          'previousValue': p.previousValue,
          'modifiedBy': p.modifiedBy,
          'dateModified': p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
          'dataType': p.dataType
        })
      }
    })
  }
})

const items = ref([])
const cardSlices = computed(() => {
  if (searchValue.value.length > 0) {
    return items.value.filter((i) => {
      return (i?.title?.toLowerCase()?.includes(searchValue.value.toLowerCase()) ||
              i?.updatedValue?.toLowerCase()?.includes(searchValue.value.toLowerCase()) ||
              i?.previousValue?.toLowerCase()?.includes(searchValue.value) ||
              i?.modifiedBy?.toLowerCase()?.includes(searchValue.value) ||
              i?.dateModified?.toLowerCase()?.includes(searchValue.value))
    })
  }
  return items.value.slice(0, visibleCards.value)
})

const searchValue = ref('')
const historyBackup = ref([])
const vueInstance = getCurrentInstance().proxy
onMounted(() => {
  historyList.value.forEach((p) => {
    if (p.dataType === 1) {
      items.value.push({
        'title': p.fieldName,
        'updatedValue': p.updatedValue !== null ? vueInstance.$options.filters.formatDate(p.updatedValue, 'date', 'MMM DD, y') : p.updatedValue,
        'previousValue': p.previousValue!== null ? vueInstance.$options.filters.formatDate(p.previousValue, 'date', 'MMM DD, y') : p.previousValue,
        'modifiedBy': p.modifiedBy,
        'dateModified': p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
        'dataType': p.dataType
      })
    } else if (p.dataType === 2) {
      items.value.push({
        'title': p.fieldName,
        'updatedValue': p.updatedValue !== null ? vueInstance.$options.filters.formatDate(p.updatedValue, 'timestamp', 'MMMM DD, YYYY, hh:mm A') : p.updatedValue,
        'previousValue': p.previousValue!== null ? vueInstance.$options.filters.formatDate(p.previousValue, 'timestamp', 'MMMM DD, YYYY, hh:mm A') : p.previousValue,
        'modifiedBy': p.modifiedBy,
        'dateModified': p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
        'dataType': p.dataType
      })
    } else {
      items.value.push({
        'title': p.fieldName,
        'updatedValue': p.updatedValue,
        'previousValue': p.previousValue,
        'modifiedBy': p.modifiedBy,
        'dateModified':  p.dateModified !== null ? vueInstance.$options.filters.formatDate(p.dateModified, 'timestamp', 'MM/DD/YYYY, hh:mm A') : p.dateModified,
        'dataType': p.dataType
      })
    }
  })
  historyBackup.value = cloneDeep(historyList.value)
})


</script>

<style scoped lang="scss">

::v-deep .load-more-btn.v-btn--disabled span.v-btn__content {
  color: var(--v-grey-darken4);
}


</style>
