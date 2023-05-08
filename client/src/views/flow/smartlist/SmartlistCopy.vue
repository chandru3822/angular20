<template>
  <v-btn
    @click.stop="copySmartlist"
    :icon="!showText"
    :text="showText"
    class="pa-5"
    :disabled="disabled"
  >
    <v-icon >mdi-content-copy</v-icon>
    <span v-if="showText">Duplicate</span>
  </v-btn>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { getSnackbar, logError, postRequest } from '@/helpers/helpers'
import { getCurrentInstance } from 'vue'

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