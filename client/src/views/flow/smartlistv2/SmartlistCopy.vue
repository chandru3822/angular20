<template>
  <v-icon @click.stop="copySmartlist">mdi-content-copy</v-icon>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { getSnackbar, handleHidingGlobalLoader, logError, postRequest } from '@/helpers/helpers'
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
  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data, status} = await postRequest(`/smartlistv2/${props.smartlist.id}/copy`)
    const snackbar = getSnackbar('SUCCESS', `Smartlist "${data.name}" was created`)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    handleHidingGlobalLoader(vueInstance, status)
    //@TODO: hand smartlist back to parent
    emit('copied', data)
  } catch (e) {
    logError(e)
    const snackbar = getSnackbar('ERROR', 'Error duplicating smartlist')
    store.commit(AppMutations.SET_LOADING, false)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  }
}
</script>

<style scoped lang="scss">

</style>