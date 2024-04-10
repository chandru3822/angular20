<template>
  <v-card v-if="!contentLoading" flat :color="backgroundColor" class="square-card flex-grow-1" :class="{'full-size': fullSize, 'half-size': !fullSize}">
    <v-card-title style="min-height: 40px" class="py-0 title-medium flex-display align-center">
      <span class="select-group-title">{{title}}</span>
      <v-checkbox :disabled="!userCanEdit" type="checkbox" class="ml-3"
                  v-model="enabled" @change="checkboxChanged()"></v-checkbox>
    </v-card-title>
    <div class="button-toggle" v-if="enabled">
      <v-btn-toggle
          v-model="allowFlag"
          borderless
          mandatory
          color="blue"
          class="mr-3 mt-3"
          style="opacity: 1 !important; height: 10%;"
          id="focused-toggle"
          @change="allowChanged()"
      >
        <a-btn
            id="focused-toggle"
            class="text-capitalize fix-toggle-opacity body-medium"
            html-style="width: 50% !important; height: 100%"
            color="unset"
            text="Allow"
        ></a-btn>
        <a-btn
            id="focused-toggle"
            class="text-capitalize fix-toggle-opacity body-medium"
            html-style="width: 50% !important; height: 100%"
            color="unset"
            text="Deny"
        ></a-btn>
      </v-btn-toggle>
    </div>
    <v-card-text>
      <a-autocomplete
          v-if="enabled"
          v-model="selected"
          :items="content"
          :loading="contentLoading"
          multiple
          clearable
          :label="textLabel"
          item-title="position"
          item-value="positionId"
          return-object
          height="35px"
          class="mr-3 mt-3"
          @change="updateSelectedChanged">
        <template v-slot:prepend-item>
          <v-list-item
              ripple
              @click="[selectedChanged= true, toggleSelectAllContent(selected)]"
          >
            <v-list-item-action>
              <v-icon>{{ icon(returnObject, 'startTimeWhiteListedPositions') }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
              class="mt-2"
          ></v-divider>
        </template>
        <template v-slot:selection="{ item, index }">
          <v-chip small
                  v-if="index === 0 && selectedContent && selectedContent.length < 2">
            <span>{{ item.position }}</span>
          </v-chip>
          <span
              v-if="index === 1 && selected && selected.length >= 2"
              class="primary--text text-caption"
          >{{ selected.length }} selected</span>
        </template>
      </a-autocomplete>
      <a-btn
          v-if="userCanEdit && saveButton"
          color="primary"
          class="d-inline-block mt-4"
          :class="{'full-size': fullSize}"
          @click="save()"
          prepend-icon="save"
          :text="saveButtonText || 'Save'"
      ></a-btn>
    </v-card-text>
  </v-card>

</template>

<script setup>
import cloneDeep from "lodash.clonedeep";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const emit = defineEmits(['checkbox-changed', 'save-multi-select', 'allow-changed', 'selected-changed'])

const props = defineProps({
  userCanEdit: Boolean,
  returnObject: {},
  content: {},
  dropdownEnabled: Boolean,
  title: String,
  label: String,
  selectedContent: {},
  allow: Boolean,
  contentLoading: Boolean,
  backgroundColor: String,
  fullSize: {
    default: false,
    type: Boolean
  },
  alternateLabel: String,
  saveButton: {
    type: Boolean,
    default: false
  },
  saveButtonText: String
})
const { userCanEdit, returnObject, content, dropdownEnabled,
  title, label, selectedContent, allow, contentLoading, backgroundColor,
  fullSize, alternateLabel, saveButton, saveButtonText } = toRefs(props)

const allowFlag = ref(0)
const enabled = ref(dropdownEnabled.value)
const contentChanged = ref(false)
const selected = ref(selectedContent.value)
const textLabel = ref(label.value)


const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

onMounted(() => {
  if(!allow.value) {
    allowFlag.value = 1;
    if (alternateLabel.value != null) {
      textLabel.value = alternateLabel.value;
    }
  }
  selected.value = selectedContent.value;
})

const icon = (f, fieldName)  => {
  if (selectAll(f, fieldName)) {
    return 'check_box'
  }
  if (selectSome(f, fieldName)) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const selectAll = ()  => {
  return selected.value?.length === content.value?.length
}
const selectSome = (f, fieldName)  => {
  return f[fieldName]?.length > 0 && !selectAll(f)
}
const toggleSelectAllContent = ()  => {
  vuetify.$nextTick(() => {
    if (selectAll()) {
      selected.value = []
      updateSelectedChanged()
    } else {
      selected.value = cloneDeep(content.value)
      updateSelectedChanged()
    }
  })
}
const updateSelectedChanged = () => {
  emit('selected-changed', selected.value)
}
const allowChanged = () => {
  switchLabel();
  emit('allow-changed', allowFlag.value);
}
const checkboxChanged = () => {
  emit('checkbox-changed', enabled.value)
}
const save = () => {
  emit('save-multi-select')
}
const switchLabel = () => {
  if(alternateLabel.value != null) {
    if (allowFlag.value == 0) {
      textLabel.value = label.value
    } else {
      textLabel.value = alternateLabel.value
    }
  }
}
</script>

<style scoped>
.v-card__text{
  padding-top: 0px;
}
.button-toggle{
  padding-left: 12px;
}
.full-size{
  width: 100%;
}
.half-size{
  width: 50%;
}
.select-group-title {
  max-width: 80%;
  word-break: break-word;
}

</style>
