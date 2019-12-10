<template>
<v-container id="container">
  <v-row class="align-center">
    <v-col>
      <h3>{{ group.groupName }}</h3>
    </v-col>
    <v-col class="d-flex justify-end">
      <v-btn
        @click="isEditMode = !isEditMode"
      >{{ isEditMode ? 'Cancel' : 'Edit'}}</v-btn>
    </v-col>
  </v-row>
  <v-row>
    <v-col>
      <v-card>
        <v-row>
          <template v-for="(field, index) in group.customFieldValues">
            <v-col cols="6" md="3">{{ field.fieldName}}</v-col>
            <v-col cols="6" md="3">
              <CustomValueInput v-if="isEditMode" :field="field" :readonly="false"/>
              <template v-else>{{ getDisplayValue(field) }}</template>
            </v-col>
          </template>
        </v-row>
      </v-card>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import CustomValueInput from "@/views/flow/components/CustomValueInput";

export default {
  name: "ProcessStepFieldGroup",
  components: {CustomValueInput},
  props: {
    group: Object
  },
  data () {
    return {
      isEditMode: false
    }
  },
  methods: {
    getDisplayValue: function (field) {

      let displayValue = null

      switch (field.dataTypeId) {
        case 1:
          displayValue = field.dateValue
          break
        case 2:
          displayValue = field.timestampValue
          break
        case 3:
          displayValue = field.booleanValue
          break
        case 4:
          displayValue = field.numericValue
          break
        case 5:
          displayValue = field.textValue
          break
        case 6:
          displayValue = field.intValue
          break;
        case 7:
          displayValue = field.intArrayValue
          break;
        default:
          displayValue = 'N/A'
      }

      return displayValue
    }
  }
}
</script>

<style scoped lang="scss">
#container {

}
</style>
