<template>
  <v-row id="side-panel-expansion-panel-container" class="mx-6">
    <v-col cols="12" lg="12" class="text-left py-0 px-0">
      <v-expansion-panels flat class="py-0" :value="sectionExpanded ? 0 : null">
        <v-expansion-panel @click="$emit('click')">
          <v-expansion-panel-header color="transparent" :hide-actions="isDisabled" :disabled="isDisabled" flat class="px-0 project-section-header" height="auto" :class="{'pt-0': removeHeaderPadding}">
            <div class="label-large">{{header}}</div>
            <v-spacer></v-spacer>
            <slot name="tool-btn"></slot>
          </v-expansion-panel-header>
          <v-expansion-panel-content cols="12" class="py-0 pb-4">
            <SpinnerInline v-if="isLoading" centered :size="20" color="primary"/>
            <slot name="expanded-content" class="px-0" v-else>Nothing to see here.</slot>
          </v-expansion-panel-content>
        </v-expansion-panel>
      </v-expansion-panels>
    </v-col>
  </v-row>
</template>

<script setup>
import SpinnerInline from '@/components/SpinnerInline'
import { toRefs } from 'vue'


const props = defineProps({
  header: String,
  sectionExpanded: {
    type: Boolean,
    default: false
  },
  isDisabled: {
    type: Boolean,
    default: false
  },
  isLoading: Boolean,
  removeHeaderPadding: {
    type: Boolean,
    default: false
  }
})
const { header, sectionExpanded, isDisabled, isLoading, removeHeaderPadding } = toRefs(props)

</script>

<style lang="scss" scoped>
</style>

<style lang="scss">
#side-panel-expansion-panel-container div.v-expansion-panel-content__wrap{
  padding:0;
}
</style>
