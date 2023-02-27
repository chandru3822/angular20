<template>
  <v-icon @click.stop="copySmartlist">mdi-content-copy</v-icon>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { getSnackbar, logError, postRequest } from '@/helpers/helpers'
import { getCurrentInstance } from 'vue'

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['copied'])

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


let copySmartlist = async () => {

  let snackbar

  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data} = await postRequest(`/smartlist/${props.smartlist.id}/copy`)
    snackbar = getSnackbar('SUCCESS', `Smartlist Duplicated`)
    emit('copied', data)
  } catch (e) {
    logError(e)
    snackbar = getSnackbar('ERROR', 'Error duplicating smartlist')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  }
}
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>