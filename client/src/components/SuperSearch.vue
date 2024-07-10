<template>
  <v-container class="pa-0">
    <v-row class="pa-0">
      <v-col xl="1" lg="2" md="2" sm="3" xs="3" class="pr-4">
        <v-autocomplete
          label="Filter"
          :items="props.filterOptions"
          v-model="filterSelection"
          clearable
          @input="debounceSyncSearchBar()"
        />
      </v-col>
      <v-col xl="11" lg="10" md="10" sm="9" xs="9" class="pl-4">
        <a-text-field
          ref="focusSearchBar"
          prepend-inner-icon="search"
          clearable
          label="Search projects..."
          v-model="searchString"
          @input="debouncedSyncFilter"
          :hint="filterSelection === 'dateCreated' ? 'Date search format: mm/dd/yyyy': ''"
          :maskaOptions="options"
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {ref, onMounted, defineProps, getCurrentInstance, computed, reactive} from "vue";
import debounce from "lodash.debounce";
import {useStickyStore} from "@/stores/StickyStore.js";

const stickyStore = useStickyStore()

const emit = defineEmits(['updateQuery'])
const filterSelection = ref('')
const searchString = ref('')
const regexString = ref('')
const props = defineProps(
  {
    filterOptions: Array
  }
)

const useMaska = computed(() => {
  // check filterSelection.value and search string length. otherwise the mask won't clear
  if (filterSelection.value === 'dateCreated' && searchString.value?.length > 0) {
    return 'Date Created: ##/##/####'
  }
  return null
})

const options = reactive({
  mask: useMaska,
  eager: true
})

const vueInstance = getCurrentInstance().proxy

const debounceSyncSearchBar = debounce(() => {
  syncSearchBar()
}, 500)

const syncSearchBar = () => {
  // update search bar based on filter input
  if (filterSelection.value) {
    searchString.value = props.filterOptions.find(f => filterSelection.value === f.value).text.concat(': ')
  } else {
    searchString.value = ''
    filterSelection.value = ''
  }
  stickyStore.projectFilter = filterSelection.value
  vueInstance.$nextTick(() => vueInstance.$refs.focusSearchBar.focus())
}


const debouncedSyncFilter = debounce(() => {
  syncFilter()
  let found
  if (searchString.value) {
    found = searchString.value.toLowerCase().match(new RegExp(regexString.value, 'i'))
  }
  if (found)
    emit('updateQuery', found[0].trim(), found[1].trim())
  else {
    emit('updateQuery', searchString.value, '')
  }
}, 500)



const syncFilter = () => {
  // update filter based on searchBar input
  const re = new RegExp(regexString.value, 'ig')
  const data = re.exec(searchString.value)
  if (data) {
    const searchForFilter = data[1].replace(':', '').trim().toLowerCase()
    filterSelection.value = props.filterOptions.find((p) => p.text.toLowerCase() === searchForFilter).value
  } else {
    filterSelection.value = ""
  }
}

const createSearchRegex = () => {
  let reString = '(?<=('
  props.filterOptions?.forEach((f, index) => {
    reString = reString.concat('^(', f.text.toLowerCase(), ':)')
    if (index < props.filterOptions?.length - 1) {
      reString = reString.concat('|')
    }
  })
  reString = reString.concat(")).*")
  regexString.value = reString
}

onMounted(() => {
  createSearchRegex()
  filterSelection.value = stickyStore?.projectFilter
  if (filterSelection.value !== '') {
    searchString.value = props.filterOptions.find(f => filterSelection.value === f.value).text.concat(': ')
  }
})

</script>
<style scoped lang="scss">
</style>
