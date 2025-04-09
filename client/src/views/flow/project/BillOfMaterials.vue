<script setup>
/*
*@name ProjectTabBillOfMaterials
*@author jess
*@date 2/11/25
*
*@description
*
*/

import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";
import {useRoute} from "vue-router/composables";
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {getRequest, getRequestWithParams, postRequest, apiRequest, logError} from "@/helpers/helpers.js";
import SpinnerInline from '@/components/SpinnerInline'
import cloneDeep from "lodash.clonedeep";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import BillOfMaterialsEditView from "@/views/flow/project/BillOfMaterialsEditView.vue";
import VueClamp from 'vue-clamp'
import BillofMaterialsExportDialog from "@/views/flow/project/BillofMaterialsExportDialog.vue";




const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const bomLoading = ref(false)
const partsMasterLoading = ref(false)
const bomParts = ref([])
const partsTypes = ref([])
const suppliers = ref([])
const partsMasterParts = ref([])
const permitPackIds = ref([])
const selectedPermitPack = ref(null)
const editMode = ref(false)
const addPart = ref(false)
const duplicatedPart = ref(false)
const showExportDialog = ref(false)
const projectName = ref(null)




const headers = ref([
  { text: 'Description', value: 'description', show: true },
  { text: 'Part Number', value: 'partNumber', show: true, width: 160 },
  { text: 'Manufacturer', value: 'brand', show: true},
  { text: 'Quantity', value: 'quantity', show: true, width: 80},
  { text: 'Supplier', value: 'supplierName', show: true},
  { text: 'Confirmed', value: 'supplierConfirmed', show: true, width: 80 },
])

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('BILL_OF_MATERIALS', 'EDIT')
})

watch(selectedPermitPack, async () => {
  if(selectedPermitPack.value) {
    bomLoading.value = true
    await getParts()
    bomLoading.value = false
  }
})


onMounted(async() =>{
  bomLoading.value = true
  await getPartsTypes()
  await getSuppliers()
  await getProject()
  await getPermitPackIds()
  bomLoading.value = false
})


const getParts = async () => {
  try {
    const { data } = await getRequest(`/bom/${projectId.value}/${selectedPermitPack.value.id}`, 'blueraven', [])
    bomParts.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading BOM')
  }
}

const getPartsTypes = async () => {
  try {
    const {data} = await getRequestWithParams(
        '/partsMaster/versions/types',
        {},
        'blueraven'
    )
    partsTypes.value = [...data]
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading part types')
  }
}

const getSuppliers = async () => {
  try {
    const {data, status} = await getRequest('/featDb/supplier/list/all', 'blueraven')
    suppliers.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading suppliers')
  }
}

const getProject = async () => {
  try{
    const {data} = await getRequest(`/project/${projectId.value}`)
    projectName.value = data?.projectName
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error getting project info')
  }
}

const getPermitPackIds = async () => {
  try{
    const {data} = await getRequest(`/bom/${projectId.value}/permitPackLogNumbers`, 'blueraven', [])
    permitPackIds.value = data
    selectedPermitPack.value = permitPackIds.value?.find(ppid => ppid.primary)
  }catch (e) {

  }
}

const getPartsMasterParts = async () => {
  if(partsMasterParts.value?.length === 0) {
    partsMasterLoading.value = true
    try {
      const {data} = await getRequest('/partsMaster/versions/allParts', 'blueraven')
      partsMasterParts.value = data
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error loading parts master list')
    }
    partsMasterLoading.value = false
  }
}


const confirmDuplicate = () => {
  duplicatedPart.value = null

}


const openAddForm = () => {
  addPart.value = true
  editMode.value = true
  getPartsMasterParts()
}

const cancel = () => {
  addPart.value = false //turn off add parts
  editMode.value = false //turn off edit mode
}

const afterSave = ($event) => {
  //this makes it update in the child (edit) view
  bomParts.value.splice(0)
  bomParts.value = bomParts.value.concat($event)

}

const exportPdf = async ($event) => {
  try {
    appStore.loading = true
    const { data, headers } = await apiRequest('blueraven', {
      method: 'post',
      url: `/bom/${projectId.value}/pdf`,
      data: $event,
      responseType: 'blob'
    })
    const filename = `${projectName.value}_${projectId.value}_bom`
    if (data) {
      const pdfFile = URL.createObjectURL(
          new Blob([data], { type: 'application/pdf' })
      )
      const docUrl = document.createElement('a')
      docUrl.href = pdfFile
      docUrl.setAttribute('download', filename)
      document.body.appendChild(docUrl)
      docUrl.click()
      setTimeout(() => {
        docUrl.remove()
        URL.revokeObjectURL(pdfFile)
      }, 100)

      showExportDialog.value = false
      appStore.showSnack('SUCCESS', 'Materials List Downloaded')
    }
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Downloading Pdf')
  } finally {
    appStore.loading = false
  }
}


</script>

<template>
  <div id="project-bom-container" class="pa-0 mx-6">
    <div class="pa-0 height-one-hunned">
      <div class="project-header">
        <v-toolbar
            color="transparent"
            class="elevation-0 bom-toolbar"
        >
          <v-toolbar-title class="title-large">
            <span>BOM</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <div>
            <a-btn v-if="userCanEdit" prepend-icon="mdi-list-box-outline" text="Export Material List" :disabled="editMode" @click="showExportDialog = true"></a-btn>
          </div>
        </v-toolbar>
      </div>

    </div>
    <v-container v-if="!editMode" class="px-0">
    <v-row
        no-gutters
        class="py-0 relative overflow-y-auto"
    >
      <v-toolbar
          color="transparent"
          class="elevation-0 bom-toolbar"
      >
        <v-toolbar-title class="headline-small d-flex align-baseline">
          <span >Bill of Materials</span>
          <v-select
              v-if="permitPackIds?.length > 0"
              :items="permitPackIds"
              filled
              v-model="selectedPermitPack"
              return-object
              dense
              hide-details
              :disable="permitPackIds?.length <= 1"
              class="permit-pack-id-select pl-2"
          >
            <template v-slot:item="{item}">
              <span class="body-medium grey--text text--darken-1 pl-2">#{{item.permitPackLogNbr}}</span>
            </template>
            <template v-slot:selection="{item}">
              <span class="body-medium primary--text pl-2">#{{item.permitPackLogNbr}}</span>
            </template>
          </v-select>
          <span v-else class="body-medium grey--text text--darken-1 pl-2">#{{selectedPermitPack?.permitPackLogNbr}}</span>
          <a-btn @click="openAddForm" size="small" variant="text" prepend-icon="mdi-plus" text="Add Part"/>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn v-if="userCanEdit && !editMode" @click="editMode = true" variant="outlined" prepend-icon="mdi-pencil" text="Edit"></a-btn>
        </div>
      </v-toolbar>
    </v-row>

    <v-col v-if="bomLoading" class="d-flex justify-center">
      <SpinnerInline :size="20" color="primary" class="d-flex justify-center"/>
    </v-col>
    <div v-else-if="bomParts?.length === 0" class="grey--text body-medium">
      No BOM Available
    </div>
    <div v-else class="bom-parts-table-container">
      <v-data-table
          id="bom-parts-table"
          :items="bomParts"
          :headers="headers"
          group-by="objectType"
          :items-per-page="-1"
          disable-sort
          fixed-header
          hide-default-footer
          item-key="index"
          class="table-striped elevation-1"
      >
        <template v-slot:group.header="{ groupBy, group, headers, isOpen=true, toggle, remove }">
          <td :colspan="headers.length" class="grey lighten-5 group-header clickable" @click="toggle">
            <div class="one-hunned d-flex grey--text text--darken-1">
              <v-icon color="grey darken-1" v-if="isOpen">mdi-chevron-up</v-icon>
              <v-icon v-else color="grey darken-1">mdi-chevron-down</v-icon>
            {{ group }}
            </div>
          </td>
        </template>
        <template #item.description="{ item }">
          <v-tooltip top max-width="240">
            <template v-slot:activator="{ on, attrs }">
              <span v-bind="attrs" v-on="on">
          <vue-clamp autoresize :max-lines="3">
            {{item.description}}
          </vue-clamp>
              </span>
            </template>
            <!--tooltip text-->
            {{item.description}}
          </v-tooltip>
        </template>
        <template #item.quantity="{ item }">
          <td class="text-end">
            <a-text-field
                v-if="editMode"
                type="number"
                :value="item.quantity"
                @input="populateDirtyRows($event, item, 'quantity')"
            />
            <span v-else>{{item.quantity}}</span>
          </td>
        </template>
        <template #item.supplierName="{ item }">
          <td class="supplier-col">
          <a-autocomplete
              v-if="editMode"
              :value="item.supplierId"
              :items="suppliers"
              item-title="name"
              item-value="id"
              placeholder="Unspecified"
              clearable
              @input="populateDirtyRows($event, item, 'supplierId')"
          />
          <span v-else-if="!item.supplierName" class="grey--text body-large">Unspecified</span>
          <span v-else>{{item.supplierName}}</span>
          </td>
        </template>
        <template #item.supplierConfirmed="{ item }">
          <td class="text-end">
            <v-simple-checkbox
              dense
              hide-details
              :value="item.supplierConfirmed"
              @input="populateDirtyRows($event, item, 'supplierConfirmed')"
              :disabled="!editMode || !item.supplierId"
          ></v-simple-checkbox>
          </td>
        </template>

      </v-data-table>
    </div>
    </v-container>
    <BillOfMaterialsEditView v-else :projectId="projectId"
                             :bomParts="bomParts"
                             :headers="headers"
                             :showAddPart="addPart"
                             :suppliers="suppliers"
                             :selectedPermitPack="selectedPermitPack"
                             :partsMasterParts="partsMasterParts"
                             :partsMasterLoading="partsMasterLoading"
                             @openAddForm="openAddForm"
                             @cancel="cancel"
                             @save="afterSave"
                             @hideAddPart="addPart = false"
    />
    <ConfirmationDialog :open-dialog="!!duplicatedPart"
                        hideCancel
                        @confirm="[duplicatedPart = null]"
                        @close-dialog="confirmDuplicate"
    >
      <template v-slot:title>Duplicate Material</template>
      <template v-slot>
        This material already exists in the BOM.  The quantity will be updated from {{duplicatedPart?.quantity}} to {{duplicatedPart?.updatedQuantity}}.
      </template>
      <template v-slot:yes>Okay</template>
    </ConfirmationDialog>
    <BillofMaterialsExportDialog :openDialog="showExportDialog"
                                 :bomParts="bomParts" :headers="headers"
                                 @download="exportPdf" @close="showExportDialog = false"
    />
  </div>
</template>

<style scoped lang="scss">
::v-deep {
  .v-data-table__wrapper {
    max-height: calc(100vh - 300px);
    //min-height: 300px;
  }
  .supplier-col {
    min-width: 135px;
  }
}
.new-part-autocomplete {
  max-width: 800px;
}
.new-part-quantity {
  max-width: 6rem;
}
.permit-pack-id-select{
  max-width:110px;
}
</style>

<style lang="scss">
.bom-toolbar .v-toolbar__content {
  padding-left: 0px !important;
  padding-right: 0px !important;
}
#bom-parts-table > div.v-data-table__wrapper > table > tbody > tr > td.group-header {
  border-top: 1px solid var(--v-grey-lighten1) !important;
}
</style>
