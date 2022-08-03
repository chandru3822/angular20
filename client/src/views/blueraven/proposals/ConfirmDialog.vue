<template>
  <v-dialog v-model="dialog" width="500">
    <v-card>
      <v-card-title class="card-title">
        <slot name="title">
          Confirm
        </slot>
      </v-card-title>

      <v-card-text class="pt-4">
        <slot><p>Are you sure you want to continue without saving?</p></slot>
      </v-card-text>

      <v-card-actions>
        <slot name="actions" v-bind:cancelFn="cancel" v-bind:okFn="ok">
          <v-btn
            text
            @click="cancel"
            class="text-capitalize"
          >
            {{ cancelButtonText }}
          </v-btn>
          <v-spacer />
          <v-btn
            color="primary"
            @click="ok"
            class="text-capitalize"
            dark
          >
            {{ okButtonText }}
          </v-btn>
        </slot>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
export default {
  props: {
    cancelButtonText: {
      type: String,
      default: 'No'
    },
    okButtonText: {
      type: String,
      default: 'Yes'
    }
  },
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
<style lang="scss" scoped>
.card-title {
  word-break: initial;
}
</style>
