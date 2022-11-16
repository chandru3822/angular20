<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-container id="ahj-hoa-details-container">
    <v-row>
      <v-col cols="12" class="pa-0">

        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-card class="mx-4 square-card">
              <v-toolbar flat>
                <v-toolbar-title class="app-title">
                  <v-btn fab text color="primary" small class="mr-2" @click="$router.push({path: '/ahj/hoa'})">
                    <v-icon>mdi-arrow-left</v-icon>
                  </v-btn>
                  {{ ahjHoa.name }}, {{ ahjHoa.state }}, {{ ahjHoa.managementCompany }}
                </v-toolbar-title>
              </v-toolbar>
            </v-card>
          </v-col>
        </v-row>
        <v-row dense>
          <v-card class="mx-2 px-2 py-3 one-hunned square-card">
            <v-row no-gutters>
              <v-col class="ahj-form-btns" cols="12">
                <v-btn text color="primary" class="text-capitalize" @click="toggleMinimizeAll">
                  {{ expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All' }}
                </v-btn>
                <v-btn v-if="dataWasChanged"
                       @click="resetForm"
                       text
                       color="primary"
                       class="cancel-link"
                       style="margin-right: 10px"
                >Cancel
                </v-btn>
                <v-btn id="save-btn"
                       v-if="userCanEdit"
                       color="primary"
                       class="white--text mr-0"
                       @click="validateForm()"
                >Save
                </v-btn>
              </v-col>
            </v-row>
            <v-form ref="ahjHoaForm">
              <!-- UPPER SECTION -->
              <v-row class="mb-4 group-row" no-gutters>
                <TwoColumnMasonry v-if="dataReady"
                                  :custom-field-groups="customFieldGroups"
                                  :user-can-edit="userCanEdit"
                                  :expanded-all="expandedAll"
                                  :callback="(field) => updateDirtyValue(field)"
                                  @toggle-collapse-expand="toggleCollapseExpand($event)"
                ></TwoColumnMasonry>
                <!--              <v-col cols="12" md="6" class="group px-2 py-2" v-for="group in customFieldGroups">-->
                <!--                <AhjCustomFields :group = group-->
                <!--                         :user-can-edit="userCanEdit"-->
                <!--                         :expanded-all="expandedAll"-->
                <!--                         :callback="(field) => updateDirtyValue(field)"-->
                <!--                         @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"-->
                <!--                ></AhjCustomFields>-->
                <!--              </v-col>-->
              </v-row>
            </v-form>
          </v-card>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import cloneDeep from "lodash.clonedeep"
import orderBy from "lodash.orderby"
import {AppMutations} from "@/stores/AppStore"
import {getRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers"
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue"
import AhjCustomFields from "@/views/blueraven/ahj/components/AhjCustomFieldGroup";
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";
import AhjCard from "@/views/blueraven/ahj/components/AhjCard";
import TwoColumnMasonry from "@/views/blueraven/ahj/components/TwoColumnMasonry";

export default {
  name: "ahjHoaDetails",
  components: {
    TwoColumnMasonry,
    AhjCustomFields,
    CustomValueInput,
    AhjCard
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel("AHJ_DATABASE", "EDIT")
    },
    expandedAll(){
      if(this.expandedGroups === this.totalGroups){
        return CollapseExpandEnum.EXPANDED
      } else if (this.expandedGroups === 0) {
        return CollapseExpandEnum.COLLAPSED
      } else {
        return CollapseExpandEnum.MIXED
      }
    }
  },
  data: () => ({
    CollapseExpandEnum,
    ahjHoaId: null,
    itemType: "hoa",
    snackbar: {},
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    ahjHoa: {},
    totalGroups: 2,
    expandedGroups: 2,
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    toggleCollapseExpand(wasExpanded) {
      if(wasExpanded === false) {
        this.expandedGroups--
      }else {
        this.expandedGroups++
      }
    },
    async getAhjHoa() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/ahjHoa/${this.ahjHoaId}`, "blueraven")
        this.ahjHoa = cloneDeep(data)
        window.document.title = `AHJ HOA - ${this.ahjHoa.name}`
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving AHJ HOA")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.ahjHoaForm.validate()) {
        this.saveAhjHoa()
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCustomFieldGroupAssignmentsForScreen() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjHoa.id, objectTypeId: 24}
        const {
          data,
          status
        } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, "blueraven")
        this.customFieldGroups = cloneDeep(data)
        this.totalGroups = this.totalGroups + this.customFieldGroups.length;
        this.expandedGroups = this.totalGroups;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving custom fields")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getCustomFieldsForGroup(groupId) {
      let match = this.customFieldGroups.find(cfga => cfga.id === groupId)
      return match ? match.customFieldValues : []
    },
    showOtherField(int, list) {
      let match = list.find(l => l.id === int)
      return match ? match.showOther : false
    },
    resetCustomFieldValueWasChangedFlags() {
      this.customFieldGroups.forEach(group => {
        group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
      })
    },
    async resetForm() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.dataWasChanged = false
      this.dataReady = false
      this.getAhjHoa().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
      })
    },
    async saveAhjHoa() {
      this.$store.commit(AppMutations.SET_LOADING, true)

      try {
        this.ahjHoa.customFieldGroups = this.customFieldGroups
        const {data, status} = await putRequest("/ahjHoa", this.ahjHoa, "blueraven")
        this.ahjHoa = cloneDeep(data)
        this.dataWasChanged = false
        this.snackbar = getSnackbar("SUCCESS", "AHJ HOA saved")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error saving AHJ HOA")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    toggleMinimizeAll() {
      if (this.expandedAll !== CollapseExpandEnum.COLLAPSED) {
        this.expandedGroups = 0
      } else {
        this.expandedGroups = this.totalGroups
      }
    }
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.ahjHoaId = parseInt(this.$route.params.ahjHoaId)

    await this.getAhjHoa()
    await this.getCustomFieldGroupAssignmentsForScreen()
    this.dataReady = true
  }
}
</script>

<style scoped lang="scss">
#ahj-hoa-details-container {
  padding-right: 9px;
  padding-left: 9px;
  padding-top: 10px;
}

#back-btn {
  text-transform: unset;
  letter-spacing: unset;

  &:before {
    background-color: initial;
  }

  #back-btn-text:hover {
    text-decoration: underline;
  }
}

.page-title {
  font-size: 32px;
  font-weight: 200;
}

.page-info {
  font-family: 'Roboto Condensed', sans-serif;
  font-size: 20px;
  text-align: right;
}

#hoa-tab-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}

.ahj-form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 10px;
}

#save-btn {
  margin: 0 5px 0 0;
  text-transform: capitalize;
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-text-field,
.v-select,
.v-input ::v-deep label,
.v-list-item__title,
.list-link {
  font-size: 0.95em !important;
}

.cancel-link {
  font-size: 0.85em !important;
}

.cancel-link:hover {
  text-decoration: underline;
}

.link-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;

  button {
    margin: 0 0 0 7px;
  }
}

.custom-field {
  width: 48%;
}

.other-field {
  margin-top: -20px;
}

.group-row {
  justify-content: space-between;
}

.col-gap {
  width: 3em;
}

.lower-section {
  border-bottom: 1px solid #ccc;
  width: 100%;
}

.v-input--is-disabled ::v-deep .v-input__slot,
.v-input--is-disabled ::v-deep input {
  cursor: not-allowed;
  pointer-events: all;
}

.v-input--is-disabled ::v-deep label {
  color: rgba(0, 0, 0, 0.38) !important;
}
</style>
