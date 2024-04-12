<template>
  <v-dialog persistent scrollable max-width="600px" :value="visible">
    <template v-slot:default="dialog">
      <v-form ref="newValueForm" autocomplete="off">
        <v-card>
          <v-toolbar color="primary" dark>
            <a-btn
                icon
                @click="closeDialog"
                color="unset"
                prepend-icon="mdi-close"
            ></a-btn>
            <v-toolbar-title>{{ title }}</v-toolbar-title>
          </v-toolbar>
          <v-card-text>
            <v-container>
              <CustomValueInput
                v-for="field in fields"
                :required="field.required"
                :callback="updateFieldValue"
                :key="field.id"
                :field="field"
                :hide-label="true"
                :api-path="apiPath"
              />
            </v-container>
          </v-card-text>
          <v-card-actions class="justify-end">
            <a-btn
                variant="text"
                color="primary"
                @click="closeDialog"
                text="Close"
            ></a-btn>
            <a-btn
                :disabled="!Object.keys(dirtyCfvs).length"
                color="primary"
                @click="validateForm()"
                text="Save"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-form>
    </template>
  </v-dialog>
</template>
<script setup>
import {getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar


const DATA_TYPES = {
  'text': 'textValue',
  'numeric': 'numericValue',
  'date': 'dateValue',
  'timestamp': 'timestampValue',
  'integer': 'intValue',
  'system': 'intValue',
  'system multiselect': 'intArrayValue',
  'integer array': 'intArrayValue',
  'boolean': 'booleanValue',
  'System List': 'intValue'
}

const extractFieldData = (field) => {
  const objVal = {type: field.dataType}
  if (field.hasListValues) {
    if (field.allowMultiple) {
      objVal.intArrayValue = field.intArrayValue
      objVal.value = field.listOfValues
        ?.filter((lov) => field.intArrayValue.includes(lov.id))
        ?.map((lov) => lov.name)
    } else {
      objVal.intValue = field.intValue
      objVal.value = field.listOfValues.find(
        (lov) => lov.id === field.intValue
      )?.name
    }
  } else {
    objVal.value = field[DATA_TYPES[field.dataType]]
    if (typeof objVal.value === 'string' && objVal.value?.trim() === '') {
      objVal.value = null
    }
  }
  return {id: field.id, value: objVal}
}

const props = defineProps(
    ['objectCode', 'editing', 'visible']
)
const emit = defineEmits(['input', 'save'])

const apiPath = ref('blueraven')
const fields = ref([])
const dirtyCfvs = ref({})
const newValueForm = ref(null)

watch(visible, async(val) => {
  if (val) {
    openDialog()
  } else {
    closeDialog()
  }
})

  const title = computed(() => {
    return props.editing ? 'Edit Row' : 'Add Row'
  })

    const validateForm = () => {
      if (newValueForm.value.validate()) {
        save()
      } else {
        snackbar('ERROR', 'ERROR: Check for missing fields or incorrect values')
      }
    }
    const fetchObjectFields = async(objectCode) => {
      const {data} = await getRequestWithParams(
        `/customField/object/${objectCode}`,
        {},
        apiPath.value
      )
      if (props.editing) {
        fields.value = data?.map((field) => {
          const datatype = DATA_TYPES[field.dataType]
          if (!datatype) {
            console.warn(
              'Cant find datatype for',
              field.dataType,
              field.dataTypeId
            )
          }
          const extra = {}
          const editingElement = props.editing[field.id]
          if (editingElement !== undefined) {
            // exclude when values are lazy loaded so the entire object is replaced on save
            if (!field.lazyLoadValues) {
              extra[datatype] = editingElement[datatype] ?? editingElement.value
            }
            extra['values'] = editingElement.value
          }
          return {
            ...field,
            ...extra,
          }
        })
      } else {
        fields.value = data
      }
    }
    const updateFieldValue = (field) => {
      const {value, id} = extractFieldData(field)
      if (value.value === undefined) {
        vueInstance.$delete(dirtyCfvs.value, id)
      } else {
        vueInstance.$set(dirtyCfvs.value, id, {id, value})
      }
    }
    const save = () => {
      emit('save', {
        rowId: props.editing?.pk,
        values: Object.values(dirtyCfvs.value),
      })
      closeDialog()
    }
    const openDialog = async() => {
      fields.value = []
      dirtyCfvs.value = {}
      await fetchObjectFields(props.objectCode)
    }
    const closeDialog = () => {
      emit('input', false)
    }

</script>
