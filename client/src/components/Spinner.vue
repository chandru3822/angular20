<template>
  <v-row class="spinner-row">
    <v-col cols="12" class="spinner-container">

  <!--    <img v-if="spinnerUrl" :src="require(spinnerUrl)" width="300" height="300"/>-->
    </v-col>
    <v-img v-if="spinnerUrl" name="spinnerImg"
           class="custom-spinner-icon abs-position-spinner"
           alt="spinner-image" :src="spinnerUrl"></v-img>
    <v-progress-circular
        indeterminate
        v-else
        class="abs-position-spinner spinner-opacity"
        :size="size"
        :color="spinnerColor"
    ></v-progress-circular>
  </v-row>
</template>

<script setup>
import { toRefs, computed } from 'vue'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()

const props = defineProps({
  spinnerColor: String,
  size: Number
})
const { spinnerColor, size } = toRefs(props)

const spinnerUrl = computed(() => {
  return appStore.spinnerUrl || null
})

</script>

<style scoped lang="scss">
.spinner-container {
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  background-color: var(--v-secondary-base);
  opacity: .5;
}

.abs-position-spinner {
  position: absolute;
  top: 50%;
  left: 50%;
  z-index: 1001;
  transform: translate(-50%, -50%);
}

.spinner-opacity {
  opacity: .8;
}

.custom-spinner-icon {
  max-height: 300px;
  max-width: 300px;
}
</style>
