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
  >
    <div v-if="snackbar.displayAsHtml" v-html="snackbar.text"></div>
    <span v-else>{{ snackbar.text }}</span>

    <template v-slot:action="{ attrs }">
      <v-btn text v-bind="attrs"
             @click="show = false">
        <v-icon color="secondary">clear</v-icon>
      </v-btn>
    </template>
  </v-snackbar>
</template>

<script setup>
import { getCurrentInstance, ref } from 'vue'
import { useAppStore } from '@/stores/AppStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const appStore = useAppStore()

const snackbar = ref({})
const show = ref(false)

appStore.$subscribe((mut, state) => {
  if (state.snack.show) {
    snackbar.value = state.snack
    show.value = true
  }
})

//@TODO: subscribe to the old app store until pinia takes over, then remove this
store.subscribe((mutation, state) => {
  if (mutation.type === "SHOW_SNACK") {
    snackbar.value = state.app.snack
    show.value = true
  }
});
</script>

<style scoped lang="scss">
#app-snackbar {
  z-index: 1002 !important;
}
</style>
