<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="card-title">
        <slot name="title">
          Confirm
        </slot>
      </v-card-title>

      <v-card-text class="pt-4">
        <slot><p>Are you sure you want to continue without saving?</p></slot>
      </v-card-text>

      <v-card-actions>
        <slot name="actions" v-bind:cancel="cancel" v-bind:ok="ok">
          <AlbatrossButton
              variant="text"
              @click="cancel(false)"
              class="text-capitalize"
              color="unset"
              :text="cancelButtonText"
          ></AlbatrossButton>
          <v-spacer />
          <AlbatrossButton
              color="primary"
              @click="ok(true)"
              class="text-capitalize"
              :text="okButtonText"
          ></AlbatrossButton>
        </slot>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

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
  return new Promise((resolve, reject) => {
    resolve.value = resolve
    reject.value = reject
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

</script>
<style lang="scss" scoped>
.card-title {
  word-break: initial;
}
</style>
