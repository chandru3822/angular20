<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
<!--          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Work Queue Categories</v-toolbar-title>-->
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newCategory = {}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newCategory.workQueueCategory"
                        placeholder="Enter a category"
                        label="Work Queue Category">
          </v-text-field>
          <v-btn v-if="addNew" :disabled="!newCategory.workQueueCategory" @click="addNewCategory">Save</v-btn>
          <v-list v-for="(wt, index) in filterBy(workQueueCategories, false, 'archived')"
                  :key="index" class="pa-0">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left">
                <v-text-field class="one-hunned" v-if="selectedWorkQueueCategoryId === wt.id" v-model="wt.workQueueCategory">
                </v-text-field>
                <div v-else>{{wt.workQueueCategory}}</div>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <v-icon v-if="selectedWorkQueueCategoryId === wt.id" @click="saveCategory(wt)">save</v-icon>
                <v-icon v-else @click="selectedWorkQueueCategoryId = wt.id">edit</v-icon>
              </v-list-item-action>
              <v-dialog
                  v-model="wt.deleteConfirm"
                  width="500">
                <template v-slot:activator="{ on }">
                  <v-list-item-action class="clickable" v-on="on">
                    <v-icon>delete</v-icon>
                  </v-list-item-action>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this work queue category: <strong>{{ wt.workQueueCategory }}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="wt.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="wt.archived = true; deleteCategory(wt.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list>
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
        workQueueCategories: [],
        addNew: false,
        newCategory: {},
        selectedWorkQueueCategoryId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId
      }
    },
    computed: {},
    methods: {
      async getWorkQueueCategories() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getWorkQueueCategories()
          this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Categories')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteCategory(categoryId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/workQueueCategory/category/${categoryId}`)
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
          this.newCategory.companyId = this.companyId
          const {data} = await postRequest(`/workQueueCategory/category`, this.newCategory)

          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Added')

          // add it to the records already on the screen
          this.workQueueCategories.push(data)
          this.workQueueCategories = orderBy(this.workQueueCategories, [wt => wt.workQueueCategory.toLowerCase()])

          // reset the new process fields
          this.addNew = false
          this.newCategory = {}

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveCategory(wt) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.selectedWorkQueueCategoryId = null
          wt.modifiedById = this.userId
          await putRequest(`/workQueueCategory/category`, wt)
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Category Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Category')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created() {
      this.getWorkQueueCategories()
    }
  }
</script>

<style scoped lang="scss">

</style>
