<template>
  <v-dialog
    v-model="openDialog"
    :width="500"
    persistent
  >
    <v-card>
      <v-card-title>
        Share Smartlist
      </v-card-title>

      <v-card-text>
        Share stuff here
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click.native="emit('closed-dialog')"
          text
          color="primary"
          class="text-capitalize mr-2 mb-2"
        >
           Cancel
        </v-btn>
<!--        <v-btn-->
<!--          v-if="!hideConfirm"-->
<!--          color="primary"-->
<!--          class="white&#45;&#45;text elevation-2 text-capitalize mr-2 mb-2"-->
<!--          :disabled="disableConfirm"-->
<!--          :class="confirmClass"-->
<!--          @click="yes">-->
<!--          Share-->
<!--        </v-btn>-->
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>

import { getRequest } from '@/helpers/helpers'
import { ref } from 'vue'

const props = defineProps({
  openDialog: {
    type: Boolean,
    required: true
  },
  smartlist: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['closed-dialog'])

let sharables = ref([])

let getSharables = async () => {
  const {data} = await getRequest(`/smartlist/sharableEntities`)
  sharables.value = data
}

getSharables()
</script>

<style scoped lang="scss">

</style>