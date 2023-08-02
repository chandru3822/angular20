<template>
<v-btn
  @click.stop="showDialog = true"
  :icon="!showText"
  :text="showText"
  class="pa-5"
  :disabled="!smartlistId || disabled"
>
  <v-icon>mdi-delete</v-icon>
  <span v-if="showText">Delete</span>

  <ConfirmationDialog
    v-if="showDialog"
    :parent-close="true"
    :open-dialog="showDialog"
    @confirm="deleteSmartlist"
    @close-dialog="showDialog = false"
  >
    Do you want to delete this smartlist?
  </ConfirmationDialog>
</v-btn>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { deleteRequest, getSnackbar, logError } from '@/helpers/helpers'
import { getCurrentInstance, ref } from 'vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const props = defineProps({
  smartlistId: {
    required: true,
    validator(value) {
      //'undefined' might be passed in from the editor (due to it being a route param) and we want to allow this

      if (value === null) {
        return false
      }

      if (typeof value === 'undefined') {
        return true
      }

      return Number.isInteger(value)
    }
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

const emit = defineEmits(['deleted'])

let showDialog = ref(false)

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

let deleteSmartlist = async () => {

  let snackbar

  try {
    store.commit(AppMutations.SET_LOADING, true)
    await deleteRequest(`/smartlist/${props.smartlistId}`)
    snackbar = getSnackbar('SUCCESS', 'Smartlist Deleted')
    emit('deleted')
  } catch (e) {
    logError(e)
    snackbar = getSnackbar('ERROR', 'Unable to delete smartlist')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    showDialog.value = false
  }
}
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>