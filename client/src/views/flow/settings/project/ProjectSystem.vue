<template>
  <v-container class="custom-field-group-container">
    <v-card flat color="primary lighten-9" class="square-card">
      <v-card-title style="height: 40px" class="py-0">
        Status Read Only
        <v-checkbox type="checkbox" class="ml-3"
                    v-model="projectObjectType.statusReadOnly"></v-checkbox>
      </v-card-title>
      <v-card-text>
        <v-autocomplete
          v-if="projectObjectType.statusReadOnly"
          v-model="projectObjectType.statusReadOnlyWhiteListedPositions"
          :items="positions"
          :loading="positionsLoading"
          multiple
          clearable
          label="White Listed Positions"
          item-text="position"
          item-value="positionId"
          return-object
          height="35px"
          class="d-inline-block mr-3"
          @change="statusReadOnlyPositionsChanged = true">
          <v-list-item
            slot="prepend-item"
            ripple
            @click="toggleSelectAllPositions()"
          >
            <v-list-item-action>
              <v-icon>{{ icon(projectObjectType) }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
            slot="prepend-item"
            class="mt-2"
          ></v-divider>
          <template
            slot="selection"
            slot-scope="{ item, index }"
          >
            <v-chip small
                    v-if="index === 0 && projectObjectType.statusReadOnlyWhiteListedPositions && projectObjectType.statusReadOnlyWhiteListedPositions.length < 2">
              <span>{{ item.position }}</span>
            </v-chip>
            <span
              v-if="index === 1 && projectObjectType.statusReadOnlyWhiteListedPositions && projectObjectType.statusReadOnlyWhiteListedPositions.length >= 2"
              class="primary--text text-caption"
            >{{ projectObjectType.statusReadOnlyWhiteListedPositions.length }} selected</span>
          </template>
        </v-autocomplete>
        <br/>
        <v-btn color="primary" dark class="d-inline-block white--text"
               @click="saveReadOnlyAndWhiteList()">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-card-text>
    </v-card>
    <v-card flat color="primary lighten-9" class="square-card mt-5">
      <v-card-title style="height: 40px" class="py-0">
        Owner Read Only
        <v-checkbox type="checkbox" class="ml-3"
                    v-model="projectObjectType.ownerReadOnly"></v-checkbox>
      </v-card-title>
      <v-card-text>
        <v-autocomplete
          v-if="projectObjectType.ownerReadOnly"
          v-model="projectObjectType.ownerReadOnlyWhiteListedPositions"
          :items="positions"
          :loading="positionsLoading"
          multiple
          clearable
          label="White Listed Positions"
          item-text="position"
          item-value="positionId"
          return-object
          height="35px"
          class="d-inline-block mr-3"
          @change="ownerReadOnlyPositionsChanged = true">
          <v-list-item
            slot="prepend-item"
            ripple
            @click="toggleSelectAllPositionsOwner()"
          >
            <v-list-item-action>
              <v-icon>{{ icon(projectObjectType) }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
            slot="prepend-item"
            class="mt-2"
          ></v-divider>
          <template
            slot="selection"
            slot-scope="{ item, index }"
          >
            <v-chip small
                    v-if="index === 0 && projectObjectType.ownerReadOnlyWhiteListedPositions && projectObjectType.ownerReadOnlyWhiteListedPositions.length < 2">
              <span>{{ item.position }}</span>
            </v-chip>
            <span
              v-if="index === 1 && projectObjectType.ownerReadOnlyWhiteListedPositions && projectObjectType.ownerReadOnlyWhiteListedPositions.length >= 2"
              class="primary--text text-caption"
            >{{ projectObjectType.ownerReadOnlyWhiteListedPositions.length }} selected</span>
          </template>
        </v-autocomplete>
        <br/>
        <v-btn color="primary" dark class="d-inline-block white--text"
               @click="saveOwnerReadOnlyAndWhiteList()">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-card-text>
    </v-card>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import cloneDeep from 'lodash.clonedeep'
  import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'ProjectSystem',

    data() {
      return {
        snackbar: {},
        positions: [],
        projectObjectType: {},
        statusReadOnlyWhiteListedPositions: [],
        statusReadOnlyPositionsChanged: false,
        ownerReadOnlyPositionsChanged: false,
        ownerReadOnlyWhiteListedPositions: [],
        positionsLoading: false,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),

      }
    },
    computed: {},
    async created() {
      this.getPositions()
      this.getObjectTypeDetails()
    },
    methods: {
      selectAll () {
        return this.statusReadOnlyWhiteListedPositions?.length === this.positions?.length
      },
      selectSome (f) {
        return this.statusReadOnlyWhiteListedPositions?.length > 0 && !this.selectAll(f)
      },
      icon (f) {
        if (this.selectAll(f)) {
          return 'check_box'
        }
        if (this.selectSome(f)) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      toggleSelectAllPositions () {
        this.$nextTick(() => {
          if (this.selectAll()) {
            this.statusReadOnlyWhiteListedPositions = []
          } else {
            this.statusReadOnlyWhiteListedPositions = cloneDeep(this.positions)
            this.statusReadOnlyPositionsChanged = true
          }
        })
      },
      toggleSelectAllPositionsOwner () {
        this.$nextTick(() => {
          if (this.selectAll()) {
            this.ownerReadOnlyWhiteListedPositions = []
            this.ownerReadOnlyPositionsChanged = true
          } else {
            this.ownerReadOnlyWhiteListedPositions = cloneDeep(this.positions)
            this.ownerReadOnlyPositionsChanged = true
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
      async saveReadOnlyAndWhiteList () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/objectType/saveStatusReadOnlyAndWhiteList?savePositions=${this.statusReadOnlyPositionsChanged ?? false}`, this.projectObjectType)
          this.statusReadOnlyPositionsChanged = false
          if(!this.projectObjectType.statusReadOnly) {
            this.statusReadOnlyWhiteListedPositions = []
          }
          this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOwnerReadOnlyAndWhiteList () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/objectType/saveOwnerReadOnlyAndWhiteList?savePositions=${this.ownerReadOnlyPositionsChanged ?? false}`, this.projectObjectType)
          this.ownerReadOnlyPositionsChanged = false
          if(!this.projectObjectType.ownerReadOnly) {
            this.ownerReadOnlyWhiteListedPositions = []
          }
          this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getObjectTypeDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/objectType/getByType/1`)
          this.projectObjectType = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
  }
</script>
