<template>
<fragment>
<v-row class="no-gutters fill-height flex-column">
  <v-col class="flex-shrink-1 flex-grow-0">
    <RequirementEditor
      v-if="canEdit"
      :available-fields="availableFields"
      :get-value="getValue"
      @in-progress="(isInProgress) => isAddingInProgress = isInProgress"
      @added="added"
    />
  </v-col>
  <v-col class="flex-grow-1 flex-shrink-0">
    <v-list>
      <template v-for="(requirement, index) in requirements">
        <v-card
          v-if="requirement.updateType !== updateTypes.DELETE && !edits[index]"
          :key="UUID()"
          class="ma-4"
          :disabled="!canEdit"
          @click="edit(index)"
        >
          <v-list-item>
            <v-list-item-content>
              <v-row no-gutters class="align-center">
                <v-col class="text-no-wrap my-3"><span class="highlight-background px-2 py-1 rounded">{{ requirement.name }}</span></v-col>
                <v-col class="text-no-wrap px-2">{{ requirement.operatorType }}</v-col>
                <v-col class="text-no-wrap my-3"><span class="highlight-background px-2 py-1 rounded">{{ getValue(requirement) }}</span></v-col>
              </v-row>
            </v-list-item-content>

            <v-list-item-action v-if="canEdit">
              <v-btn
                icon
                @click.stop="remove(index)"
              >
                <v-icon>mdi-close</v-icon>
              </v-btn>
            </v-list-item-action>
          </v-list-item>
        </v-card>

        <RequirementEditor
          v-if="edits[index]"
          :available-fields="availableFields"
          :existing-requirement="requirement"
          :get-value="getValue"
          @cancelled="edits.splice(index, 1, false)"
          @updated="(updatedRequirement) => update(updatedRequirement, index)"
        />
      </template>
    </v-list>
  </v-col>

  <v-col
    v-if="canEdit"
    class="btn-remove-container flex-shrink-1 flex-grow-0 text-right py-4 pr-4"
  >
    <v-btn
      text
      color="primary"
      class="btn-remove"
      @click="showDeleteDialog = true"
    >
      Remove All Filters
    </v-btn>
  </v-col>
</v-row>

<v-dialog
  v-model="showDeleteDialog"
  persistent
  width="450"
>
  <v-card>
    <v-card-title>Clear All Filters</v-card-title>

    <v-card-text>
      Do you want to delete all filters?
    </v-card-text>

    <v-card-actions class="justify-end">
      <v-btn
        text
        @click="showDeleteDialog = false"
      >
        Cancel
      </v-btn>

      <v-btn
        color="primary"
        @click="[showDeleteDialog = false, emit('cleared')]"
      >
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'
import { ref } from 'vue'
import { UUID } from '@/helpers/helpers'
import RequirementEditor from '@/views/flow/smartlist/editor/RequirementEditor.vue'

const emit = defineEmits(['added', 'updated', 'deleted', 'cleared'])

const props = defineProps({
  requirements: {
    type: Array,
    required: true
  },
  availableFields: {
    type: Array,
    required: true
  },
  loading: {
    type: Boolean,
    required: true
  },
  updateTypes: {
    type: Object,
    required: true
  },
  canEdit: {
    type: Boolean,
    required: true
  }
})

const showDeleteDialog = ref(false)

const isAddingInProgress = ref(false)

const edits = ref(Array(props.requirements.length).fill(false))

// const calculatedName = (r) => {
//   let name = r.name
//
//   if (r.objectTypeId === 4) {
//     name += ` - (PS) ${r.processStepName}`
//   } else if (r.objectTypeId === 6) {
//     name += ` - (E) ${r.eventName}`
//   }
//
//   return name
// }

const remove = (index) => {
  emit('deleted', index)
}

const update = (requirement, index) => {
  emit('updated', requirement, index)
  edits.value.splice(index, 1, false)
}

const edit = (index) => {
  if (props.canEdit) {
    edits.value.splice(index, 1, true)
  }
}

const getValue = (requirement, isEditing = false) => {

  if (requirement.requirementValue) {
    return requirement.requirementValue
  }

  if (requirement.dataTypeRequirementId) {

    let value = requirement.dataTypeRequirement?.dataTypeValue

    if (requirement.dataTypeRequirement?.secondaryRequirement && (requirement?.secondaryRequirementValue && !isEditing)) {
      value += ` ${requirement.secondaryRequirementValue}`
    }

    return value
  }

  if (requirement.listOfValueId || requirement.customFieldSql || requirement.companySystemListId) {
    const idToUse = (requirement.customSqlOptionId) ? requirement.customSqlOptionId :
                    (requirement.systemListOptionId) ? requirement.systemListOptionId : requirement.listOfValueId
    const match = requirement.availableListOfValues.find(i => i.id === idToUse)
    return match?.name
  }

  if (requirement.listOfValues) {
    if (requirement.smartlistSystemListId === null) {
      return requirement.listOfValues
                        .map(v => ` ${v.name}`)
                        .toString()
    } else {
      //The backend returns incorrect listOfValues for smartlist field multiselects
      return requirement.availableListOfValues
                        .filter(v => req.listOfValueIds.includes(v.id))
                        .map(v => ` ${v.name}`)
                        .toString()
    }
  }

  return 'unknown'
}

const added = (newRequirement) => {
  newRequirement.displayOrder = props.requirements.length + 1
  emit('added', newRequirement)
}
</script>

<style scoped lang="scss">

.highlight-background {
  background-color: var(--v-primary-lighten9);
}

.btn-remove-container {

  border-top: 1px solid var(--v-grey-lighten2);

  button:hover::before {
    opacity: 0 !important;
  }
}

//don't change opacity when the requirement cards are disabled
:deep(.v-card--disabled > div) {
  opacity: 1 !important;
}
</style>