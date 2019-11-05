<template>
  <div>
    <!-- todo: this needs lots of work, just round 1   -->
    <!-- todo: need to handle modifying and saving field changes   -->
    <div v-if="field.dataTypeId === 1" class="mt-1">
      <div class="field-label">{{field.fieldName}}</div>
      <flat-pickr
          v-model="field.dateValue"
          :config="config"
          class="field-picker"
          placeholder=" "
      ></flat-pickr>
    </div>

    <div v-if="field.dataTypeId === 2" class="mt-1">
      <div class="field-label">{{field.fieldName}}</div>
      <flat-pickr
          v-model="field.timestampValue"
          :config="config"
          class="field-picker"
          placeholder=" "
      ></flat-pickr>
    </div>

    <div v-if="field.dataTypeId === 3">
      <div class="field-label">{{field.fieldName}}</div>
      <input type="checkbox" v-model="field.booleanValue" :readonly="readonly">
    </div>

    <v-text-field v-if="field.dataTypeId === 6 && !field.hasListValues"
                  text
                  :readonly="readonly"
                  :label="field.fieldName"
                  placeholder=" "
                  v-model="field.intValue"
    ></v-text-field>

    <v-text-field v-if="field.dataTypeId === 4"
                  text
                  :readonly="readonly"
                  placeholder=" "
                  :label="field.fieldName"
                  v-model="field.numericValue"
    ></v-text-field>

    <v-text-field v-if="field.dataTypeId === 5"
                  text
                  :readonly="readonly"
                  placeholder=" "
                  :label="field.fieldName"
                  v-model="field.textValue"
    ></v-text-field>

    <v-select v-if="field.dataTypeId === 6 && field.hasListValues"
                  v-model="field.intValue"
                  text
                  placeholder=" "
                  :items="field.listOfValues"
                  :label="field.fieldName"
                  item-value="id"
                  item-text="name"
    ></v-select>

    <v-text-field v-if="field.dataTypeId === 7"
                  text
                  placeholder=" "
                  :readonly="readonly"
                  :label="field.fieldName"
                  v-model="field.intArrayValue"
    ></v-text-field>

    <v-select v-if="field.dataTypeId === 8"
              v-model="field.intValue"
              text
              :items="field.listOfValues"
              :label="field.fieldName"
              placeholder=" "
              item-value="id"
              item-text="name"
    ></v-select>

    <v-select v-if="field.dataTypeId === 9"
              v-model="field.intValue"
              text
              :items="field.listOfValues"
              :label="field.fieldName"
              placeholder=" "
              item-value="id"
              item-text="name"
    ></v-select>
  </div>
</template>

<script>
  export default {
    name: 'CustomValueInput',
    props: {
      readonly: Boolean,
      field: Object
    },
    data () {
      return {
        // todo: allow the component to pass in the format
        // todo: allow the component to pass in readonly value to config.clickOpens
        config: {
          altFormat: 'F j, Y h:i K',
          altInput: true,
          altInputClass: 'field-picker',
          allowInput: false,
          time_24hr: false,
          enableTime: true,
          clickOpens: true
        },
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.field-label {
  font-size: 12px;
}
</style>
<style lang="scss">
  .field-picker {
    border-bottom: solid 1px rgba(0,0,0,0.4);
    height: 27px;
    min-width: 100%;
  }
</style>
