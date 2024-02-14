<script>
import useRegisterSW from '@/mixins/useRegisterSW'

// const intervalMS = 5 * 60 * 1000 //5 minutes
const intervalMS = 60 * 60 * 1000 //1 hour

export default {
  name: 'ReloadPrompt',
  mixins: [useRegisterSW],
  data(){
    return {
      loading: false
    }
  },
  methods: {
    doStuff(){
      this.loading = true
      this.updateServiceWorker()
    },
    close(){
      this.$refs.reload.close()
      this.closePromptUpdateSW()
    },
    onOfflineReadyFn(){
      this.$refs.reload.show()
    },
    onNeedRefreshFn() {
      this.$refs.reload.show()
    },
    handleSWManualUpdates(registration){
      if (registration){
        setInterval(()=> registration.update(), intervalMS)
      }
    }
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

    <v-btn
      class="white--text text-capitalize font-weight-bold"
      :loading="loading"
      :disabled="loading"
      color="primary"
      @click.prevent="doStuff()"
    >
      Reload
      <template v-slot:loader>
        <span class="custom-loader">
          <v-icon light>mdi-cached</v-icon>
        </span>
      </template>
    </v-btn>
    <v-btn text
           color="primary"
           class="text-capitalize"
           @click="close">
      Cancel
    </v-btn>
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
