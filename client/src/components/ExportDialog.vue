<template>
<v-dialog
    v-model="show"
    width="500"
>
    <v-card>
        <v-card-title>
            Export
        </v-card-title>

        <v-card-text>
            You are attempting to export {{ totalItems | currency('', 0)}} results.
            This can take a few minutes.
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
            <div class="flex-grow-1"></div>
          <a-btn
              color="grey"
              variant="text"
              @click="$emit('cancel')"
              text="Cancel"
          ></a-btn>
          <a-btn
              color="primary"
              variant="text"
              @click="$emit('confirm')"
              text="Continue"
          ></a-btn>
        </v-card-actions>
    </v-card>
</v-dialog>
</template>

<script setup>

import { toRefs } from 'vue'

const props = defineProps({
  show: {
      type: Boolean,
      default: false
  },
  totalItems: Number
})
const { show, totalItems } = toRefs(props)
</script>
