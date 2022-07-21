<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="text-h5 grey lighten-2" primary-title>
        <slot name="title">
          Confirm
        </slot>
      </v-card-title>

      <v-card-text class="pt-4">
        <slot>Are you sure?</slot>
      </v-card-text>

      <v-divider />

      <v-card-actions>
        <v-btn
          text
          @click="cancel"
        >
          No
        </v-btn>
        <v-spacer />
        <v-btn
          color="primary"
          @click="ok"
          dark
        >
          Yes
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
export default {
  data() {
    return {
      dialog: false,
      resolve: null,
      reject: null
    }
  },
  methods: {
    open() {
      this.dialog = true
      return new Promise((resolve, reject) => {
        this.resolve = resolve
        this.reject = reject
      })
    },
    ok() {
      this.resolve(true)
      this.dialog = false
    },
    cancel() {
      this.resolve(false)
      this.dialog = false
    }
  }
}
</script>
