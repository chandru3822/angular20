<template>
  <a-btn
    @click.stop="copySmartlist"
    :icon="!showText"
    :variant="showText ? 'text' : ''"
    class="pa-5"
    :disabled="disabled"
    prepend-icon="mdi-content-copy"
    :text="showText ? 'Duplicate' : ''"
  >
  </a-btn>
</template>

<script setup>
import { logError, postRequest } from '@/helpers/helpers'
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
  }
})

const emit = defineEmits(['copied'])

const appStore = useAppStore()

let copySmartlist = async () => {
  try {
    appStore.loading = true
    const {data} = await postRequest(`/smartlist/${props.smartlist.id}/copy`)
    appStore.showSnack('SUCCESS', `Smartlist Duplicated`)
    emit('copied', data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error duplicating smartlist')
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