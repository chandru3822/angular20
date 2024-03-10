<!--This is a wrapper around the dropdown filters on the Users page-->
<!--It adds a 'Select All' option to each of the dropdowns-->
<template>
  <v-autocomplete v-model="selectedItems"
                  :items="items"
                  item-value="id"
                  item-text="name"
                  multiple
                  placeholder="Select..."
                  height="35px"
                  outlined
                  class="user-filter-select"
                  @input="updateList"
  >
    <v-list-item
      slot="prepend-item"
      ripple
      @click="toggleAll"
    >
      <v-list-item-action>
        <v-checkbox v-model="checkboxStatus" :indeterminate="getCheckboxStatus"></v-checkbox>
      </v-list-item-action>
      <v-list-item-title>Select All</v-list-item-title>
    </v-list-item>
    <v-divider
      slot="prepend-item"
      class="mt-2"
    ></v-divider>
    <template
      slot="selection"
      slot-scope="{ item, index }"
    >
      <v-chip small v-if="index === 0 && selectedItems.length < 2">
        <span>{{ item.name }}</span>
      </v-chip>
      <span
        v-if="index === 1 && selectedItems.length >= 2"

      >{{ selectedItems.length }} selected</span>
    </template>
  </v-autocomplete>
</template>


<script setup>
import {computed, onUpdated, ref} from 'vue'

  const props = defineProps({
    items: {
      type: Array,
      required: true,
    },
    defaultCheckedItems: {
      type: Array,
      required: false,
      default() {
        return []
      },
    },
    hasDefault: {
      type: Boolean,
      required: false,
      default: false,
    }
  })
  const emit = defineEmits(['list-updated'])
  const selectedItems = ref([])
  const checkboxStatus = ref(false)
  const updateOnce = ref(false)
  const updateList = function () {
    emit('list-updated', selectedItems.value)
  }
  const toggleAll = function() {
    if (selectedItems.value.length === props.items.length) {
      selectedItems.value = []
    } else {
      selectedItems.value = []
      props.items.forEach((item) => selectedItems.value.push(item.id))
    }
    emit('list-updated', selectedItems.value)
  }

  const getCheckboxStatus = computed(() => {
    return selectedItems.value.length > 0
  })


  onUpdated(() => {
    if (props.hasDefault && !updateOnce.value && props.defaultCheckedItems.length > 0) {
      selectedItems.value = props.defaultCheckedItems
      updateOnce.value = true
    }
  })
</script>

<style scoped lang="scss">
  .user-filter-select,
  .user-filter-select .v-input__control,
  .user-filter-select .v-input__control .v-input__slot,
  .user-filter-select .v-input__control .v-input__slot fieldset {
    height: 40px !important;
    min-height: 40px !important;
  }
  .user-filter-select .v-select__selections {
    padding: 0 0 5px 0 !important;
    height: 40px !important;
  }
  .user-filter-select .v-input__append-inner {
    margin-top: 5px !important;
  }
</style>
