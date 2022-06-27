<template>
  <v-dialog
      v-model="openDialog"
      width="500">
    <v-card>
      <v-card-title
          class="albatross-header-2 lighten-2 pb-1"
          primary-title>
        <slot name="title">
          Delete
        </slot>
      </v-card-title>
      <v-card-text class="albatross-body-1 pb-4 default-text-color">
        <slot>Please select on option.</slot>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
            @click="cancel"
            text
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          <slot name="cancel">Cancel</slot>
        </v-btn>
        <v-btn v-for="(option, index) in options"
            @click="select(index)"
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          {{option}}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: "MultiOptionDialog",
  props: {
    openDialog: Boolean,
    hideTitle:Boolean,
    options:[]
  },
  data() {
    return {
    }
  },
  methods: {
    cancel() {
      this.$emit('cancel')
    },
    select(option){
      this.$emit('option-' + option)
    },
  }
}
</script>

<style lang="scss" scoped>
.align-center {
  align-self: center;
}
</style>
