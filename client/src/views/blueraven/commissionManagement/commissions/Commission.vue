<template>
  <v-container class="pa-0" id="commission-container">
    <v-dialog :width="600" v-model="showProjectAssignmentModal">
      <ProjectAssignmentModal
        @cancel="showProjectAssignmentModal = false"
        :plan-id="parseInt(planId)"
        :plan-name="commission.name"
      />
    </v-dialog>
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="planId">{{ commission.name }}</span>
        <span v-else>New Commission Plan</span>
      </v-toolbar-title>
      <v-spacer />
      <v-toolbar-items>
        <div class="commission-button-container">
          <a-btn
            color="primary"
            class="mr-2"
            v-if="userIsAdmin && planId"
            @click="showProjectAssignmentModal = true"
            text="Admin"
          />
          <a-btn
            color="primary"
            class="mr-2"
            :disabled="!commission.name || !commission.positionId"
            v-if="userCanEdit || userCanAdd || userIsAdmin"
            @click="savePlan()"
            text="Save"
          />
          <a-btn
            color="success"
            class="mr-2"
            v-if="(userIsAdmin || userCanEdit || userCanAdd) && planId && commission.statusType === 'PENDING'"
            :disabled="errorMessages.length > 0"
            @click="approvePlan()"
          >
            Approve
          </a-btn>
          <ConfirmationDialog
            :open-dialog="showDeleteConfirm"
            @confirm="[deleteConfirm = true, deletePlan()]"
            @close-dialog="showDeleteConfirm=false"
          >
            Are you sure you want to delete this plan?
          </ConfirmationDialog>
          <a-btn
            v-if="planId && !commission.approved && (userCanDelete || userCanEdit || userIsAdmin)"
            @click="showDeleteConfirm = true"
            color="error"
            text="Delete"
          />
          <a-btn
            v-else-if="(planId && (userCanDelete || userCanEdit || userIsAdmin || userCanAdd) && commission.statusType !== 'INACTIVE')"
            @click="inactivateConfirm = true"
            color="error"
            class="mr-2"
            text="Inactivate"
          />
          <ConfirmationDialog
            :open-dialog="inactivateConfirm"
            :hide-confirm="planHasActiveUsers()"
            @confirm="inactivatePlan"
            @close-dialog="inactivateConfirm = false"
          >
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
          />
          <ConfirmationDialog
            :open-dialog="cloneDialog"
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
    <v-divider v-if="errorMessages.length > 0" />
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
    <v-divider />
    <v-form ref="commissionForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <a-text-field
                :readonly="!userCanEdit || commission.statusType === 'INACTIVE'"
                :disabled="!userCanEdit || commission.statusType === 'INACTIVE'"
                label="Name"
                v-model="commission.name"
              />
              <a-text-field
                :readonly="!userCanEdit || commission.statusType === 'INACTIVE'"
                :disabled="!userCanEdit || commission.statusType === 'INACTIVE'"
                label="Description"
                v-model="commission.description"
              />
              <a-text-field
                attach v-model="commissionPositionData.label"
                :readonly="true"
                :disabled="true"
                no-data-text="No Positions Available"
                label="Position"
                item-title="label"
                item-value="id"
              />
              <div v-if="commission.positionId">
                <a-text-field
                  :label="payRateText"
                  type="number"
                  :disabled="(commission.id &&
                    commission.statusType !== 'PENDING') ||
                    isDealerOrInstallerPlan ||
                    !userCanAdd"
                  :readonly="(commission.id &&
                    commission.statusType !== 'PENDING') ||
                    isDealerOrInstallerPlan ||
                    !userCanAdd"
                  v-model.number="commission.total"
                />
                <a-text-field
                  placeholder="0.00"
                  type="number"
                  label="Partner Commission Amount"
                  v-if="isDealerOrInstallerPlan"
                  :disabled="(commission.id && commission.statusType !== 'PENDING') || !userCanAdd"
                  :readonly="(commission.id && commission.statusType !== 'PENDING') || !userCanAdd"
                  v-model.number="commission.partnerAmount"
                />
                <a-select
                  attach v-model="commission.feeTypeId"
                  placeholder="Partner Fee Type"
                  v-if="isDealerOrInstallerPlan"
                  :disabled="(commission.id && commission.statusType !== 'PENDING') || !userCanAdd"
                  :readonly="(commission.id && commission.statusType !== 'PENDING') || !userCanAdd"
                  :items="feeTypes"
                  label="Fee Type"
                  item-title="label"
                  item-value="id"
                />
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="planId">
              <a-text-field
                label="Status"
                disabled
                v-model="commission.statusType"
              />
              <a-text-field
                disabled
                label="Created By"
                v-model="commission.createdName"
              />
              <a-text-field
                disabled
                label="Approved"
                v-if="commission.approvedDate"
                v-model="formattedApprovalDate"
              />
              <a-text-field
                disabled
                v-if="commission.approvedName"
                label="Approved By"
                v-model="commission.approvedName"
              />
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
          <v-spacer />
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              v-if="commission.statusType === 'PENDING' && (userCanAdd)"
              @click="[selectedMilestone = {}, addMilestone = !addMilestone, getMilestones()]"
              :prepend-icon="addMilestone ? 'remove' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <v-card v-if="addMilestone" class="square-card text-left pa-5">
          <a-select
            attach v-model="selectedMilestone.id"
            :items="milestones"
            :label="`Select a ${levelText}...`"
            item-title="milestoneType"
            item-value="id"
            autocomplete="off"
          />
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
          />
        </v-card>
        <v-divider v-if="addMilestone" />
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
                v-model.number="item.allocation"
              />
              <div v-if="commission.positionId === 4">
                <a-text-field
                  @input="checkMinMaxMilestones(item)"
                  type="number"
                  label="Minimum Pitches"
                  v-model.number="item.min"
                />
                <a-text-field
                  type="number"
                  @input="checkMinMaxMilestones(item)"
                  label="Maximum Pitches"
                  v-model.number="item.max"
                />
              </div>
              <div class="error-text mb-3" v-if="milestoneError">
                {{ milestoneErrorMsg }}
              </div>
              <a-btn
                :disabled="!item.allocation || (commission.positionId === 4 && !item.min) || milestoneError"
                @click="[milestoneExpanded = [], updateMilestone(item)]"
                color="primary"
                text="Save"
              />
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.milestoneType }}</td>
              <td class="text-left" v-if="commission.positionId === 4 && userCanEdit">{{ item.min }}</td>
              <td class="text-left" v-if="commission.positionId === 4 && userCanEdit ">{{ item.max }}</td>
              <td class="text-left">{{ item.allocation }}</td>
              <td>
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="milestoneExpanded = [item]"
                  v-if="commission.statusType === 'PENDING' && !milestoneExpanded.includes(item) && userCanEdit"
                  prepend-icon="edit"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="milestoneExpanded = []"
                  v-if="milestoneExpanded.includes(item) && userCanEdit"
                  text="Cancel"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="userCanDelete || userCanEdit"
                  @click="milestoneToDelete=item"
                  prepend-icon="delete"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="planId && [1,743,828].includes(commission.positionId)">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Source Deductions
          </v-toolbar-title>
          <v-spacer />
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              v-if="commission.statusType === 'PENDING' && userCanAdd"
              @click="[selectedSource = {}, addSource = !addSource, getSources()]"
              :prepend-icon="addSource ? 'remove' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <v-card v-if="addSource" class="square-card text-left pa-5">
          <div v-if="!commission.milestones || commission.milestones.length === 0">
            You must add milestones to this plan first.
          </div>
          <div v-else>
            <a-select
              attach v-model="selectedSource.id"
              :items="sources"
              label="Select a Source..."
              item-title="sourceName"
              item-value="id"
              autocomplete="off"
            />
            <a-text-field
              label="Fee Amount"
              v-model="selectedSource.feeAmount"
            />
            <a-select
              attach v-model="selectedSource.feeTypeId"
              :items="feeTypes"
              label="Fee Type"
              item-title="label"
              item-value="id"
            />
            <a-select
              attach v-model="selectedSource.milestoneId"
              :items="commission.milestones"
              label="Deduct at Milestone"
              item-title="milestoneType"
              item-value="milestoneId"
            />
            <a-btn
              color="primary"
              class="mr-3"
              @click="addSourceToPlan()"
              v-if="userCanAdd"
              :disabled="!selectedSource.id || !selectedSource.feeTypeId || !selectedSource.feeAmount"
              text="Add"
            />
          </div>
        </v-card>
        <v-divider v-if="addSource" />
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
                v-model="item.feeAmount"
              />
              <a-select
                attach v-model="item.feeTypeId"
                :items="feeTypes"
                label="Fee Type"
                item-title="label"
                item-value="id"
              />
              <a-select
                attach v-model="item.milestoneId"
                :items="commission.milestones"
                label="Deduct at Milestone"
                item-title="milestoneType"
                item-value="milestoneId"
              />
              <a-btn
                :disabled="!item.feeAmount || !item.feeTypeId || !item.milestoneId"
                @click="[sourceExpanded = [], updateSource(item)]"
                color="primary"
                text="Save"
              />
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
                  v-if="commission.statusType === 'PENDING' && !sourceExpanded.includes(item) && userCanEdit"
                  prepend-icon="edit"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="sourceExpanded = []"
                  v-if="sourceExpanded.includes(item)"
                  text="Cancel"
                />
                <a-btn
                  v-if="commission.statusType === 'PENDING' && userCanDelete"
                  size="small"
                  variant="text"
                  color="primary"
                  @click="sourceToDelete=item"
                  prepend-icon="delete"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="planId && isDealerOrInstallerPlan">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Adders
          </v-toolbar-title>
          <v-spacer />
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              v-if="commission.statusType === 'PENDING' && userCanAdd"
              @click="[selectedAdder = {}, addAdder = !addAdder, getAdders()]"
              :prepend-icon="addAdder ? 'remove' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-divider />
        <v-card v-if="addAdder" class="square-card text-left pa-5">
          <div v-if="!commission.milestones || commission.milestones.length === 0">
            You must add milestones to this plan first.
          </div>
          <div v-else>
            <a-select
              attach v-model="selectedAdder.id"
              :items="adders"
              label="Select a Adder..."
              item-title="adderName"
              item-value="id"
              autocomplete="off"
            />
            <a-text-field
              label="Fee Amount"
              v-model="selectedAdder.feeAmount"
            />
            <a-select
              attach v-model="selectedAdder.feeTypeId"
              :items="feeTypes"
              label="Fee Type"
              item-title="label"
              item-value="id"
            />
            <a-btn
              color="primary"
              class="mr-3"
              @click="addAdderToPlan()"
              v-if="userCanAdd"
              :disabled="!selectedAdder.id || !selectedAdder.feeTypeId || !selectedAdder.feeAmount"
              text="Add"
            />
          </div>
        </v-card>
        <v-divider v-if="addAdder" />
        <v-data-table
          :headers="adderHeaders"
          :items="commission.adders"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          single-expand
          :expanded.sync="adderExpanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available adders</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available adders</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <a-text-field
                label="Fee Amount"
                v-model="item.feeAmount"
              />
              <a-select
                attach v-model="item.feeTypeId"
                :items="feeTypes"
                label="Fee Type"
                item-title="label"
                item-value="id"
              />
              <a-btn
                :disabled="!item.feeAmount || !item.feeTypeId"
                @click="[adderExpanded = [], updateAdder(item)]"
                color="primary"
                text="Save"
              />
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.adderName }}</td>
              <td class="text-left">{{ item.feeAmount }}</td>
              <td class="text-left">{{ item.feeType }}</td>
              <td>
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="adderExpanded = [item]"
                  v-if="commission.statusType === 'PENDING' && !adderExpanded.includes(item) && userCanEdit"
                  prepend-icon="edit"
                />
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="adderExpanded = []"
                  v-if="adderExpanded.includes(item)"
                  text="Cancel"
                />
                <a-btn
                  v-if="commission.statusType === 'PENDING' && userCanDelete"
                  size="small"
                  variant="text"
                  color="primary"
                  @click="adderToDelete=item"
                  prepend-icon="delete"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <AssignedOrgs
      v-if="planId && isDealerOrInstallerPlan"
      :commission="commission"
      :data-loading="dataLoading"
      :plan-id="parseInt(planId)"
      :canAdd="userCanAdd"
      :canEdit="userCanEdit"
      :canDelete="userCanDelete"
      :isAdmin="userIsAdmin"
    />
    <AssignedUsers
      v-else-if="planId && (!isDealerOrInstallerPlan)"
      :commission="commission"
      :data-loading="dataLoading"
      :plan-id="parseInt(planId)"
      :canAdd="userCanAdd"
      :canEdit="userCanEdit"
      :canDelete="userCanDelete"
      :isAdmin="userIsAdmin"
    />
    <ConfirmationDialog
      :open-dialog="!!sourceToDelete"
      @confirm="deleteSource"
      @close-dialog="sourceToDelete=null"
    >
      Are you sure you want to delete this source: <strong>{{ sourceToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog
      :open-dialog="!!adderToDelete"
      @confirm="deleteAdder"
      @close-dialog="adderToDelete=null"
    >
      Are you sure you want to delete this adder: <strong>{{ adderToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog
      :open-dialog="!!milestoneToDelete"
      :hide-confirm="milestoneToDeleteIsUsed"
      @confirm="deleteMilestone"
      @close-dialog="milestoneToDelete=null"
    >
      <template v-slot:title v-if="milestoneToDeleteIsUsed">Error</template>
      <div v-if="milestoneToDeleteIsUsed">Cannot delete milestones that are in use by sources.</div>
      <div v-else-if="commission.positionId === 1">
        Are you sure you want to delete this milestone: <strong>{{ milestoneToDeleteType }}</strong>?
      </div>
      <div v-else>
        Are you sure you want to delete this tier:
        <strong>
          {{ milestoneToDeleteType }}: {{ milestoneToDeleteMin }} - {{ milestoneToDeleteMax }}
        </strong>?
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
    postRequest,
  } from '@/helpers/helpers.js';
  import ProjectAssignmentModal from "@/views/blueraven/commissionManagement/ProjectAssignmentModal.vue";
  import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
  import { useBrsStore } from '@/stores/BrsStore.js'
  import {getCurrentInstance, computed, ref, onMounted, watch} from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useAppStore} from '@/stores/AppStore.js'
  import {useRoute, useRouter} from "vue-router/composables"
  import { storeToRefs } from 'pinia'
  import AssignedUsers from "@/views/blueraven/commissionManagement/commissions/AssignedUsers.vue";
  import AssignedOrgs from "@/views/blueraven/commissionManagement/commissions/AssignedOrgs.vue";

  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const appStore = useAppStore()
  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const showProjectAssignmentModal = ref(false)
  const cloneDialog = ref(false)
  const payRateText = ref(commissionPositionId.value === 4 ? 'Base Pay' : 'Milestone Payment Sum')
  const levelText = ref(commissionPositionId.value === 4 ? 'Tier' : 'Milestone')
  const cloneStartDate = ref(null)
  const dataLoading = ref(true)
  const inactivateConfirm = ref(false)
  const deleteConfirm = ref(false)
  const milestoneExpanded = ref([])
  const sourceExpanded = ref([])
  const milestoneError = ref(false)
  const milestoneErrorMsg = ref('')
  const addMilestone = ref(false)
  const selectedMilestone = ref({})
  const milestones = ref([])
  const addSource = ref(false)
  const selectedSource = ref({})
  const sources = ref([])

  const addAdder = ref(false)
  const selectedAdder = ref({})
  const adders = ref([])
  const adderExpanded = ref([])
  const adderToDelete = ref(null)
  const errorMessages = ref([])
  const cloneDateError = ref(false)
  const showDeleteConfirm = ref(false)
  const milestoneToDelete = ref(null)
  const sourceToDelete = ref(null)
  const userToDelete = ref(null)

  const positions = ref([
    {
      id: 1,
      label: 'Closer',
      code: 'COMMISSIONS_CLOSER',
      path: '/commissionManagement/users'
    },
    {
      id: 4,
      label: 'Setter',
      code: 'COMMISSIONS_SETTER',
      path: '/commissionManagement/users'
    },
    {
      id: 743,
      label: 'Dealer',
      code: 'COMMISSIONS_DEALER',
      path: '/commissionManagement/commissions'
    },
    {
      id: 828,
      label: 'Installation Partner',
      code: 'COMMISSIONS_INSTALLATION_PARTNER',
      path: '/commissionManagement/commissions'
    },
  ])
  const feeTypes = ref([
    {id: 1, label: 'Per kW'},
    {id: 2, label: 'Flat'},
    {id: 3, label: 'Percent of Total'},
    {id: 4, label: 'Per Panel'},
  ])
  const sourceHeaders = ref([
    {text: 'Source', value: 'source', show: true},
    {text: 'Fee Amount', value: 'feeAmount', show: true},
    {text: 'Fee Type', value: 'feeType', show: true},
    {text: 'Deduct at Milestone', value: 'deductAtMilestone', show: true},
    {text: '', value: 'icons', show: true},
  ])

  const adderHeaders = ref([
    {text: 'Adder', value: 'adder', show: true},
    {text: 'Fee Amount', value: 'feeAmount', show: true},
    {text: 'Fee Type', value: 'feeType', show: true},
    {text: '', value: 'icons', show: true},
  ])
  const milestoneHeaders = ref([
    {text: commissionPositionId.value === 4 ? 'Tier' : 'Milestone', value: 'milestoneType', show: true},
    {text: 'Minimum Pitches', value: 'min', positionId: 4},
    {text: 'Maximum Pitches', value: 'max', positionId: 4},
    {
      text: commissionPositionId.value === 4 ? 'Tier Payment' : 'Milestone Payment',
      value: 'allocation',
      show: true
    },
    {text: '', value: 'icons', show: true},
  ])
  const isDealerOrInstallerPlan = computed(() => {
    return [743,828].includes(commissionPositionId.value)
  })
  const commission = ref({
    users: [],
    positionId: commissionPositionId || null,
    total: isDealerOrInstallerPlan.value ? 1 : null
  })

  const planId = computed(() => {
    return route.params.id
  })

  const activeUsers = computed(() => {
    return commission.value?.users?.filter(u => {
      return u.endDate === null || u.endDate > new Date()
    })
  })

  const userCanView = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'VIEW') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
  })
  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADD') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'EDIT') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'EDIT') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
  })
  const userCanDelete = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'DELETE') ||
      userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
  })
  const userIsAdmin = computed(() => {
    return userStore.userHasFeatureAccessLevel(commissionPositionData.value.code, 'ADMIN')
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
  const adderToDeleteName = computed(() => {
    return adderToDelete.value ? adderToDelete.value.adderName : ''
  })
  const formattedApprovalDate = computed(() => {
    if (!commission.value.approvedDate) return '';
    return moment(commission.value.approvedDate).format('MMMM DD, YYYY h:mm A');
  });
  const commissionPositionData = computed(() => {
    // Evaluate the position that the commission returns, not the one the user sets
    return positions.value.find(pos => pos.id === commission.value.positionId);
  });


  watch(planId, () => {
    getCommissionDetails()
  })

  watch(commissionPositionId, async() => {
    // Watching changes to the commissionPositionId and redirecting accordingly
    await router.push({path: commissionPositionData.value.path })
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
      if (data.positionId !== commissionPositionId.value) {
        await router.push({path: commissionPositionData.value.path })
      } else {
        commission.value = data
      }

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
      appStore.showSnack('ERROR', 'Error Loading Commission Details')
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

  const checkErrorMessages = () => {
    errorMessages.value = []
    if (commission.value.total === 0) {
      errorMessages.value.push('`Milestone Payment Sum` cannot be zero.')
    }
    //sum of m1 and m2 payment = milestone payment sum
    if ([1,743,828].includes(commission.value?.positionId)) {
      let sum = commission.value?.milestones?.reduce((a, b) => a + b.allocation, 0)
      if (sum !== commission.value.total) {
        errorMessages.value.push(`The sum of all milestone payment amounts must equal the '${payRateText.value}'. `)
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
        total: commission.value.total,
        partnerAmount: commission.value.partnerAmount,
        feeTypeId: commission.value.feeTypeId
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
      appStore.showSnack('ERROR', 'Error Saving Commission Plan')
      appStore.loading = false
    }
  }
  const approvePlan = async () => {
    appStore.loading = true
    try {
      const {data, status} = await postRequest(`/commissionManagement/${planId.value}/approve`, {}, 'blueraven')
      appStore.showSnack('SUCCESS', 'Commission Plan Approved')
      commission.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Approving Commission Plan')
      appStore.loading = false
    }
  }
  const inactivatePlan = async () => {
    appStore.loading = true
    try {
      await postRequest(`/commissionManagement/${planId.value}/inactivate`, {}, 'blueraven')
      appStore.showSnack('SUCCESS', 'Commission Plan Inactivated')
      await router.push({name: 'commissions'})
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Inactivating Commission Plan')
      appStore.loading = false
    }
  }
  const deletePlan = async () => {
    appStore.loading = true
    try {
      await deleteRequest(`/commissionManagement/${planId.value}`, 'blueraven')
      appStore.showSnack('SUCCESS', 'Commission Plan Deleted')
      await router.push({name: 'commissions'})
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Commission Plan')
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
      appStore.showSnack('ERROR', 'Error Cloning Commission')
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
        appStore.showSnack('ERROR', 'Error Retrieving Milestones')
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
      appStore.showSnack('ERROR', 'Error Saving Milestone')
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
      appStore.showSnack('ERROR', 'Error Adding Milestone')
      appStore.loading = false
    }
  }
  const deleteMilestone = async () => {
    const commissionPlanAllocationId = milestoneToDelete.value.commissionPlanAllocationId
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/commissionManagement/${planId.value}/milestone/${commissionPlanAllocationId}`, 'blueraven')
      appStore.showSnack('SUCCESS', `${levelText} Deleted`)
      commission.value.milestones = commission.value.milestones.filter(m => {
        return m.commissionPlanAllocationId !== commissionPlanAllocationId
      })
      checkErrorMessages()
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', `Error Deleting ${levelText}`)
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
        appStore.showSnack('ERROR', 'Error Retrieving Sources')
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
      appStore.showSnack('ERROR', 'Error Saving Milestone')
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
      appStore.showSnack('ERROR', 'Error Adding Source')
      appStore.loading = false
    }
  }
  const deleteSource = async () => {
    const id = sourceToDelete.value.id
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/commissionManagement/${planId.value}/source/${id}`, 'blueraven')
      appStore.showSnack('SUCCESS', 'Source Deleted')
      commission.value.sources = commission.value.sources.filter(s => {
        return s.id !== id
      })
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Source')
      appStore.loading = false
    }
  }

  // ADDERS
  const getAdders = async () => {
    if (addAdder.value) {
      try {
        const {data} = await getRequest(`/commissionManagement/${planId.value}/availableAdders`, 'blueraven')
        adders.value = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Adders')
        appStore.loading = false
      }
    }
  }
  const updateAdder = async (item) => {
    appStore.loading = true
    try {
      const {data, status} = await putRequest(`/commissionManagement/${planId.value}/adder`, item, 'blueraven')
      item.feeType = data.feeType
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Milestone')
      appStore.loading = false
    }
  }

  const addAdderToPlan = async () => {
    try {
      let params = {
        adderId: selectedAdder.value.id,
        feeAmount: selectedAdder.value.feeAmount,
        feeTypeId: selectedAdder.value.feeTypeId,
      }
      const {data} = await postRequest(`/commissionManagement/${planId.value}/adder`, params, 'blueraven')
      commission.value.adders.push(data)
      selectedAdder.value = {}
      addAdder.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Adder')
      appStore.loading = false
    }
  }
  const deleteAdder = async () => {
    const id = adderToDelete.value.id
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/commissionManagement/${planId.value}/adder/${id}`, 'blueraven')
      appStore.showSnack('SUCCESS', 'Adder Deleted')
      commission.value.adders = commission.value.adders.filter(s => {
        return s.id !== id
      })
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Adder')
      appStore.loading = false
    }
  }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
