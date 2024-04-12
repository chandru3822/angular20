<template>
  <v-dialog
      class="confirmation-dialog"
      v-model="show"
      :retain-focus="retainFocus"
      :width="width || 500"
      @click:outside="no"
      id = "dialogBox"
      ref="dialogBox"
  >
    <v-card>
      <v-card-title
          class="albatross-header-2 lighten-2 pb-1"
          :class="{'primary-custom-bg white--text' : primaryHeader}"
          primary-title>
        <slot v-if="!hideTitle" name="title">
          Delete
        </slot>
      </v-card-title>
      <v-card-text class="albatross-body-1 pb-4 default-text-color">
        <slot>Are you sure you want to delete?</slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <a-btn
            @click.native="no"
            variant="text"
            id="qa-confirmation-dialog-no"
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          <template #default>
            <slot name="no">Cancel</slot>
          </template>
        </a-btn>
        <a-btn
            v-if="!hideConfirm"
            color="primary"
            class="elevation-2 text-capitalize mr-2 mb-2"
            :disabled="disableConfirm"
            id="qa-confirmation-dialog-yes"
            :class="confirmClass"
            @click="yes"
        >
          <template #default>
            <slot name="yes">Delete</slot>
          </template>
        </a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
/**
 * The confirmation dialog that should be used throughout the application
 * @author jkburnett
 */

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  openDialog: Boolean, //used by parent to open the dialog
  hideTitle:Boolean, //set true if dialog should not have a title
  retainFocus:Boolean, //sets retain-focus on v-dialog component
  itemToDelete: Object, // @deprecated
  disableConfirm: Boolean, //allows parent to perform validation before allowing user to confirm
  hideConfirm: Boolean, // hides confirmation btn when only 'close' or 'cancel' is needed
  confirmClass: String, //allows parent to control appearance of confirmation btn
  width: Number, //width of the dialog
  parentClose: Boolean, //set to true when validation needed before closing a dialog on confirm
  primaryHeader: Boolean, //if set to true, header will have primary color background and white text instead of vice versa
})
const { openDialog, hideTitle, retainFocus, itemToDelete, disableConfirm, hideConfirm,
  confirmClass, width, parentClose, primaryHeader } = toRefs(props)

const emit = defineEmits(['cancel', 'close-dialog', 'confirm'])

const show = computed(() => {
  return openDialog.value
})

const yes = () => {
  emit('confirm')
  if(!parentClose.value) {
    emit('close-dialog', false)
  }
}

const no = ()  => {
  emit('cancel')
  emit('close-dialog', false)
}
</script>

<style lang="scss" scoped>
.align-center {
  align-self: center;
}

.v-card__actions{
  flex-wrap: wrap;
  justify-content: right;
}
</style>
