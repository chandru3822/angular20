<template>
  <v-dialog
      v-model="openDialog"
      width="500">
    <template #activator="{ on }">
      <v-tooltip top v-if="showTooltip">
        <template v-slot:activator="{ on: tooltip }">
          <div v-on="{ ...tooltip }" class="d-inline-block">
            <v-btn v-if="textbutton" color="brRed" class="white--text py-1 px-2" small v-on="on" :disabled="isDisabled">
              Delete
            </v-btn>
            <v-btn v-else small text v-on="on" :disabled="isDisabled">
        <v-icon>delete</v-icon>
      </v-btn>
          </div>
        </template>
            <span>{{tooltipText}}</span>
      </v-tooltip>
      <v-btn v-else-if="textbutton"
             color="brRed"
             class="white--text py-1 px-2"
             small v-on="on" :disabled="isDisabled">
        Delete
      </v-btn>
      <v-btn v-else small text v-on="on" :disabled="isDisabled">
        <v-icon>delete</v-icon>
      </v-btn>
    </template>
    <v-card>
      <v-card-title
          class="albatross-header-2 lighten-2"
          primary-title>
        Delete
      </v-card-title>
      <v-card-text class="albatross-body-1">
      Are you sure you want to delete {{label}}<strong>{{ itemToDelete}}</strong>?
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
  name: "ConfirmDeleteDialog",
  props: {
    label: String, //Dialog will say "Are you sure you want to delete {{label}}: {{itemToDelete}}?"
    itemToDelete: String,
    isDisabled: Boolean, //optional if you want to disable the icon that opens the dialog
    showTooltip: Boolean,
    tooltipText: String,
    textbutton: Boolean
  },
  data() {
    return {
      openDialog: false
    }
  },
  methods: {
    yes(){
      this.$emit('confirm-delete')
      this.openDialog = false
    },
    no() {
      this.openDialog = false
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
