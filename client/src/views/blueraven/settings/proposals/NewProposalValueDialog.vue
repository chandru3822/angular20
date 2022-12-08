<template>
  <v-dialog persistent scrollable max-width="600px" :value="visible">
    <template v-slot:default="dialog">
      <v-form ref="newValueForm">
        <v-card>
          <v-toolbar color="primary" dark>
            <v-btn icon dark @click="closeDialog">
              <v-icon>mdi-close</v-icon>
            </v-btn>
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
            <v-btn text color="primary" @click="closeDialog">Close</v-btn>
            <v-btn
              :disabled="!Object.keys(dirtyCfvs).length"
              color="primary"
              class="white--text"
              @click="validateForm()"
            >Save
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-form>
    </template>
  </v-dialog>
</template>
<script>
import Vue from 'vue'
import {getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

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
      const newVals = field.listOfValues
        ?.filter((lov) => field.intArrayValue.includes(lov.id))
        ?.map((lov) => lov.name)
      objVal.value = newVals
    } else {
      objVal.intValue = field.intValue
      objVal.value = field.listOfValues.find(
        (lov) => lov.id === field.intValue
      )?.name
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
      snackbar: {},
      apiPath: 'blueraven',
      fields: [],
      dirtyCfvs: {},
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.openDialog()
      } else {
        this.closeDialog()
      }
    },
  },
  computed: {
    title() {
      return this.editing ? 'Edit Row' : 'Add Row'
    },
  },
  methods: {
    validateForm() {
      if (this.$refs.newValueForm.validate()) {
        this.save()
      } else {
        this.snackbar = getSnackbar('ERROR', 'ERROR: Check for missing fields or incorrect values')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async fetchObjectFields(objectCode) {
      const {data} = await getRequestWithParams(
        `/customField/object/${objectCode}`,
        {},
        this.apiPath
      )
      if (this.editing) {
        this.fields = data?.map((field) => {
          const datatype = DATA_TYPES[field.dataType]
          if (!datatype) {
            console.warn(
              'Cant find datatype for',
              field.dataType,
              field.dataTypeId
            )
          }
          const extra = {}
          const editingElement = this.editing[field.id]
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
        this.fields = data
      }
    },

    updateFieldValue(field) {
      const {value, id} = extractFieldData(field)
      if (value.value === undefined) {
        Vue.delete(this.dirtyCfvs, id)
      } else {
        Vue.set(this.dirtyCfvs, id, {id, value})
      }
    },

    save() {
      this.$emit('save', {
        rowId: this.editing?.pk,
        values: Object.values(this.dirtyCfvs),
      })
      this.closeDialog()
    },

    async openDialog() {
      this.fields = []
      this.dirtyCfvs = {}
      await this.fetchObjectFields(this.objectCode)
    },

    closeDialog() {
      this.$emit('input', false)
    },
  },
}
</script>
