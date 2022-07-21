<template>
  <v-dialog
    v-model="show"
    width="500"
  >
    <v-card>
      <v-card-title
          class="albatross-header-2 lighten-2 pb-1"
          primary-title>
        <slot name="title">
          Delete
        </slot>
      </v-card-title>
      <v-card-text class="albatross-body-1 pb-4 default-text-color">
        <slot>Are you sure you want to delete?</slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          @click.native="no"
            text
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          <slot name="no">Cancel</slot>
        </v-btn>
        <v-btn
            color="primary"
            class="white--text elevation-2 text-capitalize mr-2 mb-2"
            :disabled="disableConfirm"
            @click="yes">
          <slot name="yes">Delete</slot>
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "ConfirmationDialog",
  props: {
    openDialog: Boolean,
    hideTitle:Boolean,
    itemToDelete: Object,
    disableConfirm: Boolean
  },
  data() {
    return {
    }
  },
  computed: {
    show: {
      get () {
        return this.openDialog
      },
      set (value) {
        this.$emit('close-dialog', value)
      }
    }
  },
  methods: {
    yes(){
      this.$emit('confirm')
      this.show=false
    },
    no() {
      this.$emit('close-dialog', false)
      this.show=false
    }
  }
}
</script>

<style lang="scss" scoped>
.align-center {
  align-self: center;
}
</style>
