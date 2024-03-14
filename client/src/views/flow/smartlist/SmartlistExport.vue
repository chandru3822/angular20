<template>
  <v-btn
    @click.stop="exportSmartlist"
    :icon="!showText"
    :text="showText"
    class="pa-5"
    :disabled="disabled"
  >
    <v-icon>mdi-tray-arrow-down</v-icon>
    <span v-if="showText">Export</span>
  </v-btn>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { getRequestWithParams, getSnackbar, logError } from '@/helpers/helpers'
import { DateTime } from 'luxon'
import { saveAs } from 'file-saver'
import { getCurrentInstance } from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  },
  showText: {
    type: Boolean,
    required: false,
    default: false
  },
  disabled: {
    type: Boolean,
    required: false,
    default: false
  }
})

const emit = defineEmits(['exported'])

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()

let exportSmartlist = async () => {

  try {
    appStore.loading = true
    const params = {timezone: userStore.timezone.value}
    const {data} = await getRequestWithParams(`/smartlist/${props.smartlist.id}/export`, {params})
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    })
    saveAs(blob, `${props.smartlist.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`)
    emit('exported')
  } catch (e) {
    logError(e)
    store.commit(AppMutations.SHOW_SNACK, getSnackbar('ERROR', e.data.message))
  } finally {
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>
