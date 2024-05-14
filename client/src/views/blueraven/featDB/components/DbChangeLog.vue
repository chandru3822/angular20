<template>
  <v-card width="426">
    <a-text-field
      class="mx-4 mb-4 mt-0 pt-8"
      placeholder="Search"
      prepend-inner-icon="search"
      v-model="searchValue">
    </a-text-field>
    <DbChangeLogItem
      v-for="item in cardSlices"
      :title=item.title
      :updated-value=item.updatedValue
      :previous-value=item.previousValue
      :modified-by="item.modifiedBy"
      :date-modified="item.dateModified"
      :expand-all="searchValue.length > 0"
      :query="searchValue.toLowerCase()"/>
    <a-btn
      :disabled="btnIsDisabled"
      class="mb-2 ml-2"
      variant="text"
      :text="btnIsDisabled ? 'No Additional Results' : 'Load More'"
      @click="visibleCards+=10"
    ></a-btn>
  </v-card>
</template>

<script setup>
import {ref, computed, defineProps, onMounted, getCurrentInstance, toRefs, watch} from 'vue'
import moment from "moment";
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
  console.log(showChangeLog.value)
  if (showChangeLog.value === false) {
    visibleCards.value = 5
  }
})

watch(historyList, () => {
  if (historyList.value?.length > items.value?.length) {
    items.value = []
    historyList.value.forEach((p) => {
      items.value.push({
        'title': p.field_name,
        'updatedValue': p.updated_value,
        'previousValue': p.previous_value,
        'modifiedBy': p.modified_by,
        'dateModified': `${moment(Date.parse(p.date_modified)).format('MM/DD/yyyy')} at ${moment(Date.parse(p.date_modified)).format('hh:mm a')}`
      })
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
    items.value.push({
      'title': p.field_name,
      'updatedValue': p.updated_value,
      'previousValue': p.previous_value,
      'modifiedBy': p.modified_by,
      'dateModified': `${moment(Date.parse(p.date_modified)).format('MM/DD/yyyy')} at ${moment(Date.parse(p.date_modified)).format('hh:mm a')}`
    })
  })
  historyBackup.value = cloneDeep(historyList.value)
})


</script>

<style scoped lang="scss">



</style>
