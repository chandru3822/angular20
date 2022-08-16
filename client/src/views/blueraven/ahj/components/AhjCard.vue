<template>
  <v-card>
  <v-card-title class="primary white--text albatross-subtitle-1 title-with-icon" @click="expanded = !expanded">
    {{title}}
    <v-icon class="white--text">{{expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
  </v-card-title>
  <v-card-text v-if="expanded" class="pa-4">
    <div v-for="field in group" :key="field.id" class="mb-3">
      <CustomValueInput
          :callback="(field) => updateDirtyValue(field)"
          :readonly="!userCanEdit"
          :required="field.required"
          :showFieldName="false"
          :field="field"
          :filled-style="true"
      />
    </div>

  </v-card-text>
  </v-card>
</template>

<script>
import CustomValueInput from "@/views/flow/components/CustomValueInput";

export default {
  name: "AhjCard",
  components: {
    CustomValueInput
  },
  props: {
    title: String,
    group: Array,
    userCanEdit: Boolean

  },
  data: () => ({
    expanded: false
  })
}
</script>

<style lang="scss" scoped>
.title-with-icon {
  display: flex;
  justify-content: space-between;

  .v-icon {
    cursor: pointer;
  }
}
</style>
