<script setup>
import useRegisterSW from '@/mixins/useRegisterSW'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

// const intervalMS = 5 * 60 * 1000 //5 minutes
const intervalMS = 60 * 60 * 1000 //1 hour
const loading = ref(false)
const reload = ref(null)

const doStuff = () => {
  loading.value = true
  updateServiceWorker()
}
const close = () => {
  reload.value.close()
  closePromptUpdateSW()
}
const onOfflineReadyFn = () => {
  reload.value.show()
}
const onNeedRefreshFn = ()  => {
  reload.value.show()
}
const handleSWManualUpdates = (registration) => {
  if (registration){
    setInterval(()=> registration.update(), intervalMS)
  }
}
</script>

<template>
  <dialog
      ref="reload"
      class="pwa-toast"
  >
    <div class="message">
      <span>
        New content available, click on reload button to update.
      </span>
    </div>

    <AlbatrossButton
        class="text-capitalize font-weight-bold"
        :loading="loading"
        :disabled="loading"
        color="primary"
        @click.prevent="doStuff()"
        text="Reload"
    >
      <template #loader>
        <span class="custom-loader">
          <v-icon light>mdi-cached</v-icon>
        </span>
      </template>
    </AlbatrossButton>
    <AlbatrossButton
        variant="text"
        color="primary"
        class="text-capitalize"
        @click="close"
        text="Cancel"
    ></AlbatrossButton>
  </dialog>
</template>

<style>
.pwa-toast {
  position: fixed;
  right: 0;
  bottom: 0;
  margin: 16px;
  padding: 12px;
  border: 1px solid #8885;
  border-radius: 4px;
  z-index: 1;
  text-align: left;
  box-shadow: 3px 4px 5px 0 #8885;
  background: white;
}
.pwa-toast .message {
  margin-bottom: 8px;
}
.pwa-toast button {
  border: 1px solid #8885;
  outline: none;
  margin-right: 5px;
  border-radius: 2px;
  padding: 3px 10px;
}

.custom-loader {
  animation: loader 1s infinite;
  display: flex;
}
@keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
