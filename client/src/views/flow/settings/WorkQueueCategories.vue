<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newCategory = { color: '#ffffff'}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew">
            <v-text-field v-model="newCategory.workQueueCategory"
                          placeholder="Enter a category"
                          label="Work Queue Category">
            </v-text-field>
            <div class="theme-label">
              Select a Color: {{newCategory.color}}
              <v-avatar
                  :tile="false"
                  :size="30"
                  :color="newCategory.color"
                  @click="showColor = !showColor"
                  class="account-img clickable bordered"
              >
              </v-avatar>
            </div>
            <v-color-picker v-if="showColor" class="my-3" v-model="newCategory.color" :canvas-height="colorOptions.height" :width="colorOptions.width" :mode="colorOptions.mode" :hide-mode-switch="colorOptions.hideModeSwitch"></v-color-picker>
            <v-btn :disabled="!newCategory.workQueueCategory" @click="addNewCategory">Save</v-btn>
          </div>
          <v-data-table
              :headers="headers"
              :items="filterCategories()"
              :fixed-header="true"
              :items-per-page="-1"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              class="elevation-1 mt-1"
          >
            <template #no-data>
              No available fields
            </template>

            <template #no-results>
              No available fields
            </template>

            <template #item="{ item, index }">

              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  <v-text-field class="one-hunned" v-if="selectedWorkQueueCategoryId === item.id" v-model="item.workQueueCategory"></v-text-field>
                  <div v-else>{{item.workQueueCategory}}</div>
                </td>
                <td class="text-left">
                  <v-avatar
                      :tile="false"
                      :size="30"
                      :color="item.color"
                      @click="updateItemValue(item)"
                      class="account-img clickable bordered"
                  >
                  </v-avatar>
                  <v-color-picker v-if="item.showColor" class="my-3" v-model="item.color" :canvas-height="colorOptions.height" :width="colorOptions.width" :mode="colorOptions.mode" :hide-mode-switch="colorOptions.hideModeSwitch"></v-color-picker>
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text>
                      <v-icon v-if="selectedWorkQueueCategoryId === item.id" @click="saveCategory(item)">save</v-icon>
                      <v-icon v-else @click="selectedWorkQueueCategoryId = item.id">edit</v-icon>
                    </v-btn>
                    <v-dialog
                        v-model="item.deleteConfirm"
                        width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn small text class="clickable" v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                            class="headline grey lighten-2"
                            primary-title
                        >
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this work queue category: <strong>{{ item.workQueueCategory }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                              @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                              color="primary"
                              text
                              @click="item.archived = true; deleteCategory(item.id)">
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
        </v-container>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import {getWorkQueueCategories} from '@/services/workQueueService'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'Works',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
        colorOptions: {
          canvasHeight: 75,
          width: 200,
          mode: 'hexa',
          hideModeSwitch: true
        },
        workQueueCategories: [],
        addNew: false,
        showColor: false,
        newCategory: { color: '#ffffff'},
        selectedWorkQueueCategoryId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        expanded: [],
        headers: [
          { text: 'Category', value: 'workQueueCategory', show: true },
          { text: 'Color', value: 'color', show: true },
          { text: null, value: 'icons', show: true }
        ],
      }
    },
    computed: {},
    methods: {
      updateItemValue (item) {
        if(this.selectedWorkQueueCategoryId === item.id) {
          this.$set(item, 'showColor', !item.showColor)
        }
      },
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueCategories()
          this.workQueueCategories = orderBy(data, [wqc => wqc.workQueueCategory.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCategory(typeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/workQueueCategory/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewCategory() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/workQueueCategory`, this.newCategory)

          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Added')

          // add it to the records already on the screen
          this.workQueueCategories.push(data)
          this.workQueueCategories = orderBy(this.workQueueCategories, [wqc => wqc.workQueueCategory.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newCategory = { color: null }

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveCategory(wqc) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedWorkQueueCategoryId = null
          const {data} = await putRequest(`/workQueueCategory`, wqc)
          wqc.showColor = false
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCategories () {
        return this.workQueueCategories.filter(wqc => { return !wqc.archived})
      },
    },
    async created() {
      this.getWorkQueueCategories()
    }
  }
</script>

<style scoped lang="scss">

</style>
