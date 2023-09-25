<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newCategory = { color: '#ffffff'}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
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
            <v-btn color="primary" :disabled="!newCategory.workQueueCategory" @click="addNewCategory">Save</v-btn>
          </div>
          <v-data-table
              :headers="headers"
              :items="filterCategories()"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              hide-default-footer
              fixed-header
              single-expand
              :expanded.sync="expanded"
              class="elevation-1"
          >
            <template #no-data>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available fields</span>
            </template>

            <template #item="{ item }">
              <tr :class="{'shaded-row': workQueueCategories.indexOf(item) % 2}">
                <td style="width: 50px">
                  <v-btn text color="primary" icon small class="handle" v-if="userCanEdit">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
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
                <td class="text-left">


                                    <v-card flat color="transparent" class="square-card my-2" v-if="selectedWorkQueueCategoryId === item.id">
<!--                    <v-card-title style="height: 40px" class="py-0 grey&#45;&#45;text text&#45;&#45;darken-1">-->
<!--                      Hidden-->
<!--                      <v-checkbox type="checkbox" class="ml-3"-->
<!--                                  v-model="item.hidden"></v-checkbox>-->
<!--                    </v-card-title>-->
                                      <multi-select-group
                                        v-if="!workQueueLoading"
                                        :userCanEdit="userCanEdit"
                                        :returnObject="item"
                                        :content="positions"
                                        :dropdownEnabled="item.hidden"
                                        :selectedContent="item.hiddenWhiteListedPositions"
                                        :title="'Hidden'"
                                        :label="'Allowed Positions'"
                                        :alternateLabel = "'Denied Positions'"
                                        :allow="item.hiddenAllow"
                                        :contentLoading="positionsLoading"
                                        backgroundColor="transparent"
                                        @selected-changed="workQueueCategoriesHiddenSelectedEventListener"
                                        @allow-changed="workQueueCategoriesHiddenAllowEventListener"
                                        @checkbox-changed="workQueueCategoriesHiddenCheckboxEventListener"></multi-select-group>
                                      <br v-if="!item.hidden">
                                      <v-btn color="primary" dark class="d-inline-block white--text"
                                             @click="saveHiddenAndWhiteList(item)">
                                        <v-icon class="mr-2">save</v-icon>
                                        Save Hidden
                                      </v-btn>
                                    </v-card>

                </td>

                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text color="primary" v-if="userCanEdit">
                      <v-icon v-if="selectedWorkQueueCategoryId === item.id" @click="saveCategory(item)">save</v-icon>
                      <v-icon v-else @click="selectedWorkQueueCategoryId = item.id; selectedWorkQueueCategoryDisplayOrder = item.displayOrder">edit</v-icon>
                    </v-btn>
                    <v-btn :disabled="!userCanDelete" small text color="primary" class="clickable" @click="categoryToDelete=item">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
          <ConfirmationDialog :open-dialog="!!categoryToDelete" @confirm="[deleteCategory, categoryToDelete.archived = true]" @close-dialog="categoryToDelete=null">
            Are you sure you want to delete this work queue category: <strong>{{ categoryToDeleteName }}</strong>?
          </ConfirmationDialog>
        </v-container>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import {getWorkQueueCategories} from '@/services/workQueueService'

  import {
    handleHidingGlobalLoader,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar,
    getRequest
  } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";
  import cloneDeep from "lodash.clonedeep";
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'WorkQueueCategories',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.workQueueCategories.splice(oldIndex, 1)[0]
          _self.workQueueCategories.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.workQueueCategories)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if(save) {
              _self.workQueueCategories[idx].newDisplayOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      })
    },
    data() {
      return {
        snackbar: {},
        constants,
        colorOptions: {
          canvasHeight: 75,
          width: 200,
          mode: 'hexa',
          hideModeSwitch: true
        },
        workQueueCategories: [],
        workQueueLoading: false,
        positions: [],
        positionsLoading: false,
        hiddenPositionsChanged: false,
        addNew: false,
        showColor: false,
        newCategory: { color: '#ffffff'},
        selectedWorkQueueCategoryId: null,
        selectedWorkQueueCategoryDisplayOrder: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
        expanded: [],
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Category', value: 'workQueueCategory', show: true },
          { text: 'Color', value: 'color', show: true },
          { text: null, value: 'hidden', show: true },
          { text: null, value: 'icons', show: true }
        ],
        categoryToDelete:null
      }
    },
    computed: {
      categoryToDeleteName(){
        return this.categoryToDelete ? this.categoryToDelete.workQueueCategory : ''
      }
    },
    methods: {
      workQueueCategoriesHiddenSelectedEventListener(e){
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenWhiteListedPositions = e;
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenPositionsChanged = true;
      },
      workQueueCategoriesHiddenAllowEventListener(e){
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenAllow = (e === 0);
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenPositionsChanged = true;
      },
      workQueueCategoriesHiddenCheckboxEventListener(e){
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hidden = e;
        this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenPositionsChanged = true;

      },
      selectAllHidden (wqc) {
        return wqc.hiddenWhiteListedPositions?.length === this.positions?.length
      },
      selectSomeHidden (wqc) {
        return wqc.hiddenWhiteListedPositions?.length > 0 && !this.selectAllHidden(wqc)
      },
      iconOwner (wqc) {
        if (this.selectAllHidden(wqc)) {
          return 'check_box'
        }
        if (this.selectSomeHidden(wqc)) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      toggleSelectAllPositions (wqc) {
        this.$nextTick(() => {
          if (this.selectAllHidden(wqc)) {
            wqc.hiddenWhiteListedPositions = []
            wqc.hiddenPositionsChanged = true
          } else {
            wqc.hiddenWhiteListedPositions = cloneDeep(this.positions)
            wqc.hiddenPositionsChanged = true
          }
        })
      },
      async getPositions() {
        if(this.positions?.length === 0) {
          try {
            this.positionsLoading = true
            const {data, status} = await getRequest(`/position/withParent`)
            this.positions = data
            this.positionsLoading = false
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            this.positionsLoading = false
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async saveHiddenAndWhiteList (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/workQueueCategory/saveHiddenAndWhiteList?savePositions=${this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenPositionsChanged ?? false}`, this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder])
          this.hiddenPositionsChanged = false
          if(!this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hidden) {
            this.workQueueCategories[this.selectedWorkQueueCategoryDisplayOrder].hiddenWhiteListedPositions = []
          }
          this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      updateItemValue (item) {
        if(this.selectedWorkQueueCategoryId === item.id) {
          this.$set(item, 'showColor', !item.showColor)
        }
      },
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.workQueueLoading = true;
          const {data, status} = await getWorkQueueCategories(true)
          this.workQueueCategories = data
          handleHidingGlobalLoader(this, status)
          this.workQueueLoading = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCategory() {
        const typeId = this.categoryToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/workQueueCategory/${typeId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Work Queue Category')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Work Queue Category')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.categoryToDelete = null
      },
      async addNewCategory() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/workQueueCategory`, this.newCategory)

          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

          // add it to the records already on the screen
          this.workQueueCategories.push(data)
          this.workQueueCategories = orderBy(this.workQueueCategories, [wqc => wqc.workQueueCategory.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newCategory = { color: null }

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Category')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveCategory(wqc) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedWorkQueueCategoryId = null
          const {status} = await putRequest(`/workQueueCategory`, wqc)
          wqc.showColor = false
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Category')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRowChanges(rows) {
        if(rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await putRequest(`/workQueueCategory/order`, rows)
            // this.$set(this, 'workQueueCategories', data)
            this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Order Saved')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Order')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      filterCategories () {
        return this.workQueueCategories.filter(wqc => { return !wqc.archived})
      },
    },
    async created() {
      this.getWorkQueueCategories()
      this.getPositions()
    },
  }
</script>
