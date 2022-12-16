<template>
  <fragment>
    <v-icon @click.stop="showDialog = true">mdi-delete</v-icon>

    <ConfirmationDialog
      :parent-close="true"
      :open-dialog="showDialog"
      @confirm="deleteSmartlist"
      @close-dialog="showDialog = false"
    >
      Do you want to delete this smartlist?
    </ConfirmationDialog>
  </fragment>
</template>

<script setup>
import { AppMutations } from '@/stores/AppStore'
import { deleteRequest, getSnackbar, logError } from '@/helpers/helpers'
import { getCurrentInstance, ref } from 'vue'
import ConfirmationDialog from '@/ConfirmationDialog.vue'
import { Fragment } from 'vue-frag'

const props = defineProps({
  smartlistId: {
    type: Number,
    required: true
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