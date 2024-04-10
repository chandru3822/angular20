<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="card-title">
        <slot name="title"> Confirm </slot>
      </v-card-title>

      <v-card-text class="pt-4">
        <slot><p>Are you sure you want to continue without saving?</p></slot>
      </v-card-text>

      <v-card-actions>
        <slot name="actions" v-bind:cancel="cancel" v-bind:ok="ok">
          <a-btn
            variant="text"
            @click="cancel(false)"
            class="text-capitalize"
            color="unset"
            :text="cancelButtonText"
          ></a-btn>
          <v-spacer />
          <a-btn
            color="primary"
            @click="ok(true)"
            class="text-capitalize"
            :text="okButtonText"
          ></a-btn>
        </slot>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script setup>
import { toRefs, ref, defineExpose } from 'vue'

const props = defineProps({
  cancelButtonText: {
    type: String,
    default: 'No'
  },
  okButtonText: {
    type: String,
    default: 'Yes'
  }
})
const { cancelButtonText, okButtonText } = toRefs(props)

const dialog = ref(false)
const resolve = ref(null)
const reject = ref(null)

const open = () => {
  dialog.value = true
  return new Promise((res, rej) => {
    resolve.value = res
    reject.value = rej
  })
}
const ok = (value = true) => {
  resolve.value({ ok: true, value })
  dialog.value = false
}
const cancel = (value = false) => {
  resolve.value({ ok: false, value })
  dialog.value = false
}

defineExpose({ open })
</script>

<style lang="scss" scoped>
.card-title {
  word-break: initial;
}
</style>
