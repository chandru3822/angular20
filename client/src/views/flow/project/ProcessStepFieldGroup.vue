<template>
<v-container>
  <v-row class="align-center">
    <v-col>
      <h3>{{ group.groupName }}</h3>
    </v-col>
    <v-col class="d-flex justify-end">
      <v-btn @click="isEditMode = !isEditMode">{{ isEditMode ? 'Cancel' : 'Edit'}}</v-btn>
      <v-btn v-if="isEditMode" @click="save">Save</v-btn>
    </v-col>
  </v-row>
  <v-row class="valueContainer elevation-2">
    <v-col cols="12" lg="6" v-for="(field, index) in group.customFieldValues" :key="index">
      <CustomValueInput :field="field" :readonly="!isEditMode"/>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import CustomValueInput from '@/views/flow/components/CustomValueInput'

export default {
  name: "ProcessStepFieldGroup",
  components: {CustomValueInput},
  props: {
    group: Object,
    onSaveHandler: Function
  },
  data () {
    return {
      isEditMode: false
    }
  },
  methods: {
    save: function () {
      this.isEditMode = !this.isEditMode
      this.onSaveHandler()
    }
  }
}
</script>

<style scoped lang="scss">
.valueContainer {
  background-color: #fff;
}
</style>
