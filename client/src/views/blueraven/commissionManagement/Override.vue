<template>
  <v-container class="pa-0" id="override-container">
    <v-dialog :width="600" v-model="showProjectAssignmentModal">
      <ProjectAssignmentModal @cancel="showProjectAssignmentModal = false"
                              :plan-id="parseInt(overrideId)"
                              :override="true"
                              :plan-name="override.name"></ProjectAssignmentModal>
    </v-dialog>
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="overrideId">{{override.name}}</span>
        <span v-else>New Override Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <a-btn
              color="primary"
              class="mr-2"
              v-if="userIsAdmin && overrideId"
              @click="showProjectAssignmentModal = true"
              text="Admin"
          ></a-btn>
          <a-btn
              color="primary"
              class="mr-2"
              :disabled="!override.name || !override.positionId || !override.total"
              v-if="userCanEdit"
              @click="saveOverride()"
              text="Save"
          ></a-btn>
          <a-btn
              color="success"
              class="mr-2"
              v-if="userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN') && overrideId && override.status === 'PENDING'"
              :disabled="errorMessages.length > 0"
              @click="approveOverride()"
              text="Approve"
          ></a-btn>
          <a-btn
              color="error"
              class="mr-2"
              v-if="overrideId && override.status !== 'ACTIVE' && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')"
              :disabled="errorMessages.length > 0"
              @click="openDeleteDialog(override, deleteTypes.OVERRIDE)"
              text="Delete"
          ></a-btn>
          <a-btn
              color="error"
              class="mr-2"
              v-else-if="overrideId && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')"
              @click="inactivateConfirm=true"
              text="Inactivate"
          ></a-btn>
          <MultiOptionDialog
              :open-dialog="inactivateConfirm"
              :options="inactivateOptions"
              @cancel="inactivateConfirm=false"
              @option-0="[inactivateConfirm = true, inactivateOverride()]"
          >
            <template v-slot:title>
              <span v-if="planHasActiveUsers()">Error</span>
              <span v-else>Confirm</span>
            </template>
            <div v-if="planHasActiveUsers()">
              You cannot set this plan to inactive with active users.
              <table class="table mt-2">
                <tr v-for="(u, idx) in activeUsers" :key="idx">
                  <td class="pr-3">{{u.name}}</td>
                  <td>{{u.position}}</td>
                </tr>
              </table>
            </div>
            <div v-else>
              Are you sure you want to inactivate this plan?
            </div>
          </MultiOptionDialog>
          <a-btn
              color="primary"
              v-if="overrideId && override && userCanAdd"
              @click="showCloneDialog=true"
              text="Clone"
          ></a-btn>
          <ConfirmationDialog
              :open-dialog="showCloneDialog"
              @confirm="validateStartDates"
              @close-dialog="[showCloneDialog=false, cloneStartDate=null]"
              :disable-confirm="(override.assignedUsers.filter(u => u.selected).length > 0 && !cloneStartDate) ||
                             (override.assignedUsers.filter(u => u.selected).length === 0 && cloneStartDate != null)"
          >
            <template v-slot:title>{{cloneDialogTitle}}</template>
            <div class="mb-2">
                This option allows you to copy an entire plan over. <br/>
                By default, no users are copied over.
              </div>
              Receiving Users to Copy:
              <div v-for="u in override.receivingUsers">
                <input type="checkbox" class="mr-2" v-model="u.selected">
                {{ u.name }}
              </div>
              <div class="mt-3">
                Assigned Users to Copy:
                <div v-for="u in override.assignedUsers">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}: {{u.startDate | formatDate('date')}}
                </div>
                <div class="mt-3" v-if="override.assignedUsers && override.assignedUsers.filter(u => u.selected).length > 0">
                  <DatetimePickerInput
                      v-model="cloneStartDate"
                      :timezone="timezone"
                      :type="'date'"
                      :format="'MMMM DD, YYYY'"
                      label="Start Date"
                  />
                  <div v-if="cloneStartDate">
                    * This will update the end date for all selected users to {{moment(cloneStartDate, 'YYYY-MM-DD').subtract(1, 'd') | formatDate('date') }} on their current plan.
                  </div>
                  <div v-if="cloneDateError" class="error--text">
                    You cannot select a start date that is before or equal to any other user's plan start date.
                  </div>
                </div>
              </div>
            <template v-slot:no>cancel</template>
            <template v-slot:yes>clone</template>
          </ConfirmationDialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider v-if="errorMessages.length > 0"></v-divider>
    <v-row v-if="errorMessages.length > 0">
      <v-col cols="12">
        <v-list v-for="(em, index) in errorMessages" :key="index" class="pa-0" color="transparent">
          <v-list-item>
            <v-list-item-content class="text-left error--text">
              {{em}}
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>

    <v-divider></v-divider>
    <v-form ref="overrideForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <a-text-field
                            label="Name"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="override.name"></a-text-field>
              <a-text-field
                            label="Description"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="override.description"></a-text-field>
              <a-select attach v-model="override.positionId"
                        :items="positions"
                        :readonly="!userCanEdit"
                        :disabled="override.id != null || !userCanEdit"
                        no-data-text="No Users Available"
                        label="Position Type"
                        item-title="label"
                        item-value="id"
              ></a-select>
              <a-text-field
                            :readonly="!userCanEdit"
                            :disabled="(override.id && override.status !== 'PENDING') || !userCanEdit"
                            :label="payRateText"
                            v-model="override.total"></a-text-field>

              <div v-if="customFieldGroups.length > 0">
                <CustomValueInput
                  v-for="item in customFieldGroups[0].customFieldValues"
                  :callback="(item) => updateDirtyValue(item)"
                  :readonly="!userCanEdit"
                  :showFieldName="false"
                  :field="item"
                />
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="overrideId">
              <a-text-field
                            label="Status"
                            disabled
                            v-model="override.status"></a-text-field>
              <a-text-field
                            v-if="override.createdBy"
                            disabled
                            label="Created By"
                            v-model="override.createdBy.name"></a-text-field>
              <a-text-field
                            disabled
                            v-if="override.approved"
                            label="Approved"
                            v-model="override.approved"></a-text-field>
              <a-text-field
                            disabled
                            label="Approved By"
                            v-if="override.approvedBy"
                            v-model="override.approvedBy.name"></a-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="overrideId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Receiving Overrides
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="override.status === 'PENDING'"
                @click="addReceivingUser = !addReceivingUser"
                :prepend-icon="addReceivingUser ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addReceivingUser" class="square-card text-left pa-5">
            <a-autocomplete v-model="newReceivingUser.userId"
                            :items="receivingUsersToAdd"
                            :loading="receivingUsersLoading"
                            prepend-icon="search"
                            :search-input.sync="receivingUserSearch"
                            label="Search for a user..."
                            item-title="name"
                            item-value="userId"
                            autocomplete="off"
                            attach>
            </a-autocomplete>
            <a-text-field
                          type="number"
                          label="M1 Allocation"
                          v-model="newReceivingUser.m1Allocation">
            </a-text-field>
          <a-text-field
                        v-if="commissionPositionId === 1"
                        type="number"
                        label="M2 Allocation"
                        v-model="newReceivingUser.m2Allocation">
            </a-text-field>
            <a-text-field
                          type="number"
                          label="Redline M1 Allocation"
                          v-model="newReceivingUser.redLineM1Allocation">
            </a-text-field>
            <a-text-field
                          v-if="commissionPositionId === 1"
                          type="number"
                          label="Redline M2 Allocation"
                          v-model="newReceivingUser.redLineM2Allocation">
          </a-text-field>
          <a-btn
              color="primary"
              class="mr-3"
              @click="addReceivingUserToOverride()"
              :disabled="!newReceivingUser.userId"
              text="Add"
          ></a-btn>
        </v-card>
        <v-divider v-if="addAssignedUser"></v-divider>
        <v-data-table
            :headers="visibleReceivingHeaders"
            :items="override.receivingUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            item-key="userId"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <a-text-field
                            type="number"
                            label="M1 Allocation"
                            v-model.number="item.m1Allocation">
              </a-text-field>
              <a-text-field
                            v-if="commissionPositionId === 1"
                            type="number"
                            label="M2 Allocation"
                            v-model.number="item.m2Allocation">
              </a-text-field>
              <a-text-field
                            type="number"
                            label="Redline M1 Allocation"
                            v-model.number="item.redLineM1Allocation">
              </a-text-field>
              <a-text-field
                            v-if="commissionPositionId === 1"
                            type="number"
                            label="Redline M2 Allocation"
                            v-model.number="item.redLineM2Allocation">
              </a-text-field>
              <a-btn
                  color="primary"
                  :disabled="!item.m1Allocation || (commissionPositionId === 1 && !item.m2Allocation)"
                  @click="[expanded = [], updateReceivingUser(item)]"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.m1Allocation}}</td>
              <td class="text-left" v-if="commissionPositionId !== 4">{{item.m2Allocation}}</td>
              <td class="text-left">{{item.redLineM1Allocation}}</td>
              <td class="text-left" v-if="commissionPositionId !== 4">{{item.redLineM2Allocation}}</td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="expanded = [item]"
                    v-if="override.status === 'PENDING' && !expanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="expanded = []"
                    v-if="expanded.includes(item)"
                    text="cancel"
                ></a-btn>
                <a-btn
                    color="primary"
                    variant="text"
                    @click="openDeleteDialog(item, deleteTypes.RECEIVING)"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="overrideId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Assigned to Override Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                @click="[addAssignedUser = !addAssignedUser, newAssignedUser = {}, userHistory = []]"
                :prepend-icon="addAssignedUser ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addAssignedUser" class="square-card text-left px-5 pb-5">
          <div v-if="!override.positionId">
            You must selected a Position Type.
          </div>
          <div v-else>
            <v-row>
              <v-col cols="12" md="6">
                <a-autocomplete v-model="newAssignedUser.userId"
                                :items="assignedUsersToAdd"
                                :loading="assignedUsersLoading"
                                prepend-icon="search"
                                :search-input.sync="assignedUserSearch"
                                label="Search for a user..."
                                item-title="name"
                                item-value="userId"
                                autocomplete="off"
                                @input="getUserHistory(newAssignedUser.userId)"
                                attach
                >
                  <template slot='item' slot-scope='{ item }'>
                    {{ item.name }} - {{ item.position }}
                  </template>
                </a-autocomplete>
                <DatetimePickerInput
                  v-model="newAssignedUser.startDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Start Date"
                  :readonly="!newAssignedUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newAssignedUser.startDate, newAssignedUser.endDate, userHistory, newAssignedUser)"
                />
                <DatetimePickerInput
                  v-model="newAssignedUser.endDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="End Date"
                  :readonly="!newAssignedUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newAssignedUser.startDate, newAssignedUser.endDate, userHistory, newAssignedUser)"
                />
              </v-col>
              <v-col cols="12" md="6">
                <v-data-table
                  :headers="historyHeaders"
                  :items="userHistory"
                  :fixed-header="true"
                  :items-per-page="-1"
                  disable-sort
                  hide-default-footer
                  class="elevation-1"
                  v-if="userHistory.length > 0"
                >
                </v-data-table>
                <div v-if="errorLoadingUserHistory" class="error--text">
                  We had a problem loading this user's plan history. Cannot add this user until their history can be checked.
                </div>
              </v-col>
            </v-row>
            <div v-if="newAssignedUser.dateError" class="error--text mb-2">
              * Error: {{newAssignedUser.dateErrorMsg}}
            </div>
            <div class="mb-2" v-else-if="newAssignedUser.showNote">
              {{newAssignedUser.noteMsg}}
            </div>
            <a-btn
                color="primary"
                class="mr-3"
                @click="addAssignedUserToOverride()"
                :disabled="newAssignedUser.dateError || !newAssignedUser.userId || !newAssignedUser.startDate || errorLoadingUserHistory"
                text="Add"
            ></a-btn>
          </div>
        </v-card>
        <v-divider v-if="addAssignedUser"></v-divider>
        <v-data-table
            :headers="headers"
            :items="override.assignedUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="assignedUserExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-row>
                <v-col cols="12" md="6">
                  <DatetimePickerInput
                    v-model="item.endDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="End Date"
                    :readonly="errorLoadingUserHistory"
                    @input="checkDates(item.startDate, item.endDate, userHistory, item, override.id)"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-data-table
                    :headers="historyHeaders"
                    :items="userHistory"
                    :fixed-header="true"
                    :items-per-page="-1"
                    hide-default-footer
                    class="elevation-1"
                    v-if="userHistory.length > 0"
                  >
                  </v-data-table>
                  <div v-if="errorLoadingUserHistory" class="error--text">
                    We had a problem loading this user's plan history. Cannot add this user until their history can be checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{item.dateErrorMsg}}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{item.noteMsg}}
              </div>
              <a-btn
                  color="primary"
                  class="mr-3"
                  @click="updateAssignedUser(item)"
                  :disabled="item.dateError || !item.userId || !item.startDate || errorLoadingUserHistory"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                    v-if="override.status === 'PENDING' && !assignedUserExpanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    @click="assignedUserExpanded = []"
                    v-if="assignedUserExpanded.includes(item)"
                    color="unset"
                    text="cancel"
                ></a-btn>
                <a-btn
                    v-if="override.status === 'PENDING'"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="openDeleteDialog(item, deleteTypes.ASSIGNED)"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteConfirmed" @close-dialog="closeDeleteDialog">
      <div v-if="deleteType==deleteTypes.OVERRIDE">Are you sure you want to delete this plan?</div>
      <div v-else>Are you sure you want to delete <strong>{{itemToDeleteName}}</strong>?</div>

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  import ProjectAssignmentModal from "@/views/blueraven/commissionManagement/ProjectAssignmentModal";
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequestWithRequestParams, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import MultiOptionDialog from "@/components/MultiOptionDialog";
  import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute, useRouter} from "vue-router/composables";
  import { useAppStore } from '@/stores/AppStorePinia.js'
  import { useBrsStore } from '@/stores/BrsStorePinia.js'
  import debounce from 'lodash.debounce'
  import { storeToRefs } from 'pinia'

  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)
  const appStore = useAppStore()
  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  const deleteTypes = {
    OVERRIDE:0,
    RECEIVING:1,
    ASSIGNED:2
  }

  const dataLoading = ref(true);
  const cloneDialog = ref(false);
  const showProjectAssignmentModal = ref(false);
  const payRateText = ref(commissionPositionId.value === 4 ? 'Base Pay' : 'Rate per kW ($)');
  const cloneStartDate = ref(null);
  const cloneDateError = ref(false);
  const inactivateConfirm = ref(false);
  const deleteConfirm = ref(false);
  const expanded = ref([]);
  const assignedUserExpanded = ref([]);
  const headers = ref([
    { text: 'Name', value: 'name', show: true },
    { text: 'Employee ID', value: 'employeeId', show: true },
    { text: 'Start Date', value: 'startDate', show: true },
    { text: 'End Date', value: 'endDate', show: true },
    { text: '', value: 'icons', show: true },
  ]);
  const receivingHeaders = ref([
    { text: 'Name', value: 'name', show: true },
    { text: 'Employee ID', value: 'employeeId', show: true },
    { text: 'M1 Allocation', value: 'm1Allocation', show: true },
    { text: 'M2 Allocation', value: 'm2Allocation', show: commissionPositionId.value !== 4 },
    { text: 'Redline M1', value: 'redLineM1Allocation', show: true },
    { text: 'Redline M2', value: 'redLineM2Allocation', show: commissionPositionId.value !== 4 },
    { text: '', value: 'icons', show: true },
  ]);
  const override = ref({
    approvedBy: {},
    createdBy: {},
    assignedUsers: []
  });
  const positions = ref([
    { id: 1, label: 'Closer' },
    { id: 4, label: 'Setter' }
  ]);
  const addAssignedUser = ref(false);
  const assignedUsersLoading = ref(false);
  const newAssignedUser = ref({});
  const assignedUsersToAdd = ref([]);
  const assignedUserSearch = ref(null);
  const addReceivingUser = ref(false);
  const receivingUsersLoading = ref(false);
  const newReceivingUser = ref({
    m1Allocation: 0,
    m2Allocation: 0,
    redLineM1Allocation: 0,
    redLineM2Allocation: 0,
  });
  const errorLoadingUserHistory = ref(false);
  const historyHeaders = ref([
    { text: 'Name', value: 'planName', show: true },
    { text: 'Start Date', value: 'startDate', show: true },
    { text: 'End Date', value: 'endDate', show: true },
  ]);
  const receivingUsersToAdd = ref([]);
  const receivingUserSearch = ref(null);
  const errorMessages = ref([]);
  const userHistory = ref([]);
  const customFieldGroups = ref([]);
  const showDeleteDialog = ref(false);
  const itemToDelete = ref(null);
  const deleteType = ref(null);
  const showCloneDialog = ref(false);


  const userCanAdd = computed(()  => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')
  })
  const userCanEdit = computed(()  => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT')
  })
  const userIsAdmin = computed(()  => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')
  })
  const timezone = computed(()  => {
    return userStore.timezone.value
  })
  const visibleReceivingHeaders = computed(()  => {
    return receivingHeaders.value.filter(header => header.show === true)
  })
  const itemToDeleteName = computed(()  => {
    return itemToDelete.value ? itemToDelete.value.name : ''
  })
  const cloneDialogTitle = computed(() => {
    return override.value ? `Clone ${override.value.name}` : "Clone"
  })
  const inactivateOptions = computed(() => {
    return planHasActiveUsers() ? [] : ['inactivate']
  })
  const overrideId = computed(() => {
    return route.params.id
  })
  const activeUsers = computed(() => {
    return override.value?.assignedUsers?.filter(u => {
      return u.endDate === null || u.endDate > new Date()
    })
  })

  onMounted(() => {
    if(overrideId.value) {
      getOverrideDetails()
    } else {
      dataLoading.value = false
    }
  })

  watch(commissionPositionId, async() => {
    //if they change the position (setter vs closer) have to go back to main page
    await router.push('/commissionManagement/overrides')
  })

  watch(overrideId, () => {
    getOverrideDetails()
  })
  watch(assignedUserSearch, (val) => {
    if(!val) {
      newAssignedUser.value.userId = null
      assignedUsersToAdd.value = []
      return
    }
    assignedUsersToAdd.value = []
    getAssignedUsersDebounced(val)
  })
  watch(receivingUserSearch, (val) => {
    if(!val) {
      receivingUsersToAdd.value = []
      newReceivingUser.value.userId = null
      return
    }
    receivingUsersToAdd.value = []
    getReceivingUsersDebounced(val)
  })


      const updateDirtyValue = (item) => {
        item.valueWasChanged = true
        dataWasChanged.value = true
      }
      const getCustomFieldGroups = async() => {
        appStore.loading = true
        try {
          const params = {sourceId: overrideId.value, objectTypeId: 9}
          const {data, status} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          customFieldGroups.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error retrieving custom fields')
        }
      }
      const getOverrideDetails = async () => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/commissionManagement/overrides/${overrideId.value}`, 'blueraven')
          override.value = data
          await getCustomFieldGroups()
          dataLoading.value = false
          checkErrorMessages()
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Loading Override Details')
          appStore.loading = false
        }
      }
      const checkErrorMessages = () => {
        errorMessages.value = []
        //sum of all m1 and m2's should equal rate per kw$ (or base pay for setter)
        let sum = 0
        override.value?.receivingUsers?.forEach(ru => {
          sum += ru.m1Allocation + ru.m2Allocation
        })
        if(sum !== override.value.total) {
          errorMessages.value.push(`The sum of all milestone allocations must equal the ${payRateText.value}. `)
        }
      }
      const planHasActiveUsers = () => {
        let hasActive = false
        override.value?.assignedUsers?.forEach(u => {
          if(u.endDate === null || u.endDate > new Date()){
            hasActive = true
          }
        })
        return hasActive
      }
      const deleteOverride = async () => {
        appStore.loading = true
        try {
          await deleteRequest(`/commissionManagement/overrides/${overrideId.value}`, 'blueraven')
          snackbar('SUCCESS', 'Override Plan Deleted')
          await router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Override Plan')
        }
      }
      const cloneOverride = async () => {
        appStore.loading = true
        try {
          let params = {
            receivingUsers: override.value?.receivingUsers?.filter(u => u.selected).map(u => u.userId),
            assignedUsers: override.value?.assignedUsers?.filter(u => u.selected).map(u => u.userId),
            startDate: cloneStartDate.value,
            backdateApprovalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/overrides/${overrideId.value}/clone`, params, 'blueraven')
          await router.push({name: 'override', params: {id: data.id}})
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Cloning Override Plan')
          appStore.loading = false
        }
      }
      const getUserHistory = async(userId) => {
        //reset the rest of the new user fields if they change users
        delete newAssignedUser.value.startDate
        delete newAssignedUser.value.endDate
        newAssignedUser.value.dateError = false
        newAssignedUser.value.dateErrorMsg = ''
        newAssignedUser.value.showNote = false
        newAssignedUser.value.noteMsg = ''
        errorLoadingUserHistory.value = false
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/commissionManagement/overrides/assignedUsers/${userId}/history`, 'blueraven')
          userHistory.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          errorLoadingUserHistory.value = true
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving User History')
          appStore.loading = false
        }
      }
      const validateStartDates = () => {
        //this is used when cloning users
        cloneDateError.value = false
        override.value?.assignedUsers?.forEach(u => {
          if(u.selected && u.startDate >= cloneStartDate.value) {
            cloneDateError.value = true
          }
        })

        if(!cloneDateError.value) {
          cloneOverride()
          cloneDialog.value = false;
        }
      }
      const checkDates = (startDate, endDate, plans, item, existingId) => {
        //item = where to track the error
        item.dateError = false

        if(startDate > endDate) {
          item.dateError = true
          item.dateErrorMsg = 'End Date cannot be before Start Date'
        } else {
          let overlap = []
          let hasActivePlan = false
          plans.forEach(p => {
            if(dateRangeOverlap(startDate, endDate, p, existingId)) {
              overlap.push(p)
            }
            // if any plan doesn't have an end date, then there is an active plan
            if(!p.endDate) {
              hasActivePlan = true
            }
          })
          if(overlap.length > 0) {
            item.dateError = true
            item.dateErrorMsg = 'Plans Cannot Overlap'
          } else if(!existingId && startDate && hasActivePlan) {
            item.showNote = true
            item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
          }
        }
      }
      const dateRangeOverlap = (start, end, plan, existingId) => {
        let valueToCheck = plan.planId ?? plan.id
        //this will not allow them to go back in time to add plans before existing plans which seems to be ok
        if(valueToCheck === existingId) {
          // ignore overlap check for self on existing record
          return false
        } else {
          //this is used when adding a new plan
          return start <= plan.startDate || start <= plan.endDate
        }
      }
      const saveOverride = async () => {
        appStore.loading = true
        try {
          let params = {
            name: override.value.name,
            description: override.value.description,
            positionId: override.value.positionId,
            total: override.value.total,
            id: override.value.id,
            customFieldGroups: customFieldGroups.value
          }
          const {data, status} = await postRequest(`/commissionManagement/overrides`, params, 'blueraven')
          if(!overrideId.value) {
            //need to reload some stuff if this was a new plan
            await router.push({name: 'override', params: {id: data.id}})
          }
          checkErrorMessages()
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Saving Override Plan')
          appStore.loading = false
        }
      }
      const approveOverride = async () => {
        appStore.loading = true
        try {
          const {data, status} = await postRequest(`/commissionManagement/overrides/${overrideId.value}/approve`, {}, 'blueraven')
          snackbar('SUCCESS', 'Override Plan Approved')
          override.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Approving Override Plan')
          appStore.loading = false
        }
      }
      const inactivateOverride = async () => {
        appStore.loading = true
        try {
          await postRequest(`/commissionManagement/overrides/${overrideId.value}/inactivate`, {}, 'blueraven')
          snackbar('SUCCESS', 'Override Plan Inactivated')
          await router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Inactivating Override Plan')
          appStore.loading = false
        }
      }
      const updateAssignedUser = async(item) => {
        appStore.loading = true
        try {
          const {status} = await postRequest(`/commissionManagement/overrides/${overrideId.value}/updateUser`, item, 'blueraven')
          assignedUserExpanded.value = []
          userHistory.value = []
          snackbar('SUCCESS', 'Assigned User Updated')
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Updating Assigned User')
          appStore.loading = false
        }
      }
  const getAssignedUsersDebounced = debounce((val) => {
    getAssignedUsers(val)
  }, 500)
  const getReceivingUsersDebounced = debounce((val) => {
    getReceivingUsers(val)
  }, 500)

      const getAssignedUsers = async(query) => {
        if(addAssignedUser.value) {
          assignedUsersLoading.value = true
          try {
            let params = {
              positionId: override.value.positionId,
              query,
              planId: override.value.id,
              isReceiving: false
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            assignedUsersToAdd.value = data
            assignedUsersLoading.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Retrieving Override Plan Users')
            appStore.loading = false
          }
        }
      }
      const addAssignedUserToOverride = async() => {
        if(addAssignedUser.value) {
          try {
            let params = {
              userId: newAssignedUser.value.userId,
              startDate: newAssignedUser.value.startDate,
              endDate: newAssignedUser.value.endDate
            }
            const {data} = await postRequestWithRequestParams(`/commissionManagement/overrides/${override.value.id}/assignedUsers/${override.value.positionId}`, params, { addUserToPlan: true }, 'blueraven')
            override.value.assignedUsers = data
            newAssignedUser.value = {}
            assignedUserSearch.value = null
            addAssignedUser.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Assigning User')
            appStore.loading = false
          }
        }
      }
      const deleteAssignedUser = async () => {
        const assignedUserId = itemToDelete.value.id
        // console.log(assignedUserId)
        appStore.loading = true
        try {
          const {status} = await deleteRequest(`/commissionManagement/overrides/${overrideId.value}/assignedUsers/${assignedUserId}`, 'blueraven')
          snackbar('SUCCESS', 'Assigned User Deleted')
          override.value.assignedUsers = override.value.assignedUsers.filter(au => {
            return au.id !== assignedUserId
          })
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Assigned User')
          appStore.loading = false
        }
      }
      const getReceivingUsers = async(query) => {
        if(addReceivingUser.value) {
          receivingUsersLoading.value = true
          try {
            let params = {
              query,
              planId: override.value.id,
              isReceiving: true,
              positionId: override.value.positionId
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            receivingUsersToAdd.value = data
            receivingUsersLoading.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Retrieving Receiving Override Users')
            appStore.loading = false
          }
        }
      }
      const updateReceivingUser = async(item) => {
        appStore.loading = true
        try {
          const {status} = await postRequest(`/commissionManagement/overrides/${override.value.id}/receivingUser`, item, 'blueraven')
          checkErrorMessages()
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Saving Receiving User')
          appStore.loading = false
        }
      }
      const addReceivingUserToOverride = async() => {
        if(addReceivingUser.value) {
          try {
            let params = {
              userId: newReceivingUser.value.userId,
              m1Allocation: newReceivingUser.value.m1Allocation,
              m2Allocation: newReceivingUser.value.m2Allocation,
              redLineM1Allocation: newReceivingUser.value.redLineM1Allocation,
              redLineM2Allocation: newReceivingUser.value.redLineM2Allocation
            }
            const {data} = await postRequest(`/commissionManagement/overrides/${override.value.id}/receivingUsers`, params, 'blueraven')
            override.value.receivingUsers.push(data)
            checkErrorMessages()
            newReceivingUser.value = {
              m1Allocation: 0,
              m2Allocation: 0,
              redLineM1Allocation: 0,
              redLineM2Allocation: 0,
            }
            receivingUserSearch.value = null
            addReceivingUser.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Adding Receiving User')
            appStore.loading = false
          }
        }
      }
      const deleteReceivingUser = async () => {
        const receivingUserId = itemToDelete.value.userId
        appStore.loading = true
        try {
          const {status} = await deleteRequest(`/commissionManagement/overrides/${overrideId.value}/receivingUsers/${receivingUserId}`, 'blueraven')
          snackbar('SUCCESS', 'Receiving User Deleted')
          override.value.receivingUsers = override.value.receivingUsers.filter(au => {
            return au.userId !== receivingUserId
          })
          checkErrorMessages()
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Receiving User')
          appStore.loading = false
        }
        closeDeleteDialog()
      }
      const deleteConfirmed = ()=> {
        switch (deleteType.value){
          case deleteTypes.OVERRIDE:
            deleteOverride()
            break
          case deleteTypes.RECEIVING:
            deleteReceivingUser()
            break
          case deleteTypes.ASSIGNED:
            deleteAssignedUser()
            break
          default:
        }
        closeDeleteDialog()
      }
      const openDeleteDialog = (item, type) => {
        itemToDelete.value = item
        deleteType.value=type
        showDeleteDialog.value = true
      }
      const closeDeleteDialog = ()=> {
        showDeleteDialog.value = false
        itemToDelete.value = null
        deleteType.value=null
      }

</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

