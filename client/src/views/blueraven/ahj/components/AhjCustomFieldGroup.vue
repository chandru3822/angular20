<template>
  <v-card>
  <v-card-title class="primary white--text albatross-subtitle-1 title-with-icon" @click="toggleCollapseExpand">
    {{group.groupName}}
    <v-icon class="white--text">{{expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
  </v-card-title>
  <v-card-text v-if="expanded" class="px-4 pt-4 pb-1">
    <div v-if="!group || !group.customFieldValues || group.customFieldValues.length === 0" class="centered default-text-color">No fields available</div>
    <div v-for="field in group.customFieldValues" :key="field.id" class="mb-5">
      <CustomValueInput
          :callback="(field) => callback(field)"
          :readonly="!userCanEdit"
          :required="field.required"
          :showFieldName="false"
          :field="field"
          hide-details
          :filled-style="true"
          :lock-feature="true"
          :copy-feature="true"
      />
      <v-textarea v-if="showOtherField(field.intValue, field.listOfValues)"
                  v-model="field.textValue"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  @change="[field.valueWasChanged = true, callback(field)]"
                  label="Other Value"
                  filled
                  hide-details
                  auto-grow
                  :rows="1"
                  class="other-field override-readonly-font-color mt-3"
      ></v-textarea>
    </div>
    <div v-if="!!hardcodedDocs && !!hardcodedDocs.get(group.id)">
      <AhjCard :title="hardcodedDocs.get(group.id).title">
      <AhjAttachments
          :attachments="hardcodedDocs.get(group.id).documents"
          :attachment-types="[{attachmentTypeId:hardcodedDocs.get(group.id).attachmentTypeId, attachmentType: hardcodedDocs.get(group.id).attachmentType}]"
          :user-can-edit="userCanEdit"
          :source-id="sourceId"
      ></AhjAttachments>
      </AhjCard>
    </div>

  </v-card-text>
  </v-card>
</template>

<script>
import CustomValueInput from "@/views/flow/components/CustomValueInput";
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";
import AhjAttachments from "@/views/blueraven/ahj/components/AhjAttachments";
import AhjCard from "@/views/blueraven/ahj/components/AhjCard";

export default {
  name: "AhjCustomFields",
  components: {
    AhjCard,
    AhjAttachments,
    CustomValueInput
  },
  props: {
    group: Object,
    userCanEdit: Boolean,
    expandedAll: CollapseExpandEnum,
    callback: Function,
    hardcodedDocs:Map,
    sourceId: Number

  },
  data: () => ({
    CollapseExpandEnum,
    expanded: true
  }),
  watch: {
    expandedAll(){
      if(this.expandedAll === CollapseExpandEnum.EXPANDED && this.expanded !== true) {
        this.expanded = true
      } else if(this.expandedAll === CollapseExpandEnum.COLLAPSED && this.expanded === true){
        this.expanded = false
      }
    }
  },
  methods: {
    showOtherField(int, list) {
      let match = list.find(l => l.id === int)
      return match ? match.showOther : false
    },
    toggleCollapseExpand(){
      this.expanded = !this.expanded
      this.$emit('toggle-collapse-expand', this.expanded)
    }
  }

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
