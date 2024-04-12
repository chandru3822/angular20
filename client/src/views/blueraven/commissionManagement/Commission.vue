<template>
  <v-container class="pa-0" id="commission-container">
    <v-dialog :width="600" v-model="showProjectAssignmentModal">
      <ProjectAssignmentModal @cancel="showProjectAssignmentModal = false"
                              :plan-id="parseInt(planId)"
                              :plan-name="commission.name"></ProjectAssignmentModal>
    </v-dialog>
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="planId">{{ commission.name }}</span>
        <span v-else>New Commission Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <a-btn
              color="primary"
              class="mr-2"
              v-if="userIsAdmin && planId"
              @click="showProjectAssignmentModal = true"
              text="Admin"
          ></a-btn>
          <a-btn
              color="primary"
              class="mr-2"
              :disabled="!commission.name || !commission.positionId"
              v-if="userCanEdit"
              @click="savePlan()"
              text="Save"
          ></a-btn>
          <a-btn
              color="success"
              class="mr-2"
              v-if="userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN') && planId && commission.statusType === 'PENDING'"
              :disabled="errorMessages.length > 0"
              @click="approvePlan()"
          > Approve </a-btn>
          <ConfirmationDialog :open-dialog="showDeleteConfirm" @confirm="[deleteConfirm = true, deletePlan()]"
                              @close-dialog="showDeleteConfirm=false">
            Are you sure you want to delete this plan?
          </ConfirmationDialog>
          <a-btn
              v-if="planId && !commission.approved && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')"
              @click="showDeleteConfirm = true"
              color="error"
              text="delete"
          ></a-btn>
          <a-btn
              v-else-if="planId && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')"
              @click="inactivateConfirm = true"
              color="error"
              class="mr-2"
              text="Inactivate"
          ></a-btn>
          <ConfirmationDialog :open-dialog="inactivateConfirm" :hide-confirm="planHasActiveUsers()"
                              @confirm="inactivatePlan" @close-dialog="inactivateConfirm = false">
            <template v-if="planHasActiveUsers()" v-slot:title>Error</template>
            <template v-else v-slot:title>Confirm</template>
            <div v-if="planHasActiveUsers()">
              You cannot set this plan to inactive with active users.
              <table class="table mt-2">
                <tr v-for="(u, idx) in activeUsers" :key="idx">
                  <td class="pr-3">{{ u.name }}</td>
                  <td>{{ u.position }}</td>
                </tr>
              </table>
            </div>
            <div v-if="!planHasActiveUsers()">
              Are you sure you want to inactivate this plan?
            </div>
            <template v-if="!planHasActiveUsers()" v-slot:yes>Inactivate</template>
          </ConfirmationDialog>
          <a-btn
              v-if="planId && commission && commission.users && userCanAdd && commission.users.filter(u => {return u.endDate == null}).length > 0"
              color="primary"
              class="ml-3"
              @click="cloneDialog = true"
              text="Clone"
          > </a-btn>
          <ConfirmationDialog :open-dialog="cloneDialog"
                              :disable-confirm="(commission.users.filter(u => u.selected).length > 0 && !cloneStartDate) ||
                              (commission.users.filter(u => u.selected).length === 0 && cloneStartDate != null)"
                              @confirm="validateStartDates"
                              @close-dialog="[cloneDialog = false, cloneStartDate = null]"
          >
            <template v-slot:title>Clone {{ commission.name }}</template>
            <div class="mb-2">
              This option allows you to copy an entire plan over. <br/>
              By default, no users are copied over.
            </div>
            Users to Copy:
            <div v-for="u in commission.users.filter(u => u.endDate == null)">
              <input type="checkbox" class="mr-2" v-model="u.selected">
              {{ u.name }}: {{ u.startDate | formatDate('date') }}
            </div>
            <div class="mt-3" v-if="commission.users && commission.users.filter(u => u.selected).length > 0">
              <DatetimePickerInput
                  v-model="cloneStartDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Start Date"
              />
              <div v-if="cloneStartDate">
                * This will update the end date for all selected users to
                {{ moment(cloneStartDate, 'YYYY-MM-DD').subtract(1, 'd') | formatDate('date') }} on their current plan.
              </div>
              <div v-if="cloneDateError" class="error--text">
                You cannot select a start date that is before or equal to any other user's plan start date.
              </div>
            </div>
            <template v-slot:yes>Clone</template>
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
              {{ em }}
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-form ref="commissionForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <a-text-field
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            label="Name"
                            v-model="commission.name"></a-text-field>
              <a-text-field
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            label="Description"
                            v-model="commission.description"></a-text-field>
              <a-select attach v-model="commission.positionId"
                        :items="positions"
                        no-data-text="No Users Available"
                        label="Position"
                        item-title="label"
                        item-value="id"
              ></a-select>
              <a-text-field
                            :label="payRateText"
                            type="number"
                            v-if="commission.positionId === 1"
                            :disabled="commission.id && commission.statusType !== 'PENDING'"
                            v-model.number="commission.total"></a-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="planId">
              <a-text-field
                            label="Status"
                            disabled
                            v-model="commission.statusType"></a-text-field>
              <a-text-field
                            disabled
                            label="Created By"
                            v-model="commission.createdName"></a-text-field>
              <a-text-field
                            disabled
                            label="Approved"
                            v-if="commission.approvedDate"
                            v-model="commission.approvedDate"></a-text-field>
              <a-text-field
                            disabled
                            v-if="commission.approvedName"
                            label="Approved By"
                            v-model="commission.approvedName"></a-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            {{ levelText }}s
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="commission.statusType === 'PENDING'"
                @click="[selectedMilestone = {}, addMilestone = !addMilestone, getMilestones()]"
                :prepend-icon="addMilestone ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addMilestone" class="square-card text-left pa-5">
          <a-select attach v-model="selectedMilestone.id"
                    :items="milestones"
                    :label="`Select a ${levelText}...`"
                    item-title="milestoneType"
                    item-value="id"
                    autocomplete="off">
          </a-select>
          <a-text-field
                        type="number"
                        :label="`${levelText} Payment $`"
                        v-model.number="selectedMilestone.allocation">
          </a-text-field>
          <div v-if="commission.positionId === 4">
            <a-text-field
                          type="number"
                          @input="checkMinMaxMilestones(selectedMilestone)"
                          label="Minimum Pitches"
                          v-model.number="selectedMilestone.min">
            </a-text-field>
            <a-text-field
                          @input="checkMinMaxMilestones(selectedMilestone)"
                          type="number"
                          label="Maximum Pitches"
                          v-model.number="selectedMilestone.max">
            </a-text-field>
          </div>
          <div class="error-text mb-3" v-if="milestoneError">
            {{ milestoneErrorMsg }}
          </div>
          <a-btn
              color="primary"
              class="mr-3"
              @click="addMilestoneToPlan()"
              :disabled="!selectedMilestone.id || (!selectedMilestone.allocation && !selectedMilestone.min) || milestoneError"
              text="Add"
          ></a-btn>
        </v-card>
        <v-divider v-if="addMilestone"></v-divider>
        <v-data-table
            :headers="displayedMilestoneHeaders"
            :items="commission.milestones"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            item-key="commissionPlanAllocationId"
            :expanded.sync="milestoneExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available {{ levelText }}s</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available {{ levelText }}s</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <a-text-field
                            type="number"
                            :label="`${levelText} Payment $`"
                            v-model.number="item.allocation">
              </a-text-field>
              <div v-if="commission.positionId === 4">
                <a-text-field
                              @input="checkMinMaxMilestones(item)"
                              type="number"
                              label="Minimum Pitches"
                              v-model.number="item.min">
                </a-text-field>
                <a-text-field
                              type="number"
                              @input="checkMinMaxMilestones(item)"
                              label="Maximum Pitches"
                              v-model.number="item.max">
                </a-text-field>
              </div>
              <div class="error-text mb-3" v-if="milestoneError">
                {{ milestoneErrorMsg }}
              </div>
              <a-btn
                  :disabled="!item.allocation || (commission.positionId === 4 && !item.min) || milestoneError"
                  @click="[milestoneExpanded = [], updateMilestone(item)]"
                  color="primary"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.milestoneType }}</td>
              <td class="text-left" v-if="commission.positionId === 4">{{ item.min }}</td>
              <td class="text-left" v-if="commission.positionId === 4">{{ item.max }}</td>
              <td class="text-left">{{ item.allocation }}</td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="milestoneExpanded = [item]"
                    v-if="commission.statusType === 'PENDING' && !milestoneExpanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="milestoneExpanded = []"
                    v-if="milestoneExpanded.includes(item)"
                    text="cancel"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="milestoneToDelete=item"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="planId && commission.positionId === 1">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Source Deductions
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="commission.statusType === 'PENDING'"
                @click="[selectedSource = {}, addSource = !addSource, getSources()]"
                :prepend-icon="addSource ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addSource" class="square-card text-left pa-5">
          <div v-if="!commission.milestones || commission.milestones.length === 0">
            You must add milestones to this plan first.
          </div>
          <div v-else>
            <a-select attach v-model="selectedSource.id"
                      :items="sources"
                      label="Select a Source..."
                      item-title="sourceName"
                      item-value="id"
                      autocomplete="off">
            </a-select>
            <a-text-field
                          label="Fee Amount"
                          v-model="selectedSource.feeAmount"></a-text-field>
            <a-select attach v-model="selectedSource.feeTypeId"
                      :items="feeTypes"
                      label="Fee Type"
                      item-title="label"
                      item-value="id"
            ></a-select>
            <a-select attach v-model="selectedSource.milestoneId"
                      :items="commission.milestones"
                      label="Deduct at Milestone"
                      item-title="milestoneType"
                      item-value="milestoneId"
            ></a-select>
            <a-btn
                color="primary"
                class="mr-3"
                @click="addSourceToPlan()"
                :disabled="!selectedSource.id || !selectedSource.feeTypeId || !selectedSource.feeAmount"
                text="Add"
            ></a-btn>
          </div>
        </v-card>
        <v-divider v-if="addSource"></v-divider>
        <v-data-table
            :headers="sourceHeaders"
            :items="commission.sources"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="sourceExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available sources</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available sources</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <a-text-field
                            label="Fee Amount"
                            v-model="item.feeAmount"></a-text-field>
              <a-select attach v-model="item.feeTypeId"
                        :items="feeTypes"
                        label="Fee Type"
                        item-title="label"
                        item-value="id"
              ></a-select>
              <a-select attach v-model="item.milestoneId"
                        :items="commission.milestones"
                        label="Deduct at Milestone"
                        item-title="milestoneType"
                        item-value="milestoneId"
              ></a-select>
              <a-btn
                  :disabled="!item.feeAmount || !item.feeTypeId || !item.milestoneId"
                  @click="[sourceExpanded = [], updateSource(item)]"
                  color="primary"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.sourceName }}</td>
              <td class="text-left">{{ item.feeAmount }}</td>
              <td class="text-left">{{ item.feeType }}</td>
              <td class="text-left">{{ item.milestoneType }}</td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceExpanded = [item]"
                    v-if="commission.statusType === 'PENDING' && !sourceExpanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceExpanded = []"
                    v-if="sourceExpanded.includes(item)"
                    text="cancel"
                ></a-btn>
                <a-btn
                    v-if="commission.statusType === 'PENDING'"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceToDelete=item"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Users Assigned to Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[addUser = !addUser, newUser = {}, userHistory = []]"
                v-if="userCanAdd"
                :prepend-icon="addUser ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left px-5 pb-5">
          <v-row>
            <v-col cols="12" md="6">
              <a-autocomplete v-model="newUser.userId"
                              :items="usersToAdd"
                              :loading="usersLoading"
                              prepend-icon="search"
                              cache-items
                              :search-input.sync="userSearch"
                              label="Search for a user..."
                              item-title="name"
                              item-value="userId"
                              autocomplete="off"
                              @input="getUserHistory(newUser.userId)"
                              attach
              >
                <template v-slot:item="{ props, item }">
                  {{ item.name }} - {{ item.position }}
                </template>
              </a-autocomplete>
              <DatetimePickerInput
                  v-model="newUser.startDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Start Date"
                  :readonly="!newUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
              />
              <DatetimePickerInput
                  v-model="newUser.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="End Date"
                  :readonly="!newUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
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
                We had a problem loading this user's plan history. Cannot add this user until their history can be
                checked.
              </div>
            </v-col>
          </v-row>

          <div v-if="newUser.dateError" class="error--text mb-2">
            * Error: {{ newUser.dateErrorMsg }}
          </div>
          <div class="mb-2" v-else-if="newUser.showNote">
            {{ newUser.noteMsg }}
          </div>
          <a-btn
              color="primary"
              class="mr-3"
              @click="addUserToPlan()"
              :disabled="newUser.dateError || !newUser.userId || !newUser.startDate || errorLoadingUserHistory"
              text="Add"
          ></a-btn>
        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredCommissionUsers"
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
            No available users
          </template>

          <template #no-results>
            No available users
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
                      @input="checkDates(item.startDate, item.endDate, userHistory, item, commission.id)"
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
                    We had a problem loading this user's plan history. Cannot add this user until their history can be
                    checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{ item.dateErrorMsg }}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{ item.noteMsg }}
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
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.name }}</td>
              <td class="text-left">{{ item.position }}</td>
              <td class="text-left">{{ item.employeeId }}</td>
              <td class="text-left">{{ item.startDate }}</td>
              <td class="text-left">{{ item.endDate }}</td>
              <td>
                <a-btn
                    v-if="commission.statusType === 'PENDING' && !assignedUserExpanded.includes(item)"
                    size="small"
                    variant="text"
                    color="primary"
                    prepend-icon="edit"
                    @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="assignedUserExpanded = []"
                    v-if="assignedUserExpanded.includes(item)"
                    text="cancel"
                ></a-btn>
                <a-btn
                    v-if="commission.statusType === 'PENDING'"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="userToDelete=item"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromPlan" @close-dialog="userToDelete=null">
      Are you sure you want to delete <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!sourceToDelete" @confirm="deleteSource" @close-dialog="sourceToDelete=null">
      Are you sure you want to delete this source: <strong>{{ sourceToDeleteName }}</strong>??
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!milestoneToDelete" :hide-confirm="milestoneToDeleteIsUsed"
                        @confirm="deleteMilestone" @close-dialog="milestoneToDelete=null">
      <template v-slot:title v-if="milestoneToDeleteIsUsed">Error</template>
      <div v-if="milestoneToDeleteIsUsed">Cannot delete milestones that are in use by sources.</div>
      <div v-else-if="commission.positionId === 1">
        Are you sure you want to delete this milestone: <strong>{{ milestoneToDeleteType }}</strong>?
      </div>
      <div v-else>
        Are you sure you want to delete this tier: <strong>{{ milestoneToDeleteType }}: {{ milestoneToDeleteMin }} -
        {{ milestoneToDeleteMax }}</strong>?
      </div>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequestWithRequestParams,
  postRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers';
import ProjectAssignmentModal from "@/views/blueraven/commissionManagement/ProjectAssignmentModal";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { useBrsStore } from '@/stores/BrsStorePinia.js'
import {getCurrentInstance, computed, ref, onMounted, watch} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useAppStore} from '@/stores/AppStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables"
import debounce from "lodash.debounce"
import { storeToRefs } from 'pinia'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()
const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const showProjectAssignmentModal = ref(false)
const cloneDialog = ref(false)
const payRateText = ref(commissionPositionId.value === 4 ? 'Base Pay' : 'Rate per kW ($)')
const levelText = ref(commissionPositionId.value === 4 ? 'Tier' : 'Milestone')
const addUser = ref(false)
const newUser = ref({})
const usersToAdd = ref([])
const userSearch = ref('')
const userHistory = ref([])
const usersLoading = ref(false)
const cloneStartDate = ref(null)
const dataLoading = ref(true)
const inactivateConfirm = ref(false)
const deleteConfirm = ref(false)
const milestoneExpanded = ref([])
const sourceExpanded = ref([])
const errorLoadingUserHistory = ref(false)
const assignedUserExpanded = ref([])
const milestoneError = ref(false)
const milestoneErrorMsg = ref('')
const addMilestone = ref(false)
const selectedMilestone = ref({})
const milestones = ref([])
const addSource = ref(false)
const selectedSource = ref({})
const sources = ref([])
const errorMessages = ref([])
const cloneDateError = ref(false)
const showDeleteConfirm = ref(false)
const milestoneToDelete = ref(null)
const sourceToDelete = ref(null)
const userToDelete = ref(null)

const headers = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Position', value: 'Position', show: true},
  {text: 'Employee ID', value: 'employeeId', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
  {text: '', value: 'icons', show: true},
])
const historyHeaders = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
])
const positions = ref([
  {id: 1, label: 'Closer'},
  {id: 4, label: 'Setter'}
])
const feeTypes = ref([
  {id: 1, label: 'Per kW'},
  {id: 2, label: 'Flat'}
])
const sourceHeaders = ref([
  {text: 'Source', value: 'source', show: true},
  {text: 'Fee Amount', value: 'feeAmount', show: true},
  {text: 'Fee Type', value: 'feeType', show: true},
  {text: 'Deduct at Milestone', value: 'deductAtMilestone', show: true},
  {text: '', value: 'icons', show: true},
])
const milestoneHeaders = ref([
  {text: commissionPositionId.value === 4 ? 'Tier' : 'Milestone', value: 'milestoneType', show: true},
  {text: 'Minimum Pitches', value: 'min', positionId: 4},
  {text: 'Maximum Pitches', value: 'max', positionId: 4},
  {
    text: commissionPositionId.value === 4 ? 'Tier Payment ($)' : 'Milestone Payment ($)',
    value: 'allocation',
    show: true
  },
  {text: '', value: 'icons', show: true},
])
const commission = ref({
  users: [],
  positionId: null
})

const planId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const displayedMilestoneHeaders = computed(() => {
  return milestoneHeaders.value.filter(h => h.show || h.positionId === commission.value?.positionId)
})
const milestoneToDeleteType = computed(() => {
  return milestoneToDelete.value ? milestoneToDelete.value.milestoneType : ''
})
const milestoneToDeleteIsUsed = computed(() => {
  if (milestoneToDelete.value) {
    return checkIfMilestoneUsed(milestoneToDelete.value.milestoneId)
  }
  return false
})
const milestoneToDeleteMin = computed(() => {
  return milestoneToDelete.value ? milestoneToDelete.value.min : ''
})
const milestoneToDeleteMax = computed(() => {
  return milestoneToDelete.value ? milestoneToDelete.value.max : ''
})
const sourceToDeleteName = computed(() => {
  return sourceToDelete.value ? sourceToDelete.value.sourceName : ''
})
const userToDeleteName = computed(() => {
  return userToDelete.value ? userToDelete.value.name : ''
})
const filteredCommissionUsers = computed(() => {
  return commission.value?.users?.filter(cu => {
    return !cu.archived
  })
})
const activeUsers = computed(() => {
  return commission.value?.users?.filter(u => {
    return u.endDate === null || u.endDate > new Date()
  })
})


watch(planId, () => {
  getCommissionDetails()
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/commissions')
})

watch(userSearch, (val) => {
  if (!val) {
    usersToAdd.value = []
    newUser.value.userId = null
    return
  }
  usersToAdd.value = []
  getUsersToAddDebounced(val)
})

onMounted(() => {
  if (planId.value) {
    getCommissionDetails()
  } else {
    dataLoading.value = false
  }
})

const checkMinMaxMilestones = (item) => {
  milestoneError.value = false
  if (commission.value.positionId === 4) {
    if (item.min === null || item.min === '') {
      milestoneError.value = true
      milestoneErrorMsg.value = 'All milestones must have a minimum.'
    } else if (item.max && item.max < item.min) {
      milestoneError.value = true
      milestoneErrorMsg.value = 'Milestones minimum cannot be greater than the maximum.'
    } else {
      commission.value.milestones.forEach(m => {
        if ((m.max === null || m.max === '') && (item.max === null || item.max === '')) {
          milestoneError.value = true
          milestoneErrorMsg.value = 'Cannot have 2 milestones without a maximum.'
        } else if (item.commissionPlanAllocationId !== m.commissionPlanAllocationId &&
            ((item.min >= m.min && item.min <= m.max) ||
                (item.max >= m.min && item.max <= m.max) ||
                ((item.min >= m.min || item.max >= m.min) && (m.max === null || m.max === '')))) {
          milestoneError.value = true
          milestoneErrorMsg.value = 'Milestones cannot overlap.'
        }
      })
    }
  }
}
const getCommissionDetails = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/commissionManagement/plan/${planId.value}`, 'blueraven')
    commission.value = data
    if ([2, 3].includes(commission.value.statusId)) {
      commission.value.approved = true
    }
    // temporarily only allowing closers
    commission.value.positionType = 'closers'
    checkErrorMessages()
    dataLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Commission Details')
    appStore.loading = false
  }
}
const validateStartDates = () => {
  //this is used when cloning users
  cloneDateError.value = false
  commission.value?.users?.forEach(u => {
    if (u.selected && u.startDate >= cloneStartDate.value) {
      cloneDateError.value = true
    }
  })

  if (!cloneDateError.value) {
    clonePlan(commission.value.users, cloneStartDate.value)
    cloneDialog.value = false;
  }
}
const checkDates = (startDate, endDate, plans, item, existingId) => {
  //item = where to track the error
  item.dateError = false

  if (startDate > endDate) {
    item.dateError = true
    item.dateErrorMsg = 'End Date cannot be before Start Date'
  } else {
    let overlap = []
    let hasActivePlan = false
    plans.forEach(p => {
      if (dateRangeOverlap(startDate, endDate, p, existingId)) {
        overlap.push(p)
      }
      // if any plan doesn't have an end date, then there is an active plan
      if (!p.endDate) {
        hasActivePlan = true
      }
    })
    if (overlap.length > 0) {
      item.dateError = true
      item.dateErrorMsg = 'Plans Cannot Overlap'
    } else if (!existingId && startDate && hasActivePlan) {
      item.showNote = true
      item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
    }
  }
}
const dateRangeOverlap = (start, end, plan, existingId) => {
  //this will not allow them to go back in time to add plans before existing plans which seems to be ok
  if (plan.id === existingId) {
    // ignore overlap check for self on existing record
    return false
  } else {
    //this is used when adding a new plan
    return start <= plan.startDate || start <= plan.endDate
  }
}
const checkErrorMessages = () => {
  errorMessages.value = []
  if (commission.value.total === 0) {
    errorMessages.value.push('The Rate per kW cannot be zero.')
  }
  //sum of m1 and m2 payment = rate per kw
  if (commission.value?.positionId === 1) {
    let sum = commission.value?.milestones?.reduce((a, b) => a + b.allocation, 0)
    if (sum !== commission.value.total) {
      errorMessages.value.push(`The sum of all milestone payment amounts must equal the ${payRateText.value}. `)
    }
  }
}
const planHasActiveUsers = () => {
  let hasActive = false
  commission.value?.users?.forEach(u => {
    if (u.endDate === null || u.endDate > new Date()) {
      hasActive = true
    }
  })
  return hasActive
}

const savePlan = async () => {
  appStore.loading = true
  try {
    let params = {
      id: commission.value.id,
      name: commission.value.name,
      description: commission.value.description,
      positionId: commission.value.positionId,
      total: commission.value.total
    }
    const {data, status} = await postRequest(`/commissionManagement`, params, 'blueraven')
    if (!planId.value) {
      //need to reload some stuff if this was a new plan
      await router.push({name: 'commission', params: {id: data.id}})
    }
    checkErrorMessages()
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Commission Plan')
    appStore.loading = false
  }
}
const approvePlan = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/commissionManagement/${planId.value}/approve`, {}, 'blueraven')
    snackbar('SUCCESS', 'Commission Plan Approved')
    commission.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Approving Commission Plan')
    appStore.loading = false
  }
}
const inactivatePlan = async () => {
  appStore.loading = true
  try {
    await postRequest(`/commissionManagement/${planId.value}/inactivate`, {}, 'blueraven')
    snackbar('SUCCESS', 'Commission Plan Inactivated')
    await router.push({name: 'commissions'})
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Inactivating Commission Plan')
    appStore.loading = false
  }
}
const deletePlan = async () => {
  appStore.loading = true
  try {
    await deleteRequest(`/commissionManagement/${planId.value}`, 'blueraven')
    snackbar('SUCCESS', 'Commission Plan Deleted')
    await router.push({name: 'commissions'})
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Commission Plan')
    appStore.loading = false
  }
}
const clonePlan = async (users, startDate) => {
  appStore.loading = true
  try {
    let params = {
      users: users ? users.filter(u => u.selected).map(u => u.userId) : [],
      startDate: startDate ?? null,
      backdateApprovalCreds: null
    }
    const {data, status} = await postRequest(`/commissionManagement/${planId.value}/clone`, params, 'blueraven')
    await router.push({name: 'commission', params: {id: data.id}})
    // temporarily only allowing closers
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Cloning Commission')
    appStore.loading = false
  }
}
const updateAssignedUser = async (item) => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/commissionManagement/${planId.value}/updateUser`, item, 'blueraven')
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
const getUsersToAddDebounced = debounce((val) => {
  getUsersToAdd(val)
}, 500)
const getUsersToAdd = async (query) => {
  if (addUser.value) {
    usersLoading.value = true
    try {
      let positions = commission.value.positionId === 1 ? 'closers' : 'setters'
      let params = {
        positions,
        query,
        planId: planId.value
      }
      const {data} = await getRequestWithParams(`/commissionManagement/_search`, {params}, 'blueraven')
      usersToAdd.value = data
      usersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Commission Plan Users')
      appStore.loading = false
    }
  }
}
const addUserToPlan = async () => {
  appStore.loading = true
  try {
    let params = {
      userId: newUser.value.userId,
      startDate: newUser.value.startDate,
      endDate: newUser.value.endDate,
      approvalCreds: null
    }
    const {
      data,
      status
    } = await postRequestWithRequestParams(`/commissionManagement/${planId.value}/users/${commission.value.positionId}`, params, {addUserToPlan: true}, 'blueraven')
    commission.value.users = data
    snackbar('SUCCESS', 'Commission Plan User Added')
    addUser.value = false
    newUser.value = {}
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Commission Plan User')
    appStore.loading = false
  }
}
const deleteUserFromPlan = async () => {
  const commissionPlanUser = userToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/${planId.value}/commissionUser/${commissionPlanUser.id}`, 'blueraven')
    snackbar('SUCCESS', 'Commission Plan User Deleted')
    commissionPlanUser.archived = true
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Commission Plan User')
    appStore.loading = false
  }
}

const getMilestones = async () => {
  if (addMilestone.value) {
    try {
      const {data} = await getRequest(`/commissionManagement/${planId.value}/availableMilestones/${commission.value.positionId}`, 'blueraven')
      milestones.value = data
      // if(commission.value.positionId === 4) {
      //   selectedMilestone.value.id = milestones.value[0].id
      // }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Milestones')
      appStore.loading = false
    }
  }
}
const updateMilestone = async (item) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/commissionManagement/${planId.value}/milestone`, item, 'blueraven')
    checkErrorMessages()
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Milestone')
    appStore.loading = false
  }
}
const addMilestoneToPlan = async () => {
  try {
    let params = {
      milestoneTypeId: selectedMilestone.value.id,
      allocation: selectedMilestone.value.allocation,
      min: selectedMilestone.value.min,
      max: selectedMilestone.value.max
    }
    const {data} = await postRequest(`/commissionManagement/${planId.value}/milestone`, params, 'blueraven')
    commission.value.milestones.push(data)
    checkErrorMessages()
    selectedMilestone.value = {}
    addMilestone.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Milestone')
    appStore.loading = false
  }
}
const deleteMilestone = async () => {
  const commissionPlanAllocationId = milestoneToDelete.value.commissionPlanAllocationId
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/${planId.value}/milestone/${commissionPlanAllocationId}`, 'blueraven')
    snackbar('SUCCESS', `${levelText} Deleted`)
    commission.value.milestones = commission.value.milestones.filter(m => {
      return m.commissionPlanAllocationId !== commissionPlanAllocationId
    })
    checkErrorMessages()
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', `Error Deleting ${levelText}`)
    appStore.loading = false
  }
}
const checkIfMilestoneUsed = (milestoneId) => {
  let used = false
  commission.value.sources.forEach(s => {
    if (s.milestoneId === milestoneId) {
      used = true
    }
  })

  return used

}
const getSources = async () => {
  if (addSource.value) {
    try {
      const {data} = await getRequest(`/commissionManagement/${planId.value}/availableSources`, 'blueraven')
      sources.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Sources')
      appStore.loading = false
    }
  }
}
const updateSource = async (item) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/commissionManagement/${planId.value}/source`, item, 'blueraven')
    item.milestoneType = data.milestoneType
    item.feeType = data.feeType
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Milestone')
    appStore.loading = false
  }
}
const getUserHistory = async (userId) => {
  //reset the rest of the new user fields if they change users
  delete newUser.value.startDate
  delete newUser.value.endDate
  newUser.value.dateError = false
  newUser.value.dateErrorMsg = ''
  newUser.value.showNote = false
  newUser.value.noteMsg = ''
  errorLoadingUserHistory.value = false
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/commissionManagement/commissionUser/${userId}/history`, 'blueraven')
    userHistory.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    errorLoadingUserHistory.value = true
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving User History')
    appStore.loading = false
  }
}
const addSourceToPlan = async () => {
  try {
    let params = {
      sourceId: selectedSource.value.id,
      milestoneId: selectedSource.value.milestoneId,
      feeAmount: selectedSource.value.feeAmount,
      feeTypeId: selectedSource.value.feeTypeId,
    }
    const {data} = await postRequest(`/commissionManagement/${planId.value}/source`, params, 'blueraven')
    commission.value.sources.push(data)
    selectedSource.value = {}
    addSource.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Source')
    appStore.loading = false
  }
}
const deleteSource = async () => {
  const id = sourceToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/${planId.value}/source/${id}`, 'blueraven')
    snackbar('SUCCESS', 'Source Deleted')
    commission.value.sources = commission.value.sources.filter(s => {
      return s.id !== id
    })
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Source')
    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

