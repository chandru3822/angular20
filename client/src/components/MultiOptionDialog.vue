<template>
  <v-dialog
      v-model="openDialog"
      width="500">
    <v-card>
      <v-card-title
          class="albatross-header-2 lighten-2 pb-1"
          primary-title>
        <slot name="title">
          Delete
        </slot>
      </v-card-title>
      <v-card-text class="albatross-body-1 pb-4 default-text-color">
        <slot>Please select on option.</slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <AlbatrossButton
            @click="cancel"
            variant="text"
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          <slot name="cancel">Cancel</slot>
        </AlbatrossButton>
        <AlbatrossButton
            v-for="(option, index) in options"
            @click="select(index)"
            color="primary"
            class="text-capitalize mr-2 mb-2"
            :text="option"
        ></AlbatrossButton>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import {getCurrentInstance, toRefs, computed, ref, onMounted, watch} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  openDialog: Boolean,
  hideTitle: Boolean,
  options: Array

})
const {openDialog, hideTitle, options} = toRefs(props)


const cancel = () => {
  vueInstance.$emit('cancel')
}
const select = (option) => {
  vueInstance.$emit('option-' + option)
}
</script>

<style lang="scss" scoped>
.align-center {
  align-self: center;
}
</style>
