<template>
  <v-container class="pa-0">
    <v-row class="pa-0">
      <v-col xl="1" lg="2" md="2" sm="3" xs="3">
        <v-autocomplete
          label="Filter"
          :items="props.filterOptions"
          v-model="filterSelection"
          clearable
          @input="debounceSyncSearchBar()"
        />
      </v-col>
      <v-col xl="11" lg="10" md="10" sm="9" xs="9">
        <v-text-field
          ref="focusSearchBar"
          prepend-inner-icon="search"
          clearable
          label="Search projects..."
          v-model="searchString"
          @input="debouncedSyncFilter"
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted, defineProps, getCurrentInstance } from "vue";
import debounce from "lodash.debounce";

const emit = defineEmits(['updateQuery'])
const filterSelection = ref('')
const searchString = ref('')
const regexString = ref('')
const props = defineProps(
  {
    filterOptions: Array
  }
)

const vueInstance = getCurrentInstance().proxy

const debounceSyncSearchBar = debounce(() => {
  syncSearchBar()
}, 500)

const syncSearchBar = () => {
  // update search bar based on filter input
  if (filterSelection.value) {
    searchString.value = props.filterOptions.find(f => filterSelection.value === f.value).text.concat(': ')
  }
  vueInstance.$nextTick(() => vueInstance.$refs.focusSearchBar.focus())
}


const debouncedSyncFilter = debounce(() => {
  syncFilter()
  let found
  if (searchString.value) {
    found = searchString.value.match(regexString.value)
  }
  if (found)
    emit('updateQuery', searchString.value.match(regexString.value)[0].trim(), searchString.value.match(regexString.value)[1].trim())
  else {
    emit('updateQuery', searchString.value, '')
  }
}, 500)

const syncFilter = () => {
  // update filter based on searchBar input
  const re = new RegExp(regexString.value)
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
  props.filterOptions.forEach((f, index) => {
    reString = reString.concat('^(', f.text, ':)')
    if (index < props.filterOptions.length - 1) {
      reString = reString.concat('|')
    }
  })
  reString = reString.concat(")).*")
  regexString.value = reString
}

onMounted(() => {
  createSearchRegex()
})

</script>
<style scoped lang="scss">
</style>
