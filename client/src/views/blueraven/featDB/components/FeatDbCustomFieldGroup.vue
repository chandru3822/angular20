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
            variant="filled"
            :lock-feature="true"
            :copy-feature="true"
        />
        <a-textarea v-if="showOtherField(field.intValue, field.listOfValues)"
                    v-model="field.textValue"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit"
                    @change="[field.valueWasChanged = true, callback(field)]"
                    label="Other Value"
                    variant="filled"
                    hide-details
                    auto-grow
                    :rows="1"
                    class="other-field override-readonly-font-color mt-3"
        ></a-textarea>
      </div>
      <div v-if="!!hardcodedDocs && !!hardcodedDocs.get(group.id)">
        <FeatDbCard :title="hardcodedDocs.get(group.id).title">
          <FeatDbAttachments
              :attachments="hardcodedDocs.get(group.id).documents"
              :attachment-types="[{attachmentTypeId:hardcodedDocs.get(group.id).attachmentTypeId, attachmentType: hardcodedDocs.get(group.id).attachmentType}]"
              :user-can-edit="userCanEdit"
              :source-id="sourceId"
          ></FeatDbAttachments>
        </FeatDbCard>
      </div>

    </v-card-text>
  </v-card>
</template>

<script setup>
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue";
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import FeatDbAttachments from "@/views/blueraven/featDB/components/FeatDbAttachments.vue";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const emit = defineEmits(['toggle-collapse-expand'])

const props = defineProps({
  group: Object,
  userCanEdit: Boolean,
  expandedAll: CollapseExpandEnum,
  callback: Function,
  hardcodedDocs:Map,
  sourceId: Number
})
const { group, userCanEdit, expandedAll, callback, hardcodedDocs, sourceId } = toRefs(props)

const expanded = ref(true)

watch(expandedAll, () => {
  if (expandedAll.value === CollapseExpandEnum.EXPANDED && expanded.value !== true) {
    expanded.value = true
  } else if (expandedAll.value === CollapseExpandEnum.COLLAPSED && expanded.value === true) {
    expanded.value = false
  }
})

  const showOtherField = (int, list)  => {
    let match = list.find(l => l.id === int)
    return match ? match.showOther : false
  }
  const toggleCollapseExpand = () => {
    expanded.value = !expanded.value
    emit('toggle-collapse-expand', expanded.value)
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
<style lang="scss">
</style>
