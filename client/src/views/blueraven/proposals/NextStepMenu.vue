<template>
  <div>
    <v-menu
      v-model="menu"
      transition="slide-x-transition"
      :close-on-content-click="false"
      :offset-y="true"
      :z-index="250"
      :max-width="375"
    >
      <template #activator="{ on, attrs }">
        <!--        TODO: kill overflow so you can't scroll while this is open -->
        <a-btn
          :activation-handler="on"
          v-bind="attrs"
          :dark="!disabled"
          :disabled="disabled"
          color="primary"
          class="text-capitalize"
          text="Next Steps"
        ></a-btn>
      </template>

      <v-card class="pa-2">
        <v-alert color="red" type="error" v-if="requiredFields.length > 0">
          This proposal is not valid. Please set the required configurations to
          proceed with next steps.
          <ul>
            <li v-for="field in requiredFields">
              {{ field }}
            </li>
          </ul>
        </v-alert>
        <v-list>
          <v-list-item three-line>
            <v-list-item-content>
              <v-list-item-title>Lock to Proceed</v-list-item-title>
              <span class="desc">
                Proposal needs to be locked before sending documents. Further
                edits to the proposal will not be possible after this
              </span>

              <a-btn
                class="text-capitalize mt-1"
                :color="
                  requiredFields.length === 0 && !proposal.locked
                    ? 'primary'
                    : ''
                "
                :disabled="
                  requiredFields.length > 0 ||
                  proposal.locked ||
                  lockingProposal
                "
                @click=";[(lockingProposal = true), lockProposal()]"
                :prepend-icon="proposal.locked ? 'mdi-lock' : 'mdi-lock-open'"
                :text="proposal.locked ? 'Proposal Locked' : 'Lock Proposal'"
              ></a-btn>
            </v-list-item-content>
          </v-list-item>

          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Check Credit</v-list-item-title>
              <stateful-btn
                class="text-capitalize mt-1"
                :successful="proposal.creditCheckSubmitted"
                :disabled="!(proposal.locked && isCreditCheckRequired)"
                @click="submitCreditCheck"
              >
                Check Credit
              </stateful-btn>
            </v-list-item-content>
          </v-list-item>

          <v-list-item>
            <v-list-item-content>
              <v-list-item-title>Send Documents</v-list-item-title>

              <v-form
                ref="docForm"
                :disabled="!proposal.locked"
                v-model="valid"
              >
                <a-text-field
                  label="Email"
                  v-model="docs.email"
                  :rules="rules"
                  required
                  readonly
                  disabled
                />

                <v-radio-group
                  v-model="docs.language"
                  required
                  column
                  :rules="rules"
                >
                  <v-radio label="English" value="english" />
                  <v-radio label="Spanish" value="spanish" />
                </v-radio-group>

                <a-text-field
                  label="Proposal #"
                  :value="proposal.proposalNbr"
                  :rules="rules"
                  required
                  readonly
                  disabled
                />
              </v-form>

              <stateful-btn
                class="text-capitalize"
                :successful="proposal.financeDocsSent"
                :disabled="!(proposal.locked && valid && isCreditCheckRequired)"
                @click="sendDocs('FINANCE_DOCS')"
              >
                Send Finance Documents
              </stateful-btn>

              <stateful-btn
                class="text-capitalize mt-2"
                :successful="proposal.installationAgreementSent"
                :disabled="!(proposal.locked && valid)"
                @click="sendDocs('INSTALLATION_AGREEMENT')"
              >
                Send Installation Agreement
              </stateful-btn>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-card>
    </v-menu>

    <confirm-dialog ref="confirmEmail">
      <template #title>Confirm Email</template>
      <v-container>
        <p>
          Is <strong>{{ proposal.email }}</strong> the correct email address?
        </p>
        <v-radio-group v-model="confirmEmail.isCorrectEmail">
          <v-radio
            label="Yes"
            :value="true"
            @click="confirmEmail.emailAddress = ''"
          />
          <v-radio label="No" :value="false" />
        </v-radio-group>

        <a-text-field
          v-if="
            confirmEmail.isCorrectEmail !== undefined &&
            confirmEmail.isCorrectEmail === false
          "
          v-model="confirmEmail.emailAddress"
          placeholder="Enter correct email address"
          :disabled="confirmEmail.isCorrectEmail"
        />
      </v-container>

      <template #actions="{ ok, cancel }">
        <a-btn
          variant="text"
          @click="cancel(false)"
          class="text-capitalize"
          color="unset"
          text="Cancel"
        ></a-btn>
        <v-spacer />

        <a-btn
          color="primary"
          @click="
            ok({
              email: confirmEmail.emailAddress || proposal.email,
              updated: !confirmEmail.isCorrectEmail
            })
          "
          class="text-capitalize"
          :disabled="!isEmailValid"
          :dark="isEmailValid"
          text="Check Credit"
        ></a-btn>
      </template>
    </confirm-dialog>
  </div>
</template>
<script setup>
import StatefulBtn from '@/views/blueraven/proposals/StatefulBtn'
import ConfirmDialog from '@/views/blueraven/proposals/ConfirmDialog'
import {
  getRequest,
  logError,
  postRequest,
  putRequest
} from '@/helpers/helpers'

import { getCurrentInstance, toRefs, computed, ref } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const emit = defineEmits(['update'])

const DOCS_MESSAGE = {
  FINANCE_DOCS: {
    key: 'financeDocsSent',
    message: 'Finance docs request submitted'
  },
  INSTALLATION_AGREEMENT: {
    key: 'installationAgreementSent',
    message: 'Installation agreement request submitted'
  }
}

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },
  proposal: {
    type: Object,
    required: true
  }
})
const { disabled, proposal } = toRefs(props)

const valid = ref(false)
const confirmEmail = ref({ emailAddress: '', isCorrectEmail: undefined })
const docs = ref({ email: proposal.value.email, language: undefined })
const menu = ref(false)
const rules = ref([(v) => !!v || 'Value is required'])
const lockingProposal = ref(false)
const confirmEmailRef = ref(null)

const isCreditCheckRequired = computed(() => {
  // find financial field custom group
  const cfv = proposal.value.customFieldGroups
    .find((x) => x.id === 27)
    ?.customFieldValues?.find((x) => x.customFieldId === 128)
  // find custom field value for "Financial Product"
  const financialProduct = cfv.listOfValues?.find((x) => x.id === cfv.intValue)
  // does the name have "cash" (probably need a better way of handling this at some point)
  return financialProduct?.name?.toLowerCase().indexOf('cash') < 0
})
const isEmailValid = computed(() => {
  if (confirmEmail.value?.isCorrectEmail) {
    return true
  }
  return (
    confirmEmail.value?.emailAddress?.trim().length > 0 &&
    /.+@.+[.].+/.test(confirmEmail.value.emailAddress)
  )
})
const requiredFields = computed(() => {
  return proposal.value?.customFieldGroups
    ?.flatMap((cfg) => {
      return cfg.customFieldValues
    })
    ?.filter((field) => {
      return userHasWhiteListedPosition(field, 'hidden')
    })
    ?.filter((field) => {
      return field.required
    })
    ?.filter((field) => {
      switch (field.dataTypeId) {
        case 1:
          return field.dateValue == null
        case 2:
          return field.timestampValue == null
        case 3:
          return field.booleanValue == null
        case 4:
          return field.numericValue == null
        case 5:
        case 12:
          return field.textValue == null
        case 6:
        case 8:
        case 9:
          return field.intValue == null
        case 7:
        case 10:
          return field.intArrayValue == null || field.intArrayValue.length === 0
        case 13:
          return field.richTextValue == null
      }
    })
    .map((field) => field.fieldName)
})

const userHasWhiteListedPosition = (cf, arg = 'readonly') => {
  const wlAttr =
    arg === 'readonly' ? 'whiteListedPositions' : 'hiddenWhiteListedPositions'
  const prAttr =
    arg === 'readonly'
      ? 'customFieldGroupAssignmentReadOnly'
      : 'customFieldGroupAssignmentHidden'

  //field doesn't require a white listed position
  if (!cf[prAttr]) {
    return true
  }

  //positions required for user
  const positions = cf[wlAttr]?.map((wlp) => wlp.positionId) ?? []
  return userStore.userHasAnyPosition(positions)
}

const submitCreditCheck = async () => {
  if (!proposal.value.creditCheckSubmitted) {
    //only do this if it wasn't already done on the first submit
    menu.value = false
    const { ok, value } = await confirmEmailRef.value.open()
    if (!ok) {
      return
    }
    if (value.email?.trim().length > 0 && value.updated) {
      const body = { email: value.email }
      try {
        await putRequest(
          `/install-agreement/updateEmailAddress/${proposal.value.projectId}`,
          body,
          'blueraven'
        )
      } catch (e) {
        snackbar('ERROR', 'Error updating email')
        return
      }
    }
  }

  try {
    const { status, data } = await getRequest(
      `/proposal/${proposal.value.id}/loanApplication`,
      'blueraven'
    )
    if (status !== 200) {
      snackbar('ERROR', data?.message || 'Error creating credit application')
      return
    }

    emit('update', { ...proposal.value, creditCheckSubmitted: true })

    if (data && data !== 'Quote Updated') {
      open(data, '_blank')
    }
  } catch (e) {
    snackbar('ERROR', e?.data.message || 'Error creating credit application')
  }
}

const lockProposal = async () => {
  if (proposal.value.locked || requiredFields.value.length > 0) {
    return
  }

  try {
    appStore.loading = true
    const { data } = await postRequest(
      `/proposal/${proposal.value.id}/lock`,
      {},
      'blueraven'
    )
    snackbar('SUCCESS', 'Proposal locked')
    emit('update', data)
  } catch (e) {
    snackbar('ERROR', e?.data?.message)
    logError(e)
  } finally {
    appStore.loading = false
  }
}

const sendDocs = async (docType) => {
  if (!(proposal.value.locked && valid.value)) {
    return
  }

  try {
    appStore.loading = true
    const { data = {} } = await postRequest(
      `/proposal/${proposal.value.id}/sendDocs`,
      {
        docType,
        isSpanish: docs.value.language === 'spanish'
      },
      'blueraven'
    )

    const { success, message } = data
    if (success) {
      const msg = DOCS_MESSAGE[docType]
      snackbar('SUCCESS', msg.message)
      emit('update', { ...proposal.value, [msg.key]: true })
    } else {
      snackbar('ERROR', message)
    }
  } catch (e) {
    logError(e)
    snackbar('ERROR', e?.data?.message)
  } finally {
    appStore.loading = false
  }
}
</script>
<style scoped lang="scss">
.desc {
  font-size: 0.875rem;
  line-height: 1.2;
  color: rgba(0, 0, 0, 0.6);
}
</style>
