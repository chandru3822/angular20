<template>
  <v-main>
    <v-container>
      <v-tabs class="tabs-bar">
        <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
               class="text-capitalize ma-0 label-medium">
          {{ tab.label }}
        </v-tab>
      </v-tabs>

      <router-view/>
    </v-container>
  </v-main>
</template>

<script setup>
import {onMounted, ref} from 'vue'

onMounted(() => {
  // processBtn()
})

const tabs = ref([
  {
    label: 'V-BTN',
    path: `/vue3/vbtn`,
  },
  {
    label: 'DATA',
    path: `/vue3/data`,
  },
  {
    label: 'FILE',
    path: `/vue3/file`,
  }

])

</script>
