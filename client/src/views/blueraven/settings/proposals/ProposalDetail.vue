<template>
  <div>
    <v-btn text class="pl-1 pr-2" @click="$router.back()">
      <v-icon>arrow_left</v-icon>
      <span>Back</span>
    </v-btn>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title v-if="detail">
        <span class="app-title">Version {{ detail.version }}</span>
        <v-chip label>{{ detail.status | capitalize }}</v-chip>
        <v-chip class="ma-2" color="blue" label v-if="detail.primaryVersion">
          Current
        </v-chip>
      </v-toolbar-title>
      <v-spacer />
      <v-toolbar-items v-if="detail && detail.status === 'DRAFT'">
        <v-dialog persistent max-width="600px" v-model="confirmation">
          <template #activator="{on}">
            <v-btn text v-on="on">
              Publish
            </v-btn>
          </template>
          <template #default>
            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text>
                <v-row align="center" class="pt-4">
                  <div>Are you sure you want to publish this version?</div>
                </v-row>
              </v-card-text>
              <v-card-actions class="justify-end">
                <v-btn
                  text
                  @click="confirmation = false"
                >Cancel
                </v-btn>
                <v-btn
                  color="primaryButton"
                  @click="publish(detail.id)"
                  dark
                >Publish
                </v-btn>
              </v-card-actions>

            </v-card>
          </template>
        </v-dialog>
      </v-toolbar-items>
    </v-toolbar>
    <v-card v-if="detail">
      <div class="top-actions" v-if="detail && detail.status === 'DRAFT'">

<!--        TODO: add in later -->
<!--        <v-dialog persistent max-width="600px" v-model="undoDraftChanges">-->
<!--          <template v-slot:activator="{ on, attrs }">-->
<!--            <v-btn v-on="on" v-bind="attrs">-->
<!--              Undo All Changes-->
<!--            </v-btn>-->
<!--          </template>-->
<!--          <template #default>-->
<!--            <v-card>-->
<!--              <v-card-title-->
<!--                class="headline grey lighten-2"-->
<!--                primary-title-->
<!--              >-->
<!--                Confirm-->
<!--              </v-card-title>-->

<!--              <v-card-text>-->
<!--                <v-row align="center" class="pt-4">-->
<!--                  <p>Are you sure you want to undo all changes to this draft? This action is <b>irreversible</b>! </p>-->
<!--                </v-row>-->
<!--              </v-card-text>-->
<!--              <v-card-actions class="justify-end">-->
<!--                <v-btn-->
<!--                  text-->
<!--                  @click="undoDraftChanges = false"-->
<!--                >Cancel-->
<!--                </v-btn>-->
<!--                <v-btn-->
<!--                  color="red"-->
<!--                  @click="undoAllChanges"-->
<!--                  dark-->
<!--                >Yes-->
<!--                </v-btn>-->
<!--              </v-card-actions>-->
<!--            </v-card>-->
<!--          </template>-->
<!--        </v-dialog>-->

        <v-btn color="primary" dark @click.prevent="visible = true">
          Add New
        </v-btn>
        <NewProposalValueDialog
          :visible="visible"
          :editing="editedItem"
          :object-code="propType.code"
          @input="doInput"
          @save="doSaveValues" />
      </div>
      <v-dialog persistent max-width="600px" v-model="deleteGroupConfirmation">
        <template #default>
          <v-card>
            <v-card-title
              class="headline grey lighten-2"
              primary-title
            >
              Confirm
            </v-card-title>

            <v-card-text>
              <v-row align="center" class="pt-4">
                <p>Are you sure you want to delete this record? It <b>will not</b> be available in future versions.</p>
              </v-row>
            </v-card-text>
            <v-card-actions class="justify-end">
              <v-btn
                text
                @click="deleteGroupConfirmation = undefined"
              >Cancel
              </v-btn>
              <v-btn
                color="red"
                @click="archiveItem(selectedDeleteItem)"
                dark
              >Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </template>
      </v-dialog>
      <v-tabs
        background-color="transparent"
        v-model="tab"
        show-arrows
        @change="changer"
      >
        <v-tab class="text-capitalize ma-0" v-for="t in types" :key="t.id">{{ t.name }}</v-tab>
      </v-tabs>
      <v-tabs-items v-model="tab">
        <v-tab-item v-for="t in types" :key="t.id">
          <v-card color="basil" flat>
            <v-data-table
              :headers="headers"
              :items="values"
              :options.sync="options"
              :search="search"
              :custom-filter="filterItems"
              class="elevation-1"
            >
              <template #top>
                <v-container fluid>
                  <v-row>
                    <v-col cols="12">
                      <v-text-field
                        v-model="search"
                        prepend-inner-icon="search"
                        label="Search"
                        class="mx-4 my-4"
                        single-line
                        clearable
                        hide-details
                      />
                    </v-col>
<!--                    <v-col cols="4">-->
<!--                      <v-switch-->
<!--                        v-model="modifiedOnlyFilter"-->
<!--                        inset-->
<!--                        :label="`${!modifiedOnlyFilter ? 'Show Modified Only' : 'Show All'}`"-->
<!--                      ></v-switch>-->
<!--                    </v-col>-->
                  </v-row>
                </v-container>

              </template>

              <template #item="{item, headers}">
                <tr class="clickable">
                  <td v-for="header in headers">
                    <span class="row-actions" v-if="header.value === 'actions'">
                        <v-btn small text @click.prevent="deleteItem(item)" v-if="item.versionId === detail.id">
                           <v-icon>mdi-undo</v-icon>
                      </v-btn>

                      <v-btn small text @click="archiveItemConfirm(item)">
                        <v-icon>mdi-delete</v-icon>
                      </v-btn>
                    </span>

                    <span v-if="item[header.value]" @click.prevent="editItem(item)">
                      {{ item[header.value] | customValueFormatter }}
                    </span>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
        </v-tab-item>
      </v-tabs-items>
    </v-card>
    <v-card v-if="!detail">
      <v-card-text>This isn't the proposal version you are looking for...</v-card-text>
    </v-card>
  </div>
</template>
<script>
import { deleteRequestWithPayload, getRequestWithParams, getSnackbar, postRequest } from "@/helpers/helpers";
import NewProposalValueDialog from "./NewProposalValueDialog.vue";
import { AppMutations } from "@/stores/AppStore";

const defaultActionColumn = { txt: "Actions", value: "actions", sortable: false };

const sorterFn = (fieldCode) => {
  return (a, b) => {
    if (a[fieldCode]?.value < b[fieldCode]?.value) {
      return -1;
    }

    if (a[fieldCode]?.value > b[fieldCode]?.value) {
      return 1;
    }
    return 0;
  };
};

let headerSort = (a, b) => {
  if (a?.value < b?.value) {
    return -1;
  }

  if (a?.value > b?.value) {
    return 1;
  }

  return 0;
};

export default {
  name: "ProposalDetail",
  components: { NewProposalValueDialog },
  props: ["id"],
  filters: {
    capitalize: (value) => {
      if (!value) return;
      return value[0].toUpperCase() + value?.slice(1).toLowerCase();
    },
    customValueFormatter: ({ value, type }) => {
      if (Array.isArray(value)) {
        return value?.join(", ");
      }

      if (type === "timestamp") {
        return new Intl.DateTimeFormat("default", {
          dateStyle: "short",
          timeStyle: "short"
        }).format(new Date(value));
      }
      return value;
    }
  },
  created() {
    this.getProposalDetail(this.id);
    this.getProposalObjectTypes();
  },
  data() {
    return {
      search: "",
      options: {},
      detail: {},
      tab: null,
      headers: [],
      values: [],
      types: [],
      confirmation: false,
      visible: false,
      editedItem: undefined,
      modifiedOnlyFilter: false,
      deleteGroupConfirmation: false,
      undoDraftChanges: false
    };
  },
  computed: {
    propType() {
      return this.types[this.tab] ?? {};
    }
  },
  methods: {
    async changer(val) {
      const requests = [];
      const { code } = this.propType;

      if (code) {
        requests.push(this.getProposalObjectTypeFields(code));
        requests.push(this.getProposalObjectTypeFieldValues(this.id, code));
        await Promise.all(requests);
      }
    },

    filterItems(value, search, item) {
      return Object.values(item)
        .filter(v => v.value !== undefined)
        .some(v => {
          if (Array.isArray(v.value)) {
            const needle = search?.toLowerCase();
            return v.value?.some(f => f.toLowerCase().indexOf(needle) > -1);
          }
          if (v.type === "text" || v.type === "system") {
            const needle = search?.toLowerCase();
            return v?.value?.toLowerCase().indexOf(needle) > -1;
          }
          return false;
        });
    },

    editItem(item) {
      this.visible = true;
      this.editedItem = { ...item };
    },

    async archiveItemConfirm(item) {
      this.selectedDeleteItem = item
      this.deleteGroupConfirmation = true
    },

    async archiveItem(item) {
      const { data } = await postRequest(`/proposals/${this.id}/values/${this.propType.code}/${item.pk}/archive`, undefined, 'blueraven');
      const pk = data?.pk || item.pk;
      const values = this.values?.filter(v => v.pk !== pk) ?? [];

      const sortHeader = this.headers.find(h => h.fieldOrder === 1);
      values.sort(sorterFn(sortHeader?.value));

      this.values = values;
      this.selectedDeleteItem = undefined
      this.deleteGroupConfirmation = false
    },

    async deleteItem(item) {
      const { data } = await deleteRequestWithPayload(`/proposals/${this.id}/values/${this.propType.code}/${item.pk}`, "blueraven");
      const pk = data?.pk || item.pk;
      const values = this.values?.filter(v => v.pk !== pk) ?? [];

      if (data) {
        const { versionId, row } = data;
        values.push({ pk, versionId, ...row });
      }

      const sortHeader = this.headers.find(h => h.fieldOrder === 1);
      values.sort(sorterFn(sortHeader?.value));

      this.values = values;
    },

    async undoAllChanges(){
      this.undoDraftChanges = false
    },

    async getProposalDetail(proposalVersionId) {
      const { data } = await getRequestWithParams(`/proposals/${proposalVersionId}`, {}, "blueraven");
      this.detail = data ? { ...data } : null;
    },

    async getProposalObjectTypes() {
      const { data } = await getRequestWithParams("/proposals/types", {}, "blueraven");
      this.types = [...data];
    },

    async getProposalObjectTypeFields(objectType) {
      const { data } = await getRequestWithParams(`/proposals/fields/${objectType}`, {}, "blueraven");

      let headers = data?.length > 0
        ? data.map(r => ({
          text: r.fieldName,
          sortable: true,
          fieldOrder: r.fieldOrder,
          sort: headerSort,
          value: r.id
        }))
        : [];

      headers.sort((a, b) => a.fieldOrder - b.fieldOrder);

      if (this.detail.status === "DRAFT") {
        headers.push(defaultActionColumn);
      }
      this.headers = headers;
    },

    async getProposalObjectTypeFieldValues(proposalVersionId, objectType) {
      const { data } = await getRequestWithParams(`/proposals/${proposalVersionId}/values/${objectType}`, {}, "blueraven");
      let values = data.map(({ pk, versionId, row }) => ({ pk, versionId, ...row }));
      const sortHeader = this.headers.find(h => h.fieldOrder === 1);
      values.sort(sorterFn(sortHeader?.value));
      this.values = values;
    },

    async publish(proposalVersionId) {
      const { data } = await postRequest(`/proposals/${proposalVersionId}/publish`, {}, "blueraven");
      this.detail = { ...data };
    },

    async doInput(val) {
      this.visible = val;
      if (!val) {
        this.editedItem = undefined;
      }
    },

    async doSaveValues(group) {
      try {
        const { data = {} } = await postRequest(`/proposals/${this.detail.id}/values/${this.propType.code}`, group, "blueraven");
        const { pk, versionId, row } = data;
        const sortHeader = this.headers.find(h => h.fieldOrder === 1);
        const values = this.values?.filter(v => v.pk !== pk) ?? [];
        values.push({ pk, versionId, ...row });
        values.sort(sorterFn(sortHeader?.value));
        this.values = values;
      } catch (e) {
        const snackbar = getSnackbar("ERROR", "Error Updating Proposal Version Fields");
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar);
      }
    }
  }
};
</script>
<style scoped lang="scss">
@import "@/styles/main.scss";

.top-actions {
  padding: 10px;
  display: flex;
  justify-content: flex-end;

  & > .v-btn {
    margin: 0 10px;
  }
}


.row-actions {
  display: flex;
  justify-content: flex-end;
}

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 380px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
