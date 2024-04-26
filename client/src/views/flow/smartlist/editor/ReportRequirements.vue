<template>
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
  <v-col class="flex-grow-1 flex-shrink-0 overflow-y-auto">
    <v-list>
      <template v-for="(requirement, index) in requirements">
        <v-card
          v-if="requirement.updateType !== updateTypes.DELETE"
          :key="UUID()"
          class="ma-4"
          :class="{'bye-bye': edits[index]?.isEditing}"
          :disabled="!canEdit"
          @click="toggleEditing(index, true, $event)"
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
              <a-btn
                  icon
                  @click.native.stop="remove(index)"
                  color="unset"
                  prepend-icon="mdi-close"
              ></a-btn>
            </v-list-item-action>
          </v-list-item>
        </v-card>

        <div
          v-if="edits[index]?.isEditing"
          class="editor-container"
          :style="{top: `${edits[index].top}px`}"
        >
          <RequirementEditor
            :available-fields="[]"
            :existing-requirement="requirement"
            :get-value="getValue"
            @cancelled="toggleEditing(index, false, $event)"
            @updated="(updatedRequirement) => update(updatedRequirement, index)"
          />
        </div>

      </template>
    </v-list>
  </v-col>

  <v-col
    v-if="canEdit"
    class="btn-remove-container flex-shrink-1 flex-grow-0 text-right py-4 pr-4"
  >
    <a-btn
        variant="text"
        color="primary"
        class="btn-remove"
        @click="showDeleteDialog = true"
        text="Remove All Filters"
    ></a-btn>
  </v-col>

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
        <a-btn
            variant="text"
            @click="showDeleteDialog = false"
            color="unset"
            text="Cancel"
        ></a-btn>

        <a-btn
            color="primary"
            @click="[showDeleteDialog = false, emit('cleared')]"
            text="Save"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</v-row>
</template>

<script setup>
import { ref, watch } from 'vue'
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

// keep track of whether each requirement is being edited and the top position for placement
const edits = ref(Array(props.requirements.length).fill({
  isEditing: false,
  top: 0
}))

// keep our editing list in line with current requirements
watch(props.requirements, (requirements) => {
  edits.value = Array(requirements.length).fill({
    isEditing: false,
    top: 0
  })
})


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
  toggleEditing(index, false, null)
}

const toggleEditing = (index, isEditing, event) => {
  if (props.canEdit) {
    edits.value.splice(index, 1, {...edits.value[index], isEditing})

    if (isEditing) {
      // get coords of parent card so we know where to position the requirement editor
      const boundaries = event.target.closest('.v-card').getBoundingClientRect()
      edits.value[index].top = boundaries.y
    }
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
    let match

    //honestly can't remember anymore when we use listOfValues as opposed to availableListOfValues, so check them both
    if (requirement.availableListOfValues) {
      match = requirement.availableListOfValues.find(i => i.id === idToUse)
    } else if (requirement.listOfValues) {
      match = requirement.listOfValues.find(i => i.id === idToUse)
    }
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

.editor-container {
  position: fixed;
  left: 12px;
  z-index: 9;
}

.bye-bye {
  visibility: hidden;
}

//don't change opacity when the requirement cards are disabled
:deep(.v-card--disabled > div) {
  opacity: 1 !important;
}
</style>
