<template>
<v-menu
  v-model="menu"
  :close-on-content-click="false"
  transition="scale-transition"
  offset-y
  max-width="290px"
  min-width="290px"
>
  <template #activator="{on}">
    <a-text-field
      class="px-2"
      :value="value | formatDateZoneless()"
      :label="label"
      type="search"
      autocomplete="off"
      :prepend-icon="'mdi-clock-outline'"
      clear-icon="mdi-close-circle"
      :clearable="!readonly"
      :disabled="readonly"
      v-on="!readonly && on"
      @click:clear="clearInput"
      :hide-details="hideDetails"
    />
  </template>
  <v-time-picker
    v-model="localValue"
    :allowed-minutes="allowedMinutes"
    @change="doChange"
    :ampm-in-title="true"
  >
    <v-spacer></v-spacer>
    <a-btn
        variant="text"
        color="primary"
        @click="cancel()"
        text="Cancel"
    ></a-btn>
    <a-btn
        variant="text"
        color="primary"
        @click="saveTime()"
        text="Ok"
    ></a-btn>
  </v-time-picker>
</v-menu>
</template>


<script setup>
import {onMounted, ref, toRefs, computed, watch, defineProps} from "vue";


const props = defineProps({
  value: String,
  label: String,
  hideDetails: Boolean,
  //if this is empty it shows all minutes
  allowedMinutes: Function,
  change: Function,
  readonly: {
    type: Boolean,
    default: false
  },
})

const { value: propsValue } = toRefs(props)

const date = ref(null)
const testValue = ref(null)
const menu = ref(false)

const emit = defineEmits(['input'])
onMounted(() => {
  init()
})

watch(propsValue, () => {
  if (null == propsValue.value) {
    //re-init if the field ever gets nulled out
    init()
  }
})

const doChange = () => {
  if(props.change) {
    props.change()
  }
}

//cannot edit value from parent component, need a local copy to manipulate
const localValue = computed({
  get() {
    return propsValue.value
  },
  set(date) {
    //this is so dumb.  if I just return date the localValue never changes. so i have to use this test value garbage
    testValue.value = date
    return date
  }
})
const saveTime = () => {
  emit('input', testValue.value)
  menu.value = false
}
const cancel = () => {
  menu.value = false
}
const init = () => {
  testValue.value = propsValue.value
}
const clearInput = () => {
  emit('input', null)
}
</script>

<style scoped lang="scss">
</style>
