<template>
  <div>
    <v-row class="d-flex justify-space-between align-center">

      <v-col class="d-flex justify-start align-self-start py-0">
        <DatetimePickerInput
            v-if="field.dataTypeId === 1"
            v-model="field.fieldValue"
            :timezone="timezone"
            :type="'date'"
            :required="required"
            :format="'MMMM DD, YYYY'"
            :label="field.fieldName"
            :readonly="readonly"
            :custom-class="readonly ? 'error--text' : ''"
            @input="callback(field)"
        />

        <DatetimePickerInput
            v-if="field.dataTypeId === 2"
            v-model="field.fieldValue"
            :timezone="timezone"
            type="timestamp"
            :required="required"
            :format="'MMMM DD, YYYY, h:mm A'"
            :label="field.fieldName"
            :readonly="readonly"
            :custom-class="readonly ? 'error--text' : ''"
            @input="callback(field)"
        />

        <v-checkbox
            v-if="field.dataTypeId === 3"
            v-model="field.fieldValue"
            :required="false"
            :label="field.fieldName"
            :disabled="readonly"
            :readonly="readonly"
            :class="{'error--text': readonly}"
            :ripple="false"
            @change="callback(field)"
        />

        <v-text-field
            v-if="field.dataTypeId === 4"
            text
            :required="required"
            :readonly="readonly"
            :disabled="readonly"
            :class="{'error--text': readonly}"
            placeholder=" "
            :rules="requiredRules"
            :label="field.fieldName"
            type="number"
            v-model.number="field.fieldValue"
            @change="callback(field)"
            autocomplete="off"
        />

        <v-textarea
            v-if="field.dataTypeId === 5"
            auto-grow
            rows="1"
            :required="required"
            :readonly="readonly"
            :disabled="readonly"
            :class="{'error--text': readonly}"
            placeholder=" "
            :rules="requiredRules"
            :label="field.fieldName"
            v-model="field.fieldValue"
            @change="callback(field)"
            autocomplete="off"
        />

        <v-text-field
            v-if="field.dataTypeId === 6"
            text
            :required="required"
            :readonly="readonly"
            :disabled="readonly"
            :class="{'error--text': readonly}"
            placeholder=" "
            :rules="requiredRules"
            :label="field.fieldName"
            type="number"
            v-model.number="field.fieldValue"
            @change="callback(field)"
            autocomplete="off"
        />


      </v-col>
    </v-row>

  </div>
</template>

<script setup>
import DatetimePickerInput from "@/components/DatetimePickerInput.vue"
import constants from "@/helpers/constants"
import {getCurrentInstance, computed, ref, onMounted} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
import {useUserStore} from '@/stores/UserStorePinia.js'

const userStore = useUserStore()
import {defineProps} from 'vue'

const props = defineProps({
  required: {
    type: Boolean,
    default: false
  },
  readonly: {
    type: Boolean,
    default: false
  },
  field: Object,
  callback: Function
})

const {required, readonly, field, callback} = props;

const timezone = computed(() => {
  return userStore.details.timezone?.value
})

const isLoading = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)

</script>

<style scoped lang="scss">

</style>
