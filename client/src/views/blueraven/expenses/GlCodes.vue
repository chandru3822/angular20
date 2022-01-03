<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">GL Codes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[createNew = !createNew, newGlCode = {}]">
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
          <v-btn color="primaryCustom" dark class="white--text"
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
            No GL Codes
          </template>

          <template #no-results>
            No GL Codes
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
                  <v-btn small text @click="editIndex = index" v-if="index !== editIndex">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="saveGlCode(item, false)" v-if="index === editIndex">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-btn small text @click="editIndex = null" v-if="index === editIndex">
                    cancel
                  </v-btn>
                  <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this GL Code <strong>{{item.code}}</strong>?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteGlCode(item)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {getGlCodes} from './expenseService'

export default {
  name: 'GlCodes',
  computed: {},
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
  }
}
</script>
