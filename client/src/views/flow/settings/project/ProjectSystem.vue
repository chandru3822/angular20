<template>
  <v-container class="custom-field-group-container">
    <v-card flat color="primary lighten-9" class="square-card">
      <v-card-text>
        <multi-select-group
        v-if="!objectTypeDetailsLoading"
        background-color="primary lighten-9"
        :userCanEdit="userCanEdit"
        :returnObject="projectObjectType"
        :content="positions"
        :dropdownEnabled="projectObjectType.statusReadOnly"
        :selectedContent="projectObjectType.statusReadOnlyWhiteListedPositions"
        :title="'Status Read Only'"
        :label="'Allowed Positions'"
        :alternateLabel = "'Denied Positions'"
        user
        :allow="projectObjectType.statusReadOnlyAllow"
        :contentLoading="objectTypeDetailsLoading"
        @selected-changed="statusReadOnlySelectedEventListener"
        @allow-changed="statusReadOnlyAllowEventListener"
        @checkbox-changed="statusReadOnlyCheckboxEventListener"></multi-select-group>
        <br/>
        <v-btn v-if="userCanEdit" color="primary" dark class="d-inline-block white--text"
               @click="saveReadOnlyAndWhiteList()">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-card-text>
    </v-card>
    <v-card flat color="primary lighten-9" class="square-card mt-5">
      <v-card-text>
        <multi-select-group
          v-if="!objectTypeDetailsLoading"
          background-color="primary lighten-9"
          :userCanEdit="userCanEdit"
          :returnObject="projectObjectType"
          :content="positions"
          :dropdownEnabled="projectObjectType.ownerReadOnly"
          :selectedContent="projectObjectType.ownerReadOnlyWhiteListedPositions"
          :title="'Owner Read Only'"
          :label="'Allowed Positions'"
          :alternateLabel = "'Denied Positions'"
          :allow="projectObjectType.ownerReadOnlyAllow"
          :contentLoading="objectTypeDetailsLoading"
          @selected-changed="ownerReadOnlySelectedEventListener"
          @allow-changed="ownerReadOnlyAllowEventListener"
          @checkbox-changed="ownerReadOnlyCheckboxEventListener"></multi-select-group>
        <br/>
        <v-btn v-if="userCanEdit" color="primary" dark class="d-inline-block white--text"
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
        objectTypeDetailsLoading: false

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
          this.objectTypeDetailsLoading = true;
          const {data, status} = await getRequest(`/objectType/getByType/1`)
          this.projectObjectType = data
          handleHidingGlobalLoader(this, status)
          this.objectTypeDetailsLoading = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      statusReadOnlySelectedEventListener(e){
        this.projectObjectType.statusReadOnlyWhiteListedPositions = e;
        this.statusReadOnlyPositionsChanged = true;
      },
      statusReadOnlyAllowEventListener(e){
        this.projectObjectType.statusReadOnlyAllow = (e === 0);
      },
      statusReadOnlyCheckboxEventListener(e){
        this.projectObjectType.statusReadOnly = e;
      },
      ownerReadOnlySelectedEventListener(e){
        this.projectObjectType.ownerReadOnlyWhiteListedPositions = e;
        this.ownerReadOnlyPositionsChanged = true;
      },
      ownerReadOnlyAllowEventListener(e){
        this.projectObjectType.ownerReadOnlyAllow = (e === 0);
      },
      ownerReadOnlyCheckboxEventListener(e){
        this.projectObjectType.ownerReadOnly = e;
      },
    },
  }
</script>
