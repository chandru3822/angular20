<template>
  <v-autocomplete v-model="selected"
                  :items="items"
                  item-value="id"
                  item-text="name"
                  multiple
                  placeholder="Select..."
                  height="35px"
                  outlined
                  class="py-5"
                  @input="updateList"
  >
  </v-autocomplete>
</template>


<script setup>
  import {ref} from 'vue'

  const props = defineProps({
    items: {
      type: Array,
      required: true,
    }
  })
  const emit = defineEmits(['listUpdated'])
  const selected = ref([])

  const updateList = function () {
    console.log("About to Emit")
    emit('listUpdated', selected.value)
    console.log("Emitted :)")
  }


</script>

<style scoped lang="scss">

</style>
