<template>
  <v-icon @click.stop="exportSmartlist">mdi-tray-arrow-down</v-icon>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { getRequest, getSnackbar, logError } from '@/helpers/helpers'
import { DateTime } from 'luxon'
import { saveAs } from 'file-saver'
import { getCurrentInstance } from 'vue'

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  }
})

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

let exportSmartlist = async () => {

  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data} = await getRequest(`/smartlist/${props.smartlist.id}/export`)
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    })
    saveAs(blob, `${props.smartlist.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
  } catch (e) {
    logError(e)
    store.commit(AppMutations.SHOW_SNACK, getSnackbar('ERROR', e.data.message))
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>