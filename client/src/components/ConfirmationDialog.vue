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
        <v-btn
          @click.native="no"
            text
            color="primary"
            class="text-capitalize mr-2 mb-2"
        >
          <slot name="no">Cancel</slot>
        </v-btn>
        <v-btn
            v-if="!hideConfirm"
            color="primary"
            class="white--text elevation-2 text-capitalize mr-2 mb-2"
            :disabled="disableConfirm"
            :class="confirmClass"
            @click="yes">
          <slot name="yes">Delete</slot>
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
/**
 * The confirmation dialog that should be used throughout the application
 * @author jkburnett
 */
export default {
  name: "ConfirmationDialog",
  props: {
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
        // this.$emit('close-dialog', value)
      }
    }
  },
  created(){},
  methods: {
    yes(){
      this.$emit('confirm')
      if(!this.parentClose) {
        this.$emit('close-dialog', false)
      }
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

.v-card__actions{
  flex-wrap: wrap;
  justify-content: right;
}
</style>
