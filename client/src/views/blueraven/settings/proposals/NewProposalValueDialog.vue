<template>
  <v-dialog persistent scrollable max-width="600px" :value="visible">
    <template v-slot:default="dialog">
      <v-card>
        <v-toolbar color="primary" dark>
          <v-btn
            icon
            dark
            @click="closeDialog">
            <v-icon>mdi-close</v-icon>
          </v-btn>
          <v-toolbar-title>{{ title }}</v-toolbar-title>
        </v-toolbar>
        <v-card-text>
          <v-container>
            <CustomValueInput v-for="field in fields"
                              :callback="updateFieldValue"
                              :key="field.id"
                              :field="field"
                              :hide-label="true"/>
          </v-container>
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn
            text
            @click="closeDialog"
          >Close
          </v-btn>
          <v-btn
            color="primaryButton"
            @click="save"
            dark
          >Save
          </v-btn>
        </v-card-actions>
      </v-card>
    </template>
  </v-dialog>
</template>
<script>

import Vue from "vue"
import {getRequestWithParams} from "@/helpers/helpers"
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

const DATA_TYPES = {
  'text': 'textValue',
  'numeric': 'numericValue',
  'date': 'dateValue',
  'timestamp': 'timestampValue',
  'integer': 'intValue',
  'system': 'intValue',
  'integer array': 'intArrayValue',
  'boolean': 'booleanValue'
}

const extractFieldData = (field) => {
  const objVal = {type: field.dataType}

  if (field.listOfValues?.length > 0) {
    if (!field.allowMultiple) {
      objVal.intValue = field.intValue
      objVal.value = field.listOfValues.find(lov => lov.id === field.intValue)?.name
    } else {
      objVal.intArrayValue = field.intArrayValue
      objVal.value = field.listOfValues
        ?.filter(lov => field.intArrayValue.includes(lov.id))
        ?.map(lov => lov.name)
    }
  } else {
    objVal.value = field[DATA_TYPES[field.dataType]]
  }

  return {id: field.id, value: objVal}
}


export default {
  name: 'NewProposalValue',
  props: ['objectCode', 'editing', 'visible'],
  components: {CustomValueInput},
  data() {
    return {
      fields: [],
      dirtyCfvs: {}
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.openDialog()
      } else {
        this.closeDialog()
      }
    }
  },
  computed: {
    title() {
      return this.editing ? 'Edit Row' : 'Add Row'
    }
  },
  methods: {

    async fetchObjectFields(objectCode) {
      const {data} = await getRequestWithParams(`/customField/${objectCode}`, {}, 'blueraven')
      if (this.editing) {
        this.fields = data?.map(field => {
          let datatype = DATA_TYPES[field.dataType];
          if (!datatype) {
            console.warn('Cant find datatype for', field.dataType, field.dataTypeId)
          }
          let aVal = undefined
          if (this.editing[field.id] !== undefined) {
            aVal = this.editing[field.id][datatype] ?? this.editing[field.id].value
          }
          return {
            ...field,
            [datatype]: aVal
          }
        })
      } else {
        this.fields = data
      }
    },

    updateFieldValue(field) {
      const {code, value, id} = extractFieldData(field)
      if (value.value === undefined) {
        Vue.delete(this.dirtyCfvs, id)
      } else {
        Vue.set(this.dirtyCfvs, id, {id, value})
      }
    },

    save() {
      this.$emit('save', {rowId: this.editing?.pk, values: Object.values(this.dirtyCfvs)})
      this.closeDialog()
    },

    async openDialog() {
      this.fields = []
      this.dirtyCfvs = {}
      await this.fetchObjectFields(this.objectCode)
    },

    closeDialog(dialog) {
      this.$emit('input', false)
    }
  }
}
</script>
