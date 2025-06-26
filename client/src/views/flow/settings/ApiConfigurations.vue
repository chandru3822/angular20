<template>
  <div class="configurations-container">
    <div class="configurations-header">
      <h1>Api Configurations</h1>
    </div>
    <div class="configurations-content">
      <h3 class="table-title">API Config Type</h3>
      <table class="api-config-table">
        <thead>
        <tr>
          <th>Name</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="item in apiConfigTypes"
            :key="item.id"
            @click="selectConfigType(item)"
            :class="{'selected-row': selectedConfigType && selectedConfigType.id === item.id}">
          <td>{{ item.name }}</td>
        </tr>
        </tbody>
      </table>

      <!-- Second table that appears only when a row is selected -->
      <div v-if="selectedConfigType" class="second-table-container">
        <div class="table-header">
          <h3 class="table-title">
            API Config - {{ selectedConfigType ? selectedConfigType.name : '' }}
          </h3>
          <v-btn
            color="primary"
            @click="openAddDialog"
            class="add-btn"
          >
            <v-icon left>mdi-plus</v-icon>
            Add Config
          </v-btn>
        </div>
        <table class="api-config-table">
          <thead>
          <tr>
            <th>ID - {{ configTypeLabel }}</th>
            <th>Name - {{ configTypeLabel }}</th>
            <th>Value - {{ configTypeLabel }}</th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="config in filteredConfigs" :key="config.id">
            <td>
              {{ config.listOfValuesId }}
            </td>
            <td>
              {{
                (listOfValues.find(item => item.id === config.listOfValuesId) || {}).name || ''
              }}
            </td>
            <td style="position: relative;">
              <span>{{ config.value }}</span>
              <div style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%);">
                <v-btn
                  icon
                  small
                  color="primary"
                  @click="openEditDialog(config)"
                >
                  <v-icon>mdi-pencil</v-icon>
                </v-btn>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Add/Edit Dialog -->
    <v-dialog v-model="showDialog" max-width="500px">
      <v-card>
        <v-card-title>
          <span class="headline">{{ isEditMode ? 'Edit' : 'Add' }} API Configuration</span>
        </v-card-title>

        <v-card-text>
          <v-form ref="configFormRef" v-model="formValid" @submit.prevent="saveConfig">
            <v-select
              v-model="configForm.listOfValuesId"
              :items="availableListOfValues"
              item-text="id"
              item-value="id"
              :label="`ID - ${configTypeLabel}`"
              :rules="[v => !!v || `ID - ${configTypeLabel} is required`]"
              required
            ></v-select>

            <v-text-field
              :value="(listOfValues.find(item => item.id === configForm.listOfValuesId) || {}).name || ''"
              :label="`Name - ${configTypeLabel}`"
              readonly
            ></v-text-field>

            <v-text-field
              v-model="configForm.values"
              :label="`Value - ${configTypeLabel}`"
              :rules="[
                v => !!v || `Value - ${configTypeLabel} is required`,
                v => !isDuplicateValue(v) || 'This value already exists for this configuration type'
              ]"
              required
            ></v-text-field>
          </v-form>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="grey darken-1"
            text
            @click="closeDialog"
          >
            Cancel
          </v-btn>
          <v-btn
            color="primary"
            text
            @click="saveConfig"
            :disabled="!formValid"
          >
            {{ isEditMode ? 'Update' : 'Add' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import {handleHidingGlobalLoader, getRequest, postRequest} from '@/helpers/helpers'
import { ref, computed, onMounted } from 'vue';
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const apiConfigTypes = ref([]);
const listOfValues = ref([]);
const selectedConfigType = ref(null);
const apiConfigs = ref([]);
const configFormRef = ref(null);
const showDialog = ref(false);
const isEditMode = ref(false);
const formValid = ref(false);

const configForm = ref({
  id: null,
  apiConfigTypeId: null,
  listOfValuesId: '',
  name: '',
  values: ''
});

onMounted(() => {
  fetchApiConfigTypes();
  fetchApiConfig();
});

const filteredConfigs = computed(() =>
  selectedConfigType.value
    ? apiConfigs.value.filter(config => config.apiConfigTypeId === selectedConfigType.value.id)
    : []
);

const configTypeLabel = computed(() => {
  if (!selectedConfigType.value) return '';
  if (selectedConfigType.value.name.toLowerCase().includes('inverter')) return 'Inverter Brand';
  if (selectedConfigType.value.name.toLowerCase().includes('panel')) return 'Panel Brand';
  if (selectedConfigType.value.name.toLowerCase().includes('storage')) return 'Storage Brand';
  return selectedConfigType.value.name.toUpperCase();
});

const availableListOfValues = computed(() => {
  const usedIds = filteredConfigs.value
    .filter(cfg => !isEditMode.value || cfg.id !== configForm.value.id)
    .map(cfg => cfg.listOfValuesId);
  return listOfValues.value.filter(item => !usedIds.includes(item.id));
});

const fetchApiConfigTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/flow/api-config-type', 'blueraven', [])
    apiConfigTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading API Config Types')
    appStore.loading = false
  }
}

const fetchApiConfig = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/flow/api-config/all', 'blueraven', [])
    apiConfigs.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading API Configs')
    appStore.loading = false
  }
}

const selectConfigType = (configType) => {
  selectedConfigType.value = configType;
  fetchlistOfValues(configType.listOfValuesId);
}

const fetchlistOfValues = async (listOfValuesId) => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/flow/api-config?listOfValuesId=${listOfValuesId}`, 'blueraven', [])
    listOfValues.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading API Configs')
    appStore.loading = false
  }
}

const openAddDialog = () => {
  isEditMode.value = false;
  configForm.value = {
    id: null,
    apiConfigTypeId: selectedConfigType.value.id,
    listOfValuesId: '',
    name: '',
    values: ''
  };
  showDialog.value = true;
}

const openEditDialog = (config) => {
  isEditMode.value = true;
  if (!listOfValues.value.some(c => c.id === config.listOfValuesId)) {
    listOfValues.value.push({ id: config.listOfValuesId });
  }
  configForm.value = {
    id: config.id,
    apiConfigTypeId: config.apiConfigTypeId,
    listOfValuesId: config.listOfValuesId,
    name: config.name || '',
    values: config.value
  };
  showDialog.value = true;
}

const closeDialog = () => {
  showDialog.value = false;
  configForm.value = {
    id: null,
    apiConfigTypeId: null,
    listOfValuesId: '',
    values: ''
  };
  if (configFormRef.value) {
    configFormRef.value.resetValidation();
  }
}

const isDuplicateValue = (value) => {
  if (!value || !selectedConfigType.value) return false;

  return apiConfigs.value.some(config =>
    config.values &&
    config.values.toLowerCase() === value.toLowerCase() &&
    config.apiConfigTypeId === selectedConfigType.value.id &&
    (!isEditMode.value || config.id !== configForm.value.id)
  );
}

const saveConfig = async () => {
  const valid = await configFormRef.value.validate();
  if (!valid) return;

  appStore.loading = true;
  try {
    const payload = {
      ...configForm.value,
      listOfValuesId: parseInt(configForm.value.listOfValuesId)
    };

    const {data, status} = await postRequest('/flow/api-config', payload, 'blueraven');

    if (isEditMode.value) {
      const index = apiConfigs.value.findIndex(c => c.id === data.id);
      if (index !== -1) {
        apiConfigs.value[index] = data;
      }
      appStore.showSnack('SUCCESS', 'API Configuration updated successfully');
    } else {
      apiConfigs.value.push(data);
      appStore.showSnack('SUCCESS', 'API Configuration added successfully');
    }

    closeDialog();
    await fetchApiConfig();
    handleHidingGlobalLoader(status);
  } catch (e) {
    console.error('*** ERROR ***', e);
    appStore.showSnack('ERROR', `Error ${isEditMode.value ? 'updating' : 'adding'} API Configuration`);
    appStore.loading = false;
  }
}
</script>

<style scoped>
.configurations-container {
  padding: 20px;
}

.configurations-header {
  margin-bottom: 20px;
}

.configurations-content {
  background-color: #fff;
  border-radius: 4px;
  padding: 20px;
}

.table-title {
  margin-bottom: 15px;
  color: #333;
  font-size: 18px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.add-btn {
  margin-left: auto;
}

.api-config-table {
  width: 100%;
  border-collapse: collapse;
}

.api-config-table th, .api-config-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

.api-config-table th {
  background-color: #f2f2f2;
}

.api-config-table tr:nth-child(even) {
  background-color: #f9f9f9;
}

.api-config-table tr:hover {
  background-color: #f1f1f1;
}

.second-table-container {
  margin-top: 30px;
}

.selected-row {
  background-color: #e0f7fa !important;
  cursor: pointer;
}

.api-config-table tr {
  cursor: pointer;
}

.api-config-table td:last-child {
  cursor: default;
}
</style>
