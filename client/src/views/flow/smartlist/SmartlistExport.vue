<template>
  <a-btn
    @click.native.stop="exportSmartlist"
    :icon="!showText"
    :variant="showText ? 'text' : ''"
    class="pa-5"
    id="qa-smartlist-export"
    prepend-icon="mdi-tray-arrow-down"
    :disabled="disabled"
    :text="showText ? 'Export' : ''"
  >
  </a-btn>
</template>

<script setup>
import { getRequestWithParams, logError } from '@/helpers/helpers'
import { DateTime } from 'luxon'
import { saveAs } from 'file-saver'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'

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
  },
  timezone: {
    type: String,
    required: false,
    default: null,
  }
})

const emit = defineEmits(['exported'])

const userStore = useUserStore()
const appStore = useAppStore()

let exportSmartlist = async () => {
  let timezone = props.timezone
  if (props.timezone === null) {
    timezone = userStore.timezone.value
  }
  try {
    appStore.loading = true
    const params = {timezone: timezone}
    const {data} = await getRequestWithParams(`/smartlist/${props.smartlist.id}/export`, {params})
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    })
    saveAs(blob, `${props.smartlist.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`)
    emit('exported')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', e.data.detail)
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
