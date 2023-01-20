<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">GL Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[createNew = !createNew, newGlCode = {}]">
              <v-icon v-if="!createNew">add</v-icon>
              {{createNew ? 'cancel' : 'Add GL Code'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New GL Code</h3>
          <v-text-field text
                        type="text"
                        label="GL Code"
                        v-model="newGlCode.code">
          </v-text-field>
          <v-text-field text
                        type="text"
                        label="Description"
                        v-model="newGlCode.description">
          </v-text-field>
          <v-btn color="primary" dark class="white--text"
                 :disabled="!newGlCode.code || !newGlCode.description"
                 @click="saveGlCode(newGlCode, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterGlCodes()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No GL Codes</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No GL Codes</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              label="GL Code"
                              v-model="item.code">
                </v-text-field>
                <div v-else>
                  {{ item.code }}
                </div>
              </td>
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              label="Description"
                              v-model="item.description">
                </v-text-field>
                <div v-else>
                  {{ item.description }}
                </div>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text color="primary" @click="editIndex = index" v-if="index !== editIndex">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" @click="saveGlCode(item, false)" v-if="index === editIndex">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" @click="editIndex = null" v-if="index === editIndex">
                    cancel
                  </v-btn>
                  <v-btn small text color="primary" @click="[deleteConfirm=true, itemToDelete=item]">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog = deleteConfirm
        @confirm=deleteGlCode(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this GL Code <strong>{{codeToDelete}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {getGlCodes} from './expenseService'
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'GlCodes',
  components: {ConfirmationDialog},
  computed: {
    codeToDelete(){
      return this.itemToDelete ? this.itemToDelete.code : ''
    }
  },
  data() {
    return {
      snackbar: {},
      createNew: false,
      newGlCode: {},
      editIndex: null,
      glCodes: [],
      headers: [
        {text: 'Code', value: 'code', show: true},
        {text: 'Description', value: 'description', show: true},
        {text: null, value: 'icons', show: true}
      ],
      deleteConfirm: false,
      itemToDelete: {}
    }
  },
  created() {
    this.getGlCodes()
  },
  methods: {
    filterGlCodes() {
      return this.glCodes.filter(glc => !glc.archived)
    },
    async getGlCodes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getGlCodes()
        this.glCodes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteGlCode(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/expenses/glCode/${item.id}`, 'blueraven')
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting GL Code')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveGlCode(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/expenses/glCode`, item, 'blueraven')
        if(isNew) {
          this.glCodes.push(data)
          this.newGlCode = {}
          this.createNew = false
        } else {
          this.editIndex = null
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving GL Code')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    closeDeleteDialog() {
      this.deleteConfirm = false
      this.itemToDelete = null
    }
  }
}
</script>
