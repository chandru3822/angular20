<template>
<v-container id="smartlist-container">
  <v-row>

    <v-col cols="12" class="text-left">
      <v-btn
        text
        class="btn-back"
        :ripple="false"
        @click="$router.go(-1)"
      >
        Back
      </v-btn>
    </v-col>

    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlist Editor</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            text
            color="primary"
            :disabled="showNewFieldForm"
            @click="smartlist.id ? updateSmartlist() : addSmartlist()"
          >
            <v-icon>save</v-icon>
            <span v-if="!IS_MOBILE">Save</span>
          </v-btn>
<!--          <v-btn text to="/smartlist/null" color="primary">-->
<!--            <v-icon>cancel</v-icon>-->
<!--            <span v-if="!IS_MOBILE">Cancel</span>-->
<!--          </v-btn>-->
        </v-toolbar-items>
      </v-toolbar>
    </v-col>

    <v-col cols="12">
      <v-card>
        <v-card-text>
          <v-row>
            <v-col cols="6">
              <v-text-field
                text
                label="Smartlist Name"
                v-model="smartlist.name"
              />
            </v-col>

            <v-col cols="6">
              <v-select
                v-model="smartlist.companyObjectTypeId"
                :items="companyObjectTypes"
                item-text="objectType"
                item-value="companyObjectTypeId"
                label="Object Type"
                placeholder="Select one..."
              />
            </v-col>
          </v-row>

          <v-row>
            <v-col cols="12">
              <v-checkbox
                v-model="smartlist.shared"
                label="Public"
              />
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>

    <v-col cols="6">
      <v-toolbar class="elevation-1">
        <v-toolbar-title>Fields</v-toolbar-title>
        <v-spacer />
        <v-toolbar-items>
          <v-btn
            v-if="!showNewFieldForm"
            text
            color="primary"
            :disabled="!smartlist.id"
            @click="showNewFieldForm = true"
          >
            <v-icon>add</v-icon>
            <span v-if="!IS_MOBILE">Add Field</span>
          </v-btn>

          <v-btn
            v-if="showNewFieldForm"
            text
            color="primary"
            @click="resetNewFieldForm"
          >
            <span>Cancel</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>

      <v-card>
        <v-col v-if="showNewFieldForm">
          <v-select
            v-model="newField.fieldTypeId"
            label="Field Type"
            :items="newFieldTypes"
            item-value="id"
            item-text="name"
          />

          <v-select
            v-model="newField.companyObjectTypeId"
            v-if="newField.fieldTypeId === 1"
            label="Object Type"
            :items="companyObjectTypes"
            item-value="companyObjectTypeId"
            item-text="objectType"
          />

          <v-select
            v-model="newField.smartlistFieldId"
            v-if="newField.hasOwnProperty('companyObjectTypeId')"
            label="Field Name"
            :items="availableSmartlistFields.filter(field => field.companyObjectTypeId === newField.companyObjectTypeId)"
            item-value="id"
            item-text="name"
          />

          <v-btn
            text
            color="primary"
            class=""
            :disabled="isNewFieldButtonDisabled"
            @click="addNewField"
          >
            <v-icon>save</v-icon>
            <span v-if="!IS_MOBILE">Save</span>
          </v-btn>
        </v-col>
      </v-card>

        <v-list dense>
          <draggable v-model="assignedFields" @change="reorderFields" group="assignedFields">
            <v-list-item class="grab" v-for="(field, index) in assignedFields" :key="field.id">

              <v-list-item-action>
                <v-icon>drag_handle</v-icon>
              </v-list-item-action>

              <v-list-item-content>
                <v-row>
                  <v-col cols="1" class="text-left">{{field.displayOrder}}</v-col>
                  <v-col class="text-left">{{field.name}}</v-col>
                  <v-col class="text-left">{{field.objectType}}</v-col>
                </v-row>
              </v-list-item-content>

              <v-list-item-action class="clickable">
                <v-icon @click="deleteField(index)">delete</v-icon>
              </v-list-item-action>
            </v-list-item>
          </draggable>
        </v-list>
    </v-col>
  </v-row>
  <Snackbar :snackbar="snackbar" />
</v-container>
</template>

<script>

import {AppMutations} from '@/stores/AppStore'
import {IS_MOBILE, getRequest, putRequest, postRequest, deleteRequest, logError, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar'
import draggable from 'vuedraggable'

export default {
  name: 'Smartlist',
  components: {
    Snackbar,
    draggable
  },
  data () {
    return {
      IS_MOBILE,
      snackbar: {},
      smartlist: {},
      companyObjectTypes: [],
      availableSmartlistFields: [],
      newField: {},
      showNewFieldForm: false,
      newFieldTypes: [
        {id: 1, name: 'Smartlist Field'},
        {id: 2, name: 'Custom Field'}
      ],
      assignedFields: []
    }
  },
  async created () {
    if (this.$route.params?.smartlistId !== "null") {
      this.getSmartlist()
      this.getAssignedFields()
    }

    this.getCompanyObjectTypes()
    this.getavailableSmartlistFields()
  },
  computed: {
    isNewFieldButtonDisabled () {
      if (this.newField?.fieldTypeId === 1) {
        return !(this.newField?.companyObjectTypeId && this.newField?.smartlistFieldId)
      }
      else if (this.newField?.fieldTypeId === 2) {
        return true
      } else {
        return true
      }
    }
  },
  methods: {
    async getSmartlist () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}`)
        this.smartlist = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching smartlist')
      }
    },
    async getAssignedFields () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/field`)
        this.assignedFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching assigned fields')
      }
    },
    async getCompanyObjectTypes () {
      try {
        const {data} = await getRequest(`/customField/getCustomFieldObjectTypes`)
        this.companyObjectTypes = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
      }
    },
    async getavailableSmartlistFields () {
      try {
        const {data} = await getRequest(`/smartlist/availableFields`)
        this.availableSmartlistFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching available fields')
      }
    },
    async addSmartlist () {
      try {
        await postRequest(`/smartlist`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
      }
    },
    async addNewField () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.smartlist.id}/field`, {
          smartlistId: this.smartlist.id,
          smartlistFieldId: this.newField.smartlistFieldId,
          displayOrder: this.assignedFields.length + 1
        })
        this.assignedFields.push(data)
        this.resetNewFieldForm()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding field to smartlist')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateSmartlist () {
      try {
        await putRequest(`/smartlist/${this.smartlist.id}`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
      }
    },
    resetNewFieldForm () {
      this.showNewFieldForm = false
      this.newField = {}
    },
    async deleteField (fieldIndex) {

      try {
        const fieldToDelete = this.assignedFields[fieldIndex]
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.$route.params.smartlistId}/field/${fieldToDelete.id}`)
        this.assignedFields.splice(fieldIndex, 1)
        this.reorderFields({moved: {newIndex: 0, oldIndex: 1}})
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error removing field from smartlist')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async reorderFields ({moved}) {

      // If a drag happened but order wasn't changed
      if (moved.newIndex === moved.oldIndex) {
        return
      }
      this.assignedFields.forEach((field, index) => field.displayOrder = index + 1)

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await putRequest(`/smartlist/${this.$route.params.smartlistId}/order`, this.assignedFields)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating field order')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

::v-deep {
  .btn-back {

    text-transform: capitalize;
    text-decoration: underline;

    &:not(.v-btn--round) {
      padding: 0;
    }

    &:hover:before {
      opacity: 0 !important;
    }

    .v-btn__content {
      justify-content: start;
    }
  }
}

.v-list {
  padding: 0 !important;
}

.v-list-item:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
