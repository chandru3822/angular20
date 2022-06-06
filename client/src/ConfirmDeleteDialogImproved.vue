<template>
  <v-dialog
      v-model="openConfirmDeleteDialog"
      width="500">
    <v-card>
      <v-card-title
          class="albatross-body-1 lighten-2 pb-1"
          primary-title>
        <slot name="title">
          Delete
        </slot>
      </v-card-title>
      <v-card-text class="albatross-body-2 pb-4">
        <slot></slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
            @click="no"
            class="elevation-2 text-capitalize mr-2 mb-2"
        >
          No
        </v-btn>
        <v-btn
            color="primaryButton"
            class="white--text elevation-2 text-capitalize mr-2 mb-2"
            @click="yes">
          Yes
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "ConfirmDeleteDialogImproved",
  props: {
    openConfirmDeleteDialog: Boolean,
    label: String,
    hideTitle:Boolean
  },
  data() {
    return {
    }
  },
  methods: {
    yes(){
      this.$emit('confirm-delete')
      this.$emit('update:openConfirmDeleteDialog', false)
    },
    no() {
      this.$emit('update:openConfirmDeleteDialog', false)
      this.$emit('closeConfirmDeleteDialog')
    }
  }
}
</script>

<style lang="scss" scoped>
.align-center {
  align-self: center;
}
</style>
