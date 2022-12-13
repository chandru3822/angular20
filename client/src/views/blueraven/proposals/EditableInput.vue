<template>
  <div class="editable-input d-flex pa-0 align-center">
    <span v-if="!isEditMode">{{ displayText || name }}</span>
    <v-text-field v-else v-model="name" solo single-line flat autofocus />
    <div v-if="editable">
      <v-btn small icon color="primary" @click="handleEdit" class="pl-2" v-if="editable">
        <v-icon v-if="!isEditMode">mdi-pencil</v-icon>
        <v-icon v-else>mdi-close</v-icon>
      </v-btn>
      <v-btn small icon color="primary" @click="handleSave" v-if="editable && isEditMode" >
        <v-icon>mdi-cloud</v-icon>
      </v-btn>
    </div>
  </div>
</template>
<script>

export default {
  props: {
    value: { type: String, required: true },
    displayText: { type: String },
    editable: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      name: `${this.value}`,
      originalValue: `${this.value}`,
      isEditMode: false,
    }
  },
  watch : {
    value: function(val){
      this.name = `${val}`
      this.originalValue = `${val}`
    }
  },
  methods: {
    handleEdit(evt) {
      if (this.isEditMode === true) {
        this.name = `${this.originalValue}`
        this.$emit('input', { save: false, value: this.originalValue })
      }
      this.isEditMode = !this.isEditMode
    },
    handleSave(evt) {
      this.$emit('input', { save: true, value: this.name.trim() })
      this.isEditMode = false
    }
  }
}
</script>
<style lang="scss">
.editable-input .v-text-field__details {
  display: none;
}
</style>
