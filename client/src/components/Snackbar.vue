<template>
  <v-snackbar
      id="app-snackbar"
      v-model="show"
      :bottom="snackbar.y === 'bottom'"
      :left="snackbar.x === 'left'"
      :multi-line="snackbar.mode === 'multi-line'"
      :right="snackbar.x === 'right'"
      :timeout="snackbar.timeout"
      :top="snackbar.y === 'top'"
      :color="snackbar.color"
      :class="snackbar.fontClass"
      :vertical="snackbar.mode === 'vertical'"
      class="pt-15"
  >
    <div v-if="snackbar.displayAsHtml" v-html="snackbar.text"></div>
    <span v-else>{{ snackbar.text }}</span>

    <template v-slot:action="{ attrs }">
      <a-btn
          v-if="snackbar.showBtn"
          variant="text"
          color="white"
          v-bind="attrs"
          @click="show = false"
          prepend-icon="clear"
      ></a-btn>
    </template>
  </v-snackbar>
</template>

<script setup>
import { ref } from 'vue'
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const snackbar = ref({})
const show = ref(false)

appStore.$subscribe((mut, state) => {
  if (state.snack.show) {
    snackbar.value = state.snack
    show.value = true
    appStore.snack.show = false
  }
})
</script>

<style scoped lang="scss">
#app-snackbar {
  z-index: 1002 !important;
}
</style>
