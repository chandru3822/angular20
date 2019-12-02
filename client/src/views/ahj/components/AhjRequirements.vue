<!-- suppress CssInvalidPseudoSelector -->
<template id="ahj-requirements">
  <v-card>
    <v-toolbar class="primaryCustom">
      <v-toolbar-title class="white--text font-weight-bold" :title="title">
        {{title}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon color="#ddd" style="border-radius: 3px">
        <v-icon v-show="!addMode && !editMode"
                @click="addRequirement" class="white--text">add</v-icon>
        <v-icon v-show="addMode || editMode"
                @click="hideCtrls" class="white--text">remove</v-icon>
      </v-btn>
    </v-toolbar>
    <form class="requirement-edit-ctrls px-3"
          ref="requirementForm" v-show="addMode || editMode">
      <v-textarea required label="Requirement Details" auto-grow filled
                  style="margin: 15px 0 -15px 0"
                  v-model="requirement.details">
      </v-textarea>
<!--      <v-text-field label="Display Order" filled-->
<!--                    v-model="requirement.displayOrder">-->
<!--      </v-text-field>-->
      <div class="requirement-btns">
        <a @click="hideCtrls"
           class="cancel-link">Cancel</a>
        <v-btn v-show="editMode" color="brRed" small
               @click="deleteRequirement" class="white--text py-1 px-2">
          Delete
        </v-btn>
        <v-btn @click="saveRequirement" color="primaryButton" class="white--text py-1 px-2"
               :disabled="!requirement.details || requirement.details === ''" small>
          {{ addMode ? 'Add' : 'Update' }}
        </v-btn>
      </div>
    </form>
    <draggable v-model="requirementsCopy" group="requirementsGroup"
               @start="drag=true" @end="reorderRequirements">
      <v-list v-for="requirement in requirementsCopy"
              :key="requirement.id">
        <v-list-item v-show="requirementsCopy.length > 0"
                     class="grab" :title="requirement.details">
          <v-list-item-action>
            <v-icon small class="mr-3" @click="editRequirement(requirement)">edit</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title v-text="requirement.details">
            </v-list-item-title>
          </v-list-item-content>
          <v-list-item-action>
            <v-icon>drag_handle</v-icon>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </draggable>
    <div class="empty-list"
         v-show="requirementsCopy.length < 1">
      No AHJ-specific installation requirements found
    </div>
  </v-card>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import draggable from 'vuedraggable'

  export default {
    name: "AhjRequirements",
    components: {
      draggable
    },
    props: {
      title: {
        type: String
      },
      requirementTypeId: {
        type: Number
      },
      itemId: {
        type: Number
      },
      itemType: {
        type: String
      },
      ahjId: {
        type: Number
      },
      requirements: {
        type: Array,
        default: () => []
      }
    },
    data () {
      return {
        requirement: {
          id: null,
          requirementTypeId: this.requirementTypeId,
          details: null
        },
        addMode: false,
        editMode: false,
        drag: false,
        requirementsCopy: this.requirements
      }
    },
    methods: {
      hideCtrls() {
        this.addMode = false
        this.editMode = false
      },
      reorderRequirements() {
        this.drag = false
        for(let i = 0; i < this.requirementsCopy.length; i++) {
          this.requirement = this.requirementsCopy[i]
          this.requirement.displayOrder = i
          this.saveItem()
        }
      },
      addRequirement() {
        this.editMode = false
        this.addMode = true
        this.requirement.description = ''
      },
      editRequirement(requirement) {
        this.addMode = false
        this.editMode = true
        this.requirement = Object.assign({}, requirement)
      },
      // TODO: Setup ahj requirements endpoints
      async saveRequirement() {
        this.requirement.requirementTypeId = this.requirementTypeId

        if (this.addMode) {
          this.requirement.displayOrder = this.requirementsCopy.length
          const {data} = await postRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/requirement`, this.requirement, 'blueraven')
          this.requirementsCopy.push(cloneDeep(data))
          this.addMode = false
        } else {
          const {data} = await putRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/requirement/${this.requirement.id}`, this.requirement, 'blueraven')
          let updatedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === data.id)
          this.requirementsCopy[updatedRequirementIndex].details = data.details
          this.editMode = false
        }
      },
      async deleteRequirement() {
        await deleteRequest(`/ahj/${this.ahjId}/${this.itemType}/${this.itemId}/requirement/${this.requirement.id}`, 'blueraven')
        let deletedRequirementIndex = this.requirementsCopy.findIndex(i => i.id === this.requirement.id)
        this.requirementsCopy.splice([deletedRequirementIndex], 1)
        this.editMode = false
      }
    }
  }
</script>

<style scoped lang="scss">
  .cancel-link,
  .requirement {
    font-size: 0.85em !important;
    text-decoration: none;
  }
  .cancel-link:hover {
    text-decoration: underline;
  }
  .v-card__title,
  .v-toolbar__title {
    font-size: 1em !important;
  }
  .v-text-field,
  .v-input ::v-deep label {
    font-size: 0.95em !important;
  }
  .v-list-item__action {
    margin: 0 !important;
    max-width: 24px;
  }
  .v-list-item__title {
    font-size: 0.95em !important;
    max-width: 525px;
  }
  .requirement-btns {
    display: flex;
    flex-flow: row nowrap;
    justify-content: flex-end;
    align-items: center;
    button {
      margin: 0 0 0 7px;
    }
  }
  .empty-list {
    padding: 20px;
    font-size: 0.85em;
  }
</style>
